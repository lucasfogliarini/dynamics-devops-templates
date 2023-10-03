[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$repoName,
    [Parameter(Mandatory)] [string]$accessToken
)
Invoke-Expression ". .\create-pull-request.ps1"

Write-Host "Repository: $repoName"
Write-Host "Release Environment Name: $env:RELEASE_ENVIRONMENTNAME" 
Write-Host "Stage Display Name: $env:SYSTEM_STAGEDISPLAYNAME"
Write-Host "Stage HML Status: $env:RELEASE_ENVIRONMENTS_HML_STATUS"
Write-Host "Stage PRD Status: $env:RELEASE_ENVIRONMENTS_PRD_STATUS"

if($env:SYSTEM_STAGEDISPLAYNAME -eq "QA")
{
    Add-PullRequest "$repoName" "refs/heads/qa" "refs/heads/hml" "$accessToken" $true
}

if($env:SYSTEM_STAGEDISPLAYNAME -eq "HML")
{
    Add-PullRequest "$repoName" "refs/heads/hml" "refs/heads/master" "$accessToken" $true
}