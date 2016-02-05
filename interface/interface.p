@CLASS
interface


@OPTIONS
locals
static


@auto[]
$self.field[IMPLEMENTS]
$self.etype[interface.implementation]


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
	^if($object.[$self.field]){
#		Если у объекта в поле IMPLEMENTS указана поддержка интерфейса — верим на слово.

		$result(^object.[$self.field].contains[$class])
	}{
#		Иначе проверяем, сверяя «сигнатуры» методов.

		$object_interface[^self.interface[$object.CLASS_NAME]]
		$target_interface[^self.interface[$class]]

		^try{
			^self.implemented[$object_interface;$target_interface;$method]

			$result(true)
		}{
			$exception.handled($exception.type eq '$self.etype')

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

$result(^reflection:method[$object;$method] is junction)

^if($result && def $class){
	$object[^self.info[$object.CLASS_NAME;$method]]
	$target[^self.info[$class;$method]]

	$result(^self.match[$object;$target])
}


@interface[class]
# $class  string
#
# $result hash

# Возвращает интерфейс методов указанного класса.
# Геттеры и сеттеры игнорирует.

$result[^hash::create[]]

$methods[^reflection:methods[$class]]
^methods.foreach[method;]{
	$prefix[^method.left(3)]

	^if($prefix ne 'GET' && $prefix ne 'SET'){
		$result.$method[^self.info[$class;$method]]
	}
}


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
# $result   void / interface.implementation exception

# Проверяет поддержку объектом интерфейса указанного класса.
# Если указан метод — проверяется только поддержка объектом данного метода.

^if(def $method){
	^if(!^self.match[$object;$target;$method]){
		^throw[$self.etype;Missing or partial implementation of the «${method}» method.]
	}
}{
	^target.foreach[method;]{
		^if(!^self.match[$object;$target;$method]){
			^throw[$self.etype;Missing or partial implementation of the «${method}» method. Class must implement all methods of declared interface: ^target.foreach[method;info]{@${method}[^for[i](0;$info.max_params - 1){…}[^;]]}[, ].]
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

^if(!$object.[$self.field]){
	$object.[$self.field][^hash::create[]]
}

^object.[$self.field].add[$.$class(true)]


@mixin[donor;accepter;exceptions]
# $donor      object / class
# $accepter   object / class
# $exceptions hash
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
^interface.sub[^hash::create[$exceptions]]

^interface.foreach[method;]{
	^if(!^self.has[$accepter;$method]){
		$accepter.$method[^reflection:method[$donor;$method]]
	}
}