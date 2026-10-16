# Interactive Parser3 code executor

## Aliases
### Windows
#### Add autorun key into system regisrty
	reg add "HKCU\Software\Microsoft\Command Processor" /v AutoRun /t REG_EXPAND_SZ /d "%"USERPROFILE"%\autorun.cmd" /f

#### Create autorun command file
`%USERPROFILE%\autorun.cmd`:
```
@echo off
chcp 65001 > nul
doskey /macrofile=%USERPROFILE%\aliases.txt
```

#### Create aliases file and add executor alias
`%USERPROFILE%\aliases.txt`:
```
…
p3=pushd D:\web\home\ & D:\web\usr\local\parser3\parser3.exe p3 $*
```
### Nix
##### Add executor alias
`~/.bash_aliases`:
```
…
alias p3=/web/home/parser3/parser3.cgi p3 $@
```

Or just place p3 file into one of the PATH locations.

#### Reload profile aliases
```
> . ~/.bash_profile
```

## Usage
### Run executor
```
p3

Parser 3.5.0 (compiled on i386-pc-win32)
----------------------------------------------------------------------------------------------------
```
### Print commands and add @ to execute it
```
^eval(2 * 2)
@
```
### Get the JSON result with execution statistics
```
"4"

----------------------------------------------------------------------------------------------------
runs: 1 | utime: 0.000000 | stime: 0.000000 | used: 0 | allocated since start: 2.30
----------------------------------------------------------------------------------------------------
```

### Print command and add @ with specified number of runs to execute it multiple times
```
	^math:uuid[]
	@ 10000
```
### Get the JSON-result with execution statistics
```
"C712DBF6-E73C-47E2-8C1C-F935EA574ED7"

----------------------------------------------------------------------------------------------------
runs: 10000 | utime: 0.124801 | stime: 0.000000 | used: 1212 | allocated since start: 1446.75
----------------------------------------------------------------------------------------------------
```



#Arguments
##Root
You can specify the document-root as `root` argument:
```
> p3 -root /web/
```

## Commands
### Help
`@help` or `@h` – display short help.

### Execute
`@` – execute entered code. Number of runs in optional argument.

### Clear
`@clear` or `@c` – clear input buffer.

### Parser version
`@version` or `@v` – display Parser version.

### Info
`@info` or `@i` – display environment information.

### New executor
`@fork` or `@f` – start new executor in current environment.

### Exit
`@exit` or `@e` – exit from executor (you also can use ctrl + с or super + c).


## History
All executed commands and results a stored into `p3-history.log` file located near `p3` file.