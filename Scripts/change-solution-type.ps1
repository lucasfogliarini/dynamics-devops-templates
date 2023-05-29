function Change-SolutionType {
    param(
        [string] $SolutionName,
        [string] $Repo,
        [string] $type
    )
    $path = "./$Repo/$SolutionName/Other/Solution.xml"

    # Get-ChildItem -Path "$env:BUILD_SOURCESDIRECTORY/$Repo/$SolutionName" -Recurse -Name

    Write-Host "Path: "$path

    [xml]$xmlContent = (Get-Content -Path $path)

    Write-Host "Solution XML: $xmlContent"

    try{
        Write-Host "Managed current value: "$xmlContent.ImportExportXml.SolutionManifest.Managed
        $xmlContent.ImportExportXml.SolutionManifest.Managed = $type
        Write-Host "Managed new value: "$xmlContent.ImportExportXml.SolutionManifest.Managed
        $xmlContent.Save($path)
        Write-Host "Solution type successfully changed."
    }
    Catch{
        Write-Error "Erro durante a tentativa de modificar o tipo da solution"
    }
}