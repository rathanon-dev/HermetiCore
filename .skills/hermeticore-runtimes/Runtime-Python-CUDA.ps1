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

# 2. Bootstrap Base Python via Runtime-Python.ps1
& "$PSScriptRoot\Runtime-Python.ps1" -TargetProjectName $TargetProjectName -PythonVersion $PythonVersion

# 3. Setup CUDA & cuDNN Output Directories
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

# Helper function to download, verify, and fallback
function Download-And-Verify-Batch {
    param(
        [Parameter(Mandatory=$true)][array]$Tasks,
        [Parameter(Mandatory=$true)][string]$BatchName
    )

    if ($Tasks.Count -eq 0) { return }

    # Deduplicate download tasks by FileName
    $uniqueTasks = @{}
    foreach ($t in $Tasks) {
        if (-not $uniqueTasks.ContainsKey($t.FileName)) {
            $uniqueTasks[$t.FileName] = $t
        }
    }

    $queueFile = Join-Path $tempExtractDir "${BatchName}_aria2_queue.txt"
    $queueLines = @()
    foreach ($t in $uniqueTasks.Values) {
        $queueLines += $t.ProxyUrl
        $queueLines += "  dir=$tempExtractDir"
        $queueLines += "  out=$($t.FileName)"
    }

    Set-Content -Path $queueFile -Value $queueLines -Encoding UTF8
    Write-Host "     [>] Batch Downloading $($uniqueTasks.Count) $BatchName Components..." -ForegroundColor Gray
    & $aria2 --input-file=$queueFile -j 4 -x 4 -s 4 --console-log-level=warn | Out-Null
    Remove-Item $queueFile -Force -ErrorAction SilentlyContinue

    # Integrity & Size Validation Gate
    Write-Host "     [>] Validating $BatchName payload integrity (7za test & size)..." -ForegroundColor Gray
    foreach ($t in $uniqueTasks.Values) {
        $filePath = Join-Path $tempExtractDir $t.FileName
        $isCorrupt = $false

        if (Test-Path $filePath) {
            # 1. Byte Size Verification (if size provided in manifest)
            if ($t.ExpectedSize -and ((Get-Item $filePath).Length -ne $t.ExpectedSize)) {
                $isCorrupt = $true
            }
            # 2. Archive CRC / Structure Test
            & $7za t $filePath -bsp0 -bso0 | Out-Null
            if ($LASTEXITCODE -ne 0) { $isCorrupt = $true }
        } else {
            $isCorrupt = $true
        }

        if ($isCorrupt) {
            Write-Host "     [!] Archive '$($t.FileName)' failed integrity check! Triggering direct WAN fallback..." -ForegroundColor Yellow
            if (Test-Path $filePath) { Remove-Item $filePath -Force }
            Invoke-WebRequest -Uri $t.DirectUrl -OutFile $filePath -UseBasicParsing
            & $7za t $filePath -bsp0 -bso0 | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Write-Host "     [-] Fatal: '$($t.FileName)' is permanently corrupted on upstream." -ForegroundColor Red
            } else {
                Write-Host "     [+] Fallback recovered '$($t.FileName)' successfully." -ForegroundColor Green
            }
        }
    }
}

# --------------------------------------------------------
# [PHASE 1] INSTALL CUDA
# --------------------------------------------------------
Write-Host " [*] Fetching CUDA v$CudaVersion redist JSON..." -ForegroundColor Cyan
$cudaRedistUrl = "https://developer.download.nvidia.com/compute/cuda/redist/redistrib_${CudaVersion}.json"
$effectiveCudaUrl = if ($useProxy) { "$proxyUrl/$cudaRedistUrl" } else { $cudaRedistUrl }
$cudaManifest = Invoke-RestMethod -Uri $effectiveCudaUrl -UseBasicParsing

$cudaDownloadTasks = @()
foreach ($comp in $eliteCudaComponents) {
    $winPkg = $cudaManifest.$comp.'windows-x86_64'
    if ($winPkg -and $winPkg.relative_path) {
        $directUrl = "https://developer.download.nvidia.com/compute/cuda/redist/$($winPkg.relative_path)"
        $pUrl = if ($useProxy) { "$proxyUrl/$directUrl" } else { $directUrl }
        $fName = Split-Path $winPkg.relative_path -Leaf

        $cudaDownloadTasks += [PSCustomObject]@{
            FileName     = $fName
            DirectUrl    = $directUrl
            ProxyUrl     = $pUrl
            ExpectedSize = [long]$winPkg.size
        }
    }
}

