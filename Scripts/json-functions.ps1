<#
This function formats canvas app json files.
#>
function Format-JSON-Files 
{
    param (
        [Parameter(Mandatory)] [String]$solutionComponentsPath
    )
   Get-ChildItem -Path "$solutionComponentsPath" -Recurse -Filter *.json | 
   ForEach-Object {
    #skip canvas app and workflows folder because canvas and flows team already handles this
     if(-not $_.FullName.Contains('CanvasApps') -and -not $_.FullName.Contains('Workflows')) {
       Write-Host $_.FullName
       #$formatted = jq . $_.FullName --sort-keys
       $formatted | Out-File $_.FullName -Encoding utf8NoBOM
     }
   }
}