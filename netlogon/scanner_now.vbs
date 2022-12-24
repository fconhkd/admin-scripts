'
'Version Info
'$Id$

'Server Details
'==============
hostName="my-server-ip"
portNo="8088"
accountName="ACCOUNT_NAME"
siteName="Site_NAME"

'********** DO NOT MODIFY ANY CODE BELOW THIS **********
protocol="https"
serviceTag=""
computerName=""
macAddress=""
'Script Mode Details
'===================
isAgentMode=false
silentMode = true
debugmode = false
agentTaskID="NO_AGENT_TASK_ID"
ae_service = "ManageEngine AssetExplorer Agent"
argCount = WScript.Arguments.Count
osVersion = ""
if(argCount>0) Then
    for i=0 to argCount-1
        if( i = 0 And StrComp(WScript.Arguments(i),"-help",1) = 0) Then
            correctUsage
            WScript.quit(0)
        End if
        if ((Not silentMode) And (Not debugmode)) Then  ' Option to run the script either in silent mode or debug mode.
        if (StrComp((WScript.Arguments(i)),"-SilentMode",1) = 0) Then
            silentMode = true
            elseif (StrComp(WScript.Arguments(i),"-debug",1) = 0) Then
                debugmode = true
            end if
        end if

        if (StrComp(WScript.Arguments(i),"-fs",1) = 0) Then
            if (i < argCount-1) And (StrComp(WScript.Arguments(i+1),"-debug",1) <> 0) And (StrComp(WScript.Arguments(i+1),"-SilentMode",1) <> 0) And (StrComp(WScript.Arguments(i+1),"-out",1) <> 0) Then
                filesearch=Wscript.Arguments(i+1)
            else
                correctUsage
                Wscript.quit(0)

            End if
        end if

        if (StrComp(WScript.Arguments(i),"-out",1) = 0) Then
            if (i < argCount-1) And (StrComp(WScript.Arguments(i+1),"-debug",1) <> 0) And (StrComp(WScript.Arguments(i+1),"-SilentMode",1) <> 0) And (StrComp(WScript.Arguments(i+1),"-fs",1) <> 0) Then
                isAgentMode = true
                agentTaskID=WScript.Arguments(i+1)

            else
                correctUsage
                WScript.quit(0)
            End if
        end if

        if (i = 0) Then
            if( (StrComp(WScript.Arguments(i),"-debug",1) <> 0) And (StrComp(WScript.Arguments(i),"-SilentMode",1) <> 0) And (StrComp(WScript.Arguments(i),"-fs",1) <> 0) And (StrComp(WScript.Arguments(i),"-out",1) <> 0))Then
                isAgentMode = true
                agentTaskID=WScript.Arguments(0)
            End if
        end if
    Next
end if

'Save Settings File Configuration
'================================
saveXMLFile=false
computerNameForFile="NO_COMPUTER_NAME"

'XML Version/Encoding Information
'================================
xmlVersion="1.0"
xmlEncoding="UTF-8"

strComputer = "."
Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")

set adobeSoftHavingLicKeys = CreateObject("Scripting.Dictionary")

