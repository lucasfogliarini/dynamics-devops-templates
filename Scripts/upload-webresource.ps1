function Get-SolutionWebResourcesJavaScript {
    param(
        [string]$url,
        [string]$token,
        [string]$solutionName
    )

    $fetchXml = @"
        <fetch>
            <entity name='webresource'>
                <attribute name='displayname' />
                <attribute name='name' />
                <attribute name='webresourceid' />
                <attribute name='webresourcetype' />
                <attribute name='content' />
                <filter>
                    <condition attribute="webresourcetype" operator="eq" value="3" />
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
    $responseJson = $response | ConvertTo-Json
    
    # Write-Host $responseJson

    return $response
}

function Upload-Javascript {
    param(
        [string]$url,
        [string]$token,
        [string]$solutionName,
        [string]$webResourcePath
    )

    $webresources = (Get-SolutionWebResourcesJavaScript $url $token $solutionName).value

    if ($webresources.Count -eq 0)
    {
        Write-Host "Nenhum JavaScript localizado na solution $solutionName"
        exit(0)
    }


    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")
    $headers.Add("Authorization", "Bearer $token")


    foreach ($resource in $webresources){
        $resourceId = $resource.webresourceid

        $localFile = Join-Path -Path $webResourcePath -ChildPath "$($resource.name).js"
        Write-Host "Local File: $localFile - Resource Id: $resourceId"

        # Write-Host (ConvertTo-Json $resource)
       
        $content = [System.IO.File]::ReadAllBytes($localFile);
        $content64 = [System.Convert]::ToBase64String($content);
        
        # Write-Host $content64

        if ($content64 -ne $resource.content) {
            $resource.content = $content64;
            $requestBody = $resource | ConvertTo-Json

            $response = Invoke-RestMethod "$url/api/data/v9.1/webresourceset($resourceId)" -Method Patch -Headers $headers -Body $requestBody
            $responseJson = $response | ConvertTo-Json

            Write-Host "Javascript atualizado."
        }
        else {
            Write-Output "Javascript '$($resource.name)' ja esta atualizado."
        }
    }
}