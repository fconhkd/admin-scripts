@echo off
cls
echo CRIANDO CONFIG de GRUPO LOCAIS
echo.
pause
echo.
echo ATIVANDO CONTA DO ADMINISTRADOR LOCAL
ECHO.
net user administrador /active:yes
echo ADICIONANDO ADMINISTRADORES DO DOMINIO LOCAIS
ECHO.
net localgroup administradores cardexpress.corp\anderson.moura /add
net localgroup administradores cardexpress.corp\fabio.barbosa /add
net localgroup administradores cardexpress.corp\paulo.silva /add
net localgroup administradores cardexpress.corp\tiago.turcato /add
net localgroup administradores cardexpress.corp\marcel.savegnago /add
net localgroup administradores cardexpress.corp\fabiano.conrado /add
net localgroup administradores cardexpress.corp\svc.fiscal /add
net localgroup administradores cardexpress.corp\zoltan.guilherme /add
ECHO.
ECHO.
ECHO LISTANDO USUARIOS LOCAIS
NET USERS
ECHO.
ECHO LISTANDO ADMINISTRADORES LOCAIS
NET LOCALGROUP ADMINISTRADORES
pause

