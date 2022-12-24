

Get-ADComputer -Filter * -Properties MS-Mcs-AdmPwd | Where-Object MS-Mcs-AdmPwd -ne $null | Select -ExpandProperty Name | Out-File $Path