
# Get the Storage Account context for retrieve the storage account key to perform the indicated actions against the file share
$rg_name = "myResourceGroup"
$sa_name = "mystorageacct266040474"
$storageAcct = Get-AzStorageAccount -ResourceGroupName $rg_name -StorageAccountName $sa_name

# List all Storage file shares of a Storage account
$shareName = Get-AzRmStorageShare -ResourceGroupName $rg_name -StorageAccountName $sa_name

# Remove the oldest snapshot of Azure File Share 
$outputNum = Get-AzStorageShare -Context $storageAcct.Context | Where-Object { $_.Name -eq $shareName.name -and $_.IsSnapshot -eq $true } | Measure-Object
if ( 5 -eq $outputNum.Count )
{ 
  Write-Output "The maximum number of share snapshots that Azure Files allows today is 200. `
    After 200 share snapshots, you have to delete older share snapshots in order to create new ones."
  $outputArrary = Get-AzStorageShare `
    -Context $storageAcct.Context `
    | Where-Object { $_.Name -eq $shareName.name -and $_.IsSnapshot -eq $true } `
    | Sort-Object -Property SnapshotTime `
    | Select-Object -Property SnapshotTime
  $snapshotTime = "$($outputArrary[0].SnapshotTime.UtcDateTime) +00:00" 
  $deleteSnapshot = Get-AzStorageShare -Context $storageAcct.Context -Name $shareName.Name -SnapshotTime $snapshotTime 
  Write-Output "Start to delete snapshot $($snapshotTime) now."
  Remove-AzStorageShare -Share $deleteSnapshot.CloudFileShare -Confirm:$false -Force
}
else
{ 
  Write-Output "The maximum number of share snapshots that Azure Files allows today is 200. `
    Your share snapshopts are $($outputNum.Count) now."
}
