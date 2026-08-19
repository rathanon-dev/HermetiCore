param(
    [Parameter(Mandatory=$true)]
    [string]$TargetProjectName,
    [string]$PythonVersion = "3.12.5",
    [string]$CudaVersion = "12.1.1",
    [string]$CudnnVersion = ""
)

$root = (Resolve-Path "$PSScriptRoot\..\..").Path
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

# 1. Scaffold Python Base
& "$PSScriptRoot\Runtime-Python.ps1" -TargetProjectName $TargetProjectName -PythonVersion $PythonVersion

# 2. CUDA & cuDNN Setup
$cudaBinDir = Join-Path $root "projects\$TargetProjectName\runtime\tools\nvidia\cuda\bin"
$cudnnBinDir = Join-Path $root "projects\$TargetProjectName\runtime\tools\nvidia\cudnn\bin"
if (-not (Test-Path $cudaBinDir)) { New-Item -ItemType Directory -Path $cudaBinDir -Force | Out-Null }
if (-not (Test-Path $cudnnBinDir)) { New-Item -ItemType Directory -Path $cudnnBinDir -Force | Out-Null }

$tempExtractDir = Join-Path $root "projects\$TargetProjectName\runtime\temp_cuda"
if (Test-Path $tempExtractDir) { Remove-Item $tempExtractDir -Recurse -Force }
New-Item -ItemType Directory -Path $tempExtractDir -Force | Out-Null

$aria2 = Join-Path $root "tools\aria2\aria2c.exe"
$7za = Join-Path $root "tools\7zip\7za.exe"

$eliteCudaComponents = @(
    "cuda_cudart", "libcublas", "libcufft", "libcurand", 
    "libcusolver", "libcusparse", "libnpp", "libnvjpeg", 
    "cuda_nvrtc", "libnvjitlink", "libnvptxcompiler", 
    "libnvvm", "libnvfatbin"
)

$cudnnTargets = @(
    "cudnn_adv64_*.dll", "cudnn_cnn64_*.dll", "cudnn_engines_precompiled64_*.dll",
    "cudnn_engines_runtime_compiled64_*.dll", "cudnn_graph64_*.dll", "cudnn_heuristic64_*.dll",
    "cudnn_ops64_*.dll", "cudnn64_*.dll"
)

# --------------------------------------------------------
# [PHASE 1] INSTALL CUDA
# --------------------------------------------------------
Write-Host " [*] Fetching CUDA v$CudaVersion redist JSON..." -ForegroundColor Cyan
$cudaRedistUrl = "https://developer.download.nvidia.com/compute/cuda/redist/redistrib_${CudaVersion}.json"
if ($useProxy) { $cudaRedistUrl = "$proxyUrl/$cudaRedistUrl" }
$cudaManifest = Invoke-RestMethod -Uri $cudaRedistUrl -UseBasicParsing

foreach ($comp in $eliteCudaComponents) {
    $winPkg = $cudaManifest.$comp.'windows-x86_64'
    if ($winPkg -and $winPkg.relative_path) {
        $dlUrl = "https://developer.download.nvidia.com/compute/cuda/redist/$($winPkg.relative_path)"
        if ($useProxy) { $dlUrl = "$proxyUrl/$dlUrl" }
        $fName = Split-Path $winPkg.relative_path -Leaf
        
        Write-Host "     [>] Downloading $comp..." -ForegroundColor Gray
        & $aria2 -x 8 -s 8 -d $tempExtractDir -o $fName $dlUrl | Out-Null
        
        Write-Host "     [>] Extracting DLLs from $comp -> nvidia\cuda\bin" -ForegroundColor Gray
        & $7za e "$tempExtractDir\$fName" "-o$cudaBinDir" "*.dll" -r -y -bsp0 -bso0 | Out-Null
    }
}
Write-Host " [+] Tier 2 CUDA Installed at: $cudaBinDir" -ForegroundColor Green

# --------------------------------------------------------
# [PHASE 2] INSTALL cuDNN
# --------------------------------------------------------
$activeCudaMajor = $CudaVersion.Split('.')[0]
$targetCudnnVer = $CudnnVersion

