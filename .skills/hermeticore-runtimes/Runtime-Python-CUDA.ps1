param(
    [Parameter(Mandatory=$true)][string]$TargetProjectName,
    [string]$PythonVersion = "3.12.5",
    [string]$CudaVersion = "12.1.1",
    [string]$CudnnVersion = ""
)

$root = (Resolve-Path "$PSScriptRoot\..\..").Path
Import-Module (Join-Path $root ".skills\hermeticore-core\Core.psm1") -Force
$proxyUrl = Get-HermetiProxy -WorkspaceRoot $root
$toolsDir = Join-Path $root "tools"

# Bootstrap Base Python
& "$PSScriptRoot\Runtime-Python.ps1" -TargetProjectName $TargetProjectName -PythonVersion $PythonVersion

$cudaBinDir = Join-Path $root "projects\$TargetProjectName\runtime\tools\nvidia\cuda\bin"
$cudnnBinDir = Join-Path $root "projects\$TargetProjectName\runtime\tools\nvidia\cudnn\bin"
if (-not (Test-Path $cudaBinDir)) { New-Item -ItemType Directory -Path $cudaBinDir -Force | Out-Null }
if (-not (Test-Path $cudnnBinDir)) { New-Item -ItemType Directory -Path $cudnnBinDir -Force | Out-Null }

$tempExtractDir = Join-Path $root "projects\$TargetProjectName\runtime\temp_cuda"
if (-not (Test-Path $tempExtractDir)) { New-Item -ItemType Directory -Path $tempExtractDir -Force | Out-Null }

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

function Download-And-Verify-Batch {
    param([array]$Tasks, [string]$BatchName)
    if ($Tasks.Count -eq 0) { return }

    # Setup aria2 input file for parallel download
    $queueFile = Join-Path $tempExtractDir "${BatchName}_aria2_queue.txt"
    $queueLines = @()
    foreach ($t in $Tasks) {
        $pUrl = if ($proxyUrl) { "$proxyUrl/$($t.DirectUrl)" } else { $t.DirectUrl }
        $queueLines += $pUrl; $queueLines += "  dir=$tempExtractDir"; $queueLines += "  out=$($t.FileName)"
    }
    Set-Content -Path $queueFile -Value $queueLines -Encoding UTF8
    Write-Host "     [>] Batch Downloading $($Tasks.Count) $BatchName Components..." -ForegroundColor Gray
    
    $aria2 = Join-Path $toolsDir "aria2\aria2c.exe"
    & $aria2 --input-file=$queueFile -j 4 -x 4 -s 4 --console-log-level=warn | Out-Null
    Remove-Item $queueFile -Force -ErrorAction SilentlyContinue

    # Integrity & Size Validation Gate
    Write-Host "     [>] Validating $BatchName payload integrity..." -ForegroundColor Gray
    foreach ($t in $Tasks) {
        $filePath = Join-Path $tempExtractDir $t.FileName
        try {
            if ($t.ExpectedSize -and ((Get-Item $filePath).Length -ne $t.ExpectedSize)) { throw "Size mismatch" }
            # Use Core Module to test integrity
            Expand-HermetiArchive -FilePath $filePath -Destination "Dummy" -ToolsDir $toolsDir -ErrorAction Stop
        } catch {
            Write-Host "     [!] Archive '$($t.FileName)' failed check! Triggering direct WAN fallback..." -ForegroundColor Yellow
            if (Test-Path $filePath) { Remove-Item $filePath -Force }
            # Use Core Download WITHOUT proxy (force bypass poisoned cache)
            Invoke-HermetiDownload -Url $t.DirectUrl -OutFile $filePath -ToolsDir $toolsDir -ExpectedSize $t.ExpectedSize
            Expand-HermetiArchive -FilePath $filePath -Destination "Dummy" -ToolsDir $toolsDir
            Write-Host "     [+] Fallback recovered '$($t.FileName)' successfully." -ForegroundColor Green
        }
    }
}

# [PHASE 1] INSTALL CUDA
Write-Host " [*] Fetching CUDA v$CudaVersion redist JSON..." -ForegroundColor Cyan
$cudaRedistUrl = "https://developer.download.nvidia.com/compute/cuda/redist/redistrib_${CudaVersion}.json"
$cudaManifest = Invoke-HermetiAPI -Url $cudaRedistUrl -ProxyUrl $proxyUrl -AsJson

$cudaDownloadTasks = @()
foreach ($comp in $eliteCudaComponents) {
    $winPkg = $cudaManifest.$comp.'windows-x86_64'
    if ($winPkg -and $winPkg.relative_path) {
        $fName = Split-Path $winPkg.relative_path -Leaf
        if (-not ($cudaDownloadTasks | Where-Object FileName -eq $fName)) {
            $cudaDownloadTasks += [PSCustomObject]@{
                FileName = $fName; DirectUrl = "https://developer.download.nvidia.com/compute/cuda/redist/$($winPkg.relative_path)"; ExpectedSize = [long]$winPkg.size
            }
        }
    }
}

