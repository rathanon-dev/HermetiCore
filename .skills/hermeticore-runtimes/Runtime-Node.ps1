param(
    [Parameter(Mandatory=$true)][string]$TargetProjectName,
    [string]$NodeVersion = "latest"
)

$root = (Resolve-Path "$PSScriptRoot\..\..").Path
Import-Module (Join-Path $root ".skills\hermeticore-core\Core.psm1") -Force
$proxyUrl = Get-HermetiProxy -WorkspaceRoot $root
$toolsDir = Join-Path $root "tools"

if ($NodeVersion -eq "latest") {
    Write-Host " [*] Resolving latest Node.js..." -ForegroundColor Cyan -NoNewline
    $NodeVersion = Get-HermetiLatestNodeVersion -ProxyUrl $proxyUrl
    Write-Host " v$NodeVersion" -ForegroundColor Green
}

$projectRuntimeDir = Join-Path $root "projects\$TargetProjectName\runtime\tools\node"
$tempExtractDir = Join-Path $root "projects\$TargetProjectName\runtime\temp_node"
if (-not (Test-Path $tempExtractDir)) { New-Item -ItemType Directory -Path $tempExtractDir -Force | Out-Null }

Write-Host " [*] Downloading Node.js v$NodeVersion for Tier 2..." -ForegroundColor Cyan
$arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "win-x64" }
$zipName = "node-v$NodeVersion-$arch.zip"
$dlUrl = "https://nodejs.org/dist/v$NodeVersion/$zipName"
$zipPath = Join-Path $tempExtractDir $zipName

Invoke-HermetiDownload -Url $dlUrl -OutFile $zipPath -ProxyUrl $proxyUrl -ToolsDir $toolsDir
Write-Host " [*] Extracting Node.js..." -ForegroundColor Cyan
Expand-HermetiArchive -FilePath $zipPath -Destination $tempExtractDir -ToolsDir $toolsDir

$extractedDir = Get-ChildItem -Path $tempExtractDir -Filter "node-v$NodeVersion-$arch" -Directory | Select-Object -First 1
if (-not (Test-Path $projectRuntimeDir)) { New-Item -ItemType Directory -Path $projectRuntimeDir -Force | Out-Null }
Copy-Item "$($extractedDir.FullName)\*" $projectRuntimeDir -Recurse -Force
Remove-Item $tempExtractDir -Recurse -Force

if ($proxyUrl) {
    $npmrcPath = Join-Path $projectRuntimeDir ".npmrc"
    "proxy=$proxyUrl`nhttps-proxy=$proxyUrl`nstrict-ssl=false" | Set-Content $npmrcPath
    Write-Host " [+] .npmrc proxy configured." -ForegroundColor Green
}

Write-Host " [OK] Tier 2 Node.js Installed at: $projectRuntimeDir" -ForegroundColor Green
