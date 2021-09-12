## List available Azure VM images
## http://www.thatlazyadmin.com/how-to-list-available-azure-vm-images-using-powershell/

# List the available publishers in your region
$locName = "East Asia"
Get-AzVMImagePublisher -Location $locName | Where-Object {$_.PublisherName -like "Open*"}

# From the list of Publishers select your publisher
$pubName = "OpenLogic"
Get-AzVMImageOffer -Location $locName -PublisherName $pubName | Select Offer

# List of available Offers for the Publisher
$offerName = "CentOS"
Get-AzVMImageSku -Location $locName -PublisherName $pubName -Offer $offerName | Select Skus

# See which images are available for this Sku
$skuName = "7_8"
Get-AzVMImage -Location $locName -PublisherName $pubName -Offer $offerName -Skus $skuName | Select-Object Version

# Publisher and Offer you would like to view
Get-AzVMImage -Location $locName -PublisherName $pubName -Offer $offerName -Skus $skuname

