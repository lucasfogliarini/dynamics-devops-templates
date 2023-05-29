[CmdletBinding()]
param(
  [string]$applicationId,
  [string]$clientSecret,
  [string]$url
)

$connectionString  = "AuthType=ClientSecret;ClientId=$applicationId;ClientSecret=$clientSecret;Url=$url"
 
# Login to PowerApps for the Xrm.Data commands
Write-Host "Login to PowerApps for the Xrm.Data commands"
Install-Module  Microsoft.Xrm.Data.PowerShell -RequiredVersion "2.8.14" -Force -Scope CurrentUser -AllowClobber
$conn = Get-CrmConnection -ConnectionString $connectionString

$controle = $true

while ($controle) {
    Write-Host "Existe uma operacao em andamento, tentando novamente em 30s."

    $fetchSolution = @"
<fetch>
  <entity name="solutionhistorydata">
    <attribute name="solutionname" />
    <attribute name="starttime" />
    <attribute name="operation" />
    <filter>
      <condition attribute="endtime" operator="null" />
    </filter>
  </entity>
</fetch>
"@;

    $response = (Get-CrmRecordsByFetch  -conn $conn -Fetch $fetchSolution -Verbose).CrmRecords

    if ($response.Count -ne 1){
      $controle = $false
    }else{
      Timeout /T 30
    }
}

Write-Host "Done!"