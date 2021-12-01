
# Check VM sizes supported for ephemeral OS disks
$vmSizes=Get-AzComputeResourceSku | where{$_.ResourceType -eq 'virtualMachines' -and $_.Locations.Contains('eastasia')} 

foreach($vmSize in $vmSizes)
{
   foreach($capability in $vmSize.capabilities)
   {
       if($capability.Name -eq 'EphemeralOSDiskSupported' -and $capability.Value -eq 'true')
       {
           $vmSize
       }
   }
}

# Check the Cache size
##$vmSizes=Get-AzComputeResourceSku | where{$_.ResourceType -eq 'virtualMachines' -and $_.Name.Contains('Standard_M8ms') -and $_.Locations.Contains('eastasia')} 
##$vmSizes=Get-AzComputeResourceSku | where{$_.ResourceType -eq 'virtualMachines' -and $_.Name.Contains('Standard_E4ds_v4') -and $_.Locations.Contains('eastasia')} 
##$vmSizes=Get-AzComputeResourceSku | where{$_.ResourceType -eq 'virtualMachines' -and $_.Name.Contains('Standard_E8ds_v4') -and $_.Locations.Contains('eastasia')} 
##$vmSizes.Capabilities
