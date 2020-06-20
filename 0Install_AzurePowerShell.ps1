
# Install the Azure PowerShell module
# https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-2.8.0
# Sign in with Azure PowerShel
# https://docs.microsoft.com/en-us/powershell/azure/authenticate-azureps?view=azps-2.8.0

# To check PowerShell version
$PSVersionTable.PSVersion

# Install the AzureRM module from the PowerShell Gallery
if (Get-Module -Name AzureRM -ListAvailable) {
    Write-Warning -Message ('Az module not installed. Having both the AzureRM and ' +
      'Az modules installed at the same time is not supported.')
} else {
    Install-Module -Name Az -AllowClobber -Scope AllUsers
}

# Let’s confirm if the module is installed:
Get-Module -ListAvailable *Az*

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
