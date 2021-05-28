//criar uma senha segura no powershell, vc digita a senha em seguida
$secpass = Read-Host "Password" -AsSecureString    

//criar um password usando um texto plano
$secpass = ConvertTo-SecureString "123@Mudar" -asPlainText -Force

//mudar a senha do usuario
Set-ADAccountPassword fabianohkd -Reset -NewPassword $secpass

//modificar propriedades em usuários
Set-ADUser fabianohkd -replace @{Mobile="12997872366"}

//ocultar o usuario da lista global do exchange server
set-aduser fabianohkd  -replace @{msExchHideFromAddressLists="TRUE"}