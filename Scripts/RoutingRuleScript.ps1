[CmdletBinding()]
param(
  [string]$tenantId,
  [string]$applicationId,
  [string]$clientSecret,
  [string]$devUrl,
  [string]$url,
  [Parameter(Mandatory)]
  [ValidateSet("enable","disable","fillitems")]
  [string]$action,
  [string]$routingRuleId
)
Invoke-Expression ". .\routingrules-functions.ps1"

$tokenDev = Get-Token $applicationId $clientSecret $devUrl $tenantId
$token= Get-Token $applicationId $clientSecret $url $tenantId

switch ($action) {
  
  "enable" {
    Enable-RoutingRuleSet $url $token $routingRuleId
  }
  "disable" {  
    Disable-RoutingRuleSet $url $token $routingRuleId
  }
  "fillitems" {  
    $items = Get-RouteRuleItemsInfo $devUrl $tokenDev

    foreach ($item in  $items) {
      Set-RouteRuleItem $url $token $item
    }

  }
  Default {
    Write-Host "Comando invalido $action"
  }
}

Write-Host "Done!"