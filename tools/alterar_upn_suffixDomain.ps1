Import-Module ActiveDirectory

#Esse é o antigo sufixo de dominio
$oldSuffix = "domain.corp"

#Esse é o novo sufixo
$newSuffix = "domain.com.br"

#Unidade Organizacional onde faremos as alterações
$OU = "OU=MYOU,DC=domain,DC=corp"

#nome do servidor DC
$server = "nameServer"

Get-ADUser -SearchBase $OU -Filter * | ForEach-Object {
    $newUPN = $_.UserPrincipalName.Replace($oldSuffix,$newSuffix)
    $_ | Set-ADUser -Server $server -UserPrincipalName $newUPN
}