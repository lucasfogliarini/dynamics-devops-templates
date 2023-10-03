function Get-RouteRuleItemsInfo {
    param(
        [string]$url,
        [string]$token
    )

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Bearer $token")

    $response = Invoke-RestMethod "$url/api/data/v9.1/routingruleitems?`$select=msdyn_routeto,_routedqueueid_value" -Method 'GET' -Headers $headers
    return $response.value
}

function Set-RouteRuleItem {
    param(
        [string]$url,
        [string]$token,
        [object]$routingruleitem
    )

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")
    $headers.Add("Authorization", "Bearer $token")

$body = @"
{
    `"msdyn_routeto`": $($routingruleitem.msdyn_routeto),
    `"routedqueueid@odata.bind`": `"/queues($($routingruleitem._routedqueueid_value))`"
}
"@

    $response = Invoke-RestMethod "$url/api/data/v9.1/routingruleitems($($routingruleitem.routingruleitemid))" -Method 'PATCH' -Headers $headers -Body $body
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

function Enable-RoutingRuleSet {
    param(
        [string]$url,
        [string]$token,
        [string]$routingRuleId
    )

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")
    $headers.Add("Authorization", "Bearer $token")

$body = @"
{
    `"statecode`": 1,
    `"statuscode`": 2
}
"@

    Invoke-RestMethod "$url/api/data/v9.1/routingrules($routingRuleId)" -Method 'PATCH' -Headers $headers -Body $body
}

function Disable-RoutingRuleSet {
    param(
        [string]$url,
        [string]$token,
        [string]$routingRuleId
    )

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")
    $headers.Add("Authorization", "Bearer $token")

$body = @"
{
    `"statecode`": 0,
    `"statuscode`": 1
}
"@

    Invoke-RestMethod "$url/api/data/v9.1/routingrules($routingRuleId)" -Method 'PATCH' -Headers $headers -Body $body
}

function Get-RoutingRuleInfo {
    param(
        [string]$url,
        [string]$token,
        [string]$routingRuleName
    )

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Bearer $token")

    $response = Invoke-RestMethod "$url/api/data/v9.1/routingrules?$select=name" -Method 'GET' -Headers $headers
    return $response
}