if ([string]::IsNullOrEmpty($targetCudnnVer)) {
    Write-Host " [*] Auto-matching cuDNN for CUDA ${activeCudaMajor}.x..." -ForegroundColor Cyan
    $indexUrl = "https://developer.download.nvidia.com/compute/cudnn/redist/"
    if ($useProxy) { $indexUrl = "$proxyUrl/$indexUrl" }
    $indexRes = Invoke-WebRequest -Uri $indexUrl -UseBasicParsing
    $regex = "redistrib_([0-9]+\.[0-9]+\.[0-9]+(?:\.[0-9]+)?)\.json"
    $matches = [regex]::Matches($indexRes.Content, $regex)
    $availableCudnn = $matches | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique | Sort-Object { try { [version]$_ } catch { [version]"0.0.0" } } -Descending
    
    foreach ($ver in $availableCudnn) {
        $manifestUrl = "https://developer.download.nvidia.com/compute/cudnn/redist/redistrib_${ver}.json"
        if ($useProxy) { $manifestUrl = "$proxyUrl/$manifestUrl" }
        try {
            $manifestData = Invoke-RestMethod -Uri $manifestUrl -UseBasicParsing
            $isMatch = $false
            foreach ($rp in $manifestData.psobject.Properties) {
                $winNode = $rp.Value.'windows-x86_64'
                if ($winNode) {
                    foreach ($sub in $winNode.psobject.Properties) {
                        if ($sub.Name -eq "cuda$activeCudaMajor" -and $sub.Value.relative_path) { $isMatch = $true; break }
                    }
                    if ($winNode.relative_path -and ($winNode.relative_path -match "cuda$activeCudaMajor" -or $winNode.relative_path -notmatch "cuda\d+")) { 
                        $isMatch = $true 
                    }
                }
            }
            if ($isMatch) { $targetCudnnVer = $ver; break }
        } catch {}
    }
}

if (-not [string]::IsNullOrEmpty($targetCudnnVer)) {
    Write-Host " [*] Selected cuDNN v$targetCudnnVer. Fetching redist JSON..." -ForegroundColor Cyan
    $cudnnRedistUrl = "https://developer.download.nvidia.com/compute/cudnn/redist/redistrib_${targetCudnnVer}.json"
    if ($useProxy) { $cudnnRedistUrl = "$proxyUrl/$cudnnRedistUrl" }
    $cudnnManifest = Invoke-RestMethod -Uri $cudnnRedistUrl -UseBasicParsing
    
    foreach ($rp in $cudnnManifest.psobject.Properties) {
        $winNode = $rp.Value.'windows-x86_64'
        if ($winNode) {
            $relPath = $null
            foreach ($sub in $winNode.psobject.Properties) {
                if ($sub.Name -eq "cuda$activeCudaMajor" -and $sub.Value.relative_path) { $relPath = $sub.Value.relative_path; break }
            }
            if (-not $relPath -and $winNode.relative_path) {
                if ($winNode.relative_path -match "cuda$activeCudaMajor" -or $winNode.relative_path -notmatch "cuda\d+") { $relPath = $winNode.relative_path }
            }
            if ($relPath) {
                $dlUrl = "https://developer.download.nvidia.com/compute/cudnn/redist/$relPath"
                if ($useProxy) { $dlUrl = "$proxyUrl/$dlUrl" }
                $fName = Split-Path $relPath -Leaf
                
                Write-Host "     [>] Downloading cuDNN module $fName..." -ForegroundColor Gray
                & $aria2 -x 8 -s 8 -d $tempExtractDir -o $fName $dlUrl | Out-Null
                
                Write-Host "     [>] Extracting cuDNN DLLs -> nvidia\cudnn\bin" -ForegroundColor Gray
                foreach ($filter in $cudnnTargets) {
                    & $7za e "$tempExtractDir\$fName" "-o$cudnnBinDir" $filter -r -y -bsp0 -bso0 | Out-Null
                }
            }
        }
    }
    Write-Host " [+] Tier 2 cuDNN Installed at: $cudnnBinDir" -ForegroundColor Green
} else {
    Write-Host " [-] Could not resolve cuDNN version for CUDA $activeCudaMajor" -ForegroundColor Red
}

Remove-Item $tempExtractDir -Recurse -Force
Write-Host "`n [OK] Python + CUDA/cuDNN Deployment Completed for $TargetProjectName" -ForegroundColor Green
