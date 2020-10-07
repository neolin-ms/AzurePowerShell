## Quickstart: Create a Linux virtual machine in Azure with PowerShell
## https://docs.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-powershell

## Gets all locations and the supported resource providers for each location.
#Get-AzLocation | Format-Table

## View all the services in a particular region
#$providers = Get-AzLocation | Where-Object {$_.Location -eq "eastasia"}

## Vice the available Resource Provider
#$providers.Providers

## Create a resource group
New-AzResourceGroup -Name "myResourceGroup" -Location "japanwest"

## Create virtual network resources
# Create a subnet configuration
$subnetConfig = New-AzVirtualNetworkSubnetConfig `
  -Name "mySubnet" `
  -AddressPrefix 192.168.1.0/24

# Create a virtual network
$vnet = New-AzVirtualNetwork `
  -ResourceGroupName "myResourceGroup" `
  -Location "japanwest" `
  -Name "myVNET" `
  -AddressPrefix 192.168.0.0/16 `
  -Subnet $subnetConfig

# Create a public IP address and specify a DNS name
$pip = New-AzPublicIpAddress `
  -ResourceGroupName "myResourceGroup" `
  -Location "japanwest" `
  -AllocationMethod Static `
  -IdleTimeoutInMinutes 4 `
  -Name "mypublicdns$(Get-Random)"

# Create an inbound network security group rule for port 22
$nsgRuleSSH = New-AzNetworkSecurityRuleConfig `
  -Name "myNetworkSecurityGroupRuleSSH"  `
  -Protocol "Tcp" `
  -Direction "Inbound" `
  -Priority 1000 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 22 `
  -Access "Allow"

# Create an inbound network security group rule for port 80
$nsgRuleWeb = New-AzNetworkSecurityRuleConfig `
  -Name "myNetworkSecurityGroupRuleWWW"  `
  -Protocol "Tcp" `
  -Direction "Inbound" `
  -Priority 1001 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 80 `
  -Access "Allow"

# Create a network security group
$nsg = New-AzNetworkSecurityGroup `
  -ResourceGroupName "myResourceGroup" `
  -Location "japanwest" `
  -Name "myNetworkSecurityGroup" `
  -SecurityRules $nsgRuleSSH,$nsgRuleWeb

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzNetworkInterface `
  -Name "myNic" `
  -ResourceGroupName "myResourceGroup" `
  -Location "japanwest" `
  -SubnetId $vnet.Subnets[0].Id `
  -PublicIpAddressId $pip.Id `
  -NetworkSecurityGroupId $nsg.Id

## Create a virtual machine
# Define a credential object
$securePassword = ConvertTo-SecureString ' ' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("azureuser", $securePassword)

# Create a virtual machine configuration
$vmConfig = New-AzVMConfig `
  -VMName "myVM" `
  -VMSize "Standard_D1_v2" | `
Set-AzVMOperatingSystem `
  -Linux `
  -ComputerName "myVM" `
  -Credential $cred `
  -DisablePasswordAuthentication | `
Set-AzVMSourceImage `
  -PublisherName "SUSE" `
  -Offer "sles-15-sp1-basic" `
  -Skus "gen1" `
  -Version "2020.06.10" | `
Add-AzVMNetworkInterface `
  -Id $nic.Id

# Configure the SSH key
$sshPublicKey = cat /home/neolin/.ssh/id_rsa.pub
Add-AzVMSshPublicKey `
  -VM $vmConfig `
  -KeyData $sshPublicKey `
  -Path "/home/azureuser/.ssh/authorized_keys"

# Now, combine the previous configuration definitions to create with New-AzVM:
New-AzVM `
  -ResourceGroupName "myResourceGroup" `
  -Location japanwest  -VM $vmConfig

# Confirm the new VM
Get-AzVM -Status
Get-AzResource | Select-Object Name, ResourceType, Location

## Connect to the VM
# To see the public IP address of the VM
Get-AzPublicIpAddress -ResourceGroupName "myResourceGroup" | Select "IpAddress"

# SSH connection command into the shell to create an SSH session
#ssh -i ~/.ssh/id_rsa azureuser@52.186.159.189

## Clean up resources
#$job = Remove-AzResourceGroup -Name "myResourceGroup" -Force -AsJob

# Show clean state 
#$job

# To wait until the deletion is complete, use the following command:
#Wait-Job -Id $job.Id 
