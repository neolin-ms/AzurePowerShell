## PowerShell Basics: Finding the right VM size with Get-AzVMSize
## https://docs.microsoft.com/en-us/powershell/module/az.compute/get-azvmsize?view=azps-4.2.0
## https://techcommunity.microsoft.com/t5/itops-talk-blog/powershell-basics-finding-the-right-vm-size-with-get-azvmsize/ba-p/389568

# Get virtual machine sizes for a location
$locName = "East Asia"
Get-AzVMSize -Location $locName

# Get sizes for an availability set
Get-AzVMSize -ResourceGroupName "myResourceGroup" -AvailabilitySetName "AvailabilitySet17"

# Get sizes for an existing virtual machine
Get-AzVMSize -ResourceGroupName "myResourceGroup" -VMName "myVM"

# Adding in a logical operator of,-eq you can create more granular queries with your commands
Get-AzVMSize -Location $locName | Where NumberOfCores -EQ '8'

# VM types that have a maximum data disk count (meaning the number of data disks that can be attached to the VM) of 16
Get-AzVMSize -Location $locName | Where {($_.NumberOfCores -EQ '8') -And ($_.MaxDataDiskCount -eq '16')}

# By VM size
Get-AzVMSize -Location $locName | Where-Object {$_.Name -like '*Standard_B*ms'}
