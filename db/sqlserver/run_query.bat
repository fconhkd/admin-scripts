@echo off
cls

Echo run query commands i batch
sqlcmd -S <hostname> -Q <query or procedure here> >> filename.log.txt

rem deprecated
rem osql -E -S <hostname> -i "file.sql" >> filename.log.txt


