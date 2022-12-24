ECHO OFF
REM CRIADOR_DO_CORE_MATHEUS_MARTINS_BENITES_SYK
	TITLE CORE 2.1
	mode con:cols=100 lines=35
:-------------------------------------
	>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
	if '%errorlevel%' NEQ '0' (
    call :c 0a " Requesting administrative privileges... " /n
goto UACPrompt
		) else ( goto gotAdmin )
:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
REM CRIADOR_DO_CORE_MATHEUS_MARTINS_BENITES_SYK
echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

for /f "tokens=2 delims==" %%f in ('wmic cpu get name /value ^| find "="') do set "name=%%f" 
for /f "tokens=2 delims==" %%f in ('wmic os get caption /value ^| find "="') do set "OS=%%f" 
for /f "tokens=2 delims==" %%f in ('wmic bios get SMBIOSBIOSVersion /value ^| find "="') do set "BIOS=%%f" 
for /f "tokens=2 delims==" %%f in ('wmic IDECONTROLLER get Caption /value ^| find "="') do set "IDE=%%f" 

:MENU
	echo Version Bios %bios% >> %USERPROFILE%\Desktop\RELATORIO.txt
	CLS
		call :c 0a "  //--------------------CORE Version 2.1-------------------------------\\    " /n
		call :c 0a " --"
		call :c 05 "                    / ____// __ \ / __ \ / ____/                        "
		call :c 0a "--  " /n
		call :c 0a " --"
		call :c 05 "                   / /    / / / // /_/ // __/                           "
		call :c 0a "--  " /n
		call :c 0a " --"
		call :c 05 "                  / /___ / /_/ // _, _// /___                           " 
		call :c 0a "--  " /n
		call :c 0a "  \\-------------"
		call :c 05 "    \____/ \____//_/ |_|/_____/   "
		call :c 0a "----------------------//    " /n
		call :c 0a "   \\-----
		call :c 05 " By Dell Support Brazil"
		call :c 0a "   -------  Creator:MATHEUS BENITES  -//     " /n
		ECHO.
		call :c 0F " _____________________________________________________________" /n
			call :c 07 "BIOS Version"
			call :c 0a " %bios%" /n
			echo %name%
			echo %OS%
			systeminfo | findstr "total"
			call :c 07 "Velocidade:"
			for /f "tokens=2 delims==" %%f in ('wmic MEMORYCHIP get Speed /value ^| find "="') do set "SPEED=%%f"(
			call :c 0a "%SPEED%" 
			)
			call :c 0a " MHz" /n
			call :c 0F "\             SELECIONE Memoria fisica total                     \" /n
			call :c 0F " \_______________________________________________________________,  " /n
				ECHO.
		call :c 07 "D - INSTALL DELL UPDATE "  /n
		call :c 07 "S - INSTALL SUPPORT ASSIST " /n
		call :c 07 "H - FIRMWARE HIBERNACAO"
		call :c 0a  " New"
		call :c 07 " ( INSP 3442 , INSP 3542 , INSP 5748 , VOST 3446 , VOST 3546)"  /n
		ECHO.
		call :c 0e "R-"
		call :c 0e "Restauracao de Fabrica (Windows 10)" /n
		ECHO.
		call :c 0e "B-"
		call :c 0e "BIOS FORCE UPDATE" /n
		ECHO.
		ECHO 2 - Memoria Fisica para 2GB
		ECHO 4 - Memoria Fisica para 4GB
		ECHO 6 - Memoria Fisica para 6GB
		ECHO 8 - Memoria Fisica para 8GB
		ECHO 0 - PULAR ETAPA
			ECHO.
	SET /P M=Pressione a Chave e ENTER:
		IF %M%==H GOTO FIRM
		IF %M%==h GOTO FIRM 
		IF %M%==R GOTO RESET
		IF %M%==r GOTO RESET
		IF %M%==D GOTO D
		IF %M%==d GOTO D
		IF %M%==s GOTO S
		IF %M%==S GOTO S
		IF %M%==2 GOTO 2GB
		IF %M%==4 GOTO 4GB
		IF %M%==6 GOTO 6GB
		IF %M%==8 GOTO 8GB
		IF %M%==0 GOTO SERVICO
		IF %M%==? GOTO ANALISE
		IF %M%==B GOTO BIOS
		IF %M%==b GOTO BIOS
