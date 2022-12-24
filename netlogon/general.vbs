'==============================================================================
'SCRIPT PARA INSTALAR IMPRESSORAS E MAPEAMENTOS DE REDE
'by FABIANO CONRADO (fabianoconrado@gmail.com)
'==============================================================================
Set WshNetwork = CreateObject("WScript.Network")
Set WshShell = CreateObject("WScript.Shell")
Set objShell = CreateObject("Shell.Application")
ON ERROR RESUME NEXT

' Other commands
WshShell.Run "net time \\SERVER /set /y"
'WshShell.Run "WUAUCLT /DetectNow"
'WshShell.Run "gpupdate /force"

'==============================================================================
' Impressoras compartilhadas
'==============================================================================
 'remove impressoras antigas se existir
WshNetwork.RemovePrinterConnection "\\SERVER_old\Financeiro"
 
 'Instala impressoras compartilhadas
 WshNetwork.AddWindowsPrinterConnection "\\SERVER\Financeiro"

' Define a Impressora padrão
 WshNetwork.SetDefaultPrinter "\\SERVER\Financeiro"
'==============================================================================


'==============================================================================
' Mapeando unidades de rede
'==============================================================================
'Remove unidade já mapeada
'WshNetwork.RemoveNetworkDRIVE "G:",true,true
'WshNetwork.MapNetworkDrive "G:", "\\SERVER_old\Publico","true"

'Mapeia unidade de rede e renomeia
WshNetwork.RemoveNetworkDRIVE "H:",true,true
WshNetwork.MapNetworkDrive "H:", "\\SERVER\file$","true"
objShell.NameSpace("H:\").Self.Name = "FILES (Docs)"

'Mapeia pasta particular se existir a pasta
WshNetwork.RemoveNetworkDRIVE "U:",true,true
WshNetwork.MapNetworkDrive "U:", "\\SERVER\User$\" + WshNetwork.UserName,"true"
objShell.NameSpace("U:\").Self.Name = WshNetwork.UserName + (" (Personal)")
'==============================================================================


'==============================================================================
' Outros comandos ou scripts a serem inicializados
'==============================================================================
set wshshell=createobject("wscript.shell")
'wshshell.run "H:\GENERAL\DAY_MSG.pdf"

'other apps include here
'==============================================================================


'==============================================================================
' Abrir mensagem personalisada
'==============================================================================
' Exibir Mensagem
' Titulo da msg
'strTitulo = "Departamento de Informática"  

' Corpo da Mensagem
'strMensagem = _
'"AVISO IMPORTANTE" & vbcrlf & vbcrlf & _
'"Suas Impressoras foram instaladas com sucesso para qualquer alteração" & vbcrlf & _
'"entre em contato com o departamento de TI." & vbcrlf & _
'""  & vbcrlf & _
'""  & vbcrlf & _
'"Tel: 99999-9999"

'msgbox strMensagem, 0 + 64, strTitulo'==============================================================================
'==============================================================================
'==============================================================================