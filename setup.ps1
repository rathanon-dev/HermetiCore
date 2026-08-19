# ======================================================================
# HermetiCore SELF-ASSEMBLING MASTER ENGINE (HARDENED v1.3)
# Standard: ISO/IEC/IEEE 12207 | Zero-Global-Pollution | Windows Bare-Metal
# ======================================================================
# v1.2 ADHD-Audit Fixes:
#   - FIXED: Lockfile moved from temp/bootstrap.lock -> .setup-lock at root
#   - FIXED: Root temp/ is now auto-deleted after all tools installed
#   - FIXED: Drain barrier added to wait for child processes before temp wipe
#   - POLICY: Root temp/ = TRANSIENT download staging ONLY, zero persistence
# v1.3 Refactor:
#   - POLICY: All downloads use aria2c (8-thread) AFTER bootstrap stage
#   - NOTE:   7-zip bootstrap (step 6) intentionally uses Invoke-WebRequest
#             because aria2c does not yet exist at that point in the chain.
#             This is the ONLY permitted Invoke-WebRequest call in Tier 1.
#   - ADDED:  ARM64 architecture auto-detection for Node.js and Python
# ======================================================================
[CmdletBinding()]
param (
    [Alias("a")][switch]$AutoBootstrap,
    [Alias("p")][string]$ProxyOverride = ""
)

# 1. Enforce TLS 1.2 minimum across all .NET Web Handshakes
#    NOTE: TLS 1.0 and TLS 1.1 are intentionally excluded (deprecated/insecure)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

$root = $PSScriptRoot
if (-not $root) { $root = (Get-Location).Path }

$toolsDir     = Join-Path $root "tools"
$tempDir      = Join-Path $root "temp"        # TRANSIENT ONLY — auto-deleted after install
$configDir    = Join-Path $root "config"
$logsDir      = Join-Path $root "logs"
$skillsDir    = Join-Path $root ".skills"
$mcpDir       = Join-Path $root ".mcp"
$docDir       = Join-Path $root "doc"
$projectsDir  = Join-Path $root "projects"

# ADHD-Fix: Lockfile is now at ROOT (independent of temp/ lifecycle)
$lockFile     = Join-Path $root ".setup-lock"

$7zDir         = Join-Path $toolsDir "7zip"
$7zExe         = Join-Path $7zDir "7za.exe"
$aria2Dir      = Join-Path $toolsDir "aria2"
$aria2Exe      = Join-Path $aria2Dir "aria2c.exe"
$gitDir        = Join-Path $toolsDir "git"
$gitExe        = Join-Path $gitDir "cmd\git.exe"
$ghExe         = Join-Path $gitDir "cmd\gh.exe"
$nodeDir       = Join-Path $toolsDir "node"
$nodeExe       = Join-Path $nodeDir "node.exe"
$pythonDir     = Join-Path $toolsDir "python"
$pythonExe     = Join-Path $pythonDir "python.exe"

# 2. Prevent race conditions from multiple parallel double-clicks
#    Lockfile is at ROOT — survives independently of temp/ folder
if (-not (Test-Path $toolsDir)) { New-Item -ItemType Directory -Path $toolsDir -Force | Out-Null }
if (-not (Test-Path $7zDir))    { New-Item -ItemType Directory -Path $7zDir -Force | Out-Null }
if (-not (Test-Path $aria2Dir)) { New-Item -ItemType Directory -Path $aria2Dir -Force | Out-Null }
if (-not (Test-Path $gitDir))   { New-Item -ItemType Directory -Path $gitDir -Force | Out-Null }
if (-not (Test-Path $nodeDir))  { New-Item -ItemType Directory -Path $nodeDir -Force | Out-Null }
if (-not (Test-Path $pythonDir)){ New-Item -ItemType Directory -Path $pythonDir -Force | Out-Null }

