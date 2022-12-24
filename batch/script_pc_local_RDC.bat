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
net localgroup administradores cardexpress.corp\admin01 /add
net localgroup administradores cardexpress.corp\admin01 /add
net localgroup administradores cardexpress.corp\admin01 /add
net localgroup administradores cardexpress.corp\admin01 /add
net localgroup administradores cardexpress.corp\admin01 /add
net localgroup administradores cardexpress.corp\admin01 /add
net localgroup administradores cardexpress.corp\admin01 /add
net localgroup administradores cardexpress.corp\admin01 /add
ECHO.
ECHO.
ECHO LISTANDO USUARIOS LOCAIS
NET USERS
ECHO.
ECHO LISTANDO ADMINISTRADORES LOCAIS
NET LOCALGROUP ADMINISTRADORES
pause

