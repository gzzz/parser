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
p3=pushd D:\web\home\ & D:\web\usr\local\parser3\parser3.exe executor.html

###Nix
#####Add executor alias
`~/.bash_aliases`:
…
alias p3=/web/home/parser3/parser3.cgi executor.html

####Reload profile aliases
	> ~/.bash_profile

##Usage
###Run executor

	p3

	Parser 3.4.5rc (compiled on i386-pc-win32)
	--------------------------------------------------

###Print commands and add two empty lines after to execute it

	^eval(2 * 2)

###Get the JSON result

	"4"

	--------------------------------------------------

##Bultin commands
###Clear
Command clear input buffer.
	`:clear`

###Exit
Exit from executor (you alse can use ctrl + с / super + c).
	`:exit`

## History
All executed commands and results a stored into `history.log` file near `executor.html`.