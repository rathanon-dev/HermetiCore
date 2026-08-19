param(
    [Parameter(Mandatory=$true)]
    [string]$TargetProjectName,
    [string]$PythonVersion = "3.12.5",
    # Optional: space-separated pip packages to install after bootstrapping
    # Example: -InstallPackages "fastapi uvicorn"
    [string]$InstallPackages = ""
)

$root = (Resolve-Path "$PSScriptRoot\..\..").Path
$envFile = Join-Path $root "config\.env"
$proxyUrl = $null
$useProxy = $false

# 1. OmniProxy Ingestion & Health Probe
if (Test-Path $envFile) {
    $envContent = Get-Content $envFile
    $proxyMatch = $envContent | Where-Object { $_ -match "^OMNIPROXY_URL=`"(.*)`"" }
    if ($proxyMatch) { $proxyUrl = $matches[1] }
}

if ($proxyUrl) {
    try {
        $uri = [System.Uri]$proxyUrl
        $tcp = New-Object Net.Sockets.TcpClient
        $async = $tcp.BeginConnect($uri.Host, $uri.Port, $null, $null)
        if ($async.AsyncWaitHandle.WaitOne(1200, $true) -and $tcp.Connected) {
            $useProxy = $true
            Write-Host " [PROXY] OmniProxy LAN Gateway Active ($proxyUrl)" -ForegroundColor Green
        }
        $tcp.Close()
    } catch {}
}

# 2. Setup Staging & Runtime Paths
$projectRuntimeDir = Join-Path $root "projects\$TargetProjectName\runtime\tools\python"
if (-not (Test-Path $projectRuntimeDir)) { New-Item -ItemType Directory -Path $projectRuntimeDir -Force | Out-Null }
$tempExtractDir = Join-Path $root "projects\$TargetProjectName\runtime\temp_python"
if (Test-Path $tempExtractDir) { Remove-Item $tempExtractDir -Recurse -Force }
New-Item -ItemType Directory -Path $tempExtractDir -Force | Out-Null

$pkgId = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "pythonarm64" } else { "python" }
$nupkgName = "$pkgId.$PythonVersion.nupkg"
$rawUrl = "https://api.nuget.org/v3-flatcontainer/$pkgId/$PythonVersion/$nupkgName"
$dlUrl = if ($useProxy) { "$proxyUrl/$rawUrl" } else { $rawUrl }
$nupkgPath = Join-Path $tempExtractDir $nupkgName

$aria2 = Join-Path $root "tools\aria2\aria2c.exe"
$7za = Join-Path $root "tools\7zip\7za.exe"

# 3. Download & Integrity Check with Fallback
Write-Host " [*] Downloading Python v$PythonVersion (NuGet) for Tier 2..." -ForegroundColor Cyan
& $aria2 -x 8 -s 8 -d $tempExtractDir -o $nupkgName $dlUrl | Out-Null

$isCorrupt = $false
if (Test-Path $nupkgPath) {
    & $7za t $nupkgPath -bsp0 -bso0 | Out-Null
    if ($LASTEXITCODE -ne 0) { $isCorrupt = $true }
} else {
    $isCorrupt = $true
}

if ($isCorrupt) {
    Write-Host " [!] Corrupted Python package detected from proxy cache! Triggering direct WAN fallback..." -ForegroundColor Yellow
    if (Test-Path $nupkgPath) { Remove-Item $nupkgPath -Force }
    & $aria2 -x 8 -s 8 -d $tempExtractDir -o $nupkgName $rawUrl --console-log-level=warn | Out-Null
    & $7za t $nupkgPath -bsp0 -bso0 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host " [-] Fatal: Python package failed integrity check on direct origin." -ForegroundColor Red
        exit 1
    }
}

# 4. Extract Python Runtime (Official Microsoft NuGet Distribution)
Write-Host " [*] Extracting Python (Microsoft NuGet Native)..." -ForegroundColor Cyan
$outDir = Join-Path $tempExtractDir "out"
& $7za x $nupkgPath "-o$outDir" -y -bsp0 -bso0 | Out-Null

$sourceTools = Join-Path $outDir "tools"
if (-not (Test-Path (Join-Path $sourceTools "python.exe"))) { $sourceTools = $outDir }
Copy-Item "$sourceTools\*" $projectRuntimeDir -Recurse -Force
Remove-Item $tempExtractDir -Recurse -Force

# 5. Bootstrap Pip & Inject Project-Scoped pip.ini
$pyExe  = Join-Path $projectRuntimeDir "python.exe"
$pipDir = Join-Path $projectRuntimeDir "Scripts"
Write-Host " [*] Bootstrapping pip via ensurepip..." -ForegroundColor Cyan
& $pyExe -m ensurepip --upgrade 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host " [WARN] ensurepip returned non-zero. Attempting pip self-upgrade fallback..." -ForegroundColor Yellow
    & $pyExe -m pip install --upgrade pip 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host " [ERROR] pip bootstrap failed. Check network or proxy config." -ForegroundColor Red
    }
} else {
    Write-Host " [OK] pip bootstrapped successfully." -ForegroundColor DarkGray
}

if ($useProxy) {
    $proxyHost = ([System.Uri]$proxyUrl).Host
    $pipIniPath = Join-Path $projectRuntimeDir "pip.ini"
    $pipIniContent = @"
[global]
index-url = $proxyUrl/pypi/simple/
trusted-host = $proxyHost
timeout = 30
"@
    Set-Content -Path $pipIniPath -Value $pipIniContent -Encoding ASCII

    # Also set pip config internally
    & $pyExe -m pip config set global.index-url "$proxyUrl/pypi/simple/" | Out-Null
    & $pyExe -m pip config set global.trusted-host $proxyHost | Out-Null
    Write-Host " [+] Project-scoped pip.ini configured for OmniProxy ($pipIniPath)" -ForegroundColor Green
}

# 6. Optional: Install packages specified by -InstallPackages
if ($InstallPackages) {
    $pkgList = $InstallPackages -split '\s+' | Where-Object { $_ -ne "" }
    Write-Host " [*] Installing packages: $($pkgList -join ', ')..." -ForegroundColor Cyan
    & $pyExe -m pip install @pkgList 2>&1 | Tee-Object -Variable pipOut | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host " [WARN] One or more packages failed to install. Check output above." -ForegroundColor Yellow
    } else {
        Write-Host " [OK] Packages installed: $($pkgList -join ', ')" -ForegroundColor Green
    }
}

Get-ChildItem $projectRuntimeDir -Filter "*.exe" -Recurse | ForEach-Object { Unblock-File $_.FullName -ErrorAction SilentlyContinue }
Write-Host " [OK] Tier 2 Python Isolated Runtime Created at: $projectRuntimeDir" -ForegroundColor Green
