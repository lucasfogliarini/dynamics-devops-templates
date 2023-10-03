[CmdletBinding()]
param(
  [string]$tenantId,
  [string]$applicationId,
  [string]$clientSecret,
  [string]$azureactivedirectoryobjectid,
  [string]$url,
  [string]$action,
  [string]$slaList
)
Invoke-Expression ". .\sla-functions.ps1"

$token = Get-Token $applicationId $clientSecret $url $tenantId

Write-Host "Buscando informacoes do usuario de fluxos"
$impersonateUser = Get-UserInfo $url $token $azureactivedirectoryobjectid
Write-Host "Usuario encontrado: $($impersonateUser.fullname) ($($impersonateUser.systemuserid))"

if($action -eq "disable") {
    
    Write-Host "Buscando SLAs ativos..."
    $enabledSlas = Get-SLAs $url $token "1" $slaList
    Write-Host "$($enabledSlas.Count) encontrados"

    foreach($sla in $enabledSlas) {
        Write-Host "Desabilitando SLA: $($sla.slaid)"
        Disable-SLA $impersonateUser.systemuserid $token $url $sla.slaid
    }
}
else {

    Write-Host "Buscando SLAs inativos..."
    $disabledSlas = Get-SLAs $url $token "0" $slaList
    Write-Host "$($disabledSlas.Count) encontrados"

    foreach($sla in $disabledSlas) {
        Write-Host "Habilitando SLA: $sla"
        Enable-SLA $impersonateUser.systemuserid $token $url $sla.slaid
    }
}