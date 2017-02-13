@echo off
cls

echo START BACKUP
osql -E -S <SERVER\INSTANCE> -i "bkp_SqlServer.SQL"
echo.
echo SUCESS