[CmdletBinding()]
param(
    [Parameter(Mandatory)] [String]$repoName,
    [Parameter(Mandatory)] [String]$sourceBranch,
    [Parameter(Mandatory)] [String]$targetBranch,
    [Parameter(Mandatory)] [String]$accessToken
)

$user = ""
$token = "$accessToken"

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $token)))

$uriCreatePR = "https://dev.azure.com/$(System.CollectionUri)/$(System.TeamProject)/_apis/git/repositories/$repoName/pullrequests?api-version=5.1"

$bodyCreatePR = "{sourceRefName:'$sourceBranch',targetRefName:'$targetBranch',title:'Sync changes from $sourceBranch'}"

$result = Invoke-RestMethod -Uri $uriCreatePR -Method Post -ContentType "application/json" -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo) } -Body $bodyCreatePR

Write-Host "PR Criado: $($result.pullRequestId)"