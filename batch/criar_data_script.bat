@echo off
cls
REM Criando pastas para o backup
pause Gostaria de continuar

REM Criando as variaveis no sistema
set datahoje=%date:~6,8%-%date:~3,2%-%date:~0,2%
set datadia=%date:~0,2%
set datames=%date:~3,2%
set dataano=%date:~6,8%

REM Criando a pasta de trabalho
md hoje
echo ------------------
REM Coloque o seu script aqui
echo   HELLO WORLD
echo ------------------
echo.

REM Mostrando as variaveis criadas
cd hoje
cd ..
pause Gostaria de continuar
REM Renomeia pasta para o nome escolhido
ren hoje "%datadia%"
echo tchau