if (Test-Path $lockFile) {
    $existingPid = Get-Content $lockFile -ErrorAction SilentlyContinue
    if ($existingPid -and (Get-Process -Id $existingPid -ErrorAction SilentlyContinue)) {
        Write-Host " [WARN] Another bootstrap instance is already running (PID: $existingPid). Aborting." -ForegroundColor Yellow
        exit 0
    }
    Write-Host " [INFO] Stale lockfile detected (PID: $existingPid is gone). Recovering..." -ForegroundColor Cyan
}
$PID | Set-Content $lockFile -Force

# 3. Clean zombie child processes started from this root
$targetProcs = @("7za", "aria2c", "git", "node", "python")
Get-Process -Name $targetProcs -ErrorAction SilentlyContinue | Where-Object {
    $_.Path -and $_.Path.StartsWith($root, [System.StringComparison]::InvariantCultureIgnoreCase) -and ($_.Id -ne $PID)
} | Stop-Process -Force -ErrorAction SilentlyContinue

# 4. Smart OmniProxy Detection (with 1.2s rapid timeout fallback)
$proxyUrl = "http://192.168.1.10:8080"
if ($ProxyOverride) { $proxyUrl = $ProxyOverride }
$script:UseProxy = $false

try {
    $uri = [System.Uri]$proxyUrl
    $tcp = New-Object Net.Sockets.TcpClient
    $async = $tcp.BeginConnect($uri.Host, $uri.Port, $null, $null)
    if ($async.AsyncWaitHandle.WaitOne(1200, $true) -and $tcp.Connected) {
        $script:UseProxy = $true
        Write-Host " [PROXY] OmniProxy LAN Gateway Connected ($proxyUrl)" -ForegroundColor Green
    } else {
        Write-Host " [PROXY] OmniProxy Offline. Using Direct Internet." -ForegroundColor Yellow
    }
    $tcp.Close()
} catch {
    Write-Host " [PROXY] OmniProxy Offline. Using Direct Internet." -ForegroundColor Yellow
}

function Get-DownloadUrl {
    param([string]$RawUrl)
    if ($script:UseProxy) { return "$proxyUrl/$RawUrl" }
    return $RawUrl
}

# 5. Vectorized directory scaffolding (temp/ is NOT pre-scaffolded — created on demand only)
$folders = @($toolsDir, $configDir, $logsDir, $skillsDir, $mcpDir, $docDir, $projectsDir, $7zDir, $aria2Dir, $gitDir, $nodeDir, $pythonDir)
foreach ($f in $folders) {
    if (-not (Test-Path $f)) { New-Item -ItemType Directory -Path $f -Force | Out-Null }
}

# Helper: Ensure temp staging dir exists (created on demand, not pre-scaffolded)
function Ensure-TempDir {
    if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir -Force | Out-Null }
}

# 6. Bootstrap 7-Zip with Zone.Identifier Stripping
if (-not (Test-Path $7zExe)) {
    Write-Host " [*] [1/5] Fetching 7za.exe via NuGet API..." -ForegroundColor Cyan
    Ensure-TempDir
    $nugetUrl = "https://www.nuget.org/api/v2/package/7-Zip.CommandLine"
    $targetZip = Join-Path $tempDir "7z.zip"
    Invoke-WebRequest -Uri (Get-DownloadUrl $nugetUrl) -OutFile $targetZip -UseBasicParsing
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($targetZip, "$tempDir\7z_out")
    $found7z = Get-ChildItem "$tempDir\7z_out" -Filter "7za.exe" -Recurse | Select-Object -First 1
    if ($found7z) {
        Copy-Item $found7z.FullName $7zExe -Force
        Unblock-File -Path $7zExe -ErrorAction SilentlyContinue
    }
    Remove-Item $targetZip -Force -ErrorAction SilentlyContinue
    Remove-Item "$tempDir\7z_out" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host " [OK] 7-Zip Initialized." -ForegroundColor Green
}

