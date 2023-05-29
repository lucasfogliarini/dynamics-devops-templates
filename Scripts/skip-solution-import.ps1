[CmdletBinding()]
param(
  [string]$applicationId,
  [string]$clientSecret,
  [string]$solutionName,
  [string]$url
)

$connectionString  = "AuthType=ClientSecret;ClientId=$applicationId;ClientSecret=$clientSecret;Url=$url"
 
# Login to PowerApps for the Xrm.Data commands
Write-Host "Login to PowerApps for the Xrm.Data commands"
Install-Module  Microsoft.Xrm.Data.PowerShell -RequiredVersion "2.8.14" -Force -Scope CurrentUser -AllowClobber
$conn = Get-CrmConnection -ConnectionString $connectionString

$suffix = "_Upgrade"
$solutionName = "$solutionName$suffix"

Write-Host $solutionName

# Obter detalhes da solução
Write-Host ""
Write-Host "Get Solution"
$fetchSolution = @"
<fetch>
  <entity name='solution'>
    <attribute name='friendlyname' />
    <attribute name='solutionid' />
    <attribute name='uniquename' />
    <filter>
      <condition attribute='uniquename' operator='eq' value='$solutionName' />
    </filter>
  </entity>
</fetch>
"@;

$response = (Get-CrmRecordsByFetch  -conn $conn -Fetch $fetchSolution -Verbose).CrmRecords

if ($response.Count -eq 1){
  Write-Host "Existe uma solution aguardando upgrade, portanto nao sera importada novamente."
  Write-Host "##vso[task.setvariable variable=SkipSolutionImport]$true"
}else{
  Write-Host "Nenhuma solution aguardando upgrade foi encontrada."
  Write-Host "##vso[task.setvariable variable=SkipSolutionImport]$false"
}