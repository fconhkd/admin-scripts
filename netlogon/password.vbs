' 
' 
'
On Error Resume Next 
 
Set wshshell = CreateObject("wscript.shell")
 
If WScript.Arguments.Count <> 1 Then 
 WScript.Quit 
End If 
 
Set objNetwork = CreateObject("Wscript.Network") 
strComputer = objNetwork.ComputerName 
wshshell.run "echo strComputer"
 
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2") 
 
Set colAccounts = objWMIService.ExecQuery _ 
    ("Select * From Win32_UserAccount Where Domain = '" & strComputer & "'") 


wshshell.run "echo LINHA 24"
   
For Each objAccount in colAccounts 
    If Left (objAccount.SID, 6) = "S-1-5-" and Right(objAccount.SID, 4) = "-500" Then 
      Set objUser = GetObject("WinNT://" & strComputer & "/" & objAccount.Name & "") 
      objUser.SetPassword WScript.Arguments(0) 
      objUser.SetInfo
    End If 
Next 
 
WScript.Quit