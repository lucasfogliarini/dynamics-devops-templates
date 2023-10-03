function RenameFormsToManaged {
    param(
        [Parameter(Mandatory)][string] $SolutionName,
        [Parameter(Mandatory)][string] $Repo
    )

    $oldExtension = ".xml"
    $newExtension = "_managed.xml"
    $formsPath = "./$Repo/$SolutionName/Entities"
    
    if(Test-Path $formsPath) {
        
        $forms = Get-ChildItem $formsPath -Recurse -Include "*.xml" | Where-Object { ($_.FullName -match "FormXml") -and ($_.Name -notmatch "_managed") -and !$_.PSIsContainer }
        
        foreach ($form in $forms) {
            Write-Host "Renomeando $($form.FullName)"
            $newName = $form.Name -replace "$oldExtension", "$newExtension"
            Write-Host "New name: $($newName)"
            Rename-Item -NewName $newName -Path $form.FullName
        }
    }else {
        Write-Host "Nenhuma entidade encontrada na solution."
    }
}