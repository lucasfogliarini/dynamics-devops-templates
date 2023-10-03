function Test-ConnectionReferences {
    param (
        [Parameter()] [String]$token,
        [Parameter(Mandatory)] [String]$dataverseHost,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [String]$displayNamePattern,
        [Parameter(Mandatory)] [String]$logicalNamePattern
    )
    
    # Load Required PowerShell Files
    Invoke-Expression ". $env:POWERSHELLPATH/dataverse-webapi-functions.ps1"

    $requestUrlRemainder = "solutions?`$filter=uniquename eq '$solutionName'"

    $responseSolutionInfo = Invoke-DataverseHttpGet $token $dataverseHost $requestUrlRemainder

    $responseJson = ($responseSolutionInfo | ConvertTo-Json)

    $solutionId = $responseSolutionInfo.value[0].solutionid
    
    Write-Host "SolutionId: $solutionId"

    $requestUrlConnectionStrings = "solutioncomponents?`$filter=_solutionid_value eq '$solutionId' and componenttype eq 10049"

    Write-Host "Query: $requestUrlConnectionStrings"

    $response = Invoke-DataverseHttpGet $token $dataverseHost $requestUrlConnectionStrings

    $responseJson = ($response | ConvertTo-Json)

    Write-Host "JSON: $responseJson"
   
    foreach ($sc in $response.value){
        $connectionReferenceId = $sc.objectid

        $urlConnectionReference = "connectionreferences($connectionReferenceId)?`$select=connectionreferencelogicalname,connectionreferencedisplayname"

        $responseConnectionReference = Invoke-DataverseHttpGet $token $dataverseHost $urlConnectionReference

        $responseConnectionReferenceJson = ($responseConnectionReference | ConvertTo-Json)

        Write-Host "JSON: $responseConnectionReferenceJson"

        $logicalName = $responseConnectionReference.connectionreferencelogicalname
        $displayName = $responseConnectionReference.connectionreferencedisplayname

        Write-Host "Logical Name: $logicalName / DisplayName: $displayName"

        if ($logicalName -notmatch $logicalNamePattern -or $displayName -notmatch $displayNamePattern){
            Write-Error "Solução contem referencias de conexão diferente das padrões"
            exit(1)
        }else {
            Write-Host "Conexao validada."
        }
    }
}