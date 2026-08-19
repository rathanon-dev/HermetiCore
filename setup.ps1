# ==============================================================================
# HermetiCore v1.5 — Tier 1 Shared Toolchain Setup (Dynamic Evergreen Versions)
# ==============================================================================
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$root = $PSScriptRoot
$toolsDir = Join-Path $root "tools"
$tempDir  = Join-Path $root "temp_setup"
if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir -Force | Out-Null }

Import-Module (Join-Path $root ".skills\hermeticore-core\Core.psm1") -Force
$proxyUrl = Get-HermetiProxy -WorkspaceRoot $root
if ($proxyUrl) { Write-Host " [PROXY] OmniProxy LAN Gateway Active ($proxyUrl)" -ForegroundColor Green }

# ------------------------------------------------------------------------------
# 1. 7-Zip (Bootstrap) - Dynamic NuGet
# ------------------------------------------------------------------------------
$7zDir = Join-Path $toolsDir "7zip"
$7zExe = Join-Path $7zDir "7za.exe"
if (-not (Test-Path $7zExe)) {
    Write-Host " [*] Resolving latest 7-Zip..." -ForegroundColor Cyan -NoNewline
    $latest7z = Get-HermetiLatestNuGetVersion -PackageId "7-Zip.CommandLine" -ProxyUrl $proxyUrl
    Write-Host " v$latest7z" -ForegroundColor Green
    
    $zUrl = "https://www.nuget.org/api/v2/package/7-Zip.CommandLine/$latest7z"
    $zZip = Join-Path $tempDir "7z.zip"
    Invoke-HermetiDownload -Url $zUrl -OutFile $zZip -ProxyUrl $proxyUrl -ToolsDir $toolsDir
    
    $zOut = Join-Path $tempDir "7z_extract"
    Expand-HermetiArchive -FilePath $zZip -Destination $zOut -ToolsDir $toolsDir
    if (-not (Test-Path $7zDir)) { New-Item -ItemType Directory -Path $7zDir -Force | Out-Null }
    Move-Item -Path (Join-Path $zOut "tools\7za.exe") -Destination $7zExe -Force
}
Write-Host " [OK] 7-Zip Ready." -ForegroundColor Green

# ------------------------------------------------------------------------------
# 2. Aria2c - Dynamic GitHub
# ------------------------------------------------------------------------------
$aria2Dir = Join-Path $toolsDir "aria2"
$aria2Exe = Join-Path $aria2Dir "aria2c.exe"
if (-not (Test-Path $aria2Exe)) {
    Write-Host " [*] Resolving latest Aria2c..." -ForegroundColor Cyan -NoNewline
    $aUrl = Get-HermetiLatestGitHubAsset -Repo "aria2/aria2" -AssetRegex "win-64bit.*\.zip" -ProxyUrl $proxyUrl
    Write-Host " Found!" -ForegroundColor Green
    
    $aZip = Join-Path $tempDir "aria2.zip"
    Invoke-HermetiDownload -Url $aUrl -OutFile $aZip -ProxyUrl $proxyUrl -ToolsDir $toolsDir
    Expand-HermetiArchive -FilePath $aZip -Destination $tempDir -ToolsDir $toolsDir
    $extractedAriaDir = Get-ChildItem -Path $tempDir -Filter "aria2-*-win-64bit-*" -Directory | Select-Object -First 1
    if (-not (Test-Path $aria2Dir)) { New-Item -ItemType Directory -Path $aria2Dir -Force | Out-Null }
    Copy-Item -Path "$($extractedAriaDir.FullName)\*" -Destination $aria2Dir -Recurse -Force
}
Write-Host " [OK] Aria2c Ready." -ForegroundColor Green

# ------------------------------------------------------------------------------
# 3. Portable Git - Dynamic GitHub
# ------------------------------------------------------------------------------
$gitDir = Join-Path $toolsDir "git"
if (-not (Test-Path "$gitDir\cmd\git.exe")) {
    Write-Host " [*] Resolving latest Portable Git..." -ForegroundColor Cyan -NoNewline
    $gUrl = Get-HermetiLatestGitHubAsset -Repo "git-for-windows/git" -AssetRegex "PortableGit-.*-64-bit\.7z\.exe" -ProxyUrl $proxyUrl
    Write-Host " Found!" -ForegroundColor Green
    
    $gExe = Join-Path $tempDir "git.7z.exe"
    Invoke-HermetiDownload -Url $gUrl -OutFile $gExe -ProxyUrl $proxyUrl -ToolsDir $toolsDir
    Expand-HermetiArchive -FilePath $gExe -Destination $gitDir -ToolsDir $toolsDir
}
Write-Host " [OK] Portable Git Ready." -ForegroundColor Green

# ------------------------------------------------------------------------------
# 4. Node.js - Dynamic nodejs.org
# ------------------------------------------------------------------------------
$nodeDir = Join-Path $toolsDir "node"
$nodeExe = Join-Path $nodeDir "node.exe"
if (-not (Test-Path $nodeExe)) {
    Write-Host " [*] Resolving latest Node.js..." -ForegroundColor Cyan -NoNewline
    $latestNode = Get-HermetiLatestNodeVersion -ProxyUrl $proxyUrl
    Write-Host " v$latestNode" -ForegroundColor Green
    
    $arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "win-x64" }
    $nUrl = "https://nodejs.org/dist/v$latestNode/node-v$latestNode-$arch.zip"
    $nZip = Join-Path $tempDir "node.zip"
    Invoke-HermetiDownload -Url $nUrl -OutFile $nZip -ProxyUrl $proxyUrl -ToolsDir $toolsDir
    Expand-HermetiArchive -FilePath $nZip -Destination $tempDir -ToolsDir $toolsDir
    $extractedNodeDir = Get-ChildItem -Path $tempDir -Filter "node-v$latestNode-$arch" -Directory | Select-Object -First 1
    if (-not (Test-Path $nodeDir)) { New-Item -ItemType Directory -Path $nodeDir -Force | Out-Null }
    Copy-Item -Path "$($extractedNodeDir.FullName)\*" -Destination $nodeDir -Recurse -Force
}
Write-Host " [OK] Node.js Ready." -ForegroundColor Green

