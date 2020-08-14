
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

# Create an inbound network security group rule for port 22 
$nsgRuleRDP = New-AzNetworkSecurityRuleConfig -Name myNetworkSecurityGroupRuleSSH -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22 -Access Allow

# Create an inbound network security group rule for port 80
#$nsgRuleWeb = New-AzNetworkSecurityRuleConfig -Name myNetworkSecurityGroupRuleWWW -Protocol Tcp -Direction Inbound -Priority 1001 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80 -Access Allow

# Create network security group
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $newRG -Location $newLoc -Name myNetworkSecurityGroup -SecurityRules $nsgRuleRDP, $nsgRuleWeb

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzNetworkInterface -Name myNic -ResourceGroupName myResourceGroup -Location $newLoc -SubnetId $vent.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

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
$vm = Add-AzVMNetworkInterface -VM $vm -Id $NIC.Id 

#Configre the SSH Key
$sshPublicKey = cat /home/neolin/.ssh/id_rsa.pub
Add-AzVMSshPublicKey `
  -VM $vm `
  -KeyData $sshPublicKey `
  -Path "/home/azureuser/.ssh/authorized_keys"

# Create a new storage account
$storAcc = "trmystorageaccount"
$storSkuname = "Standard_LRS"
New-AzStorageAccount -ResourceGroupName $newRG -AccountName $storAcc -Location $newLoc -SkuName $storSkuname 

# Disk setup
$diskName = ”neo-disk”
$STA = Get-AzStorageAccount -ResourceGroupName $newRG -Name $storAcc
$OSDiskUri = $STA.PrimaryEndpoints.Blob.ToString() + "vhds/" + $diskName? + ".vhd"
$vm = Set-AzVMOSDisk -VM $vm -Name $diskName -VhdUri $OSDiskUri -CreateOption fromImage 

# Create the virtual machine
New-AzVM -ResourceGroupName $newRG -Location $newLoc -VM $vm

#Check what type of disk the VM used
(Get-AzVM -ResourceGroupName $newRG -Name $vm).StorageProfile.OsDisk

# Verify the Name of the VM and the admin account we created
$verifyVM = Get-AzVM -Name $vm | Select-Object *
$verufyVM.OSProfile | Select-Object ComputerName,AdminUserName

# Get specific information about the network configuration
Get-AzNetworkInterface |
Select-Object -ExpandProperty IpConfigurations |
Select-Object Name,PrivateIpAddress

# Get the public IP address
$pupipname = Get-AzPublicIpAddress | Select-Object Name
$publicIp = Get-AzPublicIpAddress -Name $pupipname.Name -ResourceGroupName $newRG 
$publicIp | Select-Object Name,IpAddress,@{label='FQDN';expression={$_.DnsSettings.Fqdn}}

# Connect to the VM over Remote Desktop
#mstsc.exe /v <PUBLIC_IP_ADDRESS>

## Clean up the created resources
#$job = Remove-AzResourceGroup -Name TutorialResources -Force -AsJob

# Show clean state
#$job

# To wait until the deletion is complete, use the following command:
#Wait-Job -Id $job.Id
