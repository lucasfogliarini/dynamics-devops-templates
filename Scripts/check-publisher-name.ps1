function Test-PublisherPrefix {
    param (
        [Parameter()] [String]$token,
        [Parameter(Mandatory)] [String]$dataverseHost,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [String]$publisherName
    )

    # Load Required PowerShell Files
    Invoke-Expression ". $env:POWERSHELLPATH/dataverse-webapi-functions.ps1"

    $requestUrlRemainder = "solutions?`$filter=uniquename eq '$($solutionName)'&`$expand=publisherid"

    Write-Host "Query: $requestUrlRemainder"

    $response = Invoke-DataverseHttpGet $token $dataverseHost $requestUrlRemainder

    $responseJson = ($response | ConvertTo-Json)

    Write-Host "JSON: $responseJson"

    $publisherPrefix = $response.value[0].publisherid.uniquename

    Write-Host "Publisher: $publisherPrefix"

    if ($publisherPrefix -ne $publisherName) {
        Write-Error "Distribuidor da solução diferente de $publisherName"
        exit(1)
    }
}