Download-And-Verify-Batch -Tasks $cudaDownloadTasks -BatchName "CUDA"

# Extract CUDA DLLs
$uniqueCudaFiles = $cudaDownloadTasks | Select-Object -ExpandProperty FileName -Unique
foreach ($fName in $uniqueCudaFiles) {
    $srcZip = Join-Path $tempExtractDir $fName
    if (Test-Path $srcZip) {
        Write-Host "     [>] Extracting DLLs from $fName -> nvidia\cuda\bin" -ForegroundColor Gray
        & $7za e $srcZip "-o$cudaBinDir" "*.dll" -r -y -bsp0 -bso0 | Out-Null
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
    $effectiveIndexUrl = if ($useProxy) { "$proxyUrl/$indexUrl" } else { $indexUrl }
    $indexRes = Invoke-WebRequest -Uri $effectiveIndexUrl -UseBasicParsing
    $regex = "redistrib_([0-9]+\.[0-9]+\.[0-9]+(?:\.[0-9]+)?)\.json"
    $matches = [regex]::Matches($indexRes.Content, $regex)
    $availableCudnn = $matches | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique | Sort-Object { try { [version]$_ } catch { [version]"0.0.0" } } -Descending
    
    foreach ($ver in $availableCudnn) {
        $manifestUrl = "https://developer.download.nvidia.com/compute/cudnn/redist/redistrib_${ver}.json"
        $effectiveManifestUrl = if ($useProxy) { "$proxyUrl/$manifestUrl" } else { $manifestUrl }
        try {
            $manifestData = Invoke-RestMethod -Uri $effectiveManifestUrl -UseBasicParsing
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
    $effectiveCudnnUrl = if ($useProxy) { "$proxyUrl/$cudnnRedistUrl" } else { $cudnnRedistUrl }
    $cudnnManifest = Invoke-RestMethod -Uri $effectiveCudnnUrl -UseBasicParsing

    $cudnnDownloadTasks = @()
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
                $directUrl = "https://developer.download.nvidia.com/compute/cudnn/redist/$relPath"
                $pUrl = if ($useProxy) { "$proxyUrl/$directUrl" } else { $directUrl }
                $fName = Split-Path $relPath -Leaf

                $cudnnDownloadTasks += [PSCustomObject]@{
                    FileName     = $fName
                    DirectUrl    = $directUrl
                    ProxyUrl     = $pUrl
                    ExpectedSize = [long]$winNode.size
                }
            }
        }
    }

    Download-And-Verify-Batch -Tasks $cudnnDownloadTasks -BatchName "cuDNN"

    # Extract cuDNN DLLs
    $uniqueCudnnFiles = $cudnnDownloadTasks | Select-Object -ExpandProperty FileName -Unique
    foreach ($fName in $uniqueCudnnFiles) {
        $srcZip = Join-Path $tempExtractDir $fName
        if (Test-Path $srcZip) {
            Write-Host "     [>] Extracting cuDNN DLLs from $fName -> nvidia\cudnn\bin" -ForegroundColor Gray
            foreach ($filter in $cudnnTargets) {
                & $7za e $srcZip "-o$cudnnBinDir" $filter -r -y -bsp0 -bso0 | Out-Null
            }
        }
    }
    Write-Host " [+] Tier 2 cuDNN Installed at: $cudnnBinDir" -ForegroundColor Green
} else {
    Write-Host " [-] Could not resolve cuDNN version for CUDA $activeCudaMajor" -ForegroundColor Red
}

Remove-Item $tempExtractDir -Recurse -Force -ErrorAction SilentlyContinue

# Verify DLL Count in Target Folders
$finalCudaCount = (Get-ChildItem -Path $cudaBinDir -Filter "*.dll" -ErrorAction SilentlyContinue).Count
$finalCudnnCount = (Get-ChildItem -Path $cudnnBinDir -Filter "*.dll" -ErrorAction SilentlyContinue).Count
Write-Host " [*] Active Binaries Verified: CUDA ($finalCudaCount DLLs) | cuDNN ($finalCudnnCount DLLs)" -ForegroundColor Cyan
Write-Host "`n [OK] Python + CUDA/cuDNN Deployment Completed for $TargetProjectName" -ForegroundColor Green
