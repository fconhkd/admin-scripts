ECHO OFF
REM CRIADOR_DO_CORE_MATHEUS_MARTINS_BENITES_SYK
	TITLE GLPI-INVENTORY
	mode con:cols=100 lines=35
	REM Copiar script da rede para a pasta TEMP
	copy \\domain.corp\netLOGON\tools\glpi-agent-deployment.vbs %temp%	
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
ECHO EXECUTANDO O INVENTARIO DO GLPI
cscript %temp%\glpi-agent-deployment.vbs
del %temp%\glpi-agent-deployment.vbs