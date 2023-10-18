# Testable outside of agent
function Get-SpnToken {
    param (
        [Parameter(Mandatory)] [String]$tenantId,
        [Parameter(Mandatory)] [String]$clientId,
        [Parameter(Mandatory)] [String]$clientSecret,
        [Parameter(Mandatory)] [String]$url
    )
    $dataverseHost = Get-HostFromUrl $url
    $body = @{client_id = $clientId; client_secret = $clientSecret; grant_type = "client_credentials"; scope = "https://$dataverseHost/.default"; }
    $OAuthReq = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Body $body

    return $OAuthReq.access_token
}

function Get-HostFromUrl {
    param (
        [Parameter(Mandatory)] [String]$url
    )
    $options = [System.StringSplitOptions]::RemoveEmptyEntries
    return $url.Split("://", $options)[1].Split("/")[0]
}

# Convenient inside of agent
function Set-SpnTokenVariableWithinAgent {    
    param (
        [Parameter(Mandatory)] [String]$tenantId,
        [Parameter(Mandatory)] [String]$clientId,
        [Parameter(Mandatory)] [String]$clientSecret,
        [Parameter(Mandatory)] [String]$dynamicsURL
    )

    Write-Host "Received Parameters"
    Write-Host "TenantId: "$tenantId
    Write-Host "ClientId: "$clientId
    Write-Host "ClientSecret: "$clientSecret
    Write-Host "DynamicsURL: "$dynamicsURL
    
    $dataverseHost = Get-HostFromUrl $dynamicsURL
    
    Write-Host "Dataverse Host: "$dataverseHost
    
    $spnToken = Get-SpnToken $tenantId $clientId $clientSecret $dynamicsURL

    Write-Host "##vso[task.setvariable variable=SpnToken;issecret=true]$spnToken"
}

function Set-DefaultHeaders {
    param (
        [Parameter(Mandatory)] [String]$token
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Bearer $token")
    $headers.Add("Content-Type", "application/json")
    return $headers
}

function Set-RequestUrl {
    param (
        [Parameter(Mandatory)] [String]$dynamicsURL,
        [Parameter(Mandatory)] [String]$requestUrlRemainder
    )
    $dataverseHost = Get-HostFromUrl $dynamicsURL
    $requestUrl = "https://$dataverseHost/api/data/v9.2/$requestUrlRemainder"
    return $requestUrl    
}

function Invoke-DataverseHttpGet {
    param (
        [Parameter(Mandatory)] [String]$token,
        [Parameter(Mandatory)] [String]$dynamicsURL,
        [Parameter(Mandatory)] [String]$requestUrlRemainder
    )
    $headers = Set-DefaultHeaders $token
    $requestUrl = Set-RequestUrl $dynamicsURL $requestUrlRemainder
    $response = Invoke-RestMethod $requestUrl -Method 'GET' -Headers $headers
    return $response
}

function Invoke-DataverseHttpPost {
    param (
        [Parameter(Mandatory)] [String]$token,
        [Parameter(Mandatory)] [String]$dynamicsURL,
        [Parameter(Mandatory)] [String]$requestUrlRemainder,
        [Parameter(Mandatory)] [String]$body
    )
    $headers = Set-DefaultHeaders $token
    $requestUrl = Set-RequestUrl $dynamicsURL $requestUrlRemainder
    $response = Invoke-RestMethod $requestUrl -Method 'POST' -Headers $headers -Body $body
    return $response
}