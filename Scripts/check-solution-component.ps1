function Test-SolutionComponent {
  param(
    [Parameter(Mandatory)][String] $SolutionName,
    [Parameter(Mandatory)][String] $applicationId,
    [Parameter(Mandatory)][String] $clientSecret,
    [Parameter(Mandatory)][String] $url,
    [Parameter(Mandatory)][String] $tenantId
  )

  Write-Host "Solução: $SolutionName"

  $solucoesBase = @('ComunicacaoComAluno','AtividadesAcademicas','AnaliseCurricular')
  
  $connectionString  = "AuthType=ClientSecret;ClientId=$applicationId;ClientSecret=$clientSecret;Url=$url"
  
  Write-Host "Starting Power Shell Script..."
  
  # Login to PowerApps for the Admin commands
  Install-Module Microsoft.PowerApps.Administration.PowerShell -RequiredVersion "2.0.105" -Force -Scope CurrentUser -AllowClobber
  Install-Module Microsoft.Xrm.Data.Powershell -RequiredVersion "2.8.19" -Force -Scope CurrentUser -AllowClobber
  
  Write-Host "Login to PowerApps for the Admin commands"
  Add-PowerAppsAccount -TenantID $tenantId -ApplicationId $applicationId -ClientSecret $clientSecret -Endpoint "prod"
  $conn = Get-CrmConnection -ConnectionString $connectionString
  
  # Obter componentes das soluções
  Write-Host ""
  Write-Host "Get Solution Component"
  $fetchComponents = @"
<fetch>
  <entity name='solution'>
    <filter>
      <condition attribute='uniquename' operator='eq' value='$SolutionName' />
    </filter>
    <link-entity name='solutioncomponent' from='solutionid' to='solutionid' link-type='inner' alias='componente'>
      <attribute name='objectid' alias='objectid' />
      <attribute name='componenttype' alias='componenttype' />
    </link-entity>
  </entity>
</fetch>
"@;
  
  $components = (Get-CrmRecordsByFetch -conn $conn -Fetch $fetchComponents -Verbose).CrmRecords
  if ($components.Count -eq 0)
  {
      Write-Error "Solução sem componentes"
      exit(1)
  }
  
  $comErro = $false
   
  # Validar componentes
  foreach ($component in $components){
    try {
      Write-Host "Objectid: $(($component).objectid) - Tipo: $(($component).componenttype)"
  
      $fetchComponentDetail = @"
<fetch>
  <entity name='solutioncomponent'>
    <filter>
      <condition attribute='objectid' operator='eq' value='$(($component).objectid)' />
    </filter>
    <link-entity name='solution' from='solutionid' to='solutionid' link-type='inner' alias='solution'>
      <attribute name='friendlyname' alias='solutionfriendlyname' />
      <attribute name='uniquename' alias='solutionuniquename' />
      <link-entity name='solution' from='solutionid' to='parentsolutionid' link-type='outer' alias='base'>
        <attribute name='friendlyname' alias='basesolutionfriendlyname' />
        <attribute name='uniquename' alias='basesolutionuniquename' />
      </link-entity>
    </link-entity>
  </entity>
</fetch>
"@;
  
      $componentDetail = (Get-CrmRecordsByFetch -conn $conn -Fetch $fetchComponentDetail).CrmRecords
      if ($componentDetail.Count -eq 0) {
          $comErro = $true
          Write-Error "Componente não encontrado."
      }
      elseif( $null -eq ($componentDetail | Where-Object {$solucoesBase -contains ($_.basesolutionuniquename, $_.solutionuniquename | Select-Object -First 1) })){
          $comErro = $true
          Write-Error "Item não encontrado na solução base. Adicione antes de gerar uma build."
      }
      else {
          Write-Output "OK"
      }
    }
    catch {
      Write-Warning "Erro ao consultar componente:$(($component).objectid)"
      Write-Warning $_
    }
  }
  
  if($comErro) {
    exit(1)
  }

}
