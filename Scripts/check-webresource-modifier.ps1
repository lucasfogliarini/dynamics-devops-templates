function Get-UnallowedWRModifiers {
    param(
        [string]$url,
        [string]$token,
        [string]$solutionName
        [string]$allowedModifier
    )

    $fetchXml = @"
        <fetch>
            <entity name='webresource'>
                <attribute name='name' />
                <attribute name='webresourceid' />
                <filter>
                    <condition attribute="webresourcetype" operator="eq" value="3" />
                    <condition attribute="modifiedby" operator="ne" value="$($allowedModifier)" />
                </filter>
                <link-entity name='solutioncomponent' from='objectid' to='webresourceid' link-type='inner' alias='sc'>
                <link-entity name='solution' from='solutionid' to='solutionid' link-type='inner' alias='s'>
                    <filter>
                        <condition attribute='uniquename' operator='eq' value='$solutionName' />
                    </filter>
                </link-entity>
                </link-entity>
            </entity>
        </fetch>
"@;

    $fetchEncoded = [uri]::EscapeDataString($fetchXml)
    
    Write-Host "Query: $fetchEncoded"

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")
    $headers.Add("Authorization", "Bearer $token")

    $response = Invoke-RestMethod "$url/api/data/v9.1/webresourceset?fetchXml=$fetchEncoded" -Method 'GET' -Headers $headers

    if ($($response.value).Count -eq 0)
    {
        Write-Host "Nenhum JavaScript em $solutionName foi modificado por usuário não autorizado"
        exit(0)
    }
    else {
        Write-Error "A solução $solutionName contém modificadores de JavaScript não autorizados"
        exit(1)
    }