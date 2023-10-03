function Enable-SLA {
    param(
        [string]$callerId,
        [string]$token,
        [string]$url,
        [string]$slaId
    )

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("MSCRMCallerID", $callerId)
    $headers.Add("Content-Type", "application/json")
    $headers.Add("Authorization", "Bearer $token")

    $body = @"
{
    `"statecode`": 1,
    `"statuscode`": 2,
    `"isdefault`": true
}
"@

    $response = Invoke-RestMethod "$url/api/data/v9.1/slas($slaId)" -Method 'PATCH' -Headers $headers -Body $body
    $response | ConvertTo-Json
    return $response
}

function Disable-SLA {
    param(
        [string]$callerId,
        [string]$token,
        [string]$url,
        [string]$slaId
    )

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("MSCRMCallerID", $callerId)
    $headers.Add("Content-Type", "application/json")
    $headers.Add("Authorization", "Bearer $token")

$body = @"
{
    `"statecode`": 0,
    `"statuscode`": 1
}
"@

    $response = Invoke-RestMethod "$url/api/data/v9.1/slas($slaId)" -Method 'PATCH' -Headers $headers -Body $body
    $response | ConvertTo-Json
    return $response
}

function Get-Token {
    param(
        [string]$clientid,
        [string]$clientSecret,
        [string]$url,
        [string]$tenantId
    )

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/x-www-form-urlencoded")

    $body = "client_id=$clientid&client_secret=$clientSecret&grant_type=client_credentials&resource=$url"

    $response = Invoke-RestMethod "https://login.microsoftonline.com/$tenantId/oauth2/token" -Method 'POST' -Headers $headers -Body $body
    return $response.access_token
}

function Get-SLAs {
    param(
        [string]$url,
        [string]$token,
        [string]$statecode,
        [string]$slaList
    )

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Bearer $token")

    $response = Invoke-RestMethod "$url/api/data/v9.1/slas?`$filter=statecode eq $statecode&`$select=slaid,name" -Method 'GET' -Headers $headers

    $slaWhiteList = $slaList.Split('|')
    $approvedSLAs = @()
    
    foreach($sla in $response.value) {
        foreach($white in $slaWhiteList) {
            if($sla.name -eq $white) {
                $approvedSLAs += $sla
            }
        }
    }

    Write-Host "$($approvedSLAs.Count) confirmados."

    return $approvedSLAs
}

function Get-UserInfo {
    param(
        [string]$url,
        [string]$token,
        [string]$aaduserid
    )

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Bearer $token")

    $response = Invoke-RestMethod "$url/api/data/v9.1/systemusers?`$filter=azureactivedirectoryobjectid eq '$aaduserid'&`$select=fullname" -Method 'GET' -Headers $headers
    return $response.value[0]
}