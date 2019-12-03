# Сборка Парсера в Visual Studio

[Основы описаны в документации Парсера](https://www.parser.ru/docs/lang/compilewin.htm).

## Создаём рабочую директорию
```
mkdir parser3-source
cd parser3-source
```

## Загружаем исходный код
```
cvs -d :pserver:anonymous@cvs.parser.ru:/parser3project co parser3
cvs -d :pserver:anonymous@cvs.parser.ru:/parser3project co win32
```
## Visual Studio
Устанавливаем Visual Studio, например Visual Studio 2015.
https://visualstudio.microsoft.com/ru/vs/older-downloads/

Запускаем (потребуется microsoft-аккаунт, туды его в качель).
Открываем готовый проект, находящийся по адресу `parser3-source/parser3/parser3.sln`.

Выбираем release-конфигурацию.
![Config Choosing](https://github.com/gzzz/parser/raw/master/bin/win/build/img/parser3-build-config-choosing.png)

В списке решений выбираем `parser3`, в контекстном меню выбираем пункт «Собрать».
![Solution Context Menu](https://github.com/gzzz/parser/raw/master/bin/win/build/img/parser3-build-solution-context-menu.png)

В лог выводится информация о сборке, с кучей предупреждений.
![Solution Context Menu](https://github.com/gzzz/parser/raw/master/bin/win/build/img/parser3-build-log.png)

Если всё прошло хорошо, то в директории `parser3-source/parser3/src/targets/cgi/Release/` будет находиться свежесобранный `parser3.exe`.
