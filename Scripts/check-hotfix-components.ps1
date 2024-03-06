function Test-Hotfix-Components {
    param(
        [string]$url,
        [string]$token,
        [string]$solutionName
    )

    $baseSolutionName = Get-BaseSolutionName $solutionName

    Invoke-Expression ". $env:POWERSHELLPATH/dataverse-webapi-functions.ps1"

    $hotfixSolutionId = Get-SolutionId $url $token $solutionName

    $hotfixComponents = Get-SolutionComponents $url $token $hotfixSolutionId

    if ($null -eq $hotfixComponents) {
        Write-Warning "Solucao $solutionName parece estar vazia. Verifique e tenta novamente."
        Write-Error "Pipeline cancelado"
        exit 1
    }
    else{
        foreach ($component in $hotfixComponents) {

            $componentDetail = Get-SolutionComponentDetails $url $token $component.objectid

            if( $null -eq ($componentDetail | Where-Object {$baseSolutionName -contains ($_.basesolutionuniquename, $_.solutionuniquename | Select-Object -First 1) })){
                Write-Error "Componente:`n`tID = $($component.solutioncomponentid),`n`tTIPO = $($component.componenttype),`n`tOBJECTID = $($component.objectid)`n nao encontrado na solucao base $baseSolutionName. Adicione e tente novamente."
                exit 1
            }
        }
        Write-Output "Todos os componentes da solucao $solutionName estao contidos na solucao base $baseSolutionName."
        exit 0
    }
}

function Get-BaseSolutionName {
    param (
        [Parameter(Mandatory)] [String]$solutionName
    )
    $prefixName = $solutionName.Split('_hf')[0]
 
    Write-Host "Hotfix Solution name: $solutionName"
    Write-Host "Base Solution name: $prefixName"
 
    if((-not $solutionName.Contains('_hf')) -or ("" -eq $prefixName)){
        Write-Error "Solucao nao corresponde ao tipo Hotfix ou nao atende aos criterios de nomenclatura. Verifique e tente novamente."
        exit(1)
    }

    return $prefixName
}

function Get-SolutionId {
    param (
        [Parameter(Mandatory)] [String]$url,
        [Parameter()] [String]$token,
        [Parameter(Mandatory)] [String]$solutionName
    )

    $requestUrlRemainder = "solutions?`$filter=uniquename%20eq%20%27$solutionName%27&`$select=solutionid"

    $response = Invoke-DataverseHttpGet $token $url $requestUrlRemainder

    $solutionId = $response.value[0].solutionid

    Write-Host "SolutionId: $solutionid"

    return $solutionId
}

function Get-SolutionComponents {
    param (
        [Parameter(Mandatory)] [String]$url,
        [Parameter()] [String]$token,
        [Parameter(Mandatory)] [String]$solutionId
    )

    $requestUrlRemainder = "solutioncomponents?`$filter=_solutionid_value%20eq%20%27$solutionId%27"

    Write-Host "Query: $requestUrlRemainder"

    $response = Invoke-DataverseHttpGet $token $url $requestUrlRemainder

    $responseJson = ($response | ConvertTo-Json)

    Write-Host "JSON: $responseJson"

    $solutionComponents = $response.value

    return $solutionComponents
}
 
function Get-SolutionComponentDetails {
    param (
        [Parameter(Mandatory)] [String]$url,
        [Parameter()] [String]$token,
        [Parameter(Mandatory)] [String]$objectid
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

    $requestUrlRemainder = "solutioncomponents?fetchXml=$fetchEncoded"

    Write-Host "Query: $requestUrlRemainder"

    $response = Invoke-DataverseHttpGet $token $url $requestUrlRemainder

    $responseJson = ($response | ConvertTo-Json)

    Write-Host "JSON: $responseJson"

    return $response.value
}
