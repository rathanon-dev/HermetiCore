param(
    [Parameter(Mandatory=$true)][string]$TargetProjectName,
    [string]$PythonVersion = "3.12.5",
    [string]$InstallPackages = ""
)

$root = (Resolve-Path "$PSScriptRoot\..\..").Path
Import-Module (Join-Path $root ".skills\hermeticore-core\Core.psm1") -Force
$proxyUrl = Get-HermetiProxy -WorkspaceRoot $root
$toolsDir = Join-Path $root "tools"

$projectRuntimeDir = Join-Path $root "projects\$TargetProjectName\runtime\tools\python"
$tempExtractDir = Join-Path $root "projects\$TargetProjectName\runtime\temp_python"
if (-not (Test-Path $tempExtractDir)) { New-Item -ItemType Directory -Path $tempExtractDir -Force | Out-Null }

Write-Host " [*] Downloading Python v$PythonVersion (NuGet) for Tier 2..." -ForegroundColor Cyan
$pkgId = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "pythonarm64" } else { "python" }
$nupkgName = "$pkgId.$PythonVersion.nupkg"
$dlUrl = "https://api.nuget.org/v3-flatcontainer/$pkgId/$PythonVersion/$nupkgName"
$nupkgPath = Join-Path $tempExtractDir $nupkgName

Invoke-HermetiDownload -Url $dlUrl -OutFile $nupkgPath -ProxyUrl $proxyUrl -ToolsDir $toolsDir
Write-Host " [*] Extracting Python (Microsoft NuGet Native)..." -ForegroundColor Cyan
$outDir = Join-Path $tempExtractDir "out"
Expand-HermetiArchive -FilePath $nupkgPath -Destination $outDir -ToolsDir $toolsDir

$sourceTools = if (Test-Path "$outDir\tools\python.exe") { "$outDir\tools" } else { $outDir }
if (-not (Test-Path $projectRuntimeDir)) { New-Item -ItemType Directory -Path $projectRuntimeDir -Force | Out-Null }
Copy-Item "$sourceTools\*" $projectRuntimeDir -Recurse -Force
Remove-Item $tempExtractDir -Recurse -Force

# Pip Bootstrap
$pyExe  = Join-Path $projectRuntimeDir "python.exe"
$pipExe = Join-Path $projectRuntimeDir "Scripts\pip.exe"
Get-ChildItem -Path $projectRuntimeDir -Filter "*._pth" -ErrorAction SilentlyContinue | ForEach-Object {
    $c = Get-Content $_.FullName; $c = $c -replace '#\s*import site', 'import site'; Set-Content $_.FullName -Value $c
}
Write-Host " [*] Bootstrapping pip via ensurepip..." -ForegroundColor Cyan
& $pyExe -m ensurepip --upgrade 2>&1 | Out-Null
if (-not (Test-Path $pipExe)) {
    & $pyExe -m pip install --force-reinstall --no-cache-dir pip 2>&1 | Out-Null
}
if (-not (Test-Path $pipExe)) {
    $getPipPath = Join-Path $projectRuntimeDir "get-pip.py"
    Invoke-HermetiDownload -Url "https://bootstrap.pypa.io/get-pip.py" -OutFile $getPipPath -ProxyUrl $proxyUrl -ToolsDir $toolsDir
    & $pyExe $getPipPath --no-warn-script-location 2>&1 | Out-Null
    Remove-Item $getPipPath -Force -ErrorAction SilentlyContinue
}

if ($proxyUrl) {
    $proxyHost = ([System.Uri]$proxyUrl).Host
    $pipIniPath = Join-Path $projectRuntimeDir "pip.ini"
    "[global]`nindex-url = $proxyUrl/pypi/simple/`ntrusted-host = $proxyHost`ntimeout = 30" | Set-Content $pipIniPath
    & $pyExe -m pip config set global.index-url "$proxyUrl/pypi/simple/" | Out-Null
    & $pyExe -m pip config set global.trusted-host $proxyHost | Out-Null
}

if ($InstallPackages) {
    $pkgList = $InstallPackages -split '\s+' | Where-Object { $_ -ne "" }
    Write-Host " [*] Installing packages: $($pkgList -join ', ')..." -ForegroundColor Cyan
    & $pyExe -m pip install @pkgList 2>&1 | Out-Null
}

Write-Host " [OK] Tier 2 Python Isolated Runtime Created at: $projectRuntimeDir" -ForegroundColor Green
