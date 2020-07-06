# Create virtual machines with the Azure PowerShell
# https://docs.microsoft.com/en-us/powershell/azure/azureps-vm-tutorial?view=azps-2.8.0

## Step 1 of 8, Sign in
#Connect-AzAccount

## Step 2 of 8, Create a resource group
New-AzResourceGroup -Name TutorialResources -Location eastus

## Step 3 of 8, Create admin credentials for the VM

# User: tutorAdmin
# Password for user tutorAdmin: tutorAdminPW123
$cred = Get-Credential -Message "Enter a username and password for the virtual machine."

## Step 4 of 8, Create a virtual machine
$vmParams = @{
  ResourceGroupName = 'TutorialResources'
  Name = 'TutorialVM1'
  Location = 'eastus'
  ImageName = 'Win2016Datacenter'
  PublicIpAddressName = 'tutorialPublicIp'
  Credential = $cred
  OpenPorts = 3389
}
$newVM1 = New-AzVM @vmParams

# Once the VM is ready, we can view the results in the Azure Portal or by inspecting the $newVM1 variable.
$newVM1

## Step 5 of 8, Get VM information with queries

# Verify the Name of the VM and the admin account we created
$newVM1.OSProfile | Select-Object ComputerName,AdminUserName

# Get specific information about the network configuration
$newVM1 | Get-AzNetworkInterface |
Select-Object -ExpandProperty IpConfigurations |
Select-Object Name,PrivateIpAddress

# Get the public IP address
$publicIp = Get-AzPublicIpAddress -Name tutorialPublicIp -ResourceGroupName TutorialResources
$publicIp | Select-Object Name,IpAddress,@{label='FQDN';expression={$_.DnsSettings.Fqdn}}

# Connect to the VM over Remote Desktop
#mstsc.exe /v <PUBLIC_IP_ADDRESS>

## Step 6 of 8, Creating a new VM on the existing subnet
$vm2Params = @{
  ResourceGroupName = 'TutorialResources'
  Name = 'TutorialVM2'
  ImageName = 'Win2016Datacenter'
  VirtualNetworkName = 'TutorialVM1'
  SubnetName = 'TutorialVM1'
  PublicIpAddressName = 'tutorialPublicIp2'
  Credential = $cred
  OpenPorts = 3389
}
$newVM2 = New-AzVM @vm2Params

# view the results in the Azure Portal or by inspecting the $newVM1 variable.
$newVM2
Get-AzVM -Status

# To see the public IP address of the VMs
Get-AzPublicIpAddress -ResourceGroupName "TutorialResources" | Select "IpAddress"

# You can skip a few steps to get the public IP address of the new VM since it's returned in the FullyQualifiedDomainName property of the $newVM2 object. 
# Use the following command to connect using Remote Desktop.
#mstsc.exe /v $newVM2.FullyQualifiedDomainName

## Step 7 of 8, Clean up the created resources
#$job = Remove-AzResourceGroup -Name TutorialResources -Force -AsJob

# Show clean state
#$job

# To wait until the deletion is complete, use the following command:
#Wait-Job -Id $job.Id

## Step 8 of 8, Summary
# https://docs.microsoft.com/en-us/powershell/azure/azureps-vm-tutorial?tutorial-step=8&view=azps-2.8.0