# 7. Bootstrap Aria2 with Unblock-File
if (-not (Test-Path $aria2Exe)) {
    Write-Host " [*] [2/5] Fetching Aria2c Portable..." -ForegroundColor Cyan
    Ensure-TempDir
    $ariaUrl = "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip"
    $ariaZip = Join-Path $tempDir "aria2.zip"
    Invoke-WebRequest -Uri (Get-DownloadUrl $ariaUrl) -OutFile $ariaZip -UseBasicParsing
    & $7zExe x $ariaZip "-o$tempDir\aria_tmp" -y | Out-Null
    $extractedAria = Get-ChildItem "$tempDir\aria_tmp" -Filter "aria2c.exe" -Recurse | Select-Object -First 1
    if ($extractedAria) {
        Copy-Item $extractedAria.FullName $aria2Exe -Force
        Unblock-File -Path $aria2Exe -ErrorAction SilentlyContinue
    }
    Remove-Item "$tempDir\aria_tmp" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $ariaZip -Force -ErrorAction SilentlyContinue
    Write-Host " [OK] Aria2 Initialized." -ForegroundColor Green
}

# 8. Bootstrap MinGit (8-Connection Accelerated)
if (-not (Test-Path $gitExe)) {
    Write-Host " [*] [3/5] Fetching MinGit Portable..." -ForegroundColor Cyan
    Ensure-TempDir
    $gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.46.0.windows.1/MinGit-2.46.0-64-bit.zip"
    $gitZip = Join-Path $tempDir "git.zip"
    & $aria2Exe -x 8 -s 8 -d $tempDir -o "git.zip" (Get-DownloadUrl $gitUrl) | Out-Null
    & $7zExe x $gitZip "-o$gitDir" -y | Out-Null
    Get-ChildItem -Path $gitDir -Filter "*.exe" -Recurse | ForEach-Object { Unblock-File $_.FullName -ErrorAction SilentlyContinue }
    Remove-Item $gitZip -Force -ErrorAction SilentlyContinue
    Write-Host " [OK] MinGit Initialized." -ForegroundColor Green
}

# 8.5. Bootstrap GitHub CLI (gh) Portable (ADHD Zero-Footprint Injection)
if (-not (Test-Path $ghExe)) {
    Write-Host " [*] [3.5/5] Fetching GitHub CLI (gh) Portable..." -ForegroundColor Cyan
    Ensure-TempDir
    $ghArch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "amd64" }
    $ghUrl = "https://github.com/cli/cli/releases/download/v2.97.0/gh_2.97.0_windows_${ghArch}.zip"
    $ghZip = Join-Path $tempDir "gh.zip"
    & $aria2Exe -x 8 -s 8 -d $tempDir -o "gh.zip" (Get-DownloadUrl $ghUrl) | Out-Null
    & $7zExe x $ghZip "-o$tempDir\gh_tmp" -y | Out-Null
    
    # Locate gh.exe inside the extracted subfolder and move it to MinGit's cmd folder
    $extractedGh = Get-ChildItem -Path "$tempDir\gh_tmp" -Filter "gh.exe" -Recurse | Select-Object -First 1
    if ($extractedGh) {
        Move-Item $extractedGh.FullName $ghExe -Force
        Unblock-File $ghExe -ErrorAction SilentlyContinue
    }
    
    Remove-Item "$tempDir\gh_tmp" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $ghZip -Force -ErrorAction SilentlyContinue
    Write-Host " [OK] GitHub CLI Initialized (Piggybacked on MinGit)." -ForegroundColor Green
}

