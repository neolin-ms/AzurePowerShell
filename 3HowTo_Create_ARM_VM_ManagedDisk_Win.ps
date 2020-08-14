
## Step 1, Create a resource group
New-AzResourceGroup -Name TutorialResources -Location southeastasia

## Step 2, Create admin credentials for the VM

# User: tutorAdmin
# Password for user tutorAdmin: tutorAdminPW123
$cred = Get-Credential -Message "Enter a username and password for the virtual machine."

## Step 3, Create a virtual machine
$vmParams = @{
  ResourceGroupName = 'TutorialResources'
  Name = 'TutorialVM1'
  Location = 'southeastasia'
  ImageName = 'Win2016Datacenter'
  PublicIpAddressName = 'tutorialPublicIp'
  Credential = $cred
  OpenPorts = 3389
}
$newVM1 = New-AzVM @vmParams

# Once the VM is ready, we can view the results in the Azure Portal or by inspecting the $newVM1 variable.
$newVM1

#Check what type of disk the VM used
$newRG1 = "TutorialResources"
$newVM1 = "TutorialVM1"
(Get-AzVM -ResourceGroupName $newRG1 -Name $newVM1).StorageProfile.OsDisk

## Step 4, Stop deallocate the VM
$newRG1 = "TutorialResources"
Stop-AzVM -ResourceGroupName $newRG1 -Name $newVM1.Name

## Step 5. Confirm VM status
Get-AzVM -ResourceGroupName $newRG1 -Name $newVM1.Name -Status

## Step 6, Export the JSON file 
Get-AzVM -ResourceGroupName $newRG1 -Name $newVM1.Name | ConvertTo-Json -depth 100 | Out-file -FilePath C:\Temp\$($newVM1.Name).json

## Step 7, Remove the VM
Remove-AzVM -ResourceGroupName $newRG1 -Name $newVM1.Name

## Step 8, Recreate a Managed VM from JSON

#Import from json
$newJson = "C:\Temp\$newVM1.json"
$newImport = gc $json -Raw | ConvertFrom-Json
    
#Create variables for redeployment 
$newRG1 = $newImport.ResourceGroupName
$newLoc = $newImport.Location
$vmSize = $newImport.HardwareProfile.VmSize
$newVM1 = $newImport.Name
    
#Create the vm config
$newVMconfig = New-AzVMConfig -VMName $newVM1 -VMSize $vmSize
    
#Network card info
$newImportNicId = $newImport.NetworkProfile.NetworkInterfaces.Id
$nicName = $newImportNicId.split("/")[-1]
$newNic = Get-AzNetworkInterface -Name $nicName -ResourceGroupName $newRG1
$nicId = $newNic.Id
$newVMconfig = Add-AzVMNetworkInterface -VM $newVMconfig -Id $nicId
    
#OS Disk info
$osDiskName = $newImport.StorageProfile.OsDisk.Name
$osManagedDiskId = $newImport.StorageProfile.OsDisk.ManagedDisk.Id
$newVMconfig = Set-AzVMOSDisk -VM $newVMconfig -ManagedDiskId $osManagedDiskId -Name $osDiskName -CreateOption attach -windows
    
#Create the VM
New-AzVM -ResourceGroupName $newRG1 -Location $newLoc -VM $newVMconfig -Verbose

## Step 9, Confrim the recreated Managed VM

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

## Step 10, Clean up the created resources
#$job = Remove-AzResourceGroup -Name TutorialResources -Force -AsJob

# Show clean state
#$job

# To wait until the deletion is complete, use the following command:
#Wait-Job -Id $job.Id
