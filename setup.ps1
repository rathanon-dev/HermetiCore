# ==============================================================================
# HermetiCore v1.4 — Tier 1 Shared Toolchain Setup (Refactored to Core Module)
# ==============================================================================
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$root = $PSScriptRoot
$toolsDir = Join-Path $root "tools"
$tempDir  = Join-Path $root "temp_setup"
if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir -Force | Out-Null }

# Load Core Module
Import-Module (Join-Path $root ".skills\hermeticore-core\Core.psm1") -Force
$proxyUrl = Get-HermetiProxy -WorkspaceRoot $root
if ($proxyUrl) { Write-Host " [PROXY] OmniProxy LAN Gateway Active ($proxyUrl)" -ForegroundColor Green }

# ------------------------------------------------------------------------------
# 1. 7-Zip (Bootstrap)
# ------------------------------------------------------------------------------
$7zDir = Join-Path $toolsDir "7zip"
$7zExe = Join-Path $7zDir "7za.exe"
if (-not (Test-Path $7zExe)) {
    Write-Host " [*] Downloading 7-Zip (NuGet)..." -ForegroundColor Cyan
    # Get latest version from NuGet Search API
    $searchUrl = "https://azuresearch-usnc.nuget.org/query?q=packageid:7-Zip.CommandLine&prerelease=false"
    $searchRes = Invoke-HermetiAPI -Url $searchUrl -ProxyUrl $proxyUrl -AsJson
    $latestVersion = $searchRes.data[0].version
    
    $zUrl = "https://www.nuget.org/api/v2/package/7-Zip.CommandLine/$latestVersion"
    $zZip = Join-Path $tempDir "7z.zip"
    Invoke-HermetiDownload -Url $zUrl -OutFile $zZip -ProxyUrl $proxyUrl -ToolsDir $toolsDir
    
    $zOut = Join-Path $tempDir "7z_extract"
    Expand-HermetiArchive -FilePath $zZip -Destination $zOut -ToolsDir $toolsDir
    if (-not (Test-Path $7zDir)) { New-Item -ItemType Directory -Path $7zDir -Force | Out-Null }
    Move-Item -Path (Join-Path $zOut "tools\7za.exe") -Destination $7zExe -Force
}
Write-Host " [OK] 7-Zip Ready." -ForegroundColor Green

# ------------------------------------------------------------------------------
# 2. Aria2c
# ------------------------------------------------------------------------------
$aria2Dir = Join-Path $toolsDir "aria2"
$aria2Exe = Join-Path $aria2Dir "aria2c.exe"
if (-not (Test-Path $aria2Exe)) {
    Write-Host " [*] Downloading Aria2c..." -ForegroundColor Cyan
    $aUrl = "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip"
    $aZip = Join-Path $tempDir "aria2.zip"
    Invoke-HermetiDownload -Url $aUrl -OutFile $aZip -ProxyUrl $proxyUrl -ToolsDir $toolsDir
    Expand-HermetiArchive -FilePath $aZip -Destination $tempDir -ToolsDir $toolsDir
    $extractedAriaDir = Get-ChildItem -Path $tempDir -Filter "aria2-*-win-64bit-build1" -Directory | Select-Object -First 1
    if (-not (Test-Path $aria2Dir)) { New-Item -ItemType Directory -Path $aria2Dir -Force | Out-Null }
    Copy-Item -Path "$($extractedAriaDir.FullName)\*" -Destination $aria2Dir -Recurse -Force
}
Write-Host " [OK] Aria2c Ready." -ForegroundColor Green

# ------------------------------------------------------------------------------
# 3. Portable Git
# ------------------------------------------------------------------------------
$gitDir = Join-Path $toolsDir "git"
if (-not (Test-Path "$gitDir\cmd\git.exe")) {
    Write-Host " [*] Downloading Portable Git..." -ForegroundColor Cyan
    $gUrl = "https://github.com/git-for-windows/git/releases/download/v2.46.0.windows.1/PortableGit-2.46.0-64-bit.7z.exe"
    $gExe = Join-Path $tempDir "git.7z.exe"
    Invoke-HermetiDownload -Url $gUrl -OutFile $gExe -ProxyUrl $proxyUrl -ToolsDir $toolsDir
    Expand-HermetiArchive -FilePath $gExe -Destination $gitDir -ToolsDir $toolsDir
}
Write-Host " [OK] Portable Git Ready." -ForegroundColor Green

