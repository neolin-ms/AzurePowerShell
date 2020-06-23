## Quickstart: Upload, download, and list blobs with PowerShell
## https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-powershell

## Prerequisites
# This quickstart requires the Azure PowerShell module Az version 0.7 or later
#Get-InstalledModule -Name Az -AllVersions | select Name,Version

# Sign in to Azure
#Connect-AzAccount

# Store the location in a variable
Get-AzLocation | select Location
$location = "eastasia"

# Create a resource group
#$resourceGroup = "myResourceGroup"
#New-AzResourceGroup -Name $resourceGroup -Location $location

# Create a storage account, and create a standard, general-purpose storage account with LRS replication
$storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroup `
  -Name "mystorageaccount" `
  -SkuName Standard_LRS `
  -Location $location `

$ctx = $storageAccount.Context

# Create a container. Blobs are always uploaded into a container. You can organize groups of blobs like the way you organize your files on your computer in folders.
$containerName = "quickstartblobs"
New-AzStorageContainer -Name $containerName -Context $ctx -Permission blob

## Show Container, Blob.
$storageAcc = Get-AzStorageAccount -ResourceGroupName $resourceGroup
$ctx = $storageAcc.Context
Get-AzStorageContainer -Context $ctx

# Upload blobs to the container
# Blob storage supports block blobs, append blobs, and page blobs. VHD files that back IaaS VMs are page blobs. Use append blobs for logging, such as when you want to write to a file and then keep adding more information. Most files stored in Blob storage are block blobs.

# upload a file
Set-AzStorageBlobContent -File "~/_TestImages/Image001.jpg" `
  -Container $containerName `
  -Blob "Image001.jpg" `
  -Context $ctx 

# upload another file
Set-AzStorageBlobContent -File "~/_TestImages/Image002.jpg" `
  -Container $containerName `
  -Blob "Image002.jpg" `
  -Context $ctx

# List the blobs in a container
Get-AzStorageBlob -Container $ContainerName -Context $ctx | select Name

# Data transfer with AzCopy
#azcopy login
#azcopy copy 'C:\myDirectory\myTextFile.txt' 'https://mystorageaccount.blob.core.windows.net/mycontainer/myTextFile.txt'

# Clean up resources
#Remove-AzResourceGroup -Name $resourceGroup
