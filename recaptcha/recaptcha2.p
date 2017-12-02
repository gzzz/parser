@CLASS
recaptcha2


@OPTIONS
locals


@auto[]
$self.params[
	$.hl[ru]

	$.api_url[https://www.google.com/recaptcha/api.js]
	$.verify_url[https://www.google.com/recaptcha/api/siteverify]

	$.agent[Parser3 reCAPTCHA2]
	$.timeout(10)

	$.class[g-recaptcha]
	$.field[g-recaptcha-response]
	$.ip[$env:REMOTE_ADDR]
]


@create[params]
^self.params.add[^hash::create[$params]]


@script[options]
$options[^hash::create[$options]]

$params[^self.override[^hash::create[]][
	$.hl[]
	$.render[]
][$self.params;$options]]

^if(def $options.onload){
	^params.add[
		$.render[explicit]
		$.onload[$options.onload]
	]
}

$attributes[
	$.src[$self.api_url^if($params){?^params.foreach[param;value]{$param=$value}[&]}]
]

^if(!^options.html5.bool(true)){
	$attributes.type[text/javascript]
}
^if(^options.async.bool(false)){
	$attributes.async[]
}
^if(^options.defer.bool(false)){
	$attributes.defer[]
}

$result[^self.tag[script;$attributes;$options]]


@challenge[options]
$options[^hash::create[$options]]

$attributes[^self.override[
	$.class[$self.class]
][
	$.id[]
	$.class[]

	$.sitekey[data]
	$.theme[data]
	$.type[data]
	$.size[data]
	$.tabindex[data]
	$.callback[data]
	$.expired-callback[data]
][$self.params;$options]]

$tag[^if(def $options.tag){$options.tag;div}]

$result[^self.tag[$tag;$attributes]]


@print[options]
$result[
	^self.script[$options]
	^self.challenge[$options]
]


@verify[form;passed;failed]
^curl:session{
	^try{
		$response[^curl:load[
			$.url[$self.verify_url]

			$.useragent[$self.agent]
			$.connecttimeout($self.timeout)
			$.timeout($self.timeout)
			$.ssl_verifypeer(false)
			$.failonerror(false)

			$.post(true)
			$.httppost[
				$.secret[$self.secret]
				$.response[$form.[$self.field]]
				$.remoteip[$self.ip]
			]
		]]
		$response[^json:parse[^taint[as-is;$response.text]]]

		^if(def $response.[error-codes]){
			$errors[^hash::create[]]

			^response.error-codes.foreach[;code]{
				$errors.$code[$self.errors.$code]
			}

			$response.errors[$errors]
			^response.delete[error-codes]
		}
	}{
		$exception.handled(^exception.type.left(4) eq 'curl')

		$response[
			$.errors[
				$.[$exception.type][$exception.comment]
			]
		]
	}

	$caller.response[$response]

	^if(^response.success.bool(false)){
		$result[$passed]
	}{
		$result[$failed]
	}
}


@tag[name;attributes;options]
$result[<$name ^self.attributes[$attributes;$options]></$name>]


@attributes[attributes;options]
$html5(^options.html5.bool(true))

$result[^attributes.foreach[attribute;value]{$attribute^if(def $value){="$value";^if(!$html5){="$attribute"}}}[ ]]


@override[result;params;*donors]
^donors.foreach[;donor]{
	$appendix[^donor.intersection[$params]]

	^appendix.foreach[param;value]{
		$scope[$params.$param]
		^if(def $scope){
			$param[${scope}-$param]
		}

		$result.$param[$value]
	}
}


@GET_DEFAULT[field]
$result[$self.params.$field]


@SET_DEFAULT[field;value]
$self.params.$field[$value]



@CLASS
invisible_recaptcha2


@OPTIONS
locals


@BASE
recaptcha2


@challenge[options]
$options[^hash::create[$options]]

$attributes[^self.override[
	$.class[g-recaptcha]
][
	$.id[]
	$.class[]

	$.sitekey[data]
	$.badge[data]
	$.type[data]
	$.size[data]
	$.tabindex[data]
	$.callback[data]
	$.expired-callback[data]
][$self.params;$options]]

$result[^self.attributes[$attributes;$options]]