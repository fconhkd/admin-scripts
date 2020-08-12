echo off
cls

for /f "tokens=1-4 delims=/ " %%i in ("%date%") do (
	set dow=%%l
	set month=%%j
	set day=%%i
	set year=%%k
)

:: get time
for /F "tokens=1-2 delims=:. " %%i in ('time /t') do (
	set hh=%%i
	set mi=%%j
)


set datestr=%day%-%month%-%year%
echo datestr is %datestr%

rem SET PGPASSWORD=<PassWord>
SET DATABASE_NAME=<DatabaseAqui>
SET SERVER_IP=10.20.10.250

echo off
set BACKUP_FILE=%datestr%_%hh%%mi%_%DATABASE_NAME%.backup
echo backup file name is %BACKUP_FILE%
echo on
bin\pg_dump.exe -i -h %SERVER_IP% -p 5432 -U postgres -F c -b -v -f %BACKUP_FILE% %DATABASE_NAME%


:FFIM