echo off
cls

for /f "tokens=1-4 delims=/ " %%i in ("%date%") do (
	set dow=%%l
	set month=%%j
	set day=%%i
	set year=%%k
)

set datestr=%day%-%month%-%year%
echo datestr is %datestr%

rem SET PGPASSWORD=<PassWord>

echo off
set BACKUP_FILE=%datestr%_cartago_fiscal_log.backup
echo backup file name is %BACKUP_FILE%
echo on
bin\pg_dump.exe -i -h estacao011 -p 5432 -U postgres -F c -b -v -f %BACKUP_FILE% cartago_fiscal_log

echo off
set BACKUP_FILE=%datestr%_cartago_fiscal_rdc.backup
echo backup file name is %BACKUP_FILE%
echo on
bin\pg_dump.exe -i -h estacao012 -p 5432 -U postgres -F c -b -v -f %BACKUP_FILE% cartago_fiscal_rdc

echo off
set BACKUP_FILE=%datestr%_cartago_fiscal_drj.backup
echo backup file name is %BACKUP_FILE%
echo on
bin\pg_dump.exe -i -h estacao013 -p 5432 -U postgres -F c -b -v -f %BACKUP_FILE% cartago_fiscal_drj

:FFIM