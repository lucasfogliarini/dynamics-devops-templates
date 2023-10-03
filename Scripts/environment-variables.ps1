function Check-NewEnvironmentVariables {
    param(
        [string] $SolutionName,
        [string] $Repo
    )
    $path = "./$Repo/$SolutionName"

    $folders = Get-ChildItem -Path "./$Repo/$SolutionName/environmentvariabledefinitions" -Directory

    $fileQA = Get-Content -Raw "./$Repo/Settings/environment-qa.json" | ConvertFrom-Json
    $fileHml = Get-Content -Raw "./$Repo/Settings/environment-hml.json" | ConvertFrom-Json
    $fileProd = Get-Content -Raw "./$Repo/Settings/environment-prod.json" | ConvertFrom-Json

    Write-Host ""
    Write-Host "======================================================================"
    Write-Host "Variaveis de ambiente em QA: $($fileQA.EnvironmentVariables.Count)"
    Write-Host "Variaveis de ambiente em Hml: $($fileHml.EnvironmentVariables.Count)"
    Write-Host "Variaveis de ambiente em Prod: $($fileProd.EnvironmentVariables.Count)"
    
    if ($fileQA.EnvironmentVariables.Count -ne $fileHml.EnvironmentVariables.Count) {
        Write-Host "##vso[task.logissue type=warning]Existe uma divergência na quantidade de variáveis entre QA e HML."
    }

    if ($fileQA.EnvironmentVariables.Count -ne $fileProd.EnvironmentVariables.Count) {
        Write-Host "##vso[task.logissue type=warning]Existe uma divergência na quantidade de variáveis entre QA e PROD."
    }

    Write-Host "======================================================================"
    Write-Host ""

    $errors = 0

    foreach ($folder in $folders){
        [xml]$xmlContent = (Get-Content -Path "$path/environmentvariabledefinitions/$folder/environmentvariabledefinition.xml")
        $variableSchemaName = $xmlContent.environmentvariabledefinition.schemaname
        Write-Host ""
        Write-Host "Processando variavel: $variableSchemaName"

        $matchesSchemaNameQA = $fileQA.EnvironmentVariables | Where-Object {$_.SchemaName -eq $variableSchemaName} | Measure-Object
        $matchesSchemaNameHml = $fileHml.EnvironmentVariables | Where-Object {$_.SchemaName -eq $variableSchemaName} | Measure-Object
        $matchesSchemaNameProd = $fileProd.EnvironmentVariables | Where-Object {$_.SchemaName -eq $variableSchemaName} | Measure-Object

        Write-Host "$($matchesSchemaNameQA.Count) encontrados no arquivo do ambiente QA."
        Write-Host "$($matchesSchemaNameHml.Count) encontrados no arquivo do ambiente HML."
        Write-Host "$($matchesSchemaNameProd.Count) encontrados no arquivo do ambiente PROD."

        # Se a variável não estiver no arquivo incluir
        if ($matchesSchemaNameQA.Count -lt 1 -and -not ($variableSchemaName -ilike "*feature*") ) {
            $fileQA.EnvironmentVariables += @{SchemaName=$variableSchemaName; Value=''}
            Write-Host "##vso[task.logissue type=warning]Variável $variableSchemaName foi adicionada sem valor ao arquivo environment-qa.json"
            Write-Host "Variavel adicionada ao arquivo de QA."
            $errors = $errors + 1
        }

        # Se a variável não estiver no arquivo incluir
        if ($matchesSchemaNameHml.Count -lt 1 -and -not ($variableSchemaName -ilike "*feature*") ) {
            $fileHml.EnvironmentVariables += @{SchemaName=$variableSchemaName; Value=''}
            Write-Host "##vso[task.logissue type=warning]Variável $variableSchemaName foi adicionada sem valor ao arquivo environment-hml.json"
            Write-Host "Variavel adicionada ao arquivo de HML."
            $errors = $errors + 1
        }

        # Se a variável não estiver no arquivo incluir
        if ($matchesSchemaNameProd.Count -lt 1 -and -not ($variableSchemaName -ilike "*feature*") ) {
            $fileProd.EnvironmentVariables += @{SchemaName=$variableSchemaName; Value=''}
            Write-Host "##vso[task.logissue type=warning]Variável $variableSchemaName foi adicionada sem valor ao arquivo environment-prod.json"
            Write-Host "Variavel adicionada ao arquivo de PROD."
            $errors = $errors + 1
        }
    }

    Write-Host ""
    Write-Host "Escrevendo no arquivo environment-qa.json"
    ConvertTo-Json $fileQA | Out-File -FilePath "./$Repo/Settings/environment-qa.json"
    Write-Host "Escrita com sucesso!"

    Write-Host ""
    Write-Host "Escrevendo no arquivo environment-hml.json"
    ConvertTo-Json $fileHml | Out-File -FilePath "./$Repo/Settings/environment-hml.json"
    Write-Host "Escrita com sucesso!"

    Write-Host ""
    Write-Host "Escrevendo no arquivo environment-prod.json"
    ConvertTo-Json $fileProd | Out-File -FilePath "./$Repo/Settings/environment-prod.json"
    Write-Host "Escrita com sucesso!"

    if ($errors -gt 0) {
        Write-Host "##vso[task.logissue type=error]$errors variáveis sem valor nos arquivos de configuração"
        exit(1)
    }
}

function Remove-EnvironmentVariablesValues {
    param(
        [string] $SolutionName,
        [string] $Repo
    )

    Write-Host "Removing all environmentvariablevalues.json"
    Get-ChildItem -Path "./$Repo/$SolutionName/environmentvariabledefinitions" -Include environmentvariablevalues.json -Recurse | Remove-Item
    Write-Host "Done!"
}