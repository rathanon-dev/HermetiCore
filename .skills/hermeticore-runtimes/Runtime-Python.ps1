param(
    [string]$TargetProjectName,
    [string]$PythonVersion = "3.12.5"
)

$root = (Resolve-Path "..\..\").Path
$envFile = Join-Path $root "config\.env"
$proxyUrl = $null
$useProxy = $false

# 1. Read Proxy
if (Test-Path $envFile) {
    $envContent = Get-Content $envFile
    $proxyMatch = $envContent | Where-Object { $_ -match "^OMNIPROXY_URL=`"(.*)`"" }
    if ($proxyMatch) { $proxyUrl = $matches[1] }
}

# 2. Handshake
if ($proxyUrl) {
    try {
        $uri = [System.Uri]$proxyUrl
        $tcp = New-Object Net.Sockets.TcpClient
        $async = $tcp.BeginConnect($uri.Host, $uri.Port, $null, $null)
        if ($async.AsyncWaitHandle.WaitOne(1200, $true) -and $tcp.Connected) {
            $useProxy = $true
            Write-Host " [PROXY] OmniProxy LAN Gateway Connected ($proxyUrl)" -ForegroundColor Green
        }
        $tcp.Close()
    } catch {}
}

# 3. Paths
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

# 4. Download
$aria2 = Join-Path $root "tools\aria2\aria2c.exe"
Write-Host " [*] Downloading Python v$PythonVersion (NuGet) for Tier 2..." -ForegroundColor Cyan
& $aria2 -x 8 -s 8 -d $tempExtractDir -o $nupkgName $dlUrl | Out-Null

# 5. Extract
$7za = Join-Path $root "tools\7z\7za.exe"
Write-Host " [*] Extracting Python..." -ForegroundColor Cyan
& $7za x $nupkgPath "-o$tempExtractDir\out" -y -bsp0 -bso0 | Out-Null

# 6. Move
$sourceTools = Join-Path "$tempExtractDir\out" "tools"
Copy-Item "$sourceTools\*" $projectRuntimeDir -Recurse -Force
Remove-Item $tempExtractDir -Recurse -Force

Get-ChildItem $projectRuntimeDir -Filter "*.exe" -Recurse | ForEach-Object { Unblock-File $_.FullName -ErrorAction SilentlyContinue }

Write-Host " [OK] Tier 2 Python Isolated Runtime Created at: $projectRuntimeDir" -ForegroundColor Green
