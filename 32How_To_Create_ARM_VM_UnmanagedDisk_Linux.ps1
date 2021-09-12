## Create a Azure VM with unmanaged data disks
## https://stackoverflow.com/questions/56587064/create-a-azure-vm-with-unmanaged-data-disks-enabled-using-powershell#comment99753600_56587230

# Create a resource group
$newLoc = "eastasia"
$newRG = "myResourceGroup"
New-AzResourceGroup -Name $newRG -Location $newLoc

# Create a subnet configuration
$subnetconfig = New-AzVirtualNetworkSubnetConfig -Name mySubnet -AddressPrefix 192.168.1.0/24

# Create a virtual network
$vent = New-AzVirtualNetwork -ResourceGroupName $newRG -Location $newLoc -Name MyvNET -AddressPrefix 192.168.0.0/16 -Subnet $subnetconfig

# Create a public IP address and specify a DNS name
$pip = New-AzPublicIpAddress -ResourceGroupName $newRG -Location $newLoc -AllocationMethod Static -IdleTimeoutInMinutes 4 -Name "mypublicdns$(Get-Random)"

# Create a public IP address and specify a DNS name for second VM 
$pip1 = New-AzPublicIpAddress -ResourceGroupName $newRG -Location $newLoc -AllocationMethod Static -IdleTimeoutInMinutes 4 -Name "mypublicdns$(Get-Random)"

# Create an inbound network security group rule for port 22 
$nsgRuleSSH = New-AzNetworkSecurityRuleConfig -Name myNetworkSecurityGroupRuleSSH -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22 -Access Allow

# Create an inbound network security group rule for port 80
$nsgRuleWeb = New-AzNetworkSecurityRuleConfig -Name myNetworkSecurityGroupRuleWWW -Protocol Tcp -Direction Inbound -Priority 1001 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80 -Access Allow

# Create network security group
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $newRG -Location $newLoc -Name myNetworkSecurityGroup -SecurityRules $nsgRuleSSH, $nsgRuleWeb

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzNetworkInterface -Name myNic -ResourceGroupName $newRG -Location $newLoc -SubnetId $vent.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

# Create a virtual network card and associate with public IP address and NSG for second VM
$nic1 = New-AzNetworkInterface -Name myNic1 -ResourceGroupName $newRG -Location $newLoc -SubnetId $vent.Subnets[0].Id -PublicIpAddressId $pip1.Id -NetworkSecurityGroupId $nsg.Id

# Define a credential object
$securePassword = ConvertTo-SecureString ' ' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("azureuser", $securePassword) 

#VM config
$vmsize="Standard_DS2"
$vmName="myVMunmanagedDisk"
$vm = New-AzVMConfig -VMName $vmName -VMSize $vmsize
$pubName = "OpenLogic" 
$offerName = "CentOS"
$skuName = "7.3" 
$version = "7.3.20161221"
$vm = Set-AzVMOperatingSystem -VM $vm -Linux -ComputerName $vmName -Credential $cred -DisablePasswordAuthentication
$vm = Set-AzVMSourceImage -VM $vm -PublisherName $pubName -Offer $offerName -Skus $skuName -Version $version 
$vm = Add-AzVMNetworkInterface -VM $vm -Id $nic.Id 

#VM config for second VM
$vmsize1="Standard_DS2"
$vmName1="resuceVM"
$vm1 = New-AzVMConfig -VMName $vmName1 -VMSize $vmsize1
$pubName = "OpenLogic" 
$offerName = "CentOS"
$skuName = "7.3" 
$version = "7.3.20161221"
$vm1 = Set-AzVMOperatingSystem -VM $vm1 -Linux -ComputerName $vmName1 -Credential $cred -DisablePasswordAuthentication
$vm1 = Set-AzVMSourceImage -VM $vm1 -PublisherName $pubName -Offer $offerName -Skus $skuName -Version $version 
$vm1 = Add-AzVMNetworkInterface -VM $vm1 -Id $nic1.Id 

#Configre the SSH Key
$sshPublicKey = cat /home/neolin/.ssh/id_rsa.pub
Add-AzVMSshPublicKey `
  -VM $vm `
  -KeyData $sshPublicKey `
  -Path "/home/azureuser/.ssh/authorized_keys"

#Configre the SSH Key
$sshPublicKey1 = cat /home/neolin/.ssh/id_rsa.pub
Add-AzVMSshPublicKey `
  -VM $vm1 `
  -KeyData $sshPublicKey1 `
  -Path "/home/azureuser/.ssh/authorized_keys"

# Create a new storage account
$storAcc = "neomystorageaccount"
$storSkuname = "Standard_LRS"
New-AzStorageAccount -ResourceGroupName $newRG -AccountName $storAcc -Location $newLoc -SkuName $storSkuname 

# Create a new storage account for second VM
$storAcc1 = "neomystorageaccount1"
$storSkuname1 = "Standard_LRS"
New-AzStorageAccount -ResourceGroupName $newRG -AccountName $storAcc1 -Location $newLoc -SkuName $storSkuname1 

# Disk setup
$diskName = ”neo-disk”
$STA = Get-AzStorageAccount -ResourceGroupName $newRG -Name $storAcc
$OSDiskUri = $STA.PrimaryEndpoints.Blob.ToString() + "vhds/" + $diskName? + ".vhd"
$vm = Set-AzVMOSDisk -VM $vm -Name $diskName -VhdUri $OSDiskUri -CreateOption fromImage 

# Disk setup for second VM
$diskName1 = ”neo-disk1”
$STA1 = Get-AzStorageAccount -ResourceGroupName $newRG -Name $storAcc1
$OSDiskUri1 = $STA1.PrimaryEndpoints.Blob.ToString() + "vhds/" + $diskName? + ".vhd"
$vm1 = Set-AzVMOSDisk -VM $vm1 -Name $diskName1 -VhdUri $OSDiskUri1 -CreateOption fromImage 

# Create the virtual machine
New-AzVM -ResourceGroupName $newRG -Location $newLoc -VM $vm

# Create the virtual machine for second VM
New-AzVM -ResourceGroupName $newRG -Location $newLoc -VM $vm1

#Check what type of disk the VM used
#(Get-AzVM -ResourceGroupName $newRG -Name $vm).StorageProfile.OsDisk

# Verify the Name of the VM and the admin account we created
$verifyVM = Get-AzVM -Name $vm | Select-Object *
$verufyVM.OSProfile | Select-Object ComputerName,AdminUserName

# Get specific information about the network configuration
Get-AzNetworkInterface |
Select-Object -ExpandProperty IpConfigurations |
Select-Object Name,PrivateIpAddress

# Get the public IP address
#$pupipname = Get-AzPublicIpAddress | Select-Object Name
#$publicIp = Get-AzPublicIpAddress -Name $pupipname.Name -ResourceGroupName $newRG 
#$publicIp | Select-Object Name,IpAddress,@{label='FQDN';expression={$_.DnsSettings.Fqdn}}

# Connect to the VM over Remote Desktop
#ssh -i ~/.ssh/id_rsa azureuser@10.111.111.10

## Clean up the created resources
#$job = Remove-AzResourceGroup -Name TutorialResources -Force -AsJob

# Show clean state
#$job

# To wait until the deletion is complete, use the following command:
#Wait-Job -Id $job.Id
