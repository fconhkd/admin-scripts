<#
.SYNOPSIS
Set-ADPicture.ps1
Written by Joakim at Jocha AB, http://jocha.se
.DESCRIPTION
Version 1.3 - Updated 2016-02-13
This script downloads and sets the Active Directory profile photograph and sets it as your profile picture in Windows.
Remember to create a defaultuser.jpg in \\domain\netlogon\

2016-02-13 : Slightly adjusted.
2015-11-12 : Added all picture sizes for Windows 10 compatibility.
#>

[CmdletBinding(SupportsShouldProcess=$true)]Param()
function Test-Null($InputObject) { return !([bool]$InputObject) }

# Get sid and photo for current user
$user = ([ADSISearcher]"(&(objectCategory=User)(SAMAccountName=$env:username))").FindOne().Properties
$user_photo = $user.thumbnailphoto
$user_sid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value

# Continue if an image was returned
If ((Test-Null $user_photo) -eq $false) {
    Write-Verbose "Photo exists in Active Directory."
}
# If no image was found in profile, use one from network share.
Else {
    Write-Verbose "No photo found in Active Directory for $env:username, using the default image instead"
    $user_photo = [byte[]](Get-Content "\\$env:USERDNSDOMAIN\NETLOGON\icon\defaultuser.jpg" -Encoding byte)
}

# Set up image sizes and base path
$image_sizes = @(32, 40, 48, 96, 192, 200, 240, 448)
$image_mask = "Image{0}.jpg"
$image_base = "C:\ProgramData\AccountPictures"

# Set up registry
$reg_base = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\{0}"
$reg_key = [string]::format($reg_base, $user_sid)
$reg_value_mask = "Image{0}"
If ((Test-Path -Path $reg_key) -eq $false) { New-Item -Path $reg_key } 

# Save images, set reg keys
Try {
    ForEach ($size in $image_sizes) {
        # Create hidden directory, if it doesn't exist
        $dir = $image_base + "\" + $user_sid
        If ((Test-Path -Path $dir) -eq $false) { $(mkdir $dir).Attributes = "Hidden" }

        # Save photo to disk, overwrite existing files
        $file_name = ([string]::format($image_mask, $size))
        $path = $dir + "\" + $file_name
        Write-Verbose "  saving: $file_name"
        $user_photo | Set-Content -Path $path -Encoding Byte -Force

        # Save the path in registry, overwrite existing entries
        $name = [string]::format($reg_value_mask, $size)
        $value = New-ItemProperty -Path $reg_key -Name $name -Value $path -Force
    }
}
Catch {
    Write-Error "Cannot update profile picture for $env:username."
    Write-Error "Check prompt elevation and permissions to files/registry."
}