@echo off
cls

FOR /F "tokens=1,2*" %%V IN ('bcdedit') DO SET adminTest=%%V
IF (%adminTest%)==(Access) goto noAdmin
echo.

ECHO APAGANDO CHAVE DE REGISTRO GOOGLE CHROME
REG DELETE HKLM\SOFTWARE\POLICIES\GOOGLE /f
goto theEnd

:noAdmin
echo Voc� deve executar este script como um Administrador!
echo ^<press any key^>
:theEnd
pause>NUL