function Test-AllowedSolutionComponents {
    param (
        [Parameter()] [String]$token,
        [Parameter(Mandatory)] [String]$dataverseHost,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [String]$allowedComponents
    )

    # Load Required PowerShell Files
    Invoke-Expression ". $env:POWERSHELLPATH/dataverse-webapi-functions.ps1"

    Write-Host "solutionName - $solutionName"

    $solutionid = Get-SolutionId $token $dataverseHost $solutionName
    
    $solutionComponents = Get-SolutionComponents $token $dataverseHost $solutionid

    $allowedSolutionComponents = $allowedComponents.Split(',')

    # Convert to int array
    [array]$c = foreach($number in $allowedSolutionComponents) {([int]::parse($number))}

    foreach ($solComp in $solutionComponents){
        Write-Host "$solComp"
        $isValid = $c -contains $solComp.componenttype
        if ($isValid){
            Write-Host "Componente permitido $solComp"
        } else{
            Write-Host "##vso[task.logissue type=error]Componente nao permitido na solution $solComp"
            exit 1
        }   
    }
}

function Get-SolutionId {
    param (
        [Parameter()] [String]$token,
        [Parameter(Mandatory)] [String]$dataverseHost,
        [Parameter(Mandatory)] [String]$solutionName
    )

    # Load Required PowerShell Files
    Invoke-Expression ". $env:POWERSHELLPATH/dataverse-webapi-functions.ps1"

    $requestUrlRemainder = "solutions?`$filter=uniquename%20eq%20%27$solutionName%27&`$select=solutionid"

    Write-Host "Query: $requestUrlRemainder"

    $response = Invoke-DataverseHttpGet $token $dataverseHost $requestUrlRemainder

    $responseJson = ($response | ConvertTo-Json)

    Write-Host "JSON: $responseJson"

    $solutionId = $response.value[0].solutionid

    Write-Host "SolutionId: $solutionid"

    return $solutionId
}

function Get-SolutionComponents {
    param (
        [Parameter()] [String]$token,
        [Parameter(Mandatory)] [String]$dataverseHost,
        [Parameter(Mandatory)] [String]$solutionId
    )

    # Load Required PowerShell Files
    Invoke-Expression ". $env:POWERSHELLPATH/dataverse-webapi-functions.ps1"

    $requestUrlRemainder = "solutioncomponents?`$filter=_solutionid_value%20eq%20%27$solutionId%27&`$apply=groupby((componenttype),aggregate(`$count as count))"

    Write-Host "Query: $requestUrlRemainder"

    $response = Invoke-DataverseHttpGet $token $dataverseHost $requestUrlRemainder

    $responseJson = ($response | ConvertTo-Json)

    Write-Host "JSON: $responseJson"

    $solutionComponents = $response.value

    return $solutionComponents
}