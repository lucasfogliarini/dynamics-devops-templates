function Check-Relationships {
    param(
        [string] $SolutionName,
        [string] $Repo
    )

    $path = "./$Repo/$SolutionName/Other/Relationships"

    Write-Host "Path: "$path

    $relationships = Get-ChildItem $path -Recurse -Include "*.xml"

    $wrongRelationships = @()

    foreach ($relationship in $relationships) {
        
        [xml]$xmlContent = (Get-Content -Path $relationship)

        Write-Host ""
        Write-Host "Processando o arquivo $($relationship.Name)"
        Write-Host ""

        if ($xmlContent.EntityRelationships -is [Xml.XmlElement]) {

            $relationships = $xmlContent.EntityRelationships | select -ExpandProperty childnodes #| where {$_.name -like '*delete*'}

            $relationships | ForEach-Object -Process  { 

                if ($_.CascadeDelete -eq "Cascade") {
                    $wrongRelationships += $relationship.Name
                    Write-Host "    Relacionamento $($_.Name) usa uma opcao nao permitida na propriedade cascade delete."
                }
            }
        }
        else {
            Write-Host "Nao foi encontrada nenhuma entrada de Role no arquivo."
        }
    }

    if ($wrongRelationships.Count -gt 0) {
        exit(1)
    }else{
        Write-Host "OK!"
    }
}