goto MENU
:BIOS
cls
		call :c 0e "                  -ATENCAO-                  " /n
		echo.
		echo.
		call :c 07 "Ao abrir a pagina FTP Donwloads baixe o drive necessario e Feche para prosseguir" /n
		call :c 07 "Baixe o drive da Bios mais atualizada pelo site " /n
		call :c 07 "Salve na pasta Raiz C: , com o nome exatamente MAISCULO" /n
		call :c 0e "BIOS.exe "
		call :c 07 "Apos isso pressione enter para continuar com Forceit" /n
		"%PROGRAMFILES%\Internet Explorer\IExplore" "http://downloads.dell.com/published/pages/#all-products"
		pause
C:/BIOS.exe -FORCEIT -NOPAUSE
goto MENU
REM MENU DE ANALISE
	for /f "tokens=2 delims==" %%f in ('wmic COMPUTERSYSTEM get SystemType /value ^| find "="') do set "ARQUITETURA=%%f" 
	for /f "tokens=2 delims==" %%f in ('wmic IDECONTROLLER get Caption /value ^| find "="') do set "IDE=%%f" 
	for /f "tokens=2 delims==" %%f in ('wmic MEMCACHE get Purpose /value ^| find "="') do set "IDENTCACHE=%%f" 
	for /f "tokens=2 delims==" %%f in ('wmic MEMORYCHIP get DeviceLocator /value ^| find "="') do set "MEMSLOT=%%f" 
	for /f "tokens=2 delims==" %%f in ('wmic PAGEFILESET get InitialSize /value ^| find "="') do set "PAGE1=%%f"
:ANALISE
	cls
		call :c 0a "          INFO PROCESSORS" /n
		call :c 0a "Modelo:"
		call :c 07 "%name%" /n
		call :c 0a "Processadores Logicos:"
		for /f "tokens=2 delims==" %%f in ('wmic cpu get NumberOfLogicalProcessors /value ^| find "="') do set "CPU=%%f"(
		call :c 07 "%CPU%" /n
		)
		call :c 0a "Arquitetura:"
		for /f "tokens=2 delims==" %%f in ('wmic COMPUTERSYSTEM get SystemType /value ^| find "="') do set "ARQUITETURA=%%f" (
		call :c 07 "%ARQUITETURA%" /n
		)
		call :c 0a "L1 CACHE:"
		wmic MEMCACHE get NumberOfBlocks /ALL | findstr "8"
		call :c 0a "L2 CACHE:"
		wmic MEMCACHE get NumberOfBlocks /ALL | findstr "5"
		call :c 0a "L3 CACHE:"
		wmic MEMCACHE get NumberOfBlocks /ALL | findstr "3"
		call :c 0a "          INFO MEMORY RAM" /n
rem systeminfo | findstr "total"
		call :c 0a "SPEED MEMORIA RAM:"
		for /f "tokens=2 delims==" %%f in ('wmic MEMORYCHIP get Speed /value ^| find "="') do set "SPEED=%%f"(
		call :c 07 "%SPEED%" 
		)
		call :c 07 " MHz" /n
		call :c 0a "          INFO SYSTEM" /n
		call :c 0a "OS:"
		call :c 07 "%OS%" /n
		for /f "tokens=2 delims==" %%f in ('wmic PAGEFILESET get InitialSize /value ^| find "="') do set "PAGE1=%%f"(
		call :c 0a "Paginacao de Memoria inicial:"
		call :c 07 "%PAGE1% " 
		call :c 07 "MB" /n
		)
		for /f "tokens=2 delims==" %%f in ('wmic PAGEFILESET get MaximumSize /value ^| find "="') do set "PAGE2=%%f"(
		call :c 0a "Paginacao de Memoria Final:"
		call :c 07 "%PAGE2% " 
		call :c 07 "MB" /n
		)
			echo.
			echo.
			echo.
		call :c 0a "          SERVICOS IMPORTANTES" /n
		echo.
REM WINDOWS SEARCH (WSearch)
		call :c 07 "[Windowns Search]   " 
		for /f "tokens=2 delims==" %%f in ('wmic SERVICE WSearch get state /VALUE ^| find "="') do set "SEARCH=%%f" (
		call :c 07 "Status Service:"
		call :c 0a "%SEARCH%" /n
		)
		for /f "tokens=2 delims==" %%f in ('wmic SERVICE WSearch get StartMode /VALUE ^| find "="') do set "SEARCH1=%%f"(
		call :c 07 "Tipo de inicializacao:"
		call :c 0a "%SEARCH1%" /n
		)
