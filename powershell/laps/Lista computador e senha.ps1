$ADSISearcher = [ADSISearcher]'(&(objectclass=computer)(ms-mcs-admpwd=*))' 
$AllComputers = $ADSISearcher.FindAll() 
$DailyHarvest = @() 

Foreach($Comp in $AllComputers){ 
    $DailyHarvest += New-Object psobject -Property @{Name = $Comp.properties.name; Password = $Comp.properties.'ms-mcs-admpwd';} 
}

$DailyHarvest