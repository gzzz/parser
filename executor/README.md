#Interactive Parser3 code executor

##Aliases
###Windows
####Add autorun key into system regisrty
	reg add "HKCU\Software\Microsoft\Command Processor" /v AutoRun /t REG_EXPAND_SZ /d "%"USERPROFILE"%\autorun.cmd" /f

####Create autorun command file
`%USERPROFILE%\autorun.cmd`:
@echo off
chcp 65001 > nul
doskey /macrofile=%USERPROFILE%\aliases.txt

####Create aliases file and add executor alias
`%USERPROFILE%\aliases.txt`:
…
p3=pushd D:\web\home\ & D:\web\usr\local\parser3\parser3.exe p3 $*

###Nix
#####Add executor alias
`~/.bash_aliases`:
…
alias p3=/web/home/parser3/parser3.cgi p3 $@

Or just place p3 file into one of the PATH locations.

####Reload profile aliases
	> ~/.bash_profile

##Usage
###Run executor

	p3

	Parser 3.4.5rc (compiled on i386-pc-win32)
	--------------------------------------------------

###Print commands and add @ to execute it

	^eval(2 * 2)
	@

###Get the JSON result

	"4"

	--------------------------------------------------

#Arguments
##Root
You can specify the document-root as `root` argument:
`> p3 -root /web/`

##Commands
###Help
Display short help.
`@help` or `@h`

###Execute
Execute entered code.
`@`

###Clear
Clear input buffer.
`@clear` or `@c`

###Parser version
Display Parser version.
`@version` or `@v`

###Info
Display environment information.
`@info` or `@i`

###Exit
Exit from executor (you also can use ctrl + с or super + c).
`@exit` or `@e`


## History
All executed commands and results a stored into `p3-history.log` file located near `p3` file.