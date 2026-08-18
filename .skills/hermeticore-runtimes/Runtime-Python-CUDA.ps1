param(
    [string]$TargetProjectName,
    [string]$PythonVersion = "3.12.5",
    [string]$CudaVersion = "12.1.1"
)

$root = (Resolve-Path "..\..\").Path
$envFile = Join-Path $root "config\.env"
$proxyUrl = $null
$useProxy = $false

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
            Write-Host " [PROXY] OmniProxy LAN Gateway Connected ($proxyUrl)" -ForegroundColor Green
        }
        $tcp.Close()
    } catch {}
}

# Scaffold Python
& ".\Runtime-Python.ps1" -TargetProjectName $TargetProjectName -PythonVersion $PythonVersion

# Scaffold CUDA
$cudaBinDir = Join-Path $root "projects\$TargetProjectName\runtime\tools\nvidia\bin"
if (-not (Test-Path $cudaBinDir)) { New-Item -ItemType Directory -Path $cudaBinDir -Force | Out-Null }
$tempExtractDir = Join-Path $root "projects\$TargetProjectName\runtime\temp_cuda"
if (Test-Path $tempExtractDir) { Remove-Item $tempExtractDir -Recurse -Force }
New-Item -ItemType Directory -Path $tempExtractDir -Force | Out-Null

Write-Host " [*] Fetching CUDA v$CudaVersion redist JSON..." -ForegroundColor Cyan
$redistUrl = "https://developer.download.nvidia.com/compute/cuda/redist/redistrib_${CudaVersion}.json"
$manifest = Invoke-RestMethod -Uri $redistUrl -UseBasicParsing

$eliteCudaComponents = @("cublas", "cudart", "nvrtc", "cufft")
$aria2 = Join-Path $root "tools\aria2\aria2c.exe"
$7za = Join-Path $root "tools\7z\7za.exe"

foreach ($comp in $eliteCudaComponents) {
    $winPkg = $manifest.$comp.'windows-x86_64'
    if ($winPkg -and $winPkg.relative_path) {
        $dlUrl = "https://developer.download.nvidia.com/compute/cuda/redist/$($winPkg.relative_path)"
        if ($useProxy) { $dlUrl = "$proxyUrl/$dlUrl" }
        $fName = Split-Path $winPkg.relative_path -Leaf
        
        Write-Host " [*] Downloading $comp..." -ForegroundColor Cyan
        & $aria2 -x 8 -s 8 -d $tempExtractDir -o $fName $dlUrl | Out-Null
        
        Write-Host " [*] Extracting DLLs from $comp..." -ForegroundColor Cyan
        & $7za e "$tempExtractDir\$fName" "-o$cudaBinDir" "*.dll" -r -y -bsp0 -bso0 | Out-Null
    }
}

Remove-Item $tempExtractDir -Recurse -Force

Write-Host " [OK] Tier 2 CUDA Isolated DLLs Created at: $cudaBinDir" -ForegroundColor Green
