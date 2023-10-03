function Test-TableBehavior {
    param(
        [string]$url,
        [string]$token,
        [string]$solutionName
    )

    Invoke-Expression ". $env:POWERSHELLPATH/dataverse-webapi-functions.ps1"

    $solutionid = Get-SolutionId $token $url $solutionName

    $querystring = "solutioncomponents?`$filter=_solutionid_value%20eq%20%27$solutionid%27%20and%20componenttype%20eq%201%20and%20rootcomponentbehavior%20eq%200"

    $response = Invoke-DataverseHttpGet $token $url $querystring

    Write-Host "Response: $response"

    if($response.value.Count -gt 0){
        Write-Host "$($response.value.Count) tabelas encontradas com todos os componentes incluidos, por favor remova da solucao e inclua novamente sem marcar a opcao 'Incluir todos componentes'"
        exit(1)
    }
}


function Get-SolutionId {
    param (
        [Parameter()] [String]$token,
        [Parameter(Mandatory)] [String]$dataverseHost,
        [Parameter(Mandatory)] [String]$solutionName
    )

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