# Quickstart: Create and manage an Azure file share with Azure PowerShell
## https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-powershell

# Get the Storage Account context for retrieve the storage account key to perform the indicated actions against the file share
$rg_name = "myResourceGroup"
$sa_name = "mystorageacct266040474"
$storageAcct = Get-AzStorageAccount -ResourceGroupName $rg_name -StorageAccountName $sa_name

# List all Storage file shares of a Storage account
$shareName = Get-AzRmStorageShare -ResourceGroupName $rg_name -StorageAccountName $sa_name

# create a share snapshot for a share
$share = Get-AzStorageShare -Context $storageAcct.Context -Name $shareName.name
$snapshot = $share.CloudFileShare.Snapshot()

# browse the contents of the share snapshot
Get-AzStorageFile -Share $snapshot

# list of snapshots you've taken
Get-AzStorageShare `
        -Context $storageAcct.Context | `
    Where-Object { $_.Name -eq $shareName.name -and $_.IsSnapshot -eq $true }