# ------------------------------------------------------------------------------
# 4. Node.js
# ------------------------------------------------------------------------------
$nodeDir = Join-Path $toolsDir "node"
$nodeExe = Join-Path $nodeDir "node.exe"
if (-not (Test-Path $nodeExe)) {
    Write-Host " [*] Downloading Node.js..." -ForegroundColor Cyan
    $arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "win-x64" }
    $nUrl = "https://nodejs.org/dist/v20.17.0/node-v20.17.0-$arch.zip"
    $nZip = Join-Path $tempDir "node.zip"
    Invoke-HermetiDownload -Url $nUrl -OutFile $nZip -ProxyUrl $proxyUrl -ToolsDir $toolsDir
    Expand-HermetiArchive -FilePath $nZip -Destination $tempDir -ToolsDir $toolsDir
    $extractedNodeDir = Get-ChildItem -Path $tempDir -Filter "node-v20.17.0-$arch" -Directory | Select-Object -First 1
    if (-not (Test-Path $nodeDir)) { New-Item -ItemType Directory -Path $nodeDir -Force | Out-Null }
    Copy-Item -Path "$($extractedNodeDir.FullName)\*" -Destination $nodeDir -Recurse -Force
}
Write-Host " [OK] Node.js Ready." -ForegroundColor Green

# ------------------------------------------------------------------------------
# 5. Python (NuGet) & Pip Bootstrap
# ------------------------------------------------------------------------------
$pythonDir = Join-Path $toolsDir "python"
$pythonExe = Join-Path $pythonDir "python.exe"
$pipExe    = Join-Path $pythonDir "Scripts\pip.exe"
if (-not (Test-Path $pipExe)) {
    Write-Host " [*] Downloading Python 3.12.5 (NuGet)..." -ForegroundColor Cyan
    $pkgId = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "pythonarm64" } else { "python" }
    $pUrl = "https://api.nuget.org/v3-flatcontainer/$pkgId/3.12.5/$pkgId.3.12.5.nupkg"
    $pPkg = Join-Path $tempDir "python.nupkg"
    Invoke-HermetiDownload -Url $pUrl -OutFile $pPkg -ProxyUrl $proxyUrl -ToolsDir $toolsDir
    
    $pOut = Join-Path $tempDir "python_out"
    Expand-HermetiArchive -FilePath $pPkg -Destination $pOut -ToolsDir $toolsDir
    $sourceTools = if (Test-Path "$pOut\tools\python.exe") { "$pOut\tools" } else { $pOut }
    if (-not (Test-Path $pythonDir)) { New-Item -ItemType Directory -Path $pythonDir -Force | Out-Null }
    Copy-Item -Path "$sourceTools\*" -Destination $pythonDir -Recurse -Force

    # Pip Bootstrap
    Get-ChildItem -Path $pythonDir -Filter "*._pth" -ErrorAction SilentlyContinue | ForEach-Object {
        $c = Get-Content $_.FullName; $c = $c -replace '#\s*import site', 'import site'; Set-Content $_.FullName -Value $c
    }
    Write-Host " [*] Bootstrapping pip..." -ForegroundColor Cyan
    & $pythonExe -m ensurepip --upgrade 2>&1 | Out-Null
    if (-not (Test-Path $pipExe)) {
        & $pythonExe -m pip install --force-reinstall --no-cache-dir pip 2>&1 | Out-Null
    }
    if (-not (Test-Path $pipExe)) {
        $getPip = Join-Path $tempDir "get-pip.py"
        Invoke-HermetiDownload -Url "https://bootstrap.pypa.io/get-pip.py" -OutFile $getPip -ProxyUrl $proxyUrl -ToolsDir $toolsDir
        & $pythonExe $getPip --no-warn-script-location 2>&1 | Out-Null
    }
}
Write-Host " [OK] Python & pip Ready." -ForegroundColor Green

Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "`n[SUCCESS] Tier 1 Toolchain Initialized." -ForegroundColor Green