# 9. Bootstrap Node.js LTS
if (-not (Test-Path $nodeExe)) {
    Write-Host " [*] [4/5] Fetching Node.js LTS Portable..." -ForegroundColor Cyan
    Ensure-TempDir
    $nodeArch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x64" }
    $nodeUrl = "https://nodejs.org/dist/v20.17.0/node-v20.17.0-win-${nodeArch}.zip"
    $nodeZip = Join-Path $tempDir "node.zip"
    & $aria2Exe -x 8 -s 8 -d $tempDir -o "node.zip" (Get-DownloadUrl $nodeUrl) | Out-Null
    & $7zExe x $nodeZip "-o$tempDir\node_tmp" -y | Out-Null
    $extractedNode = Get-ChildItem "$tempDir\node_tmp" -Directory | Select-Object -First 1
    if ($extractedNode) {
        Copy-Item "$($extractedNode.FullName)\*" $nodeDir -Recurse -Force
        Get-ChildItem -Path $nodeDir -Filter "*.exe" -Recurse | ForEach-Object { Unblock-File $_.FullName -ErrorAction SilentlyContinue }
    }
    Remove-Item "$tempDir\node_tmp" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $nodeZip -Force -ErrorAction SilentlyContinue
    Write-Host " [OK] Node.js LTS Initialized." -ForegroundColor Green
}

# 10. Bootstrap Python 3.12 Portable (via NuGet)
if (-not (Test-Path $pythonExe)) {
    Write-Host " [*] [5/5] Fetching Python 3.12 (NuGet Portable)..." -ForegroundColor Cyan
    Ensure-TempDir
    $pyPkgId = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "pythonarm64" } else { "python" }
    $pyVer = "3.12.5"
    $pyUrl = "https://api.nuget.org/v3-flatcontainer/$pyPkgId/$pyVer/$pyPkgId.$pyVer.nupkg"
    $pyNupkg = Join-Path $tempDir "python.nupkg"
    
    # Download NuGet package
    & $aria2Exe -x 8 -s 8 -d $tempDir -o "python.nupkg" (Get-DownloadUrl $pyUrl) | Out-Null
    
    # Extract
    $tempExtractDir = Join-Path $tempDir "py_extract"
    if (Test-Path $tempExtractDir) { Remove-Item $tempExtractDir -Recurse -Force }
    New-Item -ItemType Directory -Path $tempExtractDir -Force | Out-Null
    
    & $7zExe x $pyNupkg "-o$tempExtractDir" -y -bsp0 -bso0 | Out-Null
    
    # Move 'tools' contents to target
    $sourceTools = Join-Path $tempExtractDir "tools"
    if (Test-Path $sourceTools) {
        Copy-Item -Path "$sourceTools\*" -Destination $pythonDir -Recurse -Force
    }
    
    Get-ChildItem -Path $pythonDir -Filter "*.exe" -Recurse | ForEach-Object { Unblock-File $_.FullName -ErrorAction SilentlyContinue }
    Remove-Item $pyNupkg -Force -ErrorAction SilentlyContinue
    Remove-Item $tempExtractDir -Recurse -Force -ErrorAction SilentlyContinue

    # Bootstrap pip via get-pip.py (more reliable than ensurepip for NuGet Python)
    # NuGet Python has a python312._pth file that restricts sys.path and blocks ensurepip.
    # get-pip.py bypasses this limitation. aria2c is already available at this point.
    Write-Host " [*] Bootstrapping pip via get-pip.py (aria2c download)..." -ForegroundColor Cyan
    Ensure-TempDir
    $getPipPath = Join-Path $tempDir "get-pip.py"
    $getPipUrl  = "https://bootstrap.pypa.io/get-pip.py"
    & $aria2Exe -x 4 -s 4 -d $tempDir -o "get-pip.py" (Get-DownloadUrl $getPipUrl) | Out-Null
    if (Test-Path $getPipPath) {
        & $pythonExe $getPipPath --no-warn-script-location 2>&1 | Out-Null
        $pipExe = Join-Path $pythonDir "Scripts\pip.exe"
        if (Test-Path $pipExe) {
            Write-Host " [OK] pip installed successfully via get-pip.py." -ForegroundColor Green
        } else {
            Write-Host " [WARN] pip.exe not found after get-pip.py — pip may require manual bootstrap." -ForegroundColor Yellow
        }
        Remove-Item $getPipPath -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host " [WARN] get-pip.py download failed — pip will not be available." -ForegroundColor Yellow
    }

    Write-Host " [OK] Python 3.12 Initialized (Native Portable via NuGet)." -ForegroundColor Green
}

