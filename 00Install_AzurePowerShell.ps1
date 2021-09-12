
# Install the Azure PowerShell module
# https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-2.8.0
# Sign in with Azure PowerShel
# https://docs.microsoft.com/en-us/powershell/azure/authenticate-azureps?view=azps-2.8.0

# To check PowerShell version
$PSVersionTable.PSVersion

# Install the AzureRM module from the PowerShell Gallery
Install-Module -Name Az -AllowClobber -Scope AllUsers

# Let’s confirm if the module is installed:
Get-Module -ListAvailable *Az*

# Check if you have multiple versions of Azure PowerShell installled.
Get-InstalledModule -Name Az -AllVersions | Select-Object -Property Name, Version

# Change the execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Connect to Azure with a browser sign in token
Connect-AzAccount

# Available Azure contexts are retrieved with the Get-AzContext cmdlet. List all of the available contexts with -ListAvailable:
Get-AzContext -ListAvailable

# Add the PowerShell Gallery as a trusted repository
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Get-PSRepository

# List all of the available resource
Get-AzResource | Select-Object Name, ResourceType, Location
