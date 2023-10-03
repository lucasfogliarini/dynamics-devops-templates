function Remove-BusinessHours {
    param(
        [string] $SolutionName,
        [string] $Repo
    )

    $path = "./$Repo/$SolutionName/Slas"

    Write-Host "Path: "$path

    $slas = Get-ChildItem $path -Recurse -Include "*.meta.xml"

    foreach ($sla in $slas) {
        
        [xml]$xmlContent = (Get-Content -Path $sla)

        # Remove MissingDependency nodes
        if ($xmlContent.SLA.SlaItems -is [Xml.XmlElement]) {
            
            $xmlContent.SLA.SlaItems.SlaItem | % { $_.SelectSingleNode('businesshoursid') | % { $_.ParentNode.RemoveChild($_) | Out-Null} }

            $xmlContent.Save($sla)

            Write-Host "Businesshours removidas com sucesso."
        }
        else {
            Write-Host "Nao foi encontrada nenhuma entrada de Businesshours no arquivo."
        }
    }
}