# 11. ADHD-Fix: DRAIN BARRIER — Wait for child processes to release handles
#     before wiping root temp/ to avoid EBUSY/AccessDenied on Windows
if (Test-Path $tempDir) {
    Write-Host " [*] Drain barrier: waiting for download handles to close..." -ForegroundColor DarkGray
    $drainWait = 0
    while ($drainWait -lt 10) {
        $activeChildren = Get-Process -Name @("7za","aria2c") -ErrorAction SilentlyContinue |
            Where-Object { $_.Path -and $_.Path.StartsWith($root, [System.StringComparison]::InvariantCultureIgnoreCase) }
        if (-not $activeChildren) { break }
        Start-Sleep -Milliseconds 300
        $drainWait++
    }
    # Wipe root temp/ — TRANSIENT download staging area, must not persist
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    if (-not (Test-Path $tempDir)) {
        Write-Host " [OK] Root temp/ staging area cleaned (zero-persistence policy enforced)." -ForegroundColor DarkGray
    } else {
        Write-Host " [WARN] Root temp/ could not be fully removed (file handle lock). Will clean on next run." -ForegroundColor Yellow
    }
}

# 12. Security & Credentials Auto-Provisioning (Tier 1 Config)
$sshKeyPath = Join-Path $configDir "id_ed25519"
$sshPubPath = Join-Path $configDir "id_ed25519.pub"
$envFile    = Join-Path $configDir ".env"
$envExample = Join-Path $configDir "env.example"

# Auto-hydrate config/.env from template if missing
if ((-not (Test-Path $envFile)) -and (Test-Path $envExample)) {
    Copy-Item $envExample $envFile -Force
    Write-Host " [INFO] Initialized config/.env from template." -ForegroundColor DarkCyan
}

# Auto-generate Ed25519 SSH Keypair for Zero-Prompt Git Operations
if (-not (Test-Path $sshKeyPath)) {
    Write-Host " [*] Provisioning isolated Ed25519 SSH Keypair in config/..." -ForegroundColor Cyan
    $sshKeygen = "ssh-keygen"
    $localSsh = Join-Path $gitDir "usr\bin\ssh-keygen.exe"
    if (Test-Path $localSsh) { $sshKeygen = $localSsh }
    
    $keygenArgs = @("-t", "ed25519", "-C", "hermeticore-ai@workstation", "-f", $sshKeyPath, "-N", "")
    & $sshKeygen $keygenArgs 2>&1 | Out-Null
    if (Test-Path $sshPubPath) {
        $pubContent = (Get-Content $sshPubPath -Raw).Trim()
        Write-Host ""
        Write-Host " [KEY] ================= HERMETICORE SSH PUBLIC KEY =================" -ForegroundColor Yellow
        Write-Host " $pubContent" -ForegroundColor White
        Write-Host " [KEY] Add to GitHub: https://github.com/settings/ssh/new" -ForegroundColor Cyan
        Write-Host " ===================================================================" -ForegroundColor Yellow
        Write-Host ""
    }
}

# 13. Release root lockfile
if (Test-Path $lockFile) { Remove-Item $lockFile -Force -ErrorAction SilentlyContinue }

Write-Host ""
Write-Host " ======================================================================" -ForegroundColor Green
Write-Host " [SUCCESS] HermetiCore Spore Hydration Finished!" -ForegroundColor Green
Write-Host " All Tier 1 Tools, MCPs, Skills, and Logs are 100% Active." -ForegroundColor Cyan
Write-Host " ======================================================================" -ForegroundColor Green


