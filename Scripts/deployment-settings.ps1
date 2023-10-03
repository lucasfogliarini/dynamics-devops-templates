function Set-DeletedFiles {
    $deletedFiles = git diff --name-only --diff-filter D
    
    Write-Host "Arquivos deletados: $($deletedFiles.Count)"

    foreach ($deletedFile in $deletedFiles) {
        Write-Host "Arquivo deletado: $deletedFile"
    }

    # Se tem pelo menos um arquivo deletado
    if($deletedFiles.Count -gt 0) {
        return $true
    }else{
        return $false
    }
}

function Test-ConnRefsOrEnvVars {
    param(
        [string]$environmentVariablesPath,
        [string]$customizationsXmlPath
    )

    if(Test-Path -Path $customizationsXmlPath) {
        [xml]$xmlContent = (Get-Content -Path $customizationsXmlPath)
        if ($xmlContent.ImportExportXml.connectionreferences -is [Xml.XmlElement]) {
            Write-Host "Foram encontradas $($xmlContent.ImportExportXml.connectionreferences.ChildNodes.Count) referencias de conexao"

            foreach($connRef in $xmlContent.ImportExportXml.connectionreferences.ChildNodes) {
                Write-Host "$($connRef.connectionreferencedisplayname) - $($connRef.connectorid)"
            }

            if($xmlContent.ImportExportXml.connectionreferences.ChildNodes.Count -gt 0 ) {
                return $true
            }
        }
    }

    if(Test-Path -Path $environmentVariablesPath) {
        return $true
    }

    return $false
}