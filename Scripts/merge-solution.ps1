function Merge-Solution {
    param (
        [Parameter()] [String]$token,
        [Parameter(Mandatory)] [String]$dataverseHost,
        [Parameter(Mandatory)] [String]$solutionName
    )

    # Load Required PowerShell Files
    Invoke-Expression ". $env:POWERSHELLPATH/dataverse-webapi-functions.ps1"

    Write-Host "solutionName - $solutionName"

    $patchCount = Get-PatchesCount $token $dataverseHost $solutionName

    if($patchCount -gt 0){
        $actualVersion = Get-ActualSolutionVersion $token $dataverseHost $solutionName
        $newVersion = Get-NewSolutionVersion $actualVersion
        $displayName = Get-DisplayName $token $dataverseHost $solutionName

        Write-Host "New version: $newVersion"

        if($solutionName -ne '') {
            $body = "{
            `n    `"ParentSolutionUniqueName`": `"$solutionName`",
            `n    `"DisplayName`": `"$displayName`",
            `n    `"VersionNumber`": `"$newVersion`"
            `n}"
        
            Write-Host "Body: $body"

            $requestUrlRemainder = "CloneAsSolution"
            Invoke-DataverseHttpPost $token $dataverseHost $requestUrlRemainder $body
        }
    }else{
        Write-Host "Nao existem patches para essa solution, nao sera necessario realizar o CloneAsSolution."
    }
}

function Get-ActualSolutionVersion {
    param (
        [Parameter()] [String]$token,
        [Parameter(Mandatory)] [String]$dataverseHost,
        [Parameter(Mandatory)] [String]$solutionName
    )

    # Load Required PowerShell Files
    Invoke-Expression ". $env:POWERSHELLPATH/dataverse-webapi-functions.ps1"

    $requestUrlRemainder = "solutions?`$filter=uniquename%20eq%20%27$solutionName%27&`$select=version"

    Write-Host "Query: $requestUrlRemainder"

    $response = Invoke-DataverseHttpGet $token $dataverseHost $requestUrlRemainder

    $responseJson = ($response | ConvertTo-Json)

    Write-Host "JSON: $responseJson"

    $version = $response.value[0].version

    Write-Host "Version: $version"

    return $version
}

function Get-DisplayName {
    param (
        [Parameter()] [String]$token,
        [Parameter(Mandatory)] [String]$dataverseHost,
        [Parameter(Mandatory)] [String]$solutionName
    )

    # Load Required PowerShell Files
    Invoke-Expression ". $env:POWERSHELLPATH/dataverse-webapi-functions.ps1"

    $requestUrlRemainder = "solutions?`$filter=uniquename%20eq%20%27$solutionName%27&`$select=friendlyname"

    Write-Host "Query: $requestUrlRemainder"

    $response = Invoke-DataverseHttpGet $token $dataverseHost $requestUrlRemainder

    $responseJson = ($response | ConvertTo-Json)

    Write-Host "JSON: $responseJson"

    $friendlyName = $response.value[0].friendlyname

    Write-Host "Friendly Name: $friendlyName"

    return $friendlyName
}

function Get-NewSolutionVersion {
    param (
        [Parameter()] [String]$actualVersion
    )

    $versionParts = $actualVersion.Split('.');
    $newVersion = $versionParts[0]+'.'+(($versionParts[1] -as [int])+1)+'.0.0';
    
    return $newVersion
}

function Get-PatchesCount {
    param (
        [Parameter()] [String]$token,
        [Parameter(Mandatory)] [String]$dataverseHost,
        [Parameter(Mandatory)] [String]$solutionName
    )

    # Load Required PowerShell Files
    Invoke-Expression ". $env:POWERSHELLPATH/dataverse-webapi-functions.ps1"

    $requestUrlRemainder = "solutions?`$filter=contains(uniquename,'$($solutionName)_Patch')"

    Write-Host "Query: $requestUrlRemainder"

    $response = Invoke-DataverseHttpGet $token $dataverseHost $requestUrlRemainder

    $responseJson = ($response | ConvertTo-Json)

    Write-Host "JSON: $responseJson"

    $quantity = $response.value.Count

    Write-Host "Patches: $quantity"

    return $quantity
}