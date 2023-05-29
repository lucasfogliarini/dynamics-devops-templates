function Test-SolutionName {
    param (
        [Parameter()] [String]$token,
        [Parameter(Mandatory)] [String]$dataverseHost,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [String]$pattern
    )

    # Load Required PowerShell Files
    Invoke-Expression ". $env:POWERSHELLPATH/dataverse-webapi-functions.ps1"

    $requestUrlRemainder = "solutions?`$filter=uniquename eq '$($solutionName)'&`$select=uniquename,friendlyname,solutionid"

    Write-Host "Query: $requestUrlRemainder"

    $response = Invoke-DataverseHttpGet $token $dataverseHost $requestUrlRemainder

    $responseJson = ($response | ConvertTo-Json)

    Write-Host "JSON: $responseJson"

    $friendlyName = $response.value[0].friendlyname

    Write-Host "Solution name: $friendlyName"

    Write-Host "Pattern: $pattern"

    if($friendlyName -notmatch $pattern){
        $pattern = "$($pattern)_\d+$"

        Write-Host "Pattern: $pattern"

        if ($friendlyName -notmatch $pattern) {
            Write-Error "Nome da solucao fora do padrao de nomenclatura"
            exit(1)
        }
    }
}