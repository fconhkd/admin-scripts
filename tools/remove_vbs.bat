@echo off
cls
SETLOCAL ENABLEEXTENSIONS
SETLOCAL DISABLEDELAYEDEXPANSION

REM Se a pasta não existir vai para o FIM
IF NOT EXIST %ProgramData%\%USERNAME% GOTO FFIM

echo -----------------------------------------------------------------
echo ESTE PROCEDIMENTO REMOVERA UM MALWARE DO SISTEMA AUTOMATICAMENTE
echo ...DESEJA PROSSEGUIR? (caso não feche)
echo ------------------------------------------------------------------
PAUSE

REM Local onde os scripts estão
set pathapp=C:\SSIS\CARTAGO
REM local onde os logs serão salvos
set pathlog=%pathapp%\Logs
REM Definindo as variaveis yyyy-MM-dd [en]
REM set datahoje=%date:~0,4%-%date:~5,2%-%date:~8,2%
REM Definindo as variaveis yyyy-MM-dd [pt-BR]
set datahoje=%date:~0,2%-%date:~3,2%-%date:~6,4%

:REG
reg SAVE HKCU\Software\Microsoft\Windows\CurrentVersion\Run %appdata%\bkp_%datahoje%_HKCU-Run.reg /y
reg DELETE HKCU\Software\Microsoft\Windows\CurrentVersion\Run\ /f

:APAGAR
ECHO APAGANDO ARQUIVOS >> %appdata%\ERRO_%datahoje%.log.txt
ECHO. >> %appdata%\ERRO_%datahoje%.log.txt
DEL /F /S /Q %ProgramData%\%USERNAME%\*.* >> %appdata%\ERRO_%datahoje%.log.txt
RD %ProgramData%\%USERNAME% >> %appdata%\ERRO_%datahoje%.log.txt
ECHO. >> %appdata%\ERRO_%datahoje%.log.txt

:TEMP
ECHO APAGANDO A PASTA TEMP >> %appdata%\ERRO_%datahoje%.log.txt
ECHO. >> %appdata%\ERRO_%datahoje%.log.txt
DEL /F /S /Q %TEMP%\*.* >> %appdata%\ERRO_%datahoje%.log.txt
DEL /F /S /Q %TMP%\*.* >> %appdata%\ERRO_%datahoje%.log.txt
ECHO. >> %appdata%\ERRO_%datahoje%.log.txt

:SHUTDOWN
cls
echo O COMPUTADOR SERA DESLIGADO!
PAUSE
shutdown -t 15 -f -r -c "O COMPUTADOR SERA DESLIGADO, UM VIRUS FOI DETECTADO"
GOTO FFIM


:ERRO1
ECHO ISSO É UM ERRO!,...FAZER ALGO
dir /s %ProgramData%\%USERNAME% >> %appdata%\ERRO_%datahoje%.log.txt
GOTO FFIM


:FFIM