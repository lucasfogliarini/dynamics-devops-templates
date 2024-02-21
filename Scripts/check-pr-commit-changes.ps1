function Get-PullRequest-ChangesByCommit {
    param(
        [Parameter(Mandatory)] [String]$repoName,
        [Parameter(Mandatory)] [String]$accessToken
    )

    $user = ""
    $token = "$accessToken"

    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $token)))

    # Lista todos os commits do Pull Request que iniciou o Release.
    $uriListPRCommits = "https://dev.azure.com/$(System.CollectionUri)/$(System.TeamProject)/_apis/git/repositories/$repoName/pullrequests/$(System.PullRequest.PullRequestId)/commits?api-version=7.0"

    $resultPRCommits = Invoke-RestMethod -Uri $uriListPRCommits -Method Get -ContentType "application/json" -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo) }

    Write-Host "Total de Commits relacionados: $($resultPRCommits.count)"

    foreach ($cmmt in $resultPRCommits.value){
        $uriGetCommitChanges = "https://dev.azure.com/$(System.CollectionUri)/$(System.TeamProject)/_apis/git/repositories/$repoName/commits/$(cmmt.commitId)/changes?api-version=7.0"
        $resultChanges = Invoke-RestMethod -Uri $uriGetCommitChanges -Method Get -ContentType "application/json" -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo) }

        if ($($resultChanges.changeCounts.Delete)) {
            Write-Host "Change Delete detectada nos commits relacionados. O UPGRADE de solution será aplicado"
            Write-Host "##vso[task.setvariable variable=ApplySolutionUpgrade]$true"
            exit 0
        }
    }
    Write-Host "Nenhum Change Delete detectada nos commits relacionados. O UPDATE de solution será aplicado"
}

