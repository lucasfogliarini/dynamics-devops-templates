function Test-SecurityRole {
    param(
        [string] $SolutionName,
        [string] $Repo
    )

    $path = "./$Repo/$SolutionName/Roles"

    Write-Host "Path: "$path

    $roles = Get-ChildItem $path -Recurse -Include "*.xml"

    $wrongRoles = @{}

    foreach ($role in $roles) {
        
        $wrongPrivileges = @()

        [xml]$xmlContent = (Get-Content -Path $role)

        Write-Host ""
        Write-Host "Processando o arquivo $($role)"
        Write-Host ""

        if ($xmlContent.Role.RolePrivileges -is [Xml.XmlElement]) {

            $privileges = $xmlContent.Role.RolePrivileges | Select-Object -ExpandProperty childnodes | Where-Object {$_.name -like '*delete*'}

            $privileges | ForEach-Object -Process  { 
                if ($_.level -eq 'Global') { 
                    $wrongPrivileges += "$($_.name) / $($_.level)"
                }
            }

            if ($wrongPrivileges.Count -gt 0) {
                $wrongRoles.Add($role.Name, $wrongPrivileges)
            }
            
        }
        else {
            Write-Host "Nao foi encontrada nenhuma entrada de Role no arquivo."
        }
    }

    if ($wrongRoles.Count -gt 0) {
        Write-Host "Um ou mais perfis de seguranca foram detectados com permissao de delete."
        Write-Host ""
        Display-AnalisysResult $wrongRoles
        exit(1)
    }else{
        Write-Host "OK!"
    }
}

function Show-AnalisysResult {
    param(
        [hashtable]$wrongRoles
    )

    $wrongRoles.keys | ForEach-Object -Process {
        
        Write-Host "Arquivo: $($_)"

        $wrongRoles[$_] | ForEach-Object -Process {
            Write-Host "    $($_)"
        }
    }
}