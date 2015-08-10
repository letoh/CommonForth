@echo off
if %1.==. goto :error1
if not exist %1 goto :error1
if not exist GO32.EXE goto :error2
if not exist STRIP.EXE GOTO :error3
ECHO * Stripping %1 ...
COPY %1 %1_.TMP >NUL
STRIP %1_.TMP
ECHO * Binding %1 and GO32.EXE ...
COPY /BGO32.EXE+%1_.TMP %1.EXE >NUL
DEL %1_.TMP
ECHO * ok
goto :end
:error1
echo Syntax : BIND FILENAME
echo            Note : No extension name should be added, then
echo                   it will combine GO32.EXE and FILENAME
echo                   into FILENAME.EXE .
goto :end
:error2
echo * BIND.BAT Error : Cannot find GO32.EXE .
goto end
:error3
echo * BIND.BAT Error : Cannot find STRIP.EXE .
:END
