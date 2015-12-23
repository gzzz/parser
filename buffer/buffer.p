# Класс буфера — объекта, имплементирующего интерфейс хеша, но позволяющего производить присваивания ключей произвольной вложенности.
# Если передан указатель на callback-метод — он будет вызван при модификации данных буфера.


@CLASS
buffer


@OPTIONS
locals


@create[data;callback;params]
$self.data[^hash::create[$data]]
$self.callback[$callback]
$self.params[$params]

^self._reset[]


@sql[query;callback;params]
^self.create[^hash::sql{$query};$callback;$params]


@GET_DEFAULT[name]
^if(!($self.slot is hash)){
	^throw[buffer.set;Cannot set value into ${self.slot.CLASS_NAME}.]
}

^if(!^self.slot.contains[$name]){
	$self.slot.$name[^hash::create[]]
}
$self.slot[$self.slot.$name]

$result[$self]


@SET_DEFAULT[name;value]
$self.slot.$name[$value]

^self._reset[]
^self._callback[]


@GET[context]
^switch[$context]{
	^case[def;expression;bool;double]{
		$result($self.slot)
	}
	^case[hash]{
		$result[^hash::create[$self.slot]]
	}
	^case[table]{
		$result[^self.keys[]]
	}
	^case[file]{
		$result[^file::create[text;^json:string[$self.slot]]]
	}
}

^self._reset[]


@_reset[]
$self.slot[$self.data]


@_callback[]
^if($self.callback is junction){
	^if($self.params){
		^self.callback[$self.data;$self.params]
	}{
		^self.callback[$self.data]
	}
}


@redefine[data]
# Перекрывает значения существующих ключей.
# Несуществующие ключи не добавляются.
#
# $self[
# 	$.a[origin]
# ]
# $data[
# 	$.a[redefined]
# 	$.b[redefined]
# ]
#
# ^self.redefine[$data]
#
# $self[
# 	$.a[redefined]
# ]

$data[^hash::create[$data]]

^self.slot.add[^data.intersection[$self.slot]]

^self._reset[]
^self._callback[]


@append[data]
# Добавляет значения несуществующих ключей.
# Существующие ключи не затрагиваются.
#
# $self[
# 	$.a[origin]
# ]
# $data[
# 	$.a[appended]
# 	$.b[appended]
# ]
#
# ^self.append[$data]
#
# $self[
# 	$.a[origin]
# 	$.b[appended]
# ]

$data[^hash::create[$data]]

^self.slot.add[^self.slot.union[$data]]

^self._reset[]
^self._callback[]


@join[data]
$result[^self.union[$data]]


# Hash interface.

@_at[position;mode]
$mode[^fd[$mode;value]]

$result[^self.slot._at[$position;$mode]]

^self._reset[]


@_count[]
$result(^self.slot._count[])

^self._reset[]


@_keys[name]
^if(def $name){
	$result[^self.slot._keys[$name]]
}{
	$result[^self.slot._keys[]]
}

^self._reset[]


@add[data]
^if(!($self.slot is hash)){
	^throw[buffer.add;Cannot add value into ${self.slot.CLASS_NAME}.]
}

^data.foreach[key;value]{
	$slot[$self.slot.$key]

	^if($slot is hash){
		^slot.add[$value]
	}{
		$self.slot.$key[$value]
	}
}

^self._reset[]
^self._callback[]


@at[position;mode]
$result[^self._at[$position;$mode]]


@contain[key]
$result(^self.contains[$key])


@contains[key]
$result(^self.slot.contains[$key])

^self._reset[]


@count[]
$result(^self._count[])


@delete[item]
# Можно передать не только ключ удаляемого элемента, но и хеш с ключами.

^switch[$item.CLASS_NAME]{
	^case[hash]{
		^self.slot.sub[$item]
	}
	^case[DEFAULT]{
		^self.slot.delete[$item]
	}
}

^self._reset[]
^self._callback[]


@foreach[key;value;code;separator]
# В caller'е дополнительно доступна переменная $position, указывающая (с единицы) на текущую позицию перебора.

$position(1)

$result[^self.slot.foreach[k;v]{
	$caller.$key[$k]
	$caller.$value[$v]
	$caller.position($position)

	$code

	^position.inc[]
}{$separator}]

^self._reset[]


@intersection[data]
$result[^self.slot.intersection[$data]]

^self._reset[]


@intersects[data]
$result(^self.slot.intersects[$data])

^self._reset[]


@keys[column]
$result[^self._keys[$column]]


@sort[key;value;sort;order]
^if($sort is double){
	^self.slot.sort[k;v](^self._double{
		$caller.$key[$k]
		$caller.$value[$v]

		$sort
	})[$order]
}{
	^self.slot.sort[k;v]{
		$caller.$key[$k]
		$caller.$value[$v]

		$sort
	}[$order]
}

^self._reset[]


@_double[code]
$result($code)


@sub[data]
^self.slot.sub[$data]

^self._reset[]
^self._callback[]


@union[data]
$result[^self.slot.union[$data]]

^self._reset[]
^self._callback[]