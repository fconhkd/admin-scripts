

wmic.exe /namespace:\\root\microsoftdfs path DfsrMachineConfig set MaxOfflineTimeInDays=120
REM repadmin /syncall nebucha /edjQSA
repadmin /syncall srvrdc02 /edjQSA
repadmin /syncall dnezzar /edjQSA
repadmin /syncall dellserver /edjQSA
repadmin /syncall michele /edjQSA
REM repadmin /syncall katana /edjQSA