# ------------------------------------------------------------------------------
# 5. Python - Dynamic NuGet
# ------------------------------------------------------------------------------
$pythonDir = Join-Path $toolsDir "python"
$pythonExe = Join-Path $pythonDir "python.exe"
$pipExe    = Join-Path $pythonDir "Scripts\pip.exe"
if (-not (Test-Path $pipExe)) {
    $pkgId = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "pythonarm64" } else { "python" }
    Write-Host " [*] Resolving latest Python ($pkgId)..." -ForegroundColor Cyan -NoNewline
    $latestPy = Get-HermetiLatestNuGetVersion -PackageId $pkgId -ProxyUrl $proxyUrl
    Write-Host " v$latestPy" -ForegroundColor Green
    
    $pUrl = "https://api.nuget.org/v3-flatcontainer/$pkgId/$latestPy/$pkgId.$latestPy.nupkg"
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

# ------------------------------------------------------------------------------
# 6. SSH Key Verification / Generation
# ------------------------------------------------------------------------------
$sshKeyPath = Join-Path $root "config\id_ed25519"
if (-not (Test-Path $sshKeyPath)) {
    Write-Host " [*] Generating new SSH Key (ED25519) for GitHub..." -ForegroundColor Cyan
    $sshExe = Join-Path $toolsDir "git\usr\bin\ssh-keygen.exe"
    if (Test-Path $sshExe) {
        & $sshExe -t ed25519 -f $sshKeyPath -N "" -q -C "hermeticore-ai@workstation"
        Write-Host " [!] IMPORTANT: New SSH Key generated." -ForegroundColor Yellow
        Write-Host "     Please add this public key to GitHub (https://github.com/settings/keys):"
        Write-Host "     ------------------------------------------------------------------------"
        Get-Content "$sshKeyPath.pub" | Write-Host -ForegroundColor Magenta
        Write-Host "     ------------------------------------------------------------------------"
    } else {
        Write-Host " [!] Could not generate SSH Key: ssh-keygen.exe not found in Portable Git." -ForegroundColor Yellow
    }
} else {
    Write-Host " [OK] SSH Key already exists ($sshKeyPath)." -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# 7. Local MCP Server Installation (GitHub)
# ------------------------------------------------------------------------------
Write-Host " [*] Initializing Local MCP Server (GitHub) for Antigravity..." -ForegroundColor Cyan
$mcpDir = Join-Path $toolsDir "mcp-servers"
if (-not (Test-Path $mcpDir)) { New-Item -ItemType Directory -Path $mcpDir -Force | Out-Null }
$nodeExe = Join-Path $toolsDir "node\node.exe"
$npmCli = Join-Path $toolsDir "node\node_modules\npm\bin\npm-cli.js"

if ((Test-Path $nodeExe) -and (Test-Path $npmCli)) {
    if (-not (Test-Path (Join-Path $mcpDir "package.json"))) {
        Set-Content -Path (Join-Path $mcpDir "package.json") -Value '{"name":"hermeticore-mcp-servers","version":"1.0.0"}'
    }
    
    Write-Host "     - Installing @modelcontextprotocol/server-github via local npm..."
    $env:PATH = "$(Split-Path $nodeExe -Parent);" + $env:PATH
    & $nodeExe $npmCli install @modelcontextprotocol/server-github --prefix $mcpDir --silent | Out-Null
    
    # Configure Antigravity to support it via a local plugin
    $pluginDir = Join-Path $root ".agents\plugins\hermeti-github-mcp"
    if (-not (Test-Path $pluginDir)) { New-Item -ItemType Directory -Path $pluginDir -Force | Out-Null }
    
    $mcpConfigContent = @"
{
  "mcpServers": {
    "hermeti-local-github": {
      "command": "tools\\\\node\\\\node.exe",
      "args": [
        "tools\\\\mcp-servers\\\\node_modules\\\\@modelcontextprotocol\\\\server-github\\\\dist\\\\index.js"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "`$env:GITHUB_PERSONAL_ACCESS_TOKEN"
      }
    }
  }
}
"@
    Set-Content -Path (Join-Path $pluginDir "mcp_config.json") -Value $mcpConfigContent
    
    $pluginJsonContent = @"
{
  "name": "hermeti-github-mcp",
  "description": "Local GitHub MCP Server provided by HermetiCore Tier-1 tools."
}
"@
    Set-Content -Path (Join-Path $pluginDir "plugin.json") -Value $pluginJsonContent
    Write-Host " [OK] Local GitHub MCP Server installed and registered as Antigravity Plugin." -ForegroundColor Green
} else {
    Write-Host " [!] Node.js not found in Tier 1 tools; skipping MCP installation." -ForegroundColor Yellow
}

Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "`n[SUCCESS] Tier 1 Toolchain Initialized." -ForegroundColor Green
# Trigger CI from Antigravity
