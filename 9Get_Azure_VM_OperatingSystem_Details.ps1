$VMs = Get-AzVM
$vmOutput = @()
$VMs | ForEach-Object {
  $tmpObj = New-Object -TypeName PSObject
  $tmpObj | Add-Member -MemberType Noteproperty -Name "VM Name" -Value $_.Name
  $tmpObj | Add-Member -MemberType Noteproperty -Name "OS Sku" -Value $_.StorageProfile.ImageReference.Sku
  $tmpObj | Add-Member -MemberType Noteproperty -Name "OS Offer" -Value $_.StorageProfile.ImageReference.Offer
  $tmpObj | Add-Member -MemberType Noteproperty -Name "OS Publisher" -Value $_.StorageProfile.ImageReference.Publisher
  $tmpObj | Add-Member -MemberType Noteproperty -Name "OS Version" -Value $_.StorageProfile.ImageReference.Version

  $vmOutput += $tmpObj
}
$vmOutput
