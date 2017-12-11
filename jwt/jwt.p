@CLASS
jwt


@OPTIONS
locals


@create[params]
$self.secret[$params.secret]
$self.algorithm[$params.algorithm]


@encode[payload;secret;algorithm]
$header[^json:string[
	$.alg[^self.alg[$algorithm;algorithm]]
	$.typ[JWT]
]]
$header[^self.to_url_safe[^header.base64[]]]

$payload[^json:string[$payload]]
$payload[^self.to_url_safe[^payload.base64[]]]

$signature[^self.sign[$header;$payload;$secret;$algorithm]]

$result[${header}.${payload}.$signature]


@sign[header;payload;secret;algorithm]
^if(!def $secret){
	$secret[$self.secret]
}

$result[^self.to_url_safe[^math:digest[^self.alg[$algorithm;function];${header}.$payload][
	$.format[base64]
	$.hmac[$secret]
]]]


@decode[token;secret;algorithm]
$result[]

$token[^token.split[.;h]]

$header[$token.0]
$payload[$token.1]
$signature[$token.2]

^if(^self.sign[$header;$payload;$secret;$algorithm] eq $signature){
	$result[^json:parse[^taint[as-is;^string:base64[^self.from_url_safe[$payload]]]]]
}


@to_url_safe[result]
$replace[^table::create[nameless]{
^taint[^#0A]
=
+	-
/	_}]

$result[^result.replace[$replace]]


@from_url_safe[result]
$replace[^table::create[nameless]{
-	+
_	/}]

$result[^result.replace[$replace]]

$divider(4)
$padding($divider - (^result.length[] % $divider))

$result[$result^for[](1;$padding){=}]


@alg[name;field]
^if(!def $name){
	$name[$self.algorithm]
}
$name[^name.lower[]]

$algorithms[
	$.hs256[
		$.function[sha256]
		$.algorithm[HS256]
	]
	$.hs512[
		$.function[sha512]
		$.algorithm[HS512]
	]
]
$algorithms._default[$algorithms.hs256]

$result[$algorithms.$name.$field]