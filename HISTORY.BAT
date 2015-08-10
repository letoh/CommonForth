@IF %1.==. GOTO ERROR

CALL RELEASE %1 HISTORY

@GOTO END
:ERROR
@ECHO.
@ECHO * Make a history record for Common Forth system *
@ECHO Syntax:
@ECHO    HISTORY [PATH]
@ECHO.
:END
