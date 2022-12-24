
Import-Csv myList.csv |
foreach {
    $secpass = Read-Host $($_.employeeID) -AsSecureString    
    $name = "$($_.LastName) $($_.FirstName)"

    New-ADUser -Name $name -SamAccountName $($_.sAMAccountName) `
    -GivenName $($_.givenname) -Surname $($_.sn) `
    -DisplayName $($_.displayName) -UserPrincipalName "$($_.SamAccountName)@domainname.com.br" `
    -AccountPassword $secpass -ChangePasswordAtLogon:$true `
    -Path "OU=MYSUBOU,OU=MYOU,DC=domain,DC=corp" -Enabled:$true `
    -Description $($_.title) `
    -Manager $($_.givenname) -Organization $($_.company) `
    -Company $($_.company) -Department $($_.department) `
    -Title $($_.title) `
    -Office $($_.physicalDeliveryOfficeName) -StreetAddress $($_.streetaddress) `
    -City $($_.physicalDeliveryOfficeName) `
    -Country "BR" -OfficePhone $($_.telephoneNumber) `
    -HomePhone $($_.telephoneNumber) -MobilePhone $($_.telephoneNumber) `
    -ScriptPath "script.vbs"
}