REM WINDOWS UPDATE (wuauserv) 
		call :c 07 "[Windows Update]    " 
		for /f "tokens=2 delims==" %%f in ('wmic SERVICE wuauserv get state /VALUE ^| find "="') do set "SEARCH=%%f" (
		call :c 07 "Status Service:"
		call :c 0a "%SEARCH%" /n
		)
		for /f "tokens=2 delims==" %%f in ('wmic SERVICE wuauserv get StartMode /VALUE ^| find "="') do set "SEARCH1=%%f"(
		call :c 07 "Tipo de inicializacao:"
		call :c 0a "%SEARCH1%" /n
			echo.
			echo.
			)
REM Telemetria de Usuario Conectado (DiagTrack)
		call :c 07 "[Telemetria]        " 
		for /f "tokens=2 delims==" %%f in ('wmic SERVICE DiagTrack get state /VALUE ^| find "="') do set "SEARCH=%%f" (
		call :c 07 "Status Service:"
		call :c 0a "%SEARCH%" /n
		)
		for /f "tokens=2 delims==" %%f in ('wmic SERVICE DiagTrack get StartMode /VALUE ^| find "="') do set "SEARCH1=%%f"(
		call :c 07 "Tipo de inicializacao:"
		call :c 0a "%SEARCH1%" /n
		)
REM Superfetch (SysMain)
		call :c 07 "[Superfetch]        " 
		for /f "tokens=2 delims==" %%f in ('wmic SERVICE SysMain get state /VALUE ^| find "="') do set "SEARCH=%%f" (
		call :c 07 "Status Service:"
		call :c 0a "%SEARCH%" /n
		)
		for /f "tokens=2 delims==" %%f in ('wmic SERVICE SysMain get StartMode /VALUE ^| find "="') do set "SEARCH1=%%f"(
		call :c 07 "Tipo de inicializacao:"
		call :c 0a "%SEARCH1%" /n
		)
REM Serviço transferencia inteligente de tela de fundo (BITS)
		call :c 07 "[Bits]              " 
		for /f "tokens=2 delims==" %%f in ('wmic SERVICE BITS get state /VALUE ^| find "="') do set "SEARCH=%%f" (
		call :c 07 "Status Service:"
		call :c 0a "%SEARCH%" /n
		)
		for /f "tokens=2 delims==" %%f in ('wmic SERVICE BITS get StartMode /VALUE ^| find "="') do set "SEARCH1=%%f"(
		call :c 07 "Tipo de inicializacao:"
		call :c 0a "%SEARCH1%" /n
		)
			pause
GOTO MENU
:RESET
		cls
		ECHO.
		ECHO.
		call :c 09 "Restore Factory System" /n
		call :c 0e "[Carregando System Reset...]"
		ECHO.
		ECHO.
		ECHO.
		call :c 07 "Realize o "
		call :c 0c "BACKUP "
		call :c 07 "antes desse procedimento" /n
	    timeout /t 1 /nobreak > nul
		systemreset
GOTO MENU
:FIRM
		call :c 0e "downloading Firmware Hibernaçao"
        call :c 07 "[1,0 MB]" /n       
		powercfg -x -disk-timeout-ac 0
		powercfg -x -disk-timeout-dc 0
		powercfg -x -standby-timeout-ac 0
		powercfg -x -standby-timeout-dc 0
		powercfg -x -hibernate-timeout-ac 0
		powercfg -x -hibernate-timeout-dc 0
		PowerShell -NoProfile -ExecutionPolicy Bypass -Command Invoke-WebRequest -Uri "https://downloads.dell.com/FOLDER03430935M/1/IntelMEUptool.exe" -OutFile "$PSScriptRoot\IntelMEUptool.exe"
		START C:\IntelMEUptool.exe
GOTO MENU
:D
        call :c 0e "downloading Dell update"
        call :c 07 "[8,07 MB]" /n       
		PowerShell -NoProfile -ExecutionPolicy Bypass -Command Invoke-WebRequest -Uri "https://downloads.dell.com/FOLDER04317777M/1/Dell-Update-Application_31YHC_WIN_1.9.20.0_A00.EXE" -OutFile "$PSScriptRoot\Dell-Update.EXE"
		START C:\Dell-Update.exe
		ECHO Instalado Dell update  >> %USERPROFILE%\Desktop\RELATORIO.txt
