#Microsoft Azure Rest API authentication
#https://docs.microsoft.com/en-us/rest/api/azure/
$subscriptionId = 'a76944aa-b763-4bb1-85eb-ee3731eb8cec'
$tenantId = '56d6941c-896b-4583-9a66-ebd134c37773'

$applicationId = 'b35969f3-b926-48ce-b4e3-28b34e3c77b6'
$secret='L3fc_f0UPF_5KjRCg2q6L1.IRb7M2T.qpJ'

$param = @{
    #Uri = "https://login.microsoftonline.com/$tenantId/oauth2/token?api-version=1.0";
    Uri = "https://login.microsoftonline.com/$tenantId/oauth2/token?api-version=2020-06-01";
    Method = 'Post';
    Body = @{ 
        grant_type = 'client_credentials'; 
        resource = 'https://management.core.windows.net/'; 
        client_id = $applicationId; 
        client_secret = $secret
    }
}

$result = Invoke-RestMethod @param
$token = $result.access_token
