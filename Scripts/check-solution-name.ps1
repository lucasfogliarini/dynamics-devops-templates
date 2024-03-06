function Test-SolutionName {
    param (
        [Parameter()] [String]$token,
        [Parameter(Mandatory)] [String]$dataverseHost,
        [Parameter(Mandatory)] [String]$solutionName
    )
    $prefixName = ($solutionName -split '_hf')[0]
    $pattern = "^$($prefixName)_hf_\d+(_\w+)?$"
 
    Write-Host "solution name: $solutionName"
    Write-Host "Prefix name: $prefixName"
    Write-Host "Pattern: $pattern"
 
    if((-not $solutionName.Contains('_hf')) -or ("" -eq $prefixName) -or ($solutionName -notmatch $pattern)){
        Write-Error "Nome da solucao fora do padrao de nomenclatura, utilize <NomeLogicoDaFeature>_hf_<NumeroDoBug>."
        exit(1)
    }
    else{
        #Load Required PowerShell Files
        Invoke-Expression ". $env:POWERSHELLPATH/dataverse-webapi-functions.ps1"
 
        $request = "solutions?`$filter=uniquename eq '$($prefixName)'&`$select=uniquename"
   
        Write-Host "Query: $request"
   
        $response = Invoke-DataverseHttpGet $token $dataverseHost $request
   
        $responseJson = ($response | ConvertTo-Json)
        Write-Host "JSON: $responseJson"
 
        if($($response.value[0].uniquename)){
            Write-Host "Sucesso!"
        }
    }
}