GOTO MENU
:S
        call :c 0e "Downloading Dell Support Assist"
        call :c 07 "[2,11 MB]" /n       
		PowerShell -NoProfile -ExecutionPolicy Bypass -Command Invoke-WebRequest -Uri "http://content.dellsupportcenter.com/updates/aulauncher.exe" -OutFile "$PSScriptRoot\Dell-SUPPORT.EXE"
		START C:\Dell-SUPPORT.exe
		ECHO Instalado Support Assist  >> %USERPROFILE%\Desktop\RELATORIO.txt
GOTO MENU
:2GB
		wmic pagefileset create name="C:\pagefile.sys"
		wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=2048,MaximumSize=4096
		ECHO Otimizado Memoria Virtual da Paginacao para 2048 mb  >> %USERPROFILE%\Desktop\RELATORIO.txt
goto SERVICO
:4GB
		wmic pagefileset create name="C:\pagefile.sys"
		wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=4096,MaximumSize=6144
		ECHO Otimizado Memoria Virtual da Paginacao para 4096 mb  >> %USERPROFILE%\Desktop\RELATORIO.txt
goto SERVICO
:6GB
		wmic pagefileset create name="C:\pagefile.sys"
		wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=6144,MaximumSize=8192
		ECHO Otimizado Memoria Virtual da Paginacao para 6144 mb  >> %USERPROFILE%\Desktop\RELATORIO.txt
goto SERVICO
:8GB
		wmic pagefileset create name="C:\pagefile.sys"
		wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=8192,MaximumSize=10124
		ECHO Otimizado Memoria Virtual da Paginacao para 8192 mb  >> %USERPROFILE%\Desktop\RELATORIO.txt
goto SERVICO
:SERVICO
REM Superfetch (SysMain)
		sc config SysMain start= disabled 
		sc failureflag SysMain flag=0 
		sc failure SysMain  reset= 3 actions= /0 
		net stop SysMain    
        call :c 0a "[Desabilitado Superfetch]" /n 
		ECHO DESABILITADO Superfetch >> %USERPROFILE%\Desktop\RELATORIO.txt
		timeout /t 1 /nobreak > nul
REM Telemetria de Usuario Conectado (DiagTrack)
		sc config DiagTrack start= disabled
		sc failureflag DiagTrack flag=0
		sc failure DiagTrack reset=3 actions= /0
		net     stop DiagTrack
        call :c 0a "[Desativado Telemetria]" /n 
		ECHO DESABILITADO Experiencias e Telemetria de Usuario Conectado >> %USERPROFILE%\Desktop\RELATORIO.txt
		timeout /t 1 /nobreak > nul
REM Serviço transferencia inteligente de tela de fundo (BITS)
		sc config BITS start= disabled 
		sc failureflag BITS flag=0 
		sc failure BITS  reset= 3 actions= /0 
		net stop BITS 
        call :c 0a "[Desativado transferencia inteligente de tela de fundo]" /n 
		ECHO DESABILITADO Servico de transferencia inteligente de tela de fundo >> %USERPROFILE%\Desktop\RELATORIO.txt
		timeout /t 1 /nobreak > nul
REM StartupAppTask
		schtasks /change /tn "\Microsoft\Windows\Application Experience\StartupAppTask" /DISABLE
		schtasks /Delete /tn "\Microsoft\Windows\Application Experience\StartupAppTask" /F
        call :c 0a "[Desativado StartupAppTask]" /n 
        timeout /t 1 /nobreak > nul
REM ProgramDataUpdater
		schtasks /change /tn "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /DISABLE
		schtasks /Delete /tn "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /F
        call :c 0a "[Desativado ProgramDataUpdater]" /n 
        timeout /t 1 /nobreak > nul
		schtasks /change /tn "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /DISABLE
		schtasks /Delete /tn "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /F
        call :c 0a "[Desativado Microsoft Compatibility Appraiser]" /n 
REM Microsoft Compatibility Appraiser
		timeout /t 1 /nobreak > nul
		ECHO DESATIVADO Agendador de Tarefas Experience Telemetria >> %USERPROFILE%\Desktop\RELATORIO.txt
REM Manutencao Automatica
		schtasks /change /tn "\Microsoft\Windows\TaskScheduler\Maintenance Configurator" /DISABLE
		schtasks /Delete /tn "\Microsoft\Windows\TaskScheduler\Maintenance Configurator" /F
		ECHO DESATIVADO Manutencao automatica >> %USERPROFILE%\Desktop\RELATORIO.txt
        call :c 0a "[Manutencao Automatica]" /n 
		timeout /t 1 /nobreak > nul
