Enable-BitLocker -MountPoint $env:SystemDrive -EncryptionMethod Aes256 -TpmProtector -SkipHardwareTest
sleep -Seconds 15
Add-BitLockerKeyProtector -MountPoint $env:SystemDrive -RecoveryPasswordProtector