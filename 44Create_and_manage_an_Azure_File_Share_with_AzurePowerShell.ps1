# Overview of share snapshots for Azure Files
# https://docs.microsoft.com/en-us/azure/storage/files/storage-snapshots-files
# Quickstart: Create and manage an Azure file share with Azure PowerShell
# https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-powershell
# Get-AzRmStorageShare
# https://docs.microsoft.com/en-us/powershell/module/az.storage/get-azrmstorageshare?view=azps-6.4.0
# Remove-AzStorageShare
# https://docs.microsoft.com/en-us/powershell/module/az.storage/remove-azstorageshare?view=azps-6.4.0
# Measure-Object
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/measure-object?view=powershell-7.1
# Everything you wanted to know about the if statement
# https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-if?view=powershell-7.1


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
$snapshot | fl

# list of snapshots you've taken
Get-AzStorageShare -Context $storageAcct.Context | Where-Object { $_.Name -eq $shareName.name -and $_.IsSnapshot -eq $true }

# Get a file share snapshot with specific share name and SnapshotTime
$deleteSnapshot = Get-AzStorageShare -Context $storageAcct.Context -Name $shareName.name -SnapshotTime "9/12/2021 11:19:34 AM +00:00"

# Delete a share snapshot
Remove-AzStorageShare -Share $deleteSnapshot.CloudFileShare -Confirm:$false -Force

# Remove the oldest snapshot of Azure File Share 

$outputNum = Get-AzStorageShare -Context $storageAcct.Context | Where-Object { $_.Name -eq $shareName.name -and $_.IsSnapshot -eq $true } | Measure-Object
if ( 200 -eq $outputNum.Count )
{ 
  Write-Output "The maximum number of share snapshots that Azure Files allows today is 200. `
    After 200 share snapshots, you have to delete older share snapshots in order to create new ones."
  $outputArrary = Get-AzStorageShare `
    -Context $storageAcct.Context `
    | Where-Object { $_.Name -eq $shareName.name -and $_.IsSnapshot -eq $true } `
    | Sort-Object -Property SnapshotTime -Descending `
    | Select-Object -Property SnapshotTime
  $snapshotTime = "$($outputArrary[0].SnapshotTime.UtcDateTime) +00:00" 
  $deleteSnapshot = Get-AzStorageShare -Context $storageAcct.Context -Name $shareName.Name -SnapshotTime $snapshotTime 
  Write-Output "Start to delete snapshot $(snapshotTime) now."
  Remove-AzStorageShare -Share $deleteSnapshot.CloudFileShare -Confirm:$false -Force
}
else
{ 
  Write-Output "The maximum number of share snapshots that Azure Files allows today is 200. `
    Your share snapshopts are $($outputNum.Count) now."
}