REM AllowTelemetry
		REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
		ECHO DESATIVADO Telemetry regedit >> %USERPROFILE%\Desktop\RELATORIO.txt
        call :c 0a "[AllowTelemetry Desativado]" /n
		timeout /t 1 /nobreak > nul
REM Politicas de Energia	
		call :c 0a "[Configurado politicas de energia]" /n
		powercfg -x -disk-timeout-ac 0
		powercfg -x -disk-timeout-dc 0
		powercfg -x -standby-timeout-ac 0
		powercfg -x -standby-timeout-dc 0
		powercfg -x -hibernate-timeout-ac 0
		powercfg -x -hibernate-timeout-dc 0
		ECHO Configurado politicas de energia sem Hibernacao  >> %USERPROFILE%\Desktop\RELATORIO.txt
		timeout /t 1 /nobreak > nul
REM Limpeza de dados web
		RunDll32.exe inetcpl.cpl , ClearMyTracksByProcess 255
		call :c 0a "[Realizado Limpeza de dados web]" /n 
		ECHO Limpeza de dados web - Cookies - Dados do filtro de phishing >> %USERPROFILE%\Desktop\RELATORIO.txt
		timeout /t 1 /nobreak > nul
GOTO CORE
:CORE 
		CLS
		for /f "tokens=2 delims==" %%f in ('wmic cpu get NumberOfLogicalProcessors /value ^| find "="') do set "CPU=%%f" (
		ECHO Otimizado Nucleos na inicializacao para %CPU%  nucleos >> %USERPROFILE%\Desktop\RELATORIO.txt
		bcdedit /set numproc %CPU%
		cls
		echo Otimizando nucleos apartir bcdedit...
		timeout /t 1 /nobreak > nul
		call :c 0a " [Processamento Otimizado Na inicializaçao para %CPU% Nucleos] " /n 
		)
		timeout /t 3 /nobreak > nul
GOTO CACHE
:CACHE
		for /f "tokens=2 delims==" %%f in ('wmic cpu get l2cachesize /value ^| find "="') do set "L2=%%f" (
		ECHO Otimizando L2 Cache para %L2% kb >> %USERPROFILE%\Desktop\RELATORIO.txt
		REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v SecondLevelDataCache /t REG_DWORD /d %L2% /f
		cls
		echo Otimizado L2 Cache Do Processador...
		timeout /t 1 /nobreak > nul
		call :c 0a " [L2 Cache Configurado Para %L2% Kb ]" /n 
		)
		timeout /t 3 /nobreak > nul
GOTO SERIAL ATA
:SERIAL ATA
		for /F "skip=1" %%i in ('wmic IDECONTROLLER GET DeviceID') do (
		REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v MSISupported /t REG_DWORD /d 0 /f
		)
		cls
		echo Corrigindo Serial ATA Controller...
		ECHO Desativado MSISupported no - %IDE%  >> %USERPROFILE%\Desktop\RELATORIO.txt
		timeout /t 1 /nobreak > nul
		call :c 0a " [Configurado %IDE% ]" /n 
GOTO FIM
:FIM
		GPUPDATE/FORCE
		ECHO Realizado Gpupdate/force >> %USERPROFILE%\Desktop\RELATORIO.txt
		call :c 0a "[GPUPDATE/FORCE]" /n
		timeout /t 1 /nobreak > nul
		call :c 0a "[Fix complete]" /n 
		timeout /t 3 /nobreak > nul
		CLS
		ECHO.
		echo.
		echo.
		echo.
		call :c 0a "          SERVICES" /n
		echo.
REM WINDOWS SEARCH (WSearch)
		call :c 07 "[Windowns Search]   " 
		for /f "tokens=2 delims==" %%f in ('wmic SERVICE WSearch get state /VALUE ^| find "="') do set "SEARCH=%%f" (
		call :c 07 "Status Service:"
		call :c 0a "%SEARCH%" /n
		)
		for /f "tokens=2 delims==" %%f in ('wmic SERVICE WSearch get StartMode /VALUE ^| find "="') do set "SEARCH1=%%f"(
		call :c 07 "Tipo de inicializacao:"
		call :c 0a "%SEARCH1%" /n
		)
