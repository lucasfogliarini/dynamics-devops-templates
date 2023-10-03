function Get-SolutionComponents {
    param(
        [string]$url,
        [string]$token,
        [string]$solutionName
    )

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")
    $headers.Add("Authorization", "Bearer $token")

    $response = Invoke-RestMethod "$url/api/data/v9.1/solutions?`$filter=uniquename eq '$solutionName'&`$expand=solution_solutioncomponent(`$select=objectid,componenttype)&`$select=uniquename" -Method 'GET' -Headers $headers

    return $response
}

function Get-SolutionComponentDetails {
    param(
        [string]$url,
        [string]$token,
        [string]$objectid
    )

    $fetchXml = @"
<fetch>
    <entity name='solutioncomponent'>
    <filter>
        <condition attribute='objectid' operator='eq' value='$($objectid)' />
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

    $fetchEncoded = [System.Web.HttpUtility]::UrlEncode($fetchXml)

    Write-Host "Query: $fetchEncoded"

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")
    $headers.Add("Authorization", "Bearer $token")

    $response = Invoke-RestMethod "$url/api/data/v9.1/solutioncomponents?fetchXml=$fetchEncoded" -Method 'GET' -Headers $headers
    $responseJson = $response | ConvertTo-Json
    
    Write-Host $responseJson

    return $response
}

function Test-SolutionComponent {
    param(
        [string]$url,
        [string]$token,
        [string]$solutionName,
        [string]$baseSolutions
    )
    
    try {
    
        $solucoesBase = $baseSolutions.Split(",")

        $comErro = $false

        $components = Get-SolutionComponents $url $token $solutionName

        foreach ($component in $components.value[0].solution_solutioncomponent) {

            Write-Host "Objectid: $($component.objectid) - Tipo: $($component.componenttype)"

            $componentDetail = Get-SolutionComponentDetails $url $token $component.objectid

            if( $null -eq ($componentDetail.value | Where-Object {$solucoesBase -contains ($_.basesolutionuniquename, $_.solutionuniquename | Select-Object -First 1) })){
                $comErro = $true
                Write-Error "Item nao encontrado na solucao base. Adicione antes de gerar uma build."
            }
            else {
                Write-Output "OK"
            }
        }

        if ($comErro) {
            exit(1)
        }

    }
    catch {
        Write-Warning "Erro ao consultar componente:$($component.objectid)"
        Write-Warning $_
    }
}