Download-And-Verify-Batch -Tasks $cudaDownloadTasks -BatchName "CUDA"

# Extract CUDA DLLs
$7za = Join-Path $toolsDir "7zip\7za.exe"
foreach ($t in $cudaDownloadTasks) {
    $srcZip = Join-Path $tempExtractDir $t.FileName
    Write-Host "     [>] Extracting DLLs from $($t.FileName) -> nvidia\cuda\bin" -ForegroundColor Gray
    & $7za e $srcZip "-o$cudaBinDir" "*.dll" -r -y -bsp0 -bso0 | Out-Null
}
Write-Host " [+] Tier 2 CUDA Installed at: $cudaBinDir" -ForegroundColor Green

# [PHASE 2] INSTALL cuDNN
$activeCudaMajor = $CudaVersion.Split('.')[0]
$targetCudnnVer = $CudnnVersion

if ([string]::IsNullOrEmpty($targetCudnnVer)) {
    Write-Host " [*] Auto-matching cuDNN for CUDA ${activeCudaMajor}.x..." -ForegroundColor Cyan
    $indexUrl = "https://developer.download.nvidia.com/compute/cudnn/redist/"
    $indexHtml = Invoke-HermetiAPI -Url $indexUrl -ProxyUrl $proxyUrl
    $regex = "redistrib_([0-9]+\.[0-9]+\.[0-9]+(?:\.[0-9]+)?)\.json"
    $matches = [regex]::Matches($indexHtml, $regex)
    $availableCudnn = $matches | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique | Sort-Object { try { [version]$_ } catch { [version]"0.0.0" } } -Descending
    
    foreach ($ver in $availableCudnn) {
        $manifestUrl = "https://developer.download.nvidia.com/compute/cudnn/redist/redistrib_${ver}.json"
        $manifestData = Invoke-HermetiAPI -Url $manifestUrl -ProxyUrl $proxyUrl -AsJson
        if ($manifestData) {
            $isMatch = $false
            foreach ($rp in $manifestData.psobject.Properties) {
                $winNode = $rp.Value.'windows-x86_64'
                if ($winNode) {
                    foreach ($sub in $winNode.psobject.Properties) {
                        if ($sub.Name -eq "cuda$activeCudaMajor" -and $sub.Value.relative_path) { $isMatch = $true; break }
                    }
                    if ($winNode.relative_path -and ($winNode.relative_path -match "cuda$activeCudaMajor" -or $winNode.relative_path -notmatch "cuda\d+")) { $isMatch = $true }
                }
            }
            if ($isMatch) { $targetCudnnVer = $ver; break }
        }
    }
}

if (-not [string]::IsNullOrEmpty($targetCudnnVer)) {
    Write-Host " [*] Selected cuDNN v$targetCudnnVer. Fetching redist JSON..." -ForegroundColor Cyan
    $cudnnManifestUrl = "https://developer.download.nvidia.com/compute/cudnn/redist/redistrib_${targetCudnnVer}.json"
    $cudnnManifest = Invoke-HermetiAPI -Url $cudnnManifestUrl -ProxyUrl $proxyUrl -AsJson
    
    $cudnnTasks = @()
    foreach ($rp in $cudnnManifest.psobject.Properties) {
        $winNode = $rp.Value.'windows-x86_64'
        if ($winNode) {
            $path = $null; $size = 0
            foreach ($sub in $winNode.psobject.Properties) {
                if ($sub.Name -eq "cuda$activeCudaMajor" -and $sub.Value.relative_path) { $path = $sub.Value.relative_path; $size = $sub.Value.size; break }
            }
            if (-not $path -and $winNode.relative_path) { $path = $winNode.relative_path; $size = $winNode.size }
            if ($path) {
                $fName = Split-Path $path -Leaf
                if (-not ($cudnnTasks | Where-Object FileName -eq $fName)) {
                    $cudnnTasks += [PSCustomObject]@{ FileName = $fName; DirectUrl = "https://developer.download.nvidia.com/compute/cudnn/redist/$path"; ExpectedSize = [long]$size }
                }
            }
        }
    }
    Download-And-Verify-Batch -Tasks $cudnnTasks -BatchName "cuDNN"
    foreach ($t in $cudnnTasks) {
        $srcZip = Join-Path $tempExtractDir $t.FileName
        Write-Host "     [>] Extracting cuDNN DLLs from $($t.FileName) -> nvidia\cudnn\bin" -ForegroundColor Gray
        foreach ($target in $cudnnTargets) { & $7za e $srcZip "-o$cudnnBinDir" $target -r -y -bsp0 -bso0 | Out-Null }
    }
    Write-Host " [+] Tier 2 cuDNN Installed at: $cudnnBinDir" -ForegroundColor Green
}

Remove-Item $tempExtractDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host " [OK] Python + CUDA/cuDNN Deployment Completed for $TargetProjectName" -ForegroundColor Green
