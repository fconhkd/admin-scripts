@echo off
 
set dbUser=USERNAME
set dbPassword=PASSWORD
set backupDir="E:\Backup"
set mysqldump="C:\Program Files\MySQL\MySQL Server 5.0\bin\mysqldump.exe"
set mysqlDataDir="C:\Program Files\MySQL\MySQL Server 5.0\data"
set zip="C:\Program Files\7-Zip\7z.exe"
 
:: get date
for /F "tokens=1-3 delims=/ " %%i in ('date /t') do (
set dd=%%i
set mm=%%j
set yy=%%k
)
 
:: get time
for /F "tokens=1-2 delims=:. " %%i in ('time /t') do (
set hh=%%i
set mi=%%j
)
 
set dirName=%yy%\%mm%\%dd%_%hh%%mi%
 
:: switch to the "data" folder
pushd %mysqlDataDir%
 
:: iterate over the folder structure in the "data" folder to get the databases
for /d %%f in (*) do (
 
if not exist %backupDir%\%dirName%\ (
mkdir %backupDir%\%dirName%
)
 
%mysqldump% --host="localhost" --user=%dbUser% --password=%dbPassword% --single-transaction --add-drop-table --databases %%f > %backupDir%\%dirName%\%%f.sql
 
%zip% a -tgzip %backupDir%\%dirName%\%%f.sql.gz %backupDir%\%dirName%\%%f.sql
 
del %backupDir%\%dirName%\%%f.sql
 
)