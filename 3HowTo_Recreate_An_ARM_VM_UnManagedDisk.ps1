
## Create a Azure VM with unmanaged data disks
## https://stackoverflow.com/questions/56587064/create-a-azure-vm-with-unmanaged-data-disks-enabled-using-powershell#comment99753600_56587230

# Create a resource group
$newLoc = "southeastasia"
$newRG1 = "TutorialResources"
New-AzResourceGroup -Name $newRG1 -Location $newLoc

# Create a subnet configuration
$subnetconfig = New-AzVirtualNetworkSubnetConfig -Name mySubnet -AddressPrefix 192.168.1.0/24

# Create a virtual network
$vent = New-AzVirtualNetwork -ResourceGroupName TutorialResources -Location $newLoc -Name MyvNET -AddressPrefix 192.168.0.0/16 -Subnet $subnetconfig

# Create a public IP address and specify a DNS name
$pip = New-AzPublicIpAddress -ResourceGroupName TutorialResources -Location $newLoc -AllocationMethod Static -IdleTimeoutInMinutes 4 -Name "mypublicdns$(Get-Random)"

# Create an inbound network security group rule for port 3389
$nsgRuleRDP = New-AzNetworkSecurityRuleConfig -Name myNetworkSecurityGroupRuleRDP -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389 -Access Allow

# Create an inbound network security group rule for port 80
$nsgRuleWeb = New-AzNetworkSecurityRuleConfig -Name myNetworkSecurityGroupRuleWWW -Protocol Tcp -Direction Inbound -Priority 1001 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80 -Access Allow

# Create a network security group
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName TutorialResources -Location $newLoc -Name myNetworkSecurityGroup -SecurityRules $nsgRuleRDP, $nsgRuleWeb

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzNetworkInterface -Name myNic -ResourceGroupName TutorialResources -Location $newLoc -SubnetId $vent.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

# Define a credential object
# User: tutorAdmin
# Password: tutorAdminPW123
$cred = Get-Credential

#VM config
$vmsize = "Standard_DS2"
$vmName="myVM" 
$vm = New-AzVMConfig -VMName $vmName -VMSize $vmsize
$pubName = ”MicrosoftWindowsServer”
$offerName = ”WindowsServer”
$skuName = ”2016-Datacenter”
$vm = Set-AzVMOperatingSystem -VM $vm -Windows -ComputerName $vmName -Credential $cred
$vm = Set-AzVMSourceImage -VM $vm -PublisherName $pubName -Offer $offerName -Skus $skuName -Version "latest"
$vm = Add-AzVMNetworkInterface -VM $vm -Id $NIC.Id 

# Create a new storage account
New-AzStorageAccount -ResourceGroupName "TutorialResources" -AccountName "trmystorageaccount" -Location $newLoc -SkuName "Standard_LRS"

# Disk setup
$diskName = ”neo-disk”
$storageaccount = "trmystorageaccount"
$STA = Get-AzStorageAccount -ResourceGroupName TutorialResources -Name $storageAccount
$OSDiskUri = $STA.PrimaryEndpoints.Blob.ToString() + "vhds/" + $diskName? + ".vhd"
$vm = Set-AzVMOSDisk -VM $vm -Name $diskName -VhdUri $OSDiskUri -CreateOption fromImage 


# Create the virtual machine
New-AzVM -ResourceGroupName TutorialResources -Location $newLoc -VM $vm

#Check what type of disk the VM used
$newRG1 = "TutorialResources"
$newVM1 = "myVM"
(Get-AzVM -ResourceGroupName $newRG1 -Name $newVM1).StorageProfile.OsDisk

# Verify the Name of the VM and the admin account we created
$newVM1 = Get-AzVM -Name myVM | Select-Object *
$newVM1.OSProfile | Select-Object ComputerName,AdminUserName

# Get specific information about the network configuration
Get-AzNetworkInterface |
Select-Object -ExpandProperty IpConfigurations |
Select-Object Name,PrivateIpAddress

# Get the public IP address
$pupipname = Get-AzPublicIpAddress | Select-Object Name
$publicIp = Get-AzPublicIpAddress -Name $pupipname.Name -ResourceGroupName TutorialResources
$publicIp | Select-Object Name,IpAddress,@{label='FQDN';expression={$_.DnsSettings.Fqdn}}

# Connect to the VM over Remote Desktop
#mstsc.exe /v <PUBLIC_IP_ADDRESS>

## Clean up the created resources
#$job = Remove-AzResourceGroup -Name TutorialResources -Force -AsJob

# Show clean state
#$job

# To wait until the deletion is complete, use the following command:
#Wait-Job -Id $job.Id
