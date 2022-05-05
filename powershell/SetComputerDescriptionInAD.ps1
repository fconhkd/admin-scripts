# write information about the computer hardware/model in the Description field in Active Directory
$userLogged = $env:USERNAME
$computer = $env:COMPUTERNAME
$computerinfo= Get-WMIObject Win32_ComputerSystemProduct
$Vendor = $computerinfo.vendor
$Model = $computerinfo.Name
$SerialNumber = $computerinfo.identifyingNumber
$DNSDOMAIN= (Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem).Domain
$ComputerSearcher = New-Object DirectoryServices.DirectorySearcher
$ComputerSearcher.SearchRoot = "LDAP://$("DC=$(($DNSDOMAIN).Replace(".",",DC="))")"
$ComputerSearcher.Filter = "(&(objectCategory=Computer)(CN=$Computer))"
$computerObj = [ADSI]$ComputerSearcher.FindOne().Path
$computerObj.Put( "Description", "$vendor | $Model | $SerialNumber" )
$computerObj.SetInfo()
