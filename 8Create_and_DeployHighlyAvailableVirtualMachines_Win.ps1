## Tutorial: Create and deploy highly available virtual machines with Azure PowerShell
## https://docs.microsoft.com/en-us/azure/virtual-machines/windows/tutorial-availability-sets?toc=%2Fazure%2Fvirtual-machines%2Fwindows%2Ftoc.json

## Create an availability set
# Create a resource group.
New-AzResourceGroup `
   -Name myResourceGroupAvailability `
   -Location EastUS

# Create a managed availability set using New-AzAvailabilitySet with the -sku aligned parameter.
New-AzAvailabilitySet `
   -Location "EastUS" `
   -Name "myAvailabilitySet" `
   -ResourceGroupName "myResourceGroupAvailability" `
   -Sku aligned `
   -PlatformFaultDomainCount 3 `
   -PlatformUpdateDomainCount 5

## Create VMs inside an availability set
# set an administrator username and password for the VM with Get-Credential.
$cred = Get-Credential

# create two VMs with New-AzVM in the availability set.
for ($i=1; $i -le 5; $i++)
{
    New-AzVm `
        -ResourceGroupName "myResourceGroupAvailability" `
        -Name "myVM$i" `
        -Location "East US" `
        -VirtualNetworkName "myVnet" `
        -SubnetName "mySubnet" `
        -SecurityGroupName "myNetworkSecurityGroup" `
        -PublicIpAddressName "myPublicIpAddress$i" `
        -AvailabilitySetName "myAvailabilitySet" `
        -Credential $cred
}

# Check the Available Set
$avset = Get-AzAvailabilitySet -ResourceGroupName "myResourceGroupAvailability"
$avset.Name

# (Option) Check the Available Set from Azure Portal, Resource Groups > myResourceGroupAvailability > myAvailabilitySet.

## Check for available VM sizes
# get all available sizes for virtual machines that you can deploy in the availability set.
Get-AzVMSize `
   -ResourceGroupName "myResourceGroupAvailability" `
   -AvailabilitySetName "myAvailabilitySet"

## Clean upda the created resources
#$job = Remove-AzResourceGroup -Name TutorialResources -Force -AsJob 

# Show clean state
#$job

# To wait until the deletion is complete, use the following command:
#Wait-Job -Id $job.Id
