@echo off
cls
rem w32tm /config /manualpeerlist:"0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org",0x4 /syncfromflags:MANUAL
w32tm /config /manualpeerlist:"a.st1.ntp.br b.st1.ntp.br c.st1.ntp.br d.st1.ntp.br gps.ntp.br a.ntp.br b.ntp.br c.ntp.br",0x8 /syncfromflags:MANUAL
net stop w32time
net start w32time
w32tm /resync /rediscover