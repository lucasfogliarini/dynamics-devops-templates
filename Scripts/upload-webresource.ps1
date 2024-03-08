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

    $requestUrlRemainder = "webresourceset?fetchXml=$fetchEncoded"
    $response = Invoke-DataverseHttpGet $token $url $requestUrlRemainder
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
    
    Write-Host "Org URL: $url"
    Write-Host "SolutionName: $solutionName"

    Invoke-Expression ". $env:POWERSHELLPATH/dataverse-webapi-functions.ps1"

    $webresources = (Get-SolutionWebResourcesJavaScript $url $token $solutionName).value

    if ($webresources.Count -eq 0)
    {
        Write-Host "Nenhum JavaScript localizado na solution $solutionName"
        exit(0)
    }

    foreach ($resource in $webresources){
        $resourceId = $resource.webresourceid
        $currentResourceName = $($resource.name)
        if (!$($resource.name).Contains('.js')) {
            $currentResourceName = "$($resource.name).js"
        }

        $localFile = Join-Path -Path $webResourcePath -ChildPath $currentResourceName
        Write-Host "Local File: $localFile - Resource Id: $resourceId"

        Write-Host (ConvertTo-Json $resource)
       
        $content = [System.IO.File]::ReadAllBytes($localFile);
        $content64 = [System.Convert]::ToBase64String($content);
        
        # Write-Host $content64

        if ($content64 -ne $resource.content) {
            $resource.content = $content64;
            $requestBody = $resource | ConvertTo-Json

            $requestUrlRemainder = "webresourceset($resourceId)"

            $response = Invoke-DataverseHttpPost $token $url $requestUrlRemainder $requestBody 
            $responseJson = $response | ConvertTo-Json

            Write-Host "Javascript atualizado."
        }
        else {
            Write-Output "Javascript '$($resource.name)' ja esta atualizado."
        }
    }
}