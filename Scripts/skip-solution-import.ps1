[CmdletBinding()]
param(
  [string]$tenantId,
  [string]$applicationId,
  [string]$clientSecret,
  [string]$solutionName,
  [string]$url
)

Invoke-Expression ". .\dataverse-webapi-functions.ps1"

$token = Get-SpnToken $tenantId $applicationId $clientSecret $url
 
$suffix = "_Upgrade"
$solutionName = "$solutionName$suffix"

Write-Host $solutionName

$querystring = "solutions?`$filter=uniquename%20eq%20%27$solutionName%27&`$select=solutionid"

$response = Invoke-DataverseHttpGet $token $url $querystring

$responseJson = ($response | ConvertTo-Json)

Write-Host "JSON: $responseJson"

if ($response.value.Count -eq 1){
  Write-Host "Existe uma solution aguardando upgrade, portanto nao sera importada novamente."
  Write-Host "##vso[task.setvariable variable=SkipSolutionImport]$true"
}else{
  Write-Host "Nenhuma solution aguardando upgrade foi encontrada."
  Write-Host "##vso[task.setvariable variable=SkipSolutionImport]$false"
}