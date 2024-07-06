@echo off
cls

rem REMOVENDO APP WIN10
powershell "Get-AppxPackage *AdobePhotoshopExpress* | Remove-AppxPackage"
powershell "Get-AppxPackage *Eclipse* | Remove-AppxPackage"
powershell "Get-AppxPackage *Duolingo* | Remove-AppxPackage"
powershell "Get-AppxPackage *Netflix* | Remove-AppxPackage"
powershell "Get-AppxPackage *Facebook* | Remove-AppxPackage"
powershell "Get-AppxPackage *Twitter* | Remove-AppxPackage"
powershell "Get-AppxPackage *MicrosoftPowerBIForWindows* | Remove-AppxPackage"
powershell "Get-AppxPackage *Store* | Remove-AppxPackage"
rem powershell "Get-AppxPackage *SkypeApp* | Remove-AppxPackage"
powershell "Get-AppxPackage *Xbox* | Remove-AppxPackage"
powershell "Get-AppxPackage *Bing* | Remove-AppxPackage"
powershell "Get-AppxPackage *Dell* | Remove-AppxPackage"
powershell "Get-AppxPackage *DropBox* | Remove-AppxPackage"
powershell "Get-AppxPackage *Sway* | Remove-AppxPackage"
powershell "Get-AppxPackage *SmartByte* | Remove-AppxPackage"
powershell "Get-AppxPackage *McAfee* | Remove-AppxPackage"
powershell "Get-AppxPackage *Crush* | Remove-AppxPackage"
powershell "Get-AppxPackage *Solitaire* | Remove-AppxPackage"
