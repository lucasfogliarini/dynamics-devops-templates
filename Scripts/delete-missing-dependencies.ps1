function Remove-MissingDependeciesNode {
    param(
        [string] $SolutionName,
        [string] $Repo
    )

    $path = "./$Repo/$SolutionName/Other/Solution.xml"

    Write-Host "Path: "$path

    [xml]$xmlContent = (Get-Content -Path $path)

# Remove MissingDependency nodes
if ($xmlContent.ImportExportXml.SolutionManifest.MissingDependencies -is [Xml.XmlElement]) {
    $xmlContent.ImportExportXml.SolutionManifest.MissingDependencies.MissingDependency | %{ $_.ParentNode.RemoveChild($_) | Out-Null }

    $xmlContent.Save($path)
    Write-Host "MissingDependencies removidas com sucesso."
}else{
    Write-Host "Nao foi encontrada nenhuma entrada de MissingDependencies no arquivo."
}

}
