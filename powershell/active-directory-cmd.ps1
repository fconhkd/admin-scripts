//obter informações de usuários
Get-ADUser fabianohkd

//obter dados de usuários em tabela
Get-ADUser fabianohkd | Format-Table Enabled,Givenname,ObjectClass,SamAccountName,UserPrincipalName

//listar todos os usuários com um determinado atributo
Get-ADUser -Filter {msExchHideFromAddressLists -eq "TRUE"} | Select-Object UserPrincipalName

//criar uma senha segura no powershell, vc digita a senha em seguida
$secpass = Read-Host "Password" -AsSecureString    

//criar um password usando um texto plano
$secpass = ConvertTo-SecureString "123@Mudar" -AsPlainText -Force

//mudar a senha do usuario
Set-ADAccountPassword fabianohkd -Reset -NewPassword $secpass

//o mesmo de cima em uma unica linha
Set-ADAccountPassword -Identity fabianohkd -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$newPass" -Force)

//modificar propriedades em usuários
Set-ADUser fabianohkd -replace @{Mobile="12988888366"}

//ocultar o usuario da lista global do exchange server
set-aduser fabianohkd  -replace @{msExchHideFromAddressLists="TRUE"}