const HKEY_LOCAL_MACHINE = &H80000002
Const HKEY_CURRENT_USER = &H80000001
const HKEY_USERS = &H80000003
const doubleQuote=""""
const backSlash="\"
newLineConst = VBCrLf
spaceString = " "
equalString = "="
supportMailID="ti@cardexpressbrasil.com.br"
set sqlSoftList = CreateObject("Scripting.Dictionary")

initSQLSoftList
xmlInfoString = "<?xml"
xmlInfoString = addCategoryData(xmlInfoString, "version",xmlVersion)
xmlInfoString = addCategoryData(xmlInfoString, "encoding",xmlEncoding)
xmlInfoString = xmlInfoString & "?>"

outputText = xmlInfoString & newLineConst
outputText = outputText &  "<DocRoot>"

'Adding Agent Scan Key Info
'==========================
if(isAgentMode) Then
    agentTaskInfo  = "<agentTaskInfo  "
    agentTaskInfo  = addCategoryData(agentTaskInfo, "AgentTaskID",agentTaskID)
    agentTaskInfo  = agentTaskInfo & "/>"
    outputText = outputText & agentTaskInfo
end if

'Adding Script Information
'=========================
scriptVersion="5.5"
scriptVersionInfo = "<scriptVersion "
scriptVersionInfo = addCategoryData(scriptVersionInfo, "Version",scriptVersion)
scriptVersionInfo = scriptVersionInfo & "/>"
outputText = outputText & scriptVersionInfo

'Data Fetching Starts
'====================
outputText = outputText & "<Hardware_Info>"
dataText = ""

'Compuer System Info
'===================
dataText = "<Computer "
getDomainName=true

'Get domain name from registry
'------------------------------
On Error Resume Next
Set objReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")

is64BitOS = false
objReg.GetStringValue HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Control\Session Manager\Environment", "PROCESSOR_ARCHITECTURE", osArch
if not isNULL(osArch) then
    pos=InStr(osArch,"64")
    if pos>0 Then
        is64BitOS = true
    End if
End if


query="Select * from Win32_ComputerSystem"
Set queryResult = objWMIService.ExecQuery (query)
For Each iterResult in queryResult
    csdata = ""
    computerNameForFile = LCase(iterResult.Caption & "")
    computerName = computerNameForFile
    'csdata = addCategoryData(csdata, "Name", computerNameForFile)
    manufacturer = iterResult.Manufacturer
    csdata = addCategoryData(csdata, "Manufacturer", manufacturer)
    csdata = addCategoryData(csdata, "PrimaryOwnerName", iterResult.PrimaryOwnerName)
    modelPartNo = iterResult.Model
    csdata = addCategoryData(csdata, "UserName", iterResult.UserName)
    csdata = addCategoryData(csdata, "WorkGroup", iterResult.WorkGroup)
    csdata = addCategoryData(csdata, "TotalPhysicalMemory", iterResult.TotalPhysicalMemory)
    domainName = iterResult.Domain & ""
    if (not ISNULL(domainName) and domainName<>"" )then
    	csdata = addCategoryData(csdata, "DomainName", domainName)
    else
	    domainKeyRoot = "SYSTEM\ControlSet001\Services\Tcpip\parameters\"
	    objReg.GetStringValue HKEY_LOCAL_MACHINE, domainKeyRoot, "Domain", domainName

	    if ISNULL(domainName) then
		    domainName = ""
	    end if
	    csdata = addCategoryData(csdata, "DomainName", domainName)
    end if
    domainRole = iterResult.DomainRole
    csdata = addCategoryData(csdata, "DomainRole", domainRole)
Next

query="Select * from Win32_ComputerSystemProduct"
Set queryResult = objWMIService.ExecQuery (query)
For Each iterResult in queryResult
	model = iterResult.Name
Next

if (StrComp(manufacturer,"LENOVO",1)<>0) then
    csdata = addCategoryData(csdata, "Model", model)
else
   csdata = addCategoryData(csdata, "Model", model&" ("&modelPartNo&")") 
End if

if ((not ISNull(domainName)) and InStr(domainName,".") > 0) then
    computerName = computerName&"."&LCase(domainName)
    computerNameForFile = computerName
End if


query="Select * from Win32_BIOS"
Set queryResult = objWMIService.ExecQuery (query)
For Each iterResult in queryResult
    biosdata = ""
    biosdata = addCategoryData(biosdata, "BiosName", iterResult.Caption)
    biosdata = addCategoryData(biosdata, "BiosVersion", iterResult.Version)
    biosdata = addCategoryData(biosdata, "BiosDate", iterResult.ReleaseDate)
    serviceTag = iterResult.SerialNumber
    biosdata = addCategoryData(biosdata, "ServiceTag", serviceTag)
Next
'dataText = dataText & biosdata

query="select DNSDomain,DNSHostName from Win32_NetworkAdapterConfiguration where DNSDomain!=null AND DNSHostName!=null"
Set queryResult = objWMIService.ExecQuery (query)
dnsDomain= ""
dnsHostName=""
For Each iterResult in queryResult
    dnsdata = ""
    dnsDomain = iterResult.DNSDomain
    dnsHostName = iterResult.DNSHostName
    dnsdata = addCategoryData(dnsdata, "DNSDomain", dnsDomain)
    dnsdata = addCategoryData(dnsdata, "DNSHostName", dnsHostName)
Next

if((InStr(computerName,".") = 0) and (not isNull(dnsDomain)) and (InStr(dnsDomain,".")>0))then
    computerName = computerName&"."&dnsDomain
    computerNameForFile = computerName
end if
nameAttr = addCategoryData("", "Name", computerName)
dataText = dataText & nameAttr & csdata
dataText = dataText & biosdata
dataText = dataText & dnsdata

query="Select MemoryDevices from Win32_PhysicalMemoryArray where Use=3"
Set queryResult = objWMIService.ExecQuery (query)
For Each iterResult in queryResult
    mscount = ""
    mscount = addCategoryData(mscount, "MemorySlotsCount", iterResult.MemoryDevices)
Next
dataText = dataText & mscount

query="Select ChassisTypes from Win32_SystemEnclosure"
Set queryResult = objWMIService.ExecQuery (query)
For Each iterResult in queryResult
    isLaptop=""
    labtopIterator = iterResult.ChassisTypes
    for each laptop in labtopIterator
        isLaptop = laptop
    Next

Next
dataText = addCategoryData(dataText, "isLaptop", isLaptop)
dataText = dataText & "/>"
outputText = outputText & dataText
Err.clear

'Operating System Info
'=====================
On Error Resume Next
    getComputerName=true
    query="select * from Win32_OperatingSystem"
    Set queryResult = objWMIService.ExecQuery (query)
    dataText = "<OperatingSystem "
    For Each iterResult in queryResult
        osdata = ""
        osdata = addCategoryData(osdata, "Name", iterResult.Caption)
        osdata = addCategoryData(osdata, "Version", iterResult.Version)
        osdata = addCategoryData(osdata, "BuildNumber", iterResult.BuildNumber)
        osdata = addCategoryData(osdata, "ServicePackMajorVersion", iterResult.ServicePackMajorVersion)
        osdata = addCategoryData(osdata, "ServicePackMinorVersion", iterResult.ServicePackMinorVersion)
        osdata = addCategoryData(osdata, "SerialNumber", iterResult.SerialNumber)
        osdata = addCategoryData(osdata, "TotalVisibleMemorySize", iterResult.TotalVisibleMemorySize)
        osdata = addCategoryData(osdata, "FreePhysicalMemory", iterResult.FreePhysicalMemory)
        osdata = addCategoryData(osdata, "TotalVirtualMemorySize", iterResult.TotalVirtualMemorySize)
        osdata = addCategoryData(osdata, "FreeVirtualMemory", iterResult.FreeVirtualMemory)
        osArchitecture = iterResult.OSArchitecture
        if (isNULL(osArchitecture) or Trim(osArchitecture)="") then
            if(is64BitOS)then
                osArchitecture = "64-bit"
            else
                osArchitecture = "32-bit"
            end if
        end if
        osdata = addCategoryData(osdata, "OSArchitecture", osArchitecture)
        osVersion = iterResult.Version
    Next
    dataText = dataText & osdata & "/>"
    outputText = outputText & dataText
Err.clear

'CPU Info
'========

Dim procIdList()
On Error Resume Next
    query="Select * from Win32_Processor"
    Set queryResult = objWMIService.ExecQuery (query)
    count = 0
    dataText = "<CPU>"
    For Each iterResult in queryResult
        count = count+1
        dataText = dataText & "<CPU_" & count & " "
        objReg.GetStringValue HKEY_LOCAL_MACHINE, "HARDWARE\DESCRIPTION\System\CentralProcessor\0", "ProcessorNameString", cpuName
        if (not isNULL(cpuName) and cpuName<>"") then
            processorName = cpuName
        else
            processorName = iterResult.Name
        end if
        dataText = addCategoryData(dataText, "CPUName", processorName)
        dataText = addCategoryData(dataText, "CPUSpeed", iterResult.MaxClockSpeed)
        dataText = addCategoryData(dataText, "CPUStepping", iterResult.Stepping)
        dataText = addCategoryData(dataText, "CPUManufacturer", iterResult.Manufacturer)
        dataText = addCategoryData(dataText, "CPUModel", iterResult.Family)
        dataText = addCategoryData(dataText, "CPUSerialNo", iterResult.UniqueId)
        dataText = addCategoryData(dataText, "NumberOfCores", iterResult.NumberOfCores)
        dataText = dataText & "/>"
    Next
    outputText = outputText & dataText & "</CPU>"
Err.clear

'MemoryModule Info
'=================
On Error Resume Next
    query="Select * from Win32_PhysicalMemory"
    Set queryResult = objWMIService.ExecQuery (query)
    dataText = "<MemoryModule>"
    count=0
    For Each iterResult in queryResult
        count=count+1
        dataText = dataText & "<MemoryModule_" & count & " "
        dataText = addCategoryData(dataText, "Name", iterResult.Tag)
        dataText = addCategoryData(dataText, "Capacity", iterResult.Capacity)
        dataText = addCategoryData(dataText, "BankLabel", iterResult.BankLabel)
        dataText = addCategoryData(dataText, "DeviceLocator", iterResult.DeviceLocator)
        dataText = addCategoryData(dataText, "MemoryType", iterResult.MemoryType)
        dataText = addCategoryData(dataText, "TypeDetail", iterResult.TypeDetail)
        dataText = addCategoryData(dataText, "Speed", iterResult.Speed)
        dataText = dataText & "/>"
    Next
    dataText = dataText & "</MemoryModule>"
    outputText = outputText & dataText
Err.clear


'HardDisc Info
'=============
On Error Resume Next
    query="Select * from Win32_DiskDrive"
    Set queryResult = objWMIService.ExecQuery (query)
    dataText = "<HardDisk>"
    count=0
    For Each iterResult in queryResult
        count=count+1
        dataText = dataText & "<HardDisk_" & count & " "
        dataText = addCategoryData(dataText, "HDName", iterResult.Caption)
        dataText = addCategoryData(dataText, "HDModel", iterResult.Model)
        dataText = addCategoryData(dataText, "HDSize", iterResult.Size)
        HDSerialNumberId = iterResult.DeviceID
        HDSerialNumberId = Replace(HDSerialNumberId,"\","\\")
        query="Select SerialNumber from  CIM_PhysicalMedia where Tag = " & doubleQuote & HDSerialNumberId & doubleQuote
        Set queryResultForSN = objWMIService.ExecQuery (query)
        For Each iterResultSN in queryResultForSN
            serialNo = iterResultSN.SerialNumber
        Next
        if not ISNULL(serialNo) And serialNo<>"" then
            dataText = addCategoryData(dataText, "HDSerialNumber", serialNo)
        else
            dataText = addCategoryData(dataText, "HDSerialNumber", "HardDiskSerialNumber")
        End if
        dataText = addCategoryData(dataText, "HDDescription", iterResult.Description)
        dataText = addCategoryData(dataText, "HDManufacturer", iterResult.Manufacturer)
        dataText = addCategoryData(dataText, "TotalCylinders", iterResult.TotalCylinders)
        dataText = addCategoryData(dataText, "BytesPerSector", iterResult.BytesPerSector)
        dataText = addCategoryData(dataText, "SectorsPerTrack", iterResult.SectorsPerTrack)
        dataText = dataText & "/>"
    Next
    dataText = dataText & "</HardDisk>"
    outputText = outputText & dataText
Err.clear

'LogicalDisk Info
'================
On Error Resume Next
    query="Select * from Win32_LogicalDisk"
    Set queryResult = objWMIService.ExecQuery (query)
    dataText = "<LogicDrive>"
    count=0
    For Each iterResult in queryResult
        count=count+1
        dataText = dataText & "<LogicDrive_" & count & " "
        dataText = addCategoryData(dataText, "Name", iterResult.Caption)
        dataText = addCategoryData(dataText, "Description", iterResult.Description)
        discType = getDiskType(iterResult.DriveType)
        dataText = addCategoryData(dataText, "Type", discType)
        dataText = addCategoryData(dataText, "Size", iterResult.Size)
        dataText = addCategoryData(dataText, "FreeSpace", iterResult.FreeSpace)
        dataText = addCategoryData(dataText, "SerialNumber", iterResult.VolumeSerialNumber)
        dataText = addCategoryData(dataText, "FileSystem", iterResult.FileSystem)
        dataText = dataText & "/>"
    Next
    dataText = dataText & "</LogicDrive>"
    outputText = outputText & dataText
Err.clear

'PhysicalDrive Info
'==================
On Error Resume Next
    count=0
    query="Select * from CIM_MediaAccessDevice"
    Set queryResult = objWMIService.ExecQuery (query)
    dataText = "<PhysicalDrive>"
    For Each iterResult in queryResult
        count=count+1
        dataText = dataText & "<PhysicalDrive_" & count & " "
        dataText = addCategoryData(dataText, "Name", iterResult.Caption)
        dataText = addCategoryData(dataText, "Description", iterResult.Description)
        'dataText = addCategoryData(dataText, "Manufacturer", iterResult.Manufacturer)
        dataText = dataText & "/>"
    Next
    dataText = dataText & "</PhysicalDrive>"
    outputText = outputText & dataText
Err.clear



'KeyBoard Info
'=============
On Error Resume Next
    query="Select * from Win32_KeyBoard"
    Set queryResult = objWMIService.ExecQuery (query)
    dataText = ""
    For Each iterResult in queryResult
        dataText = "" 'In dll the final iteration only added...
        dataText = dataText & "<KeyBoard "
        dataText = addCategoryData(dataText, "Name", iterResult.Caption)
        dataText = dataText & "/>"
    Next
    outputText = outputText & dataText
Err.clear

'Mouse Info
'===========
On Error Resume Next
    query="Select * from Win32_PointingDevice"
    Set queryResult = objWMIService.ExecQuery (query)
    dataText = ""
    For Each iterResult in queryResult
        dataText = "" 'In dll the final iteration only added...
        dataText = dataText & "<Mouse "
        dataText = addCategoryData(dataText, "Name", iterResult.Name)
        dataText = addCategoryData(dataText, "ButtonsCount", iterResult.NumberOfButtons)
        dataText = addCategoryData(dataText, "Manufacturer", iterResult.Manufacturer)
        dataText = dataText & "/>"
    Next
    outputText = outputText & dataText
Err.clear


'Monitor Info
'============
Dim sMultiStrings()
On Error Resume Next
    query="Select * from Win32_DesktopMonitor where PNPDeviceID != NULL"
    Set queryResult = objWMIService.ExecQuery (query)
    dataText = ""
    For Each iterResult in queryResult
        dataText = "" 'In dll the final iteration only added...
        dataText = dataText & "<Monitor "
        dataText = addCategoryData(dataText, "Name", iterResult.Name)
        dataText = addCategoryData(dataText, "DisplayType", iterResult.DisplayType)
        dataText = addCategoryData(dataText, "MonitorType", iterResult.MonitorType)
        dataText = addCategoryData(dataText, "Manufacturer", iterResult.MonitorManufacturer)
        dataText = addCategoryData(dataText, "Height", iterResult.ScreenHeight)
        dataText = addCategoryData(dataText, "Width", iterResult.ScreenWidth)
        dataText = addCategoryData(dataText, "XPixels", iterResult.PixelsPerXLogicalInch)
        dataText = addCategoryData(dataText, "YPixels", iterResult.PixelsPerYLogicalInch)
        'Getting monitor serial number from registry.
        pnpDeviceId = iterResult.PNPDeviceID
        subKey = "SYSTEM\CurrentControlSet\Enum\" & pnpDeviceId & "\Device Parameters"
        objReg.GetBinaryValue HKEY_LOCAL_MACHINE, subKey, "EDID", EDID
        serialNumber = GetMonitorSerialNumber(EDID)
        dataText = addCategoryData(dataText, "SerialNumber", serialNumber)
        dataText = dataText & "/>"
    Next
    outputText = outputText & dataText
Err.clear

'Network Info
'=============
On Error Resume Next
    query="Select * from Win32_NetworkAdapterConfiguration where IPEnabled = True"
    Set queryResult = objWMIService.ExecQuery (query)
    dataText = "<Network>"
    count=0
    For Each iterResult in queryResult
        count=count+1
        dataText = dataText & "<Network_" & count & " "
        'To Remove the NIC Index from the NIC Caption
        nwCaption = getNetworkCaption(iterResult.Caption)
        dataText = addCategoryData(dataText, "Name", nwCaption)
        dataText = addCategoryData(dataText, "Index", iterResult.Index)
        macAddress = macAddress & iterResult.MACAddress & "###"
        dataText = addCategoryData(dataText, "MACAddress", iterResult.MACAddress)
        dataText = addCategoryData(dataText, "DNSDomain", iterResult.DNSDomain)
        dataText = addCategoryData(dataText, "DNSHostName", iterResult.DNSHostName)
        dataText = addCategoryData(dataText, "DHCPEnabled", iterResult.DHCPEnabled)
        dataText = addCategoryData(dataText, "DHCPLeaseObtained", iterResult.DHCPLeaseObtained)
        dataText = addCategoryData(dataText, "DHCPLeaseExpires", iterResult.DHCPLeaseExpires)
        dataText = addCategoryData(dataText, "DHCPServer", iterResult.DHCPServer)
        ipIterator = iterResult.IPAddress
        ipAddress=""
        for each ipaddr in ipIterator
            if (ipAddress <> "") then
                ipAddress = ipAddress & "-" & ipaddr
            else
                ipAddress = ipaddr
            end if
        Next
        dataText = addCategoryData(dataText, "IpAddress", ipAddress)
        ipIterator = iterResult.DefaultIPGateway
        ipAddress=""
        for each ipaddr in ipIterator
            if (ipAddress <> "") then
                ipAddress = ipAddress & "-" & ipaddr
            else
                ipAddress = ipaddr
            end if
        Next
        dataText = addCategoryData(dataText, "Gateway", ipAddress)
        ipIterator = iterResult.DNSServerSearchOrder
        ipAddress=""
        for each ipaddr in ipIterator
            if (ipAddress <> "") then
                ipAddress = ipAddress & "-" & ipaddr
            else
                ipAddress = ipaddr
            end if
        Next
        dataText = addCategoryData(dataText, "DnsServer", ipAddress)
        ipIterator = iterResult.IPSubnet
        ipAddress=""
        for each ipaddr in ipIterator
            if (ipAddress <> "") then
                ipAddress = ipAddress & "-" & ipaddr
            else
                ipAddress = ipaddr
            end if
        Next
        dataText = addCategoryData(dataText, "Subnet", ipAddress)
        dataText = dataText & "/>"
    Next
    dataText = dataText & "</Network>"
    outputText = outputText & dataText
Err.clear

'SoundCard Info
'============
On Error Resume Next
    query="Select * from Win32_SoundDevice"
    Set queryResult = objWMIService.ExecQuery (query)
    dataText = ""
    For Each iterResult in queryResult
        dataText = "" 'In dll the final iteration only added...
        dataText = dataText & "<SoundCard "
        dataText = addCategoryData(dataText, "SoundCardName", iterResult.Caption)
        dataText = addCategoryData(dataText, "SoundCardManufacturer", iterResult.Manufacturer)
        dataText = dataText & "/>"
    Next
    outputText = outputText & dataText
Err.clear

'VideoCard Info
'==================
On Error Resume Next
    query="Select * from Win32_VideoController where Availability!=8"
    Set queryResult = objWMIService.ExecQuery (query)
    dataText = "<VideoCard>"
    count=0
    For Each iterResult in queryResult
        count=count+1
        dataText = dataText & "<VideoCard_" & count & " "
        dataText = addCategoryData(dataText, "VideoCardName", iterResult.Caption)
        dataText = addCategoryData(dataText, "VideoCardChipset", iterResult.VideoProcessor)
        dataText = addCategoryData(dataText, "VideoCardMemory", iterResult.AdapterRAM)
        dataText = dataText & "/>"
    Next

    dataText = dataText & "</VideoCard>"
    outputText = outputText & dataText
Err.clear

'SerialPort Info
'==================
On Error Resume Next
    query="Select * from Win32_SerialPort"
    Set queryResult = objWMIService.ExecQuery (query)
    dataText = "<SerialPort>"
    count=0
    For Each iterResult in queryResult
        count=count+1
        dataText = dataText & "<SerialPort_" & count & " "
        dataText = addCategoryData(dataText, "Name", iterResult.Caption)
        dataText = addCategoryData(dataText, "BaudRate", iterResult.MaxBaudRate)
        dataText = addCategoryData(dataText, "Status", iterResult.Status)
        dataText = dataText & "/>"
    Next
    dataText = dataText & "</SerialPort>"
    outputText = outputText & dataText
Err.clear

'ParallelPort Info
'==================
On Error Resume Next
    query="Select * from Win32_ParallelPort"
    Set queryResult = objWMIService.ExecQuery (query)
    dataText = "<ParallelPort>"
    count=0
    For Each iterResult in queryResult
        count=count+1
        dataText = dataText & "<ParallelPort_" & count & " "
        dataText = addCategoryData(dataText, "Name", iterResult.Caption)
        dataText = addCategoryData(dataText, "Status", iterResult.Status)
        dataText = dataText & "/>"
    Next
    dataText = dataText & "</ParallelPort>"
    outputText = outputText & dataText
Err.clear

'USB Info
'========
On Error Resume Next
    query="Select * from Win32_USBController"
    Set queryResult = objWMIService.ExecQuery (query)
    dataText = "<USB>"
    count=0
    For Each iterResult in queryResult
        count=count+1
        dataText = dataText & "<USB_" & count & " "
        dataText = addCategoryData(dataText, "Name", iterResult.Caption)
        dataText = addCategoryData(dataText, "Manufacturer", iterResult.Manufacturer)
        dataText = dataText & "/>"
    Next
    dataText = dataText & "</USB>"
    outputText = outputText & dataText
Err.clear



'Printer Info
'=================
On Error Resume Next
    set printersList = CreateObject("Scripting.Dictionary")
    dataText = "<Printer>"
    count=0
    query="Select * from Win32_Printer Where Network=False"
    Set queryResult = objWMIService.ExecQuery (query)
    For Each iterResult in queryResult
        printerName = iterResult.Caption
        if(Not printersList.Exists(printerName))then
            count=count+1
            printersList.add printerName,count
            On Error Resume Next
            dataText = dataText & "<Printer_" & count & " "
            dataText = addCategoryData(dataText, "Name", printerName)
            dataText = addCategoryData(dataText, "Model", iterResult.DriverName)
            dataText = addCategoryData(dataText, "Default", iterResult.Default)
            dataText = addCategoryData(dataText, "Network", iterResult.Network)
            dataText = addCategoryData(dataText, "Local", iterResult.Local)
            dataText = addCategoryData(dataText, "PortName", iterResult.PortName)
            dataText = addCategoryData(dataText, "Location", iterResult.Location)
            dataText = addCategoryData(dataText, "Comment", iterResult.Comment)
            dataText = addCategoryData(dataText, "ServerName", iterResult.ServerName)
            Err.clear
            dataText = dataText & "/>"
        end if
    Next

    query="Select * from Win32_Printer Where Network=True"
    Set queryResult = objWMIService.ExecQuery (query)
    For Each iterResult in queryResult
        printerName = iterResult.Caption
        if(Not printersList.Exists(printerName))then
            count=count+1
            printersList.add printerName,count
            On Error Resume Next
            dataText = dataText & "<Printer_" & count & " "
            dataText = addCategoryData(dataText, "Name", printerName)
            dataText = addCategoryData(dataText, "Model", iterResult.DriverName)
            dataText = addCategoryData(dataText, "Default", iterResult.Default)
            dataText = addCategoryData(dataText, "Network", iterResult.Network)
            dataText = addCategoryData(dataText, "Local", iterResult.Local)
            dataText = addCategoryData(dataText, "PortName", iterResult.PortName)
            dataText = addCategoryData(dataText, "Location", iterResult.Location)
            dataText = addCategoryData(dataText, "Comment", iterResult.Comment)
            dataText = addCategoryData(dataText, "ServerName", iterResult.ServerName)
            Err.clear
            dataText = dataText & "/>"
        end if
    Next
    if(queryResult.Count = 0) then
        dataText = getPrinterInfo(dataText,count)
    End if
    dataText = dataText & "</Printer>"
    outputText = outputText & dataText
Err.clear

'HotFix Info
'===========
On Error Resume Next
    if(isVistaAndAbove)then
	    query="Select * from Win32_QuickFixEngineering where caption!=''" ' where condition added to avoid some unknown hotfix.(i.e) In vista machine, it results a key but could not get actual hotfix name.
	    Set queryResult = objWMIService.ExecQuery (query)
	    dataText = "<HotFix>"
	    count=0
	    For Each iterResult in queryResult
		    count=count+1
		    dataText = dataText & "<HotFix_" & count & " "
		    dataText = addCategoryData(dataText, "HotFixID", iterResult.HotFixID)
		    'dataText = addCategoryData(dataText, "InstalledBy", iterResult.InstalledBy)
		    'dataText = addCategoryData(dataText, "InstalledOn", iterResult.InstalledOn)
		    dataText = addCategoryData(dataText, "Description", iterResult.Description)
		    dataText = dataText & "/>"
	    Next
	    dataText = dataText & "</HotFix>"
    else
	    query="Select * from Win32_QuickFixEngineering where FixComments!=''"
	    Set queryResult = objWMIService.ExecQuery (query)
	    dataText = "<HotFix>"
	    count=0
	    For Each iterResult in queryResult
		    count=count+1
		    dataText = dataText & "<HotFix_" & count & " "
		    dataText = addCategoryData(dataText, "HotFixID", iterResult.HotFixID)
		    dataText = addCategoryData(dataText, "InstalledBy", iterResult.InstalledBy)
		    dataText = addCategoryData(dataText, "InstalledOn", iterResult.InstalledOn)
		    dataText = addCategoryData(dataText, "Description", iterResult.Description)
		    dataText = dataText & "/>"
	    Next
	    dataText = dataText & "</HotFix>"
    end if
    outputText = outputText & dataText
Err.clear

'Users account details
'=====================
'do not fetch users from AD
if(not(domainRole=4 or domainRole=5))then ' if not AD
On Error Resume Next
    query="Select PartComponent from Win32_SystemUsers"
    Set queryResult = objWMIService.ExecQuery (query)
    dataText = "<UsersAccount>"
    count=0
    For Each iterResult in queryResult
        Set accountDetails = objWMIService.Get(iterResult.PartComponent)
        count=count+1
        dataText = dataText & "<UsersAccount_" & count & " "
        dataText = addCategoryData(dataText, "Name", accountDetails.Name)
        dataText = addCategoryData(dataText, "Domain", accountDetails.Domain)
        dataText = addCategoryData(dataText, "FullName", accountDetails.FullName)
        dataText = addCategoryData(dataText, "Description", accountDetails.Description)
        dataText = addCategoryData(dataText, "LocalAccount", accountDetails.LocalAccount)
        dataText = addCategoryData(dataText, "Status", accountDetails.Status)
        dataText = addCategoryData(dataText, "SID", accountDetails.SID)
        dataText = dataText & "/>"
    Next
    dataText = dataText & "</UsersAccount>"
    outputText = outputText & dataText
Err.clear
end if
outputText = outputText & "</Hardware_Info>"

'Microsoft Keys
'=================
On Error Resume Next
outputText = outputText & "<Software_Info>"
set licenseKeys = CreateObject("Scripting.Dictionary")

licenseDataText = licenseDataText & "<MicrosoftOfficeKeys>"
count=0
strKeyPath = "SOFTWARE\Microsoft\Office"
for itr=1 to 2
    continue = true
    Set objCtx = CreateObject("WbemScripting.SWbemNamedValueSet")
    if(itr=2) then
        objCtx.Add "__ProviderArchitecture", 32
    elseif (is64BitOS) then
        objCtx.Add "__ProviderArchitecture", 64
    else
        continue = false
    end if
    objCtx.Add "__RequiredArchitecture", TRUE
    if(continue)then
        Set objLocator = CreateObject("Wbemscripting.SWbemLocator")
        Set objServices = objLocator.ConnectServer("localhost","root\default","","",,,,objCtx)
        Set objReg1 = objServices.Get("StdRegProv")
        objReg1.EnumKey HKEY_LOCAL_MACHINE, strKeyPath, arrSubKeys
        If NOT ISNULL(arrSubKeys) then
            For Each subkey In arrSubKeys
                subkeyPath = strKeyPath & "\" & subkey & "\Registration"
                objReg1.EnumKey HKEY_LOCAL_MACHINE, subkeyPath, productSubKeys
                If NOT ISNULL(productSubKeys) then
                    For Each productsubkey In productSubKeys
                        count=count+1
                        licenseDataText = licenseDataText & "<Key_" & count & " "
                        licenseDataText = addCategoryData(licenseDataText, "Key", productsubkey)
                        productsubkeyPath = subkeyPath & "\" &  productsubkey
                        objReg1.GetStringValue HKEY_LOCAL_MACHINE, productsubkeyPath, "ProductID", productId
                        objReg1.GetBinaryValue HKEY_LOCAL_MACHINE, productsubkeyPath, "DigitalProductID", productKey
                        if NOT ISNULL(productId) then
                            licenseDataText = addCategoryData(licenseDataText, "ProductID", productId)
                        end if
                        if NOT ISNULL(productKey) then
                            key = getLicenceKey(productKey,subkey)
                            if (NOT ISNULL(key) and key<>"") then
                                licenseDataText = addCategoryData(licenseDataText, "ProductKey", key)
                                licenseKeys.add productsubkey,key
                            end if
                        end if
                        licenseDataText = licenseDataText &  " />"
                    Next
                end if
            Next
        end if
    end if
Next
licenseDataText = licenseDataText & "</MicrosoftOfficeKeys>"
Err.clear

'Windows Key
'===========
On Error Resume Next
licenseDataText = licenseDataText & "<WindowsKey "
windowsKeyRoot = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\"
count=0
strKeyPath = "SOFTWARE\Microsoft\Office"
for itr=1 to 2
	continue = true
	Set objCtx = CreateObject("WbemScripting.SWbemNamedValueSet")
	if(itr=2) then
		objCtx.Add "__ProviderArchitecture", 32
	elseif (is64BitOS) then
		objCtx.Add "__ProviderArchitecture", 64
	else
		continue = false
	end if
	objCtx.Add "__RequiredArchitecture", TRUE
	if(continue)then
		Set objLocator = CreateObject("Wbemscripting.SWbemLocator")
		Set objServices = objLocator.ConnectServer("localhost","root\default","","",,,,objCtx)
		Set objReg1 = objServices.Get("StdRegProv") 
		objReg1.GetStringValue HKEY_LOCAL_MACHINE, windowsKeyRoot, "ProductID", windowsId
		if not ISNULL(windowsId) then
			licenseDataText = addCategoryData(licenseDataText, "ProductID", windowsId)
		end if
		objReg1.GetBinaryValue HKEY_LOCAL_MACHINE, windowsKeyRoot, "DigitalProductID", windowsKeyData
		if not ISNULL(windowsKeyData)then
			windowsKey = getLicenceKey(windowsKeyData,null)
			licenseDataText = addCategoryData(licenseDataText, "ProductKey", windowsKey)
		end if
	end if
Next
licenseDataText = licenseDataText & "/>"
Err.clear
outputText = outputText & licenseDataText
'SoftwareList Info
'=================
On Error Resume Next

softwareDataText = softwareDataText & "<InstalledProgramsList>"
strComputer = "."
set softList = CreateObject("Scripting.Dictionary")

Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
strKeyPath = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
objReg.EnumKey HKEY_LOCAL_MACHINE, strKeyPath, arrSubKeys
count=0

set autodeskSoftLicKeys = CreateObject("Scripting.Dictionary")
autodeskProductSuiteSerialNumber = ""
setAutodeskLicenses objReg

'Softwares installed under different users
'=========================================
objReg.EnumKey HKEY_LOCAL_MACHINE, "SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList",profileSIDs

If NOT ISNULL(profileSIDs) then
    For Each profileSID In profileSIDs
        objReg.EnumKey HKEY_USERS, profileSID&"\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",arrSubKeys
        If NOT ISNULL(arrSubKeys) then
            For Each subkey In arrSubKeys
		licenseKey=""
                isAddSoftware = true
                subkeyPath = profileSID&"\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"& subkey
                objReg.GetStringValue HKEY_USERS, subkeyPath, "DisplayName", softwareName
                objReg.GetStringValue HKEY_USERS, subkeyPath, "ParentKeyName", parentKeyName
                objReg.GetStringValue HKEY_USERS, subkeyPath, "DisplayVersion", softwareVersion
                objReg.GetStringValue HKEY_USERS, subkeyPath, "Publisher", softwarePublisher
                objReg.GetStringValue HKEY_USERS, subkeyPath, "InstallLocation", softwareLocation
                objReg.GetStringValue HKEY_USERS, subkeyPath, "InstallDate", softwareInstallDate
                keyForSoftwareUsage = "SOFTWARE\Microsoft\Windows\CurrentVersion\App Management\ARPCache\" & subkey
                objReg.GetBinaryValue HKEY_USERS, keyForSoftwareUsage, "SlowInfoCache", usageData
                swUsage = getSoftwareUsage(usageData)
                If (NOT ISNULL(softwareName) And (ISNULL(parentKeyName) OR parentKeyName="" ))then
                    if(softwareName <> "" and (not softList.Exists(softwareName) or licenseKeys.Exists(subkey))) then
                        if ((InStr(Lcase(softwareName),"adobe") > 0) or (InStr(Lcase(softwareName),"acrobat") > 0)) then
                            licenseKey = getAdobeLicenseKey(objReg,subkeyPath,softwareName)
                            objReg.GetDWORDValue HKEY_USERS, subkeyPath, "SystemComponent", systemComponent
                            systemComponent=""&systemComponent
                            if (licenseKey="" and systemComponent="1") then
                                isAddSoftware = false
                            else
                                if (licenseKey="") then
                                    tmpCheck = adobeSoftHavingLicKeys.Item(softwareName)
                                    if((Not isNULL(tmpCheck)) and (tmpCheck<>""))then
                                        isAddSoftware = false
                                    End if
                                end if
                            End if
                            if ((licenseKey<> "") and (Not adobeSoftHavingLicKeys.Exists(softwareName)))then
                                adobeSoftHavingLicKeys.add softwareName,licenseKey
                            end if
		    	elseif(autodeskSoftLicKeys.Exists(softwareName)) then
			    licenseKey = autodeskSoftLicKeys.Item(softwareName)
		    	elseif ((InStr(Lcase(softwareName),"autocad") > 0) or (InStr(Lcase(softwareName),"autodesk") > 0)) then
			    if (InStr(Lcase(softwareName),"suite")) > 0 Then 
				    licenseKey = autodeskProductSuiteSerialNumber
			    End If
                        elseif (isSQL(softwareName))then
			    softList.add softwareName,count
                            softwareName = updateSQLEdition(softwareName,HKEY_USERS,profileSID&"\SOFTWARE\Microsoft",objReg)
                        End if
                        if(isAddSoftware=true) then
                            count=count+1
                            softList.add softwareName,count
                            softwareDataText = softwareDataText & "<Software_" & count & " "
                            softwareDataText = addCategoryData(softwareDataText, "Name", softwareName)
                            softwareDataText = addCategoryData(softwareDataText, "Version", softwareVersion)
                            softwareDataText = addCategoryData(softwareDataText, "Vendor", softwarePublisher)
                            softwareDataText = addCategoryData(softwareDataText, "Location", softwareLocation)
                            softwareDataText = addCategoryData(softwareDataText, "InstallDate", softwareInstallDate)
                            softwareDataText = addCategoryData(softwareDataText, "Usage", swUsage)
                            if(licenseKey<>"" and StrComp(licenseKey,"-")<>0)then
                                softwareDataText = addCategoryData(softwareDataText, "ProductKey", licenseKey)
                            end if
                            softwareDataText = addCategoryData(softwareDataText, "Key", subkey)
                            softwareDataText = softwareDataText &  "/>"
                        End if
                    end if
                end if

            Next
        end if
    Next
End if

'Softwares installed
'===================
is64BitOS = false
objReg.GetStringValue HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Control\Session Manager\Environment", "PROCESSOR_ARCHITECTURE", osArch
if not isNULL(osArch) then
    pos=InStr(osArch,"64")
    if pos>0 Then
        is64BitOS = true
    End if
End if

for itr=1 to 2
    continue = true
    Set objCtx = CreateObject("WbemScripting.SWbemNamedValueSet")
    if(itr=2) then
        objCtx.Add "__ProviderArchitecture", 32
    elseif (is64BitOS) then
        objCtx.Add "__ProviderArchitecture", 64
    else
        continue = false
    end if
    objCtx.Add "__RequiredArchitecture", TRUE
    if(continue)then
        Set objLocator = CreateObject("Wbemscripting.SWbemLocator")
        Set objServices = objLocator.ConnectServer("localhost","root\default","","",,,,objCtx)
        Set objReg1 = objServices.Get("StdRegProv")
        objReg1.EnumKey HKEY_LOCAL_MACHINE, strKeyPath, arrSubKeys

        If NOT ISNULL(arrSubKeys) then
            For Each subkey In arrSubKeys
                licenseKey=""
		isAddSoftware = true
                subkeyPath = strKeyPath & "\" & subkey
                objReg1.GetStringValue HKEY_LOCAL_MACHINE, subkeyPath, "DisplayName", softwareName
                objReg1.GetStringValue HKEY_LOCAL_MACHINE, subkeyPath, "ParentKeyName", parentKeyName
                objReg1.GetStringValue HKEY_LOCAL_MACHINE, subkeyPath, "DisplayVersion", softwareVersion
                objReg1.GetStringValue HKEY_LOCAL_MACHINE, subkeyPath, "Publisher", softwarePublisher
                objReg1.GetStringValue HKEY_LOCAL_MACHINE, subkeyPath, "InstallLocation", softwareLocation
                objReg1.GetStringValue HKEY_LOCAL_MACHINE, subkeyPath, "InstallDate", softwareInstallDate
                keyForSoftwareUsage = "SOFTWARE\Microsoft\Windows\CurrentVersion\App Management\ARPCache\" & subkey
                objReg1.GetBinaryValue HKEY_LOCAL_MACHINE, keyForSoftwareUsage, "SlowInfoCache", usageData
                swUsage = getSoftwareUsage(usageData)
                If (NOT ISNULL(softwareName) And (ISNULL(parentKeyName) OR parentKeyName="" ))then
                    if(softwareName <> "" and (not softList.Exists(softwareName) or licenseKeys.Exists(subkey))) then
                        if ((InStr(Lcase(softwareName),"adobe") > 0) or (InStr(Lcase(softwareName),"acrobat") > 0)) then
                            licenseKey = getAdobeLicenseKey(objReg,subkeyPath,softwareName)
                            objReg.GetDWORDValue HKEY_LOCAL_MACHINE, subkeyPath, "SystemComponent", systemComponent
                            systemComponent=""&systemComponent
                            if (licenseKey="" and systemComponent="1") then
                                isAddSoftware = false
                            else
                                if (licenseKey="") then
                                    tmpCheck = adobeSoftHavingLicKeys.Item(softwareName)
                                    if((Not isNULL(tmpCheck)) and (tmpCheck<>""))then
                                        isAddSoftware = false
                                    End if
                                end if
                            End if
                            if ((licenseKey<> "") and (Not adobeSoftHavingLicKeys.Exists(softwareName)))then
                                adobeSoftHavingLicKeys.add softwareName,licenseKey
                            end if
		    	elseif(autodeskSoftLicKeys.Exists(softwareName)) then
			    licenseKey = autodeskSoftLicKeys.Item(softwareName)
		    	elseif ((InStr(Lcase(softwareName),"autocad") > 0) or (InStr(Lcase(softwareName),"autodesk") > 0)) then
			    if (InStr(Lcase(softwareName),"suite")) > 0 Then 
				    licenseKey = autodeskProductSuiteSerialNumber
			    End If
		    	elseif (isSQL(softwareName))then
			    softList.add softwareName,count
                            softwareName = updateSQLEdition(softwareName,HKEY_LOCAL_MACHINE,"SOFTWARE\Microsoft",objReg1)
                        End if
                        if(isAddSoftware=true) then
                            count=count+1
                            softList.add softwareName,count
                            softwareDataText = softwareDataText & "<Software_" & count & " "
                            softwareDataText = addCategoryData(softwareDataText, "Name", softwareName)
                            softwareDataText = addCategoryData(softwareDataText, "Version", softwareVersion)
                            softwareDataText = addCategoryData(softwareDataText, "Vendor", softwarePublisher)
                            softwareDataText = addCategoryData(softwareDataText, "Location", softwareLocation)
                            softwareDataText = addCategoryData(softwareDataText, "InstallDate", softwareInstallDate)
                            softwareDataText = addCategoryData(softwareDataText, "Usage", swUsage)
                            if(licenseKey<>"" and StrComp(licenseKey,"-")<>0)then
                                softwareDataText = addCategoryData(softwareDataText, "ProductKey", licenseKey)
                            end if
                            softwareDataText = addCategoryData(softwareDataText, "Key", subkey)
                            softwareDataText = softwareDataText &  "/>"
                        End if
                    end if
                end if
            Next
        end if
    end if
Next

Err.clear

Set objCtx = CreateObject("WbemScripting.SWbemNamedValueSet")
objCtx.Add "__ProviderArchitecture", 32
objCtx.Add "__RequiredArchitecture", TRUE
Set objLocator = CreateObject("Wbemscripting.SWbemLocator")
Set objServices = objLocator.ConnectServer("localhost","root\default","","",,,,objCtx)
Set objReg1 = objServices.Get("StdRegProv")

'Enumerate IE in vista and later OS
'==================================

objReg.GetStringValue HKEY_LOCAL_MACHINE, "SOFTWARE\Microsoft\Internet Explorer\", "Version", ieVersion
if not isNULL(ieVersion) then
    idx = InStr(ieVersion,".")
    If(idx>0) Then
        ieMajorVersion = Trim(Left(ieVersion,idx-1))
        softwareName = "Windows Internet Explorer "&ieMajorVersion
    End If
    if(softwareName <> "" and (not softList.Exists(softwareName))) then
        count=count+1
        softList.add softwareName,count
        softwareDataText = softwareDataText & "<Software_" & count & " "
        softwareDataText = addCategoryData(softwareDataText, "Name", softwareName)
        softwareDataText = addCategoryData(softwareDataText, "Version", ieVersion)
        softwareDataText = softwareDataText &  "/>"
    End if
End  if

'file search
'===========
On Error Resume Next
if(not isNULL(filesearch) and filesearch <> "") then

    ext = stringTokenizer(filesearch,",")
    extCount = UBound(ext)

    for i=0 to extCount-1

        query="Select * from CIM_DataFile where Extension = '"&ext(i) & "'"

        Set queryResult = objWMIService.ExecQuery (query)

        For Each iterResult in queryResult
            softwareName = Mid(iterResult.Name,InStrRev(iterResult.Name,"\")+1)
            softwareVersion = iterResult.Version
            softwarePublisher = iterResult.Manufacturer
            softwareLocation = iterResult.Drive & iterResult.Path
            softwareInstallDate = iterResult.InstallDate

            If NOT ISNULL(softwareName) then
                if(softwareName <> "" and (not softList.Exists(softwareName))) then

                    count=count+1
                    softList.add softwareName,count
                    softwareDataText = softwareDataText & "<Software_" & count & " "
                    softwareDataText = addCategoryData(softwareDataText, "Name", softwareName)
                    softwareDataText = addCategoryData(softwareDataText, "Version", softwareVersion)
                    softwareDataText = addCategoryData(softwareDataText, "Vendor", softwarePublisher)
                    softwareDataText = addCategoryData(softwareDataText, "Location", softwareLocation)
                    'softwareDataText = addCategoryData(softwareDataText, "InstallDate", softwareInstallDate)
                    'softwareDataText = addCategoryData(softwareDataText, "Usage", swUsage)
                    'softwareDataText = addCategoryData(softwareDataText, "Key", subkey)
                    softwareDataText = softwareDataText &  "/>"
                end if
            end if
        Next

    Next
End if
softwareDataText = softwareDataText & "</InstalledProgramsList>"
Err.clear

'Oracle Info
'===========
On Error Resume Next
softwareDataText = softwareDataText & "<OracleInfo>"
oracleKeyRoot = "SOFTWARE\ORACLE"
objReg.EnumKey HKEY_LOCAL_MACHINE, oracleKeyRoot, arrSubKeys
count=0
If NOT ISNULL(arrSubKeys) then
    For Each subkey In arrSubKeys
        if(Left(subkey,4)="HOME" Or Left(subkey,7)="KEY_Ora") then

            subkeyPath = oracleKeyRoot & "\" & subkey
            objReg.GetStringValue HKEY_LOCAL_MACHINE, subkeyPath, "SQLPATH", sqlPath
            objReg.GetStringValue HKEY_LOCAL_MACHINE, subkeyPath, "ORACLE_GROUP_NAME", groupName
            objReg.GetStringValue HKEY_LOCAL_MACHINE, subkeyPath, "ORACLE_HOME_NAME", homeName
            objReg.GetStringValue HKEY_LOCAL_MACHINE, subkeyPath, "ORACLE_BUNDLE_NAME", bundleName
            objReg.GetStringValue HKEY_LOCAL_MACHINE, subkeyPath, "VERSION", version
            objReg.GetStringValue HKEY_LOCAL_MACHINE, subkeyPath, "ORACLE_HOME", home
            count=count+1
            softwareDataText = softwareDataText & "<Software_" & count & " "
            softwareDataText = addCategoryData(softwareDataText, "sqlPath", sqlPath)
            softwareDataText = addCategoryData(softwareDataText, "groupName", groupName)
            softwareDataText = addCategoryData(softwareDataText, "homeName", homeName)
            softwareDataText = addCategoryData(softwareDataText, "bundleName", bundleName)
            softwareDataText = addCategoryData(softwareDataText, "version", version)
            softwareDataText = addCategoryData(softwareDataText, "home", home)
            softwareDataText = addCategoryData(softwareDataText, "Key", subkey)
            softwareDataText = softwareDataText &  "/>"
        end if
    Next
end if
softwareDataText = softwareDataText & "</OracleInfo>"
softwareDataText = softwareDataText & "</Software_Info>"
outputText = outputText  & softwareDataText

'Adding Agent details.
'=====================

'outputText = outputText & "<Computer_Info><Computer "
'outputText = addCategoryData(outputText,"Name",computerName)
'outputText = outputText & "/></Computer_Info>"

agentTaskInfo  = "<AgentTaskInfo><AgentTaskInfo "
agentTaskInfo  = addCategoryData(agentTaskInfo, "AgentTaskID",agentTaskID)
isAgentRunning = isServiceRunning(ae_service)
accountNameReg = ""
siteNameReg = ""
agentId = ""
scanTime = "" &Now
agentSubKey = "Software\ZOHO Corp\ManageEngine AssetExplorer\Agent\"
if(is64BitOS)then
    objReg1.GetStringValue HKEY_LOCAL_MACHINE, agentSubKey, "AgentId", agentId
    objReg1.GetStringValue HKEY_LOCAL_MACHINE, agentSubKey, "Version", version
    objReg1.GetStringValue HKEY_LOCAL_MACHINE, agentSubKey, "AgentPort", port
    objReg1.GetStringValue HKEY_LOCAL_MACHINE, agentSubKey, "AccountName", accountNameReg
    objReg1.GetStringValue HKEY_LOCAL_MACHINE, agentSubKey, "SiteName", siteNameReg
else
objReg.GetStringValue HKEY_LOCAL_MACHINE, agentSubKey, "AgentId", agentId
objReg.GetStringValue HKEY_LOCAL_MACHINE, agentSubKey, "Version", version
objReg.GetStringValue HKEY_LOCAL_MACHINE, agentSubKey, "AgentPort", port
objReg.GetStringValue HKEY_LOCAL_MACHINE, agentSubKey, "AccountName", accountNameReg
objReg.GetStringValue HKEY_LOCAL_MACHINE, agentSubKey, "SiteName", siteNameReg
End if
updateRegistry "LastScanTime", scanTime
agentTaskInfo = addCategoryData(agentTaskInfo,"ComputerName",computerName)
agentTaskInfo = addCategoryData(agentTaskInfo,"ServiceTag",serviceTag)
agentTaskInfo  = addCategoryData(agentTaskInfo, "AgentId",agentId)
agentTaskInfo  = addCategoryData(agentTaskInfo, "MacAddress",macAddress)
agentTaskInfo  = addCategoryData(agentTaskInfo, "LastScanTime",scanTime)
agentTaskInfo  = addCategoryData(agentTaskInfo, "Version",version)
agentTaskInfo  = addCategoryData(agentTaskInfo, "AgentPort",port)
agentTaskInfo  = addCategoryData(agentTaskInfo, "isAgentRunning",isAgentRunning)

agentTaskInfo  = agentTaskInfo & "/></AgentTaskInfo>"
outputText = outputText & agentTaskInfo
If accountNameReg <> "" And siteNameReg <> "" Then
    accountName = accountNameReg
    siteName = siteNameReg
end if

accountInfo = "<Account_Info "
accountInfo = addCategoryData(accountInfo, "AccountName", accountName)
accountInfo = addCategoryData(accountInfo, "SiteName", siteName)
accountInfo = accountInfo & "/>"
outputText = outputText & accountInfo

outputText = outputText & "</DocRoot>"
Err.clear

On Error Resume Next

'Converting Data to XML
'======================
set xml = CreateObject("Microsoft.xmldom")
xml.async = false
loadResult = xml.loadxml(outputText)

On Error Resume Next

hexErrorCode = ""
errordescription = ""
succesMsg = ""
errorMessage = ""
cause = ""
resolution = ""

'Sending Data via http
'=====================

urlStr = protocol & "://" & hostName & ":" & portNo & "/discoveryServlet/WsDiscoveryServlet?computerName=" & computerName & "&serviceTag=" & serviceTag & "&macAddress=" & macAddress
set http = createobject("microsoft.xmlhttp")


if(isAgentMode) Then
    saveXMLFile=true
    computerNameForFile=agentTaskID
elseif (loadResult) Then
        http.open "post",urlStr,false
        http.send xml
        'postErrorMessage()
        if Err Then
            http.send outputText
            if Err Then
                errorMessage = getErrorMessage(Err)
                if(cause = "") then
                    cause = "Could not send the system data to " & protocol & "://" & hostName & ":"&portNo & "."
                end if
                if (not silentMode) Then
                    displayErrorMessage()
                else
                    postErrorMessage()
                End if
                saveXMLFile=true
            else
                succesMsg = "successfully scanned the system data, Find this machine details in AssetExplorer server."
            end if
        else
            succesMsg = "successfully scanned the system data, Find this machine details in AssetExplorer server."
        end if
else 'not agent mode and xml load fails
        http.send outputText
        if Err Then
            errorMessage = getErrorMessage(Err)
            if(cause = "") then
                cause = "Could not send the system data to " & protocol & "://" & hostName & ":"&portNo & "." & newLineConst
            end if
            if (not silentMode) Then
                displayErrorMessage()
            else
                postErrorMessage()
            End if
            saveXMLFile=true
        else
            succesMsg = "successfully scanned the system data, Find this machine details in AssetExplorer server."
        end if
end if


'Saving XML File
'===============

if(saveXMLFile=true) then
    'Saving the Inventory Data as XML File - will be useful to troubleshoot the Error
    fileName = ".\" & computerNameForFile  & ".xml"
    xml.save fileName
    if Err Then
        writesuccess = writeFile(computerNameForFile & ".xml",outputText)
        if not writesuccess Then
            if(cause = "") then
                errorMessage = getErrorMessage(Err)
                cause = "Could not write the system data in a xml."
                resolution = "Open a command prompt and execute the script as  " & doubleQuote & "cscript ae_scan.vbs -debug >" &computerNameForFile &  ".xml" & doubleQuote &  ",This will generate a file " & doubleQuote & computerNameForFile & ".xml" & doubleQuote &"." & newLineConst & "Send this file to "& supportMailID & " to help you."
                if (not silentMode) Then
                    displayErrorMessage()
                End if

            end if
        end if
    end if
end if
if(isAgentMode) then
    isFile = isFileExist(computerNameForFile &".xml")
    if(isFile And cause = "") then
        succesMsg = "Successfully generated the " & computerNameForFile & ".xml." & "Now You can import the " & computerNameForFile & ".xml in the AssetExplorer server using Standalone audit"
    end if
end if
if (not silentMode) And (succesMsg <> "") then
    WScript.Echo succesMsg
end if

'prints the data for debugmode
'=============================
if (debugmode) Then
    WScript.Echo outputText
end if

'To Add Data
'===========
Function addCategoryData(outputText, category, data)
    'For handling problem when data contains &
    pos=InStr(data,"&")
    if pos>0 Then
        data = Replace(data,"&","###AND###")
    end if
    'For handling problem when data contains <
    pos=InStr(data,"<")
    if pos>0 Then
        data = Replace(data,"<","###[###")
    end if
    'For handling problem when data contains >
    pos=InStr(data,">")
    if pos>0 Then

        data = Replace(data,">","###]###")

    end if
    'For handling problem when data contains DOUBLEQUOTE
    pos=InStr(data,doubleQuote)
    if pos>0 Then
        data = Replace(data,doubleQuote,"###DQ###")
    end if
    data = removeInvalidXMLChar(data)
    retStr = outputText
    if NOT ISNULL(data) then
        retStr = retStr & spaceString
        retStr = retStr & category
        retStr = retStr & equalString
        retStr = retStr & doubleQuote
        retStr = retStr &  Trim(data)
        retStr = retStr & doubleQuote
    end if
    addCategoryData=retStr
End Function

'To get the licence Key
'======================
Public Function getLicenceKey(bDigitalProductID,version)
    Dim bProductKey()
    Dim bKeyChars(24)
    Dim ilByte
    Dim nCur
    Dim sCDKey
    Dim ilKeyByte
    Dim ilBit
    ReDim Preserve bProductKey(14)
    Set objShell = CreateObject("WScript.Shell")
    Set objShell = Nothing

    if isNull(version)then
        version = 0 ' number less than 14, so that it detects the key for lower versions of office and OS
    end if
    if (version<14) then
        For ilByte = 52 To 66
            bProductKey(ilByte - 52) = bDigitalProductID(ilByte)
        Next
    else
        i=0
        For ilByte = CLng("&h"&328) To CLng("&h"&328)+14
            bProductKey(i) = bDigitalProductID(ilByte)
            i=i+1
        Next
    end if

    bKeyChars(0) = Asc("B")
    bKeyChars(1) = Asc("C")
    bKeyChars(2) = Asc("D")
    bKeyChars(3) = Asc("F")
    bKeyChars(4) = Asc("G")
    bKeyChars(5) = Asc("H")
    bKeyChars(6) = Asc("J")
    bKeyChars(7) = Asc("K")
    bKeyChars(8) = Asc("M")
    bKeyChars(9) = Asc("P")
    bKeyChars(10) = Asc("Q")
    bKeyChars(11) = Asc("R")
    bKeyChars(12) = Asc("T")
    bKeyChars(13) = Asc("V")
    bKeyChars(14) = Asc("W")
    bKeyChars(15) = Asc("X")
    bKeyChars(16) = Asc("Y")
    bKeyChars(17) = Asc("2")
    bKeyChars(18) = Asc("3")
    bKeyChars(19) = Asc("4")
    bKeyChars(20) = Asc("6")
    bKeyChars(21) = Asc("7")
    bKeyChars(22) = Asc("8")
    bKeyChars(23) = Asc("9")
    For ilByte = 24 To 0 Step -1
      nCur = 0
      For ilKeyByte = 14 To 0 Step -1
        nCur = nCur * 256 Xor bProductKey(ilKeyByte)
        bProductKey(ilKeyByte) = Int(nCur / 24)
        nCur = nCur Mod 24
      Next
      sCDKey = Chr(bKeyChars(nCur)) & sCDKey
      If ilByte Mod 5 = 0 And ilByte <> 0 Then sCDKey = "-" & sCDKey
    Next
    getLicenceKey = sCDKey
End Function


'To get Software usage
'=====================
Function getSoftwareUsage(softwareUsageData)
    getSoftwareUsage = "Not Known"
    if not ISNULL(softwareUsageData) then
        usageLevel = CLng(softwareUsageData(24))
        if(usageLevel<3) then
            getSoftwareUsage = "Rarely"
        elseif (usageLevel<9) then
            getSoftwareUsage = "Occasionally"
        elseif (usageLevel<>255) then
            getSoftwareUsage = "Frequently"
        end if
    end if
End Function


'To get the Logical Disk Type
'============================
Function getDiskType(diskType)
    getDiskType="Unknown"
    if(diskType="1") then
        getDiskType="No Root Directory"
    elseif (diskType="2") then
        getDiskType="Removable Disk"
    elseif (diskType="3") then
        getDiskType="Local Disk"
    elseif (diskType="4") then
        getDiskType="Network Drive"
    elseif (diskType="5") then
        getDiskType="Compact Disc"
    elseif (diskType="6") then
        getDiskType="RAM Disk"
    end if
End Function


'To Remove the Index in Network Caption
'======================================
Function getNetworkCaption(captionString)
    getNetworkCaption = captionString
    idx = InStr(captionString," ")
    If(idx>0) Then
        getNetworkCaption = Trim(Mid(captionString,idx))
    End If
End Function

'To Get Monitor Serial number
'============================

Function GetMonitorSerialNumber(EDID)

    sernumstr=""
    sernum=0
    for i=0 to ubound(EDID)-4
        if EDID(i)=0 AND EDID(i+1)=0 AND EDID(i+2)=0 AND EDID(i+3)=255 AND EDID(i+4)=0 Then
            ' if sernum<>0 then
                'sMsgString = "a second serial number has been found!"
                'WScript.ECho sMsgString
                'suspicious=1
            'end if
            sernum=i+4
        end if
    next
    if sernum<>0 then
        endstr=0
        sernumstr=""
        for i=1 to 13
            if EDID(sernum+i)=10 then
                endstr=1
            end if
            if endstr=0 then
                sernumstr=sernumstr & chr(EDID(sernum+i))
            end if

        next
        'sMsgString = "Monitor serial number: " & sernumstr
        'WScript.Echo sMsgString
    else
    sernumstr="-"
    'sMsgString = "No monitor serial number found. Possibly the computer is a laptop."
    'WScript.Echo sMsgString
    end if
    GetMonitorSerialNumber = sernumstr

End Function

'To Handle Error
'===============
Function displayErrorMessage()
    if resolution = "" Then
        resolution = "Open a command prompt and execute the script as  " & doubleQuote & "cscript ae_scan.vbs -debug >" &computerNameForFile &  ".xml" & doubleQuote &  ",This will generate a file " & doubleQuote & computerNameForFile & ".xml" & doubleQuote &"." & newLineConst & "Send this file to "& supportMailID & " to help you."
    end if
    if (not silentMode) Then
        Wscript.Echo errorMessage & newLineConst & "Cause      : " & cause & newLineConst & "Resolution : "& resolution & newLineConst & "If you have any difficulties " & "please report the above Error Message to " & supportMailID
    end if
End Function


'To Get the Error Message for Given Error Code
'=============================================
Function getErrorMessage(Err)
    hexErrorCode = "0x" & hex(Err.Number)
    errordescription = Err.Description
    errorMessage = newLineConst & newLineConst
    errorMessage = errorMessage & "Exception occured while running the Script. (ManageEngine AssetExplorer)"
    errorMessage = errorMessage & newLineConst
    errorMessage = errorMessage & newLineConst & newLineConst

    if(hexErrorCode="0x800C0005") Then
        cause = "The AssetExplorer server is not reachable from this machine."
        resolution = "Check the server name and port number in the script."
    elseif(hexErrorCode="0x80004005") Then
        cause = "The AssetExplorer server is not reachable from this machine."
        resolution = "Check the server name and port number in the script."
    elseif(hexErrorCode="0x80070005") Then
        cause = "The AssetExplorer server is not reachable from this machine."
        resolution = "Check the server name and port number in the script."
    else
        errorMessage = errorMessage & "Error Code : 0x" & hex(Err.Number)
        errorMessage = errorMessage & newLineConst
        errorMessage = errorMessage & "Error Desc : " & Err.description
        errorMessage = errorMessage & newLineConst

    end if
    Err.clear
    errorMessage = errorMessage & newLineConst
    getErrorMessage = errorMessage
End Function


'To post the error message to the server
'=======================================
Function postErrorMessage()
    On Error Resume Next
    if(cause = "") Then
        cause = "-"
    End if
    if(resolution = "") Then
        resolution = "-"
    End if

    exceptionMessage = xmlInfoString &  newLineConst
    exceptionMessage = exceptionMessage &  "<DocRoot>"
    exceptionMessage = exceptionMessage & scriptVersionInfo
    exceptionMessage = exceptionMessage & "<Exception_Msg>"
    exceptionMessage = exceptionMessage & "<Computer "
    exceptionMessage = addCategoryData(exceptionMessage,"Name",computerNameForFile)
    exceptionMessage = exceptionMessage & "/>"
    exceptionMessage = exceptionMessage & "<Error "
    exceptionMessage = addCategoryData(exceptionMessage,"code",hexErrorCode)
    exceptionMessage = addCategoryData(exceptionMessage,"description","errorde scription")
    exceptionMessage = addCategoryData(exceptionMessage,"cause",cause)
    exceptionMessage = addCategoryData(exceptionMessage,"solution",resolution)
    exceptionMessage = exceptionMessage & "/>"
    exceptionMessage = exceptionMessage & "</Exception_Msg>"
    exceptionMessage = exceptionMessage & "<Computer_Info><Computer "
    exceptionMessage = addCategoryData(exceptionMessage,"Name",computerNameForFile)
    exceptionMessage = exceptionMessage & "/></Computer_Info>"
    exceptionMessage = exceptionMessage  & "</DocRoot>"
    'post error message,if it fails write the same in a log file
    http.send exceptionMessage
    if (Err) Then
        sd = writeFile("Error_Scan.log",exceptionMessage)
    End if

End Function

'To write the content in the given filename
'==========================================
Function writeFile(fileName,content)
    On Error Resume Next
    writeFile = false
    Dim oFilesys, oFiletxt, sFilename, sPath
    Set oFilesys = CreateObject("Scripting.FileSystemObject")
    Set oFiletxt = oFilesys.CreateTextFile(fileName,True)
    sPath = oFilesys.GetAbsolutePathName(fileName)
    sFilename = oFilesys.GetFileName(sPath)
    isXPOrLaterOS = isXPAndAbove()
    if(Not isXPOrLaterOS)then
        oFiletxt.WriteLine(content)
        if(Err) then
            writeFile = false
        else
            writeFile = true
        End if
    End if
    oFiletxt.Close'

    if(isXPOrLaterOS)then
        res = saveAsUTF8File(fileName,content)
        if(res) then
            writeFile = false
        else
            writeFile = true
        End if
    End if
End Function

Function isFileExist(fileName)
    On Error Resume Next
    isFileExist = false
    Dim fso
    Set fso = CreateObject("Scripting.FileSystemObject")

    if (fso.FileExists(fileName)) then
        isFileExist = true
    else
        isFileExist = false
    end if
    set fso = Nothing
End Function


'Ref : http://www.w3.org/TR/2000/REC-xml-20001006#NT-Char

Function removeInvalidXMLChar(xmldata)

    Dim isValidChar
    Dim current
    Dim retdata

    retdata = xmldata
    strLen = len(xmldata)
    if(strLen>0)then
        for i=1 to strLen
            current = AscW(Mid(xmldata,i,1))
            isValidChar = false
            isValidChar = isValidChar or CBool(current = HexToDec("9"))
            isValidChar = isValidChar or CBool(current = HexToDec("A"))
            isValidChar = isValidChar or CBool(current = HexToDec("D"))
            isValidChar = isValidChar or (CBool(current >= HexToDec("20")) and CBool(current <= HexToDec("D7FF")))
            isValidChar = isValidChar or (CBool(current >= HexToDec("E000")) and CBool(current <= HexToDec("FFFD")))
            isValidChar = isValidChar or (CBool(current >= HexToDec("10000")) and CBool(current <= HexToDec("10FFFF")))
            if(Not isValidChar) then
                retdata = Replace(retdata,chr(current),"")
            End if
        Next
    End if
    removeInvalidXMLChar = retdata
End Function

'Hex to decimal
Function HexToDec(hexVal)

    dim dec
    dim strLen
    dim digit
    dim intValue
    dim i

    dec = 0
    strLen = len(hexVal)
    for i =  strLen to 1 step -1

        digit = instr("0123456789ABCDEF", ucase(mid(hexVal, i, 1)))-1
        if digit >= 0 then
                intValue = digit * (16 ^ (len(hexVal)-i))
            dec = dec + intValue
        else
            dec = 0
                i = 0 	'exit for
        end if
    next

  HexToDec = dec
End Function

Function stringTokenizer(strToParse,token)
    Dim res()
    resCount = 0
    if not isNULL(strToParse) and strToParse <> "" then
        do
            n=InStr(strToParse,",")
            if(n>0)then
                resCount = resCount+1
                ReDim Preserve res(resCount)
                res(resCount-1) = Mid(strToParse,1,n-1)

                strToParse = Mid(strToParse,n+1)
            else
                resCount = resCount+1
                ReDim Preserve res(resCount)
                res(resCount-1) = strToParse

            End if
            'n=InStr(str,",")

        Loop while n>0
    End if

    stringTokenizer = res

End  Function

Sub correctUsage
    WScript.Echo  VBCrLf & "USAGE : CSCRIPT ae_scan.vbs [OPTION] " & VBCrLf & VBCrLf & " -SilentMode                                        To run the script in silent mode." & VBCrLf & " -out 'filename'                         To create filename.xml as output" & VBCrLf & " -fs 'file extensions with comma seperated'       To add the files with the given file extensions as a software." & VBCrLf & VBCrLf & "Example: " & "CSCRIPT ae_scan.vbs -fs exe,msi -SilentMode -out scan_data" &VBCrLf
End Sub

Function isServiceRunning(serviceName)

    isServiceRunning = false
    Set objWbemLocator = CreateObject("WbemScripting.SWbemLocator")
    Set objService = objWbemLocator.ConnectServer("localhost", "root\CIMV2")
    Set colItems = objService.ExecQuery("select * from Win32_Service where Name='"&serviceName&"' or DisplayName ='"&serviceName&"'")
    For Each objItem in colItems
        state = objItem.state
        if state = "Running" then
            isServiceRunning = true
        End if
    Next
End Function

Sub updateRegistry(regValue,data)
    if(is64BitOS)then
        objReg1.SetStringValue HKEY_LOCAL_MACHINE, agentSubKey, regValue,data
    else
        objReg.SetStringValue HKEY_LOCAL_MACHINE, agentSubKey, regValue,data
    end if
End Sub

Function saveAsUTF8File( fileName,content)
    On Error Resume Next

    saveAsUTF8File = False
    Dim objStream

    Const adTypeText            = 2
    Const adSaveCreateOverWrite = 2

    if(isXPAndAbove)then   ' ADODB.Stream is applicable for xp and later version only
        Set objStream = CreateObject( "ADODB.Stream" )
        objStream.Open
        objStream.Type = adTypeText
        objStream.Position = 0
        objStream.Charset = xmlEncoding
        objStream.WriteText content
        objStream.SaveToFile fileName, adSaveCreateOverWrite
        objStream.Close
        Set objStream = Nothing

        If Err Then
            saveAsUTF8File = False
        Else
            saveAsUTF8File = True
        End If
    else
        saveAsUTF8File = False
    end if
End Function

Function isXPAndAbove()
    On Error Resume Next
    isXPAndAbove = false
    if(Not isNULL(osVersion) and osVersion<>"")then
        ver = Left(osVersion,3)*1

        if(ver>=5.1)then
            isXPAndAbove = true
        else
            isXPAndAbove = false
        end if
    End if

End Function

Function isVistaAndAbove()
    On Error Resume Next
    isVistaAndAbove = false
    if(Not isNULL(osVersion) and osVersion<>"")then
        ver = Left(osVersion,3)*1

        if(ver>=6.0)then
            isVistaAndAbove = true
        else
            isVistaAndAbove = false
        end if
    End if
End Function

'printers from registry
'======================
Function getPrinterInfo(data,printercount)
    On Error Resume Next
    objReg.EnumKey HKEY_LOCAL_MACHINE, "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Print\Providers\",providers 'LanMan Print Services\Servers\",arrSubKeys  ' winsys\Printers\Gemini"
    If NOT ISNULL(providers) then
        For Each provider In providers
            objReg.EnumKey HKEY_LOCAL_MACHINE, "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Print\Providers\"&provider&"\Servers\",servers
            If NOT ISNULL(servers) then
                For Each server In servers
                    objReg.EnumKey HKEY_LOCAL_MACHINE, "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Print\Providers\"&provider&"\Servers\"&server&"\Printers",printers
                    If NOT ISNULL(printers) then
                        For Each printer In printers
                            objReg.GetStringValue HKEY_LOCAL_MACHINE, "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Print\Providers\"&provider&"\Servers\"&server&"\Printers\"&printer&"\DsSpooler", "PrinterName", printerName
                            if(Not isNULL(printerName) and printerName<>"" and (Not printersList.Exists(printerName))) then
                                count=count+1
                                printersList.add printerName,count
                                data = data & "<Printer_" & count & " "
                                data = addCategoryData(data, "Name", printerName)
                                objReg.GetStringValue HKEY_LOCAL_MACHINE, "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Print\Providers\"&provider&"\Servers\"&server&"\Printers\"&printer&"\DsSpooler", "driverName", printDriver
                                data = addCategoryData(data, "Model", printDriver)
                                objReg.GetMultiStringValue HKEY_LOCAL_MACHINE, "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Print\Providers\"&provider&"\Servers\"&server&"\Printers\"&printer&"\DsSpooler", "portName", printerPorts

                                For Each portName In printerPorts
                                    printerPort = portName
                                Next

                                data = addCategoryData(data, "PortName", printerPort)
                                objReg.GetStringValue HKEY_LOCAL_MACHINE, "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Print\Providers\"&provider&"\Servers\"&server&"\Printers\"&printer&"\DsSpooler", "Location", location
                                data = addCategoryData(data, "Location", location)
                                objReg.GetStringValue HKEY_LOCAL_MACHINE, "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Print\Providers\"&provider&"\Servers\"&server&"\Printers\"&printer&"\DsSpooler", "Description", description
                                data = addCategoryData(data, "Comment", description)
                                objReg.GetStringValue HKEY_LOCAL_MACHINE, "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Print\Providers\"&provider&"\Servers\"&server&"\Printers\"&printer&"\DsSpooler", "serverName", serverName
                                data = addCategoryData(data, "ServerName", serverName)
                                data = addCategoryData(data, "Network", "TRUE")
                                data = addCategoryData(data, "Local", "FALSE")
                                data = data & "/>"
                            End if
                        Next
                    End if

                Next
            End if
        Next
    End if
    getPrinterInfo = data
    Err.clear
End Function

Function updateSQLEdition(softName,regMainKey,regSubKey,regObj)
    if (isSQL(softName))then
        regObj.GetStringValue regMainKey, regSubKey&"\Microsoft SQL Server\MSSQL.1\Setup", "Edition", sqlEdition  'sql 2005 default instance
        if (Not isNull(sqlEdition) And sqlEdition <> "") then
            'WScript.Echo "2005"
            softName = softName&" ("& sqlEdition &")"
        else
            regObj.GetStringValue regMainKey, regSubKey&"\MSSQLServer\Setup", "Edition", sqlEdition	'sql 2000 default instance
            if (Not isNull(sqlEdition) And sqlEdition <> "") then
                'WScript.Echo "2000"
                softName = softName&" ("&sqlEdition&")"
            else
                regObj.GetMultiStringValue regMainKey, regSubKey&"\Microsoft SQL Server\", "InstalledInstances", sqlInsatlledInstances
                'WScript.Echo "3 "&sqlInsatlledInstances(0)
                For Each sqlInsatlledInstance In sqlInsatlledInstances
                    if ( Not isNull(sqlInsatlledInstance) or sqlInsatlledInstance <> "") then
                        regObj.GetStringValue regMainKey, "SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL", sqlInsatlledInstance, sqlInstance
                        'WScript.Echo "4 "&sqlInstance

                        if (Not isNull(sqlInstance) And sqlInstance <> "") then
                            regObj.GetStringValue regMainKey, regSubKey&"\Microsoft SQL Server\"&sqlInstance&"\Setup", "Edition", sqlEdition
                            'WScript.Echo "5 "&sqlEdition
                            if (Not isNull(sqlEdition) And sqlEdition <> "") then
                                softName = softName&" ("&sqlEdition&")"
                                exit for
                            end if
                        end if
                    end if
                Next
            end if
        End if
    End if
    updateSQLEdition = softName
End Function

Function getAdobeLicenseKey(wmiObj,regKey,softName)
    On Error Resume Next
    adobeLicKey = ""

    wmiObj.GetStringValue HKEY_LOCAL_MACHINE,regKey,"EPIC_SERIAL",adobeLicKey
    if( isNULL(adobeLicKey) or Trim(adobeLicKey)="")then
        wmiObj.GetStringValue HKEY_LOCAL_MACHINE,regKey,"SERIAL",adobeLicKey
        if(isNULL(adobeLicKey) or Trim(adobeLicKey)="")then
            verIndex=InstrRev(Trim(softName)," ")
            softNameWithOutVersion = Mid(softName,1,verIndex-1)
            version=Mid(softName,verIndex+1,1)
            wmiObj.EnumKey HKEY_LOCAL_MACHINE, "SOFTWARE\Adobe\"&softNameWithOutVersion,adobeArrSubKeys1

            If NOT ISNULL(adobeArrSubKeys1) then

                For Each abobeSubkey1 In adobeArrSubKeys1
                    if(inStr(abobeSubkey1,version)=1)then 'if abobeSubkey1 starts with version
                        wmiObj.GetStringValue HKEY_LOCAL_MACHINE,"SOFTWARE\Adobe\"&softNameWithOutVersion&"\"&abobeSubkey1&"\Registration","SERIAL",adobeLicKey
                        if(not ISNULL(adobeLicKey) and adobeLicKey<>"")then
                            exit for
                        else
                            'WScript.Echo "Adobe LicenceKey is not found"
                        End if
                    End if
                Next
            End if
            if(ISNULL(adobeLicKey) or Trim(adobeLicKey)="")then
                productIndex=InStr(Trim(softName), " ")
                productName = Mid(softName,1,productIndex-1)
                softNameWithoutProduct = Mid(softName,productIndex+1,verIndex-productIndex-1)
                wmiObj.EnumKey HKEY_LOCAL_MACHINE, "SOFTWARE\Adobe\"&softNameWithoutProduct,adobeArrSubKeys2

                If NOT ISNULL(adobeArrSubKeys2) then

                    For Each abobeSubkey2 In adobeArrSubKeys2
                        if(inStr(abobeSubkey2,version)=1)then 'if abobeSubkey2 starts with version

                            wmiObj.GetStringValue HKEY_LOCAL_MACHINE,"SOFTWARE\Adobe\"&softNameWithoutProduct&"\"&abobeSubkey2&"\Registration","SERIAL",adobeLicKey
                            if(not ISNULL(adobeLicKey) and adobeLicKey<>"")then
                                exit for
                            else
                                'WScript.Echo "Adobe LicenceKey is not found"
                            End if
                        End if
                    Next
                End if
            End if
        End if
    End if
    if(ISNULL(adobeLicKey))then
        adobeLicKey=""
    End if
    getAdobeLicenseKey = adobeLicKey
End Function
sub setAutodeskLicenses(objRegLoc)
autodeskKey = "SOFTWARE\Autodesk"
objRegLoc.EnumKey HKEY_LOCAL_MACHINE, autodeskKey, autodeskProducts
If NOT ISNULL(autodeskProducts) then
	For Each adPrd In autodeskProducts
		objRegLoc.EnumKey HKEY_LOCAL_MACHINE, autodeskKey&"\"&adPrd,productdVersions
		if(not ISNULL(productdVersions)) then
			For Each adPrdVer In productdVersions
				objRegLoc.GetStringValue HKEY_LOCAL_MACHINE, autodeskKey&"\"&adPrd&"\"&adPrdVer,"ProductName",adPrdName
				if((ISNULL(adPrdName)) or (adPrdName = ""))then
					objRegLoc.GetStringValue HKEY_LOCAL_MACHINE, autodeskKey&"\"&adPrd&"\"&adPrdVer, "Product Name",adPrdName
				end if
				if((not ISNULL(adPrdName)) and (adPrdName <> ""))then
					objRegLoc.GetStringValue HKEY_LOCAL_MACHINE, autodeskKey&"\"&adPrd&"\"&adPrdVer,"SerialNumber",adSerialNo
					if((not ISNULL(adSerialNo)) and (adSerialNo <> "") and (adSerialNo <> "-") and (instr(adSerialNo, "000-") = 0))then
						autodeskSoftLicKeys.add adPrdName,adSerialNo
						autodeskProductSuiteSerialNumber=adSerialNo
						exit for
					else
						objRegLoc.GetStringValue HKEY_LOCAL_MACHINE, autodeskKey&"\"&adPrd&"\"&adPrdVer,"Serial Number",adSerialNo
						if((not ISNULL(adSerialNo)) and (adSerialNo <> "") and (adSerialNo <> "-") and (instr(adSerialNo, "000-") = 0))then
							autodeskSoftLicKeys.add adPrdName,adSerialNo
							autodeskProductSuiteSerialNumber = adSerialNo
							exit for
						end if
					end if
				end if
				objRegLoc.EnumKey HKEY_LOCAL_MACHINE, autodeskKey&"\"&adPrd&"\"&adPrdVer,adRegKeys
				if (not ISNULL(adRegKeys)) then
					For Each adRegKey In adRegKeys
						objRegLoc.GetStringValue HKEY_LOCAL_MACHINE, autodeskKey&"\"&adPrd&"\"&adPrdVer&"\"&adRegKey,"ProductName",adPrdName
						if((ISNULL(adPrdName)) or (adPrdName = ""))then
							objRegLoc.GetStringValue HKEY_LOCAL_MACHINE, autodeskKey&"\"&adPrd&"\"&adPrdVer&"\"&adRegKey,"Product Name",adPrdName
						end if
						if((not ISNULL(adPrdName)) and (adPrdName <> ""))then
							objRegLoc.GetStringValue HKEY_LOCAL_MACHINE, autodeskKey&"\"&adPrd&"\"&adPrdVer&"\"&adRegKey,"SerialNumber",adSerialNo
							if((not ISNULL(adSerialNo)) and (adSerialNo <> "") and (adSerialNo <> "-") and (instr(adSerialNo, "000-") = 0))then
								autodeskSoftLicKeys.add adPrdName,adSerialNo
								autodeskProductSuiteSerialNumber = adSerialNo
								exit for
							end if
						else
							objRegLoc.GetStringValue HKEY_LOCAL_MACHINE, autodeskKey&"\"&adPrd&"\"&adPrdVer&"\"&adRegKey,"Serial Number",adSerialNo

							if((not ISNULL(adSerialNo)) and (adSerialNo <> "") and (adSerialNo <> "-") and (instr(adSerialNo, "000-") = 0))then
								autodeskSoftLicKeys.add adPrdName,adSerialNo
								autodeskProductSuiteSerialNumber = adSerialNo
								exit for
							end if
						end if
					Next
				end if
			Next
		end if
	Next
end if
end sub

function isSQL(softwareName)
	if (sqlSoftList.Exists(Lcase(softwareName)))then
		isSQL = true
	else
		isSQL = false
	end if
end function

sub initSQLSoftList
	sqlSoftList.add "microsoft sql server 2000", ""
	sqlSoftList.add "microsoft sql server 2005", "" 
	sqlSoftList.add "microsoft sql server 2008", "" 
	sqlSoftList.add "microsoft sql server 2008 R2", "" 
	sqlSoftList.add "microsoft sql server 2012", "" 
	sqlSoftList.add "microsoft sql server 2000 (64-bit)", "" 
	sqlSoftList.add "microsoft sql server 2005 (64-bit)", "" 
	sqlSoftList.add "microsoft sql server 2008 (64-bit)", "" 
	sqlSoftList.add "microsoft sql server 2008 R2 (64-bit)", "" 
	sqlSoftList.add "microsoft sql server 2012 (64-bit)", "" 
end sub
