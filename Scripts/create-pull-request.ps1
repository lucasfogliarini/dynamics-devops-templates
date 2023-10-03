function Add-PullRequest {
    param(
        [Parameter(Mandatory)] [String]$repoName,
        [Parameter(Mandatory)] [String]$sourceBranch,
        [Parameter(Mandatory)] [String]$targetBranch,
        [Parameter(Mandatory)] [String]$accessToken,
        [bool]$autoComplete
    )

    $user = ""
    $token = "$accessToken"

    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $token)))

    # Antes de criar um PR verifica se ja existe um ativo.
    $uriGetActivePR = "https://dev.azure.com/$(System.CollectionUri)/$(System.TeamProject)/_apis/git/repositories/$repoName/pullrequests?searchCriteria.status=active&searchCriteria.sourceRefName=$sourceBranch&searchCriteria.targetRefName=$targetBranch&api-version=7.0"

    $resultGet = Invoke-RestMethod -Uri $uriGetActivePR -Method Get -ContentType "application/json" -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo) }

    Write-Host "PR Abertos: $($resultGet.count)"

    if ($resultGet.count -gt 0) {
        Write-Host "Nenhum PR sera criado, ja existe um ativo."
    }
    else {
        $uriCreatePR = "https://dev.azure.com/$(System.CollectionUri)/$(System.TeamProject)/_apis/git/repositories/$repoName/pullrequests?api-version=5.1"

        if($autoComplete){
            
            $bodyCreatePR = @{
                sourceRefName = $sourceBranch
                targetRefName = $targetBranch
                title = "Sync changes from $sourceBranch"
                completionOptions = @{ 
                    deleteSourceBranch = $false
                    mergeStrategy = "noFastForward"
                }
                status = "completed"
            }

        }else{
            
            $bodyCreatePR = @{
                sourceRefName = $sourceBranch
                targetRefName = $targetBranch
                title = "Sync changes from $sourceBranch"
            }
        }
        
        $jsonBody = ConvertTo-Json $bodyCreatePR
        $result = Invoke-RestMethod -Uri $uriCreatePR -Method Post -ContentType "application/json" -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo) } -Body $jsonBody

        Write-Host "PR Criado: $($result.pullRequestId)"
    }
}