REM WINDOWS UPDATE (wuauserv) 
		call :c 07 "[Windows Update]    " 
		for /f "tokens=2 delims==" %%f in ('wmic SERVICE wuauserv get state /VALUE ^| find "="') do set "SEARCH=%%f" (
		call :c 07 "Status Service:"
		call :c 0a "%SEARCH%" /n
		)
		for /f "tokens=2 delims==" %%f in ('wmic SERVICE wuauserv get StartMode /VALUE ^| find "="') do set "SEARCH1=%%f"(
		call :c 07 "Tipo de inicializacao:"
		call :c 0a "%SEARCH1%" /n
			echo.
			echo.
			)
REM Telemetria de Usuario Conectado (DiagTrack)
		call :c 07 "[Telemetria]        " 
		for /f "tokens=2 delims==" %%f in ('wmic SERVICE DiagTrack get state /VALUE ^| find "="') do set "SEARCH=%%f" (
		call :c 07 "Status Service:"
		call :c 0a "%SEARCH%" /n
		)
		for /f "tokens=2 delims==" %%f in ('wmic SERVICE DiagTrack get StartMode /VALUE ^| find "="') do set "SEARCH1=%%f"(
		call :c 07 "Tipo de inicializacao:"
		call :c 0a "%SEARCH1%" /n
		)
REM Superfetch (SysMain)
		call :c 07 "[Superfetch]        " 
		for /f "tokens=2 delims==" %%f in ('wmic SERVICE SysMain get state /VALUE ^| find "="') do set "SEARCH=%%f" (
		call :c 07 "Status Service:"
		call :c 0a "%SEARCH%" /n
		)
		for /f "tokens=2 delims==" %%f in ('wmic SERVICE SysMain get StartMode /VALUE ^| find "="') do set "SEARCH1=%%f"(
		call :c 07 "Tipo de inicializacao:"
		call :c 0a "%SEARCH1%" /n
		)
REM Serviço transferencia inteligente de tela de fundo (BITS)
		call :c 07 "[Bits]              " 
		for /f "tokens=2 delims==" %%f in ('wmic SERVICE BITS get state /VALUE ^| find "="') do set "SEARCH=%%f" (
		call :c 07 "Status Service:"
		call :c 0a "%SEARCH%" /n
		)
		for /f "tokens=2 delims==" %%f in ('wmic SERVICE BITS get StartMode /VALUE ^| find "="') do set "SEARCH1=%%f"(
		call :c 07 "Tipo de inicializacao:"
		call :c 0a "%SEARCH1%" /n
		)
		echo.
		echo.
		call :c 0c "FINALIZANDO EM 5 SEGUNDOS..."
		timeout /t 5 /nobreak > nul

exit
:c
setlocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:colorPrint Color  Str  [/n]
setlocal
REM CRIADOR_DO_CORE_MATHEUS_MARTINS_BENITES_SYK
set "s=%~2"
call :colorPrintVar %1 s %3
exit /b

:colorPrintVar  Color  StrVar  [/n]
if not defined DEL call :initColorPrint
setlocal enableDelayedExpansion
pushd .
':
cd \
set "s=!%~2!"
for %%n in (^"^

^") do (
  set "s=!s:\=%%~n\%%~n!"
  set "s=!s:/=%%~n/%%~n!"
  set "s=!s::=%%~n:%%~n!"
)
for /f delims^=^ eol^= %%s in ("!s!") do (
  if "!" equ "" setlocal disableDelayedExpansion
  if %%s==\ (
    findstr /a:%~1 "." "\'" nul
    <nul set /p "=%DEL%%DEL%%DEL%"
  ) else if %%s==/ (
    findstr /a:%~1 "." "/.\'" nul
    <nul set /p "=%DEL%%DEL%%DEL%%DEL%%DEL%"
  ) else (
    >colorPrint.txt (echo %%s\..\')
    findstr /a:%~1 /f:colorPrint.txt "."
    <nul set /p "=%DEL%%DEL%%DEL%%DEL%%DEL%%DEL%%DEL%"
  )
)
if /i "%~3"=="/n" echo(
popd
exit /b


:initColorPrint
for /f %%A in ('"prompt $H&for %%B in (1) do rem"') do set "DEL=%%A %%A"
<nul >"%temp%\'" set /p "=."
REM CRIADOR_DO_CORE_MATHEUS_MARTINS_BENITES_SYKZ
subst ': "%temp%" >nul
exit /b