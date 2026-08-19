param(
    [Parameter(Mandatory=$true)]
    [string]$TargetProjectName,
    [string]$NodeVersion = "20.17.0"
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
$projectRuntimeDir = Join-Path $root "projects\$TargetProjectName\runtime\tools\node"
if (-not (Test-Path $projectRuntimeDir)) { New-Item -ItemType Directory -Path $projectRuntimeDir -Force | Out-Null }
$tempExtractDir = Join-Path $root "projects\$TargetProjectName\runtime\temp_node"
if (Test-Path $tempExtractDir) { Remove-Item $tempExtractDir -Recurse -Force }
New-Item -ItemType Directory -Path $tempExtractDir -Force | Out-Null

$zipName = "node-v$NodeVersion-win-x64.zip"
$rawUrl = "https://nodejs.org/dist/v$NodeVersion/$zipName"
$dlUrl = if ($useProxy) { "$proxyUrl/$rawUrl" } else { $rawUrl }
$zipPath = Join-Path $tempExtractDir $zipName

$aria2 = Join-Path $root "tools\aria2\aria2c.exe"
$7za = Join-Path $root "tools\7zip\7za.exe"

# 3. Download & Integrity Verification with Poison-Cache Auto-Fallback
Write-Host " [*] Fetching Node.js v$NodeVersion payload..." -ForegroundColor Cyan
& $aria2 -x 8 -s 8 -d $tempExtractDir -o $zipName $dlUrl | Out-Null

# Verify archive integrity
$isCorrupt = $false
if (Test-Path $zipPath) {
    & $7za t $zipPath -bsp0 -bso0 | Out-Null
    if ($LASTEXITCODE -ne 0) { $isCorrupt = $true }
} else {
    $isCorrupt = $true
}

if ($isCorrupt) {
    Write-Host " [!] Corrupted Node.js archive detected from proxy cache! Triggering direct WAN fallback..." -ForegroundColor Yellow
    if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
    Invoke-WebRequest -Uri $rawUrl -OutFile $zipPath -UseBasicParsing
    & $7za t $zipPath -bsp0 -bso0 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host " [-] Fatal: Node.js archive failed integrity check on direct origin." -ForegroundColor Red
        exit 1
    }
}

# 4. Extract & Deploy
Write-Host " [*] Unpacking Node.js Runtime..." -ForegroundColor Cyan
$outDir = Join-Path $tempExtractDir "out"
& $7za x $zipPath "-o$outDir" -y -bsp0 -bso0 | Out-Null

$extractedFolder = (Get-ChildItem $outDir -Directory)[0].FullName
Copy-Item "$extractedFolder\*" $projectRuntimeDir -Recurse -Force
Remove-Item $tempExtractDir -Recurse -Force

# 5. Inject Project-Scoped .npmrc & Proxy Config
if ($useProxy) {
    $npmrcPath = Join-Path $root "projects\$TargetProjectName\runtime\.npmrc"
    $npmrcContent = @"
proxy=$proxyUrl
https-proxy=$proxyUrl
strict-ssl=false
"@
    Set-Content -Path $npmrcPath -Value $npmrcContent -Encoding ASCII
    Write-Host " [+] Project-scoped .npmrc configured for OmniProxy ($npmrcPath)" -ForegroundColor Green
}

Get-ChildItem $projectRuntimeDir -Filter "*.exe" -Recurse | ForEach-Object { Unblock-File $_.FullName -ErrorAction SilentlyContinue }
Write-Host " [OK] Tier 2 Node.js Isolated Runtime Created at: $projectRuntimeDir" -ForegroundColor Green
