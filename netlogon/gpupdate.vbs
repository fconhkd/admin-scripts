'==============================================================================
'by FABIANO CONRADO (fabianoconrado@gmail.com)
'==============================================================================
'
Set WshNetwork = CreateObject("WScript.Network")
Set WshShell = CreateObject("WScript.Shell")
Set objShell = CreateObject("Shell.Application")
ON ERROR RESUME NEXT

'==============================================================================
' Executando comando DOS
'==============================================================================
WshShell.Run "gpupdate /force"