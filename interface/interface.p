@CLASS
interface


@OPTIONS
locals
static


@auto[]
$self._field[IMPLEMENTS]


@declare[class]
# $class  string
#
# $result void / interface.implementation exception

# Декларатор поддержки интерфейса указанного класса.
# Если класс поддерживает интерфейс, метод добавляет указание на поддержку в поле IMPLEMENTS.

$caller_interface[^self.interface[$caller.self.CLASS_NAME]]
$target_interface[^self.interface[$class]]

^self.implemented[$caller_interface;$target_interface]
^self.set[$caller.self;$class]


@implements[object;class;method]
# $object   object
# $class    string
# [$method] string
#
# $result   bool

^if(def $method){
	$result(^self.has[$object;$method;$class])
}{
	^if($object.[$self._field]){
#		Если у объекта в поле IMPLEMENTS указана поддержка интерфейса — верим на слово.

		$result(^object.[$self._field].contains[$class])
	}{
#		Иначе проверяем, сверяя «сигнатуры» методов.

		$object_interface[^self.interface[$object.CLASS_NAME]]
		$target_interface[^self.interface[$class]]

		^try{
			^self.implemented[$object_interface;$target_interface;$method]

			$result(true)
		}{
			$exception.handled($exception.type eq 'interface.implementation')

			$result(false)
		}
	}
}


@has[object;method;class]
# $object  object
# $method  string
# [$class] string
#
# $result  bool

# Проверяет наличие у объекта указанного метода.
# Если передано имя класса, то проверяется «сигнатура» метода.

$hasjunction(^self.is[$method;junction;$object])
$hasmethod(^reflection:method[$object;$method] is junction)

$result($hasjunction || $hasmethod)

^if($hasmethod && def $class){
	$object[^self.info[$object.CLASS_NAME;$method]]
	$target[^self.info[$class;$method]]

	$result(^self.match[$object;$target])
}


@is[object;type;context]
# $object    string
# $type      string
# [$context] junction
#
# $result  bool

# Проверяет имеет ли указанный по имени объект заданный тип.

^if($context is void){
	$context[$caller.self]
}

$result(false)

^try{
	$result(
		^reflection:method[$context;$object] is $type
		|| (
			^reflection:is[$object;$type;$context]
			&& $context.$object is $type
		)
	)
}{
	$exception.handled(
		$exception.type eq 'parser.runtime'
		&& (
# 			ошибка при проверке string
			^exception.comment.pos[element can not be fetched from string] > -1
			|| ^exception.comment.pos[it has no elements] > -1
# 			ошибка при проверке таблицы
			|| ^exception.comment.pos[column not found] > -1
# 			ошибка при проверке regex и console
			|| ^exception.comment.pos[reading of invalid field] > -1
		)
	)
}


@interface[class;full]
# $class  string
#
# $result hash

# Возвращает интерфейс методов указанного класса.
# Геттеры и сеттеры игнорирует, если не передан аргумент $full.

$result[^hash::create[]]

$methods[^reflection:methods[$class]]
^methods.foreach[method;]{
	$prefix[^method.left(3)]

	^if(^full.bool(false) || ($prefix ne 'GET' && $prefix ne 'SET')){
		$result.$method[^self.info[$class;$method]]
	}
}


@fields[class]
# $class  object / class
#
# $result hash

# Возвращает информацию о полях объекта.

$result[^reflection:fields[$class]]


@info[class;method]
# $class  string
# $method string
#
# $result hash

# Возвращает информацию о методе.

$result[^reflection:method_info[$class;$method]]


@implemented[object;target;method]
# $object   hash
# $target   hash
# [$method] string
#
# $result   void / interface.implemented exception

# Проверяет поддержку объектом интерфейса указанного класса.
# Если указан метод — проверяется только поддержка объектом данного метода.

^if(def $method){
	^if(!^self.match[$object;$target;$method]){
		^throw[interface.implemented;;Missing or partial implementation of the «${method}» method.]
	}
}{
	^target.foreach[method;]{
		^if(!^self.match[$object;$target;$method]){
			^throw[interface.implemented;;Missing or partial implementation of the «${method}» method. Class must implement all methods of declared interface: ^target.foreach[method;info]{@${method}[^for[i](0;$info.max_params - 1){…}[^;]]}[, ].]
		}
	}
}


@match[object;target;method]
# $object   hash
# $target   hash
# [$method] string
#
# $result bool

# Сравнивает «сигнатуры» указанного метода объекта и цели.
# Если имя метода не передано, то считает, что переданы хеши с информацией о методах, а не об интерфейсах.

^if(def $method){
	$result(^object.contains[$method] && ^target.contains[$method] && $object.$method.max_params >= $target.$method.max_params)
}{
	$result($object.max_params >= $target.max_params)
}


@set[object;class]
# $object object / class
# $class  string
#
# $result void

# Устанавливает признак поддержки интерфейса.
# Предварительно создаёт поле IMPLEMENTS объекта или класса, если оного не существует.

$result[]

^if(!$object.[$self._field]){
	$object.[$self._field][^hash::create[]]
}

^object.[$self._field].add[$.$class(true)]


@mixin[donor;accepter;exceptions]
# $donor        object / class
# $accepter     object / class
# [$exceptions] hash
#
# $result void

# Подмешивает методы донора акцептору.
# Не перекрывает существующие методы акцептора.
#
# Третьим параметром можно передать исключения, например, конструкторы.
#
# dynamic: ^interface:mixin[$self.donor;$self]
# static:  ^interface:mixin[$donor:CLASS;$accepter:CLASS]

$interface[^self.interface[$donor.CLASS_NAME]]
^interface.sub[^self.interface[$accepter.CLASS_NAME](true)]
^interface.sub[^hash::create[$exceptions]]

^interface.foreach[method;]{
	$accepter.$method[^reflection:method[$donor;$method]]
}


@merge[a;b;exceptions]
# $a            object / class
# $b            object / class
# [$exceptions] hash
#
# $result void

# Подмешивает методы и поля одного объекта или класса другому в обе стороны.
# Таким образом, каждый из классов получает полный общий набор методов.
# Не перекрывает существующие методы.
#
# Третьим параметром можно передать исключения, например, конструкторы.
#
# dynamic: ^interface:mixin[$self.a;$self]
# static:  ^interface:mixin[$a:CLASS;$b:CLASS]

^self.mixin[$a;$b;$exceptions]
^self.mixin[$b;$a;$exceptions]


@field[donor;accepter;exceptions]
# $donor        object / class
# $accepter     object / class
# [$exceptions] hash
#
# $result void

# Подмешивает поля одного объекта или класса другому.
# Третьим параметром можно передать исключения.
# Не перекрывает существующие поля.

$fields[^self.fields[$donor]]
^fields.sub[^self.fields[$accepter]]
^fields.sub[^hash::create[$exceptions]]

^fields.foreach[name;value]{
	^switch(true){
		^case(^reflection:is[$name;code;$fields]){
			$accepter.$name{$value}
		}
		^case($value is int || $value is double){
			$accepter.$name($value)
		}
		^case[DEFAULT]{
			$accepter.$name[$value]
		}
	}
}


@ancestors[object;ancestor]
# $object     string / object / class
# [$ancestor] string
#
# $result hash

# Возвращает список классов-предков указанного класса или объекта.
# Если указан $ancestor — возвращается список по указанного предка.

$result[^hash::create[]]

^if($object is string){
	$object[^reflection:class_by_name[$object]]
}

$base[^reflection:base[$object]]

^while(def $base){
	$result.[$base.CLASS_NAME]($result + 1)

	^if($base.CLASS_NAME eq $ancestor){
		$base[]
	}{
		$base[^reflection:base[$base]]
	}
}


@descendant[object;ancestor]
# $object   string / object / class
# $ancestor string
#
# $result bool

# Возвращает истину, если cреди предков указанного объекта или класса имеется указанный.

$ancestors[^self.ancestors[$object;$ancestor]]

$result(^ancestors.contains[$ancestor])


@classes[filename]
# [$filename] string
#
# $result hash / interface.classes exception

# Возвращает хеш доступных классов (аналог ^reflection:classes[]).

# Можно указать имя файла, классы, декларированные в котором, интересуют.
# При поиске классов в файле наличие методов класса (methoded) не проверяется.

^if(def $filename){
	^assert(!-f $filename)[File «${filename}» not found.;interface.classes]

	$result[^hash::create[]]

	$file[^file::load[text;$filename]]

	^file.text.match[^^@CLASS\n(.+)^$;mg]{
		$result.[$match.1][]
	}
}{
	$result[^reflection:classes[]]
}


@inject[method_name;method;classes;options]
# $method_name string
# $method      junction / string
# [$classes]   hash
# [$options]   hash
#
# $result void

# Устанавливает указанным классам указанный метод под указанным именем.
# Если классы не указаны — устанавливает метод всем доступным пользовательским классам.

# Существующие методы не перекрываются, если не указана опция «force».
# Установка метода не производится, если у класса имеется сеттер свойства с именем, совпадающим с устанавливаемым или сеттер по умолчанию.
# Можно указать опцию «ignore-setters», для установки метода несмотря на наличие сеттеров.

$result[]

^if($method is string){
	$method[^method.split[:;h]]

	^if(def $method.1){
		$class[$method.0]
		$method[$method.1]
	}{
		$class[MAIN]
		$method[$method.0]
	}

	$method[^reflection:method[$class;$method]]
}

$options[^fe[$options]{^hash::create[]}]
$classes[^fd[$classes]{^self.classes[]}]

^classes.sub[
	$.bool[]
	$.console[]
	$.cookie[]
	$.curl[]
	$.date[]
	$.double[]
	$.env[]
	$.file[]
	$.form[]
	$.hash[]
	$.hashfile[]
	$.image[]
	$.inet[]
	$.int[]
	$.json[]
	$.mail[]
	$.math[]
	$.memcached[]
	$.memory[]
	$.reflection[]
	$.regex[]
	$.request[]
	$.response[]
	$.status[]
	$.string[]
	$.table[]
	$.void[]
	$.xdoc[]
	$.xnode[]
]

^classes.foreach[class_name;]{
	$class[^reflection:class_by_name[$class_name]]

	^if(
		(
			!^self.has[$class;$method_name]
			|| ^options.force.bool(false)
		)
		&& (
			!^self.has[$class;SET_$method_name]
			&& !^self.has[$class;SET_DEFAULT]
			|| ^options.ignore-setters.bool(false)
		)
	){
		$class.$method_name[$method]
	}
}