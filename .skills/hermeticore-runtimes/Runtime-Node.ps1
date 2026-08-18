param(
    [string]$TargetProjectName,
    [string]$NodeVersion = "20.17.0"
)

$root = (Resolve-Path "..\..\").Path
$envFile = Join-Path $root "config\.env"
$proxyUrl = $null
$useProxy = $false

# 1. Read Proxy from config/.env
if (Test-Path $envFile) {
    $envContent = Get-Content $envFile
    $proxyMatch = $envContent | Where-Object { $_ -match "^OMNIPROXY_URL=`"(.*)`"" }
    if ($proxyMatch) {
        $proxyUrl = $matches[1]
    }
}

# 2. Handshake Proxy (1.2s timeout)
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

# 3. Scaffold Paths
$projectRuntimeDir = Join-Path $root "projects\$TargetProjectName\runtime\tools\node"
if (-not (Test-Path $projectRuntimeDir)) { New-Item -ItemType Directory -Path $projectRuntimeDir -Force | Out-Null }
$tempExtractDir = Join-Path $root "projects\$TargetProjectName\runtime\temp_node"
if (Test-Path $tempExtractDir) { Remove-Item $tempExtractDir -Recurse -Force }
New-Item -ItemType Directory -Path $tempExtractDir -Force | Out-Null

$zipName = "node-v$NodeVersion-win-x64.zip"
$rawUrl = "https://nodejs.org/dist/v$NodeVersion/$zipName"
$dlUrl = if ($useProxy) { "$proxyUrl/$rawUrl" } else { $rawUrl }

$zipPath = Join-Path $tempExtractDir $zipName

# 4. Download using Tier 1 Aria2
$aria2 = Join-Path $root "tools\aria2\aria2c.exe"
Write-Host " [*] Downloading Node.js v$NodeVersion for Tier 2..." -ForegroundColor Cyan
& $aria2 -x 8 -s 8 -d $tempExtractDir -o $zipName $dlUrl | Out-Null

# 5. Extract using Tier 1 7-Zip
$7za = Join-Path $root "tools\7z\7za.exe"
Write-Host " [*] Extracting Node.js..." -ForegroundColor Cyan
& $7za x $zipPath "-o$tempExtractDir\out" -y -bsp0 -bso0 | Out-Null

# 6. Move to target
$extractedNode = (Get-ChildItem "$tempExtractDir\out" -Directory)[0].FullName
Copy-Item "$extractedNode\*" $projectRuntimeDir -Recurse -Force
Remove-Item $tempExtractDir -Recurse -Force

Get-ChildItem $projectRuntimeDir -Filter "*.exe" -Recurse | ForEach-Object { Unblock-File $_.FullName -ErrorAction SilentlyContinue }

Write-Host " [OK] Tier 2 Node.js Isolated Runtime Created at: $projectRuntimeDir" -ForegroundColor Green
