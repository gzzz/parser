# Класс буфера — объекта, имплементирующего интерфейс хеша, но позволяющего производить присваивания ключей произвольной вложенности.
# Если передан указатель на callback-метод — он будет вызван при модификации данных буфера.


@CLASS
buffer


@OPTIONS
locals


@create[data;callback;params;fulldata]
$self.__data[^fe[$data]{^hash::create[]}]
$self.__callback[$callback]
$self.__params[$params]
$self.__fulldata[^fe[$fulldata;$self.__data]]


@sql[query;callback;params]
$data[^hash::sql{$query}]

^self.create[$data;$callback;$params;$data]


@GET_DEFAULT[name]
# На запрос к любому несуществующему полю-хешу возвращает экземпляр буфера.
# Другие типы данных возвращает как есть.

$data[^self._get[$self.__data;$name]]

^if($data is hash){
	$result[^self._create[$data;$self.__callback;$self.__params;$self.__fulldata]]
}{
	$result[$data]
}


@SET_DEFAULT[name;value]
$self.__data.$name[$value]

^self._callback[]


@_get[target;key]
# Возвращает ключ из $self.__data по указанному имени.
# Если ключа не существует — создаёт его.

^if(!^target.contains[$key]){
	$target.$key[^hash::create[]]
}

$result[$target.$key]


@_create[data;callback;params;fulldata]
# Создаёт новый буфер, передавая в качестве данных указатель на добавленный в $seld.data ключ.
# Таким образом, каждый экземпляр буфера работает со своей частью общего хеша данных.

$result[^reflection:create[$self.CLASS_NAME;create;$data;$callback;$params;$fulldata]]


@GET[context]
^switch[$context]{
	^case[def;expression;bool;double]{
		$result($self.__data)
	}
	^case[hash]{
		$result[^hash::create[$self.__data]]
	}
	^case[table]{
		$result[^self.keys[]]
	}
	^case[file]{
		$result[^file::create[text;^json:string[$self.__data]]]
	}
}


@_callback[]
# Вызывает callback-метод, если таковой передан буферу при создании.
# В качестве аргументов передаёт методу копию общего хеша данных и параметры, если таковые указаны при создании буфера.

^if($self.__callback is junction){
	^if($self.__params){
		^self.__callback[^hash::create[$self.__fulldata];$self.__params]
	}{
		^self.__callback[^hash::create[$self.__fulldata]]
	}
}


# Hash interface.

@_at[position;mode]
$mode[^fd[$mode;value]]

$result[^self.__data._at[$position;$mode]]


@_count[]
$result(^self.__data._count[])


@_keys[name]
^if(def $name){
	$result[^self.__data._keys[$name]]
}{
	$result[^self.__data._keys[]]
}


@add[data]
^data.foreach[key;value]{
	$slot[$self.__data.$key]

	^if($slot is hash){
		^slot.add[$value]
	}{
		$self.__data.$key[$value]
	}
}

^self._callback[]


@at[position;mode]
$result[^self._at[$position;$mode]]


@contain[key]
$result(^self.contains[$key])


@contains[key]
$result(^self.__data.contains[$key])


@count[]
$result(^self._count[])


@delete[item]
# Можно передать не только ключ удаляемого элемента, но и хеш с ключами.

^self.sub[$item]


@foreach[key;value;code;separator]
# В caller'е дополнительно доступна переменная $position, указывающая (с единицы) на текущую позицию перебора.

$position(1)

$result[^self.__data.foreach[k;v]{
	$caller.$key[$k]
	$caller.$value[$v]
	$caller.position($position)

	$code

	^position.inc[]
}{$separator}]


@intersection[data]
$result[^self.__data.intersection[$data]]


@intersects[data]
$result(^self.__data.intersects[$data])


@keys[column]
$result[^self._keys[$column]]


@sort[key;value;sort;order]
^if($sort is double){
	^self.__data.sort[k;v](^self._double{
		$caller.$key[$k]
		$caller.$value[$v]

		$sort
	})[$order]
}{
	^self.__data.sort[k;v]{
		$caller.$key[$k]
		$caller.$value[$v]

		$sort
	}[$order]
}

^self._callback[]


@_double[code]
$result($code)


@sub[data]
^switch[$data.CLASS_NAME]{
	^case[string;int;double]{
		^self.__data.delete[$data]
	}
	^case[DEFAULT]{
		^self.__data.sub[^hash::create[$data]]
	}
}

^self._callback[]


@union[data]
$result[^self.__data.union[$data]]


# Custom interface.

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

^self.__data.add[^data.intersection[$self.__data]]

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

^self.__data.add[^self.union[$data]]

^self._callback[]


@join[data]
$result[^self.union[$data]]


@put[data]
^if($data is hash){
	^data.foreach[;value]{
		^self._put[$value]
	}
}{
	^self._put[$data]
}

^self._callback[]


@_put[value]
$key($self.__data + 1)

^while(^self.__data.contains[$key]){
	^key.inc[]
}

$self.__data.$key[$value]



# Экспериментальный класс, позволяющий установить значения по ключу, трактуя точки в его имени как разделители уровней.
# Точки в именах ключей хеша, переданного при создании или ключей в операциях слияния, вычитая и пересечения особым образом не трактуются.

@CLASS
lbuffer


@OPTIONS
locals


@BASE
buffer


@GET_DEFAULT[name]
$slot[$self.__data]

$keys[^name.split[.]]

^keys.menu{
	$key[$keys.piece]

	$slot[^self._get[$slot;$key]]
}

^if($slot is hash){
	$result[^self._create[$slot;$self.__callback;$self.__params;$self.__fulldata]]
}{
	$result[$slot]
}


@SET_DEFAULT[name;value]
$slot[$self.__data]

$keys[^name.split[.]]

^keys.menu{
	$key[$keys.piece]

	^if(^keys.line[] < $keys){
		$slot[^self._get[$slot;$key]]
	}{
		$slot.$key[$value]
	}
}

^self._callback[]