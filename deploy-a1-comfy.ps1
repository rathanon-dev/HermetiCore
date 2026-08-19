$ErrorActionPreference = "Stop"
$proxyUrl = "http://192.168.1.10:8080"
$proxyHost = "192.168.1.10"
$baseDir = "d:\HermetiCore"
$comfyDir = "$baseDir\projects\A1-Comfy"
$workspaceDir = "$comfyDir\workspace"
$runtimeDir = "$comfyDir\runtime\python"
$gitExe = "$baseDir\tools\git\cmd\git.exe"

Write-Host "Starting A1-Comfy Tier 2 Deployment..." -ForegroundColor Cyan

# 1. Clone Project
if (-not (Test-Path $comfyDir)) { New-Item -ItemType Directory -Path $comfyDir -Force | Out-Null }
if (-not (Test-Path "$workspaceDir\.git")) {
    Write-Host "Cloning ComfyUI..." -ForegroundColor Yellow
    & $gitExe clone "https://github.com/comfyanonymous/ComfyUI.git" $workspaceDir
}

# 2. Setup Tier 2 Python Runtime (Copy from Tier 1)
if (-not (Test-Path $runtimeDir)) {
    Write-Host "Creating Tier 2 Runtime (Isolated)..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "$comfyDir\runtime" -Force | Out-Null
    Copy-Item -Path "$baseDir\tools\python" -Destination $runtimeDir -Recurse -Force
}

# 3. Fix pip in Tier 2 (Uncomment import site & get-pip)
$pthFile = Get-ChildItem -Path $runtimeDir -Filter "*._pth" | Select-Object -First 1
if ($pthFile) {
    (Get-Content $pthFile.FullName) -replace "#import site", "import site" | Set-Content $pthFile.FullName
}

if (-not (Test-Path "$runtimeDir\Scripts\pip.exe")) {
    Write-Host "Installing pip into Tier 2..." -ForegroundColor Yellow
    $getPip = "$comfyDir\get-pip.py"
    Invoke-WebRequest -Uri "$proxyUrl/https://bootstrap.pypa.io/get-pip.py" -OutFile $getPip -UseBasicParsing
    & "$runtimeDir\python.exe" $getPip
}

# 4. Install PyTorch & ComfyUI Requirements via Proxy
Write-Host "Installing PyTorch (CUDA 12.1) & Dependencies..." -ForegroundColor Yellow
& "$runtimeDir\python.exe" -m pip install torch torchvision torchaudio --index-url "$proxyUrl/https://download.pytorch.org/whl/cu121" --trusted-host $proxyHost
& "$runtimeDir\python.exe" -m pip install -r "$workspaceDir\requirements.txt" --index-url "$proxyUrl/https://pypi.org/simple/" --trusted-host $proxyHost

# 5. Create start script
$startScript = "$comfyDir\start.bat"
$batContent = "@echo off`ncd workspace`n..\runtime\python\python.exe main.py`npause"
Set-Content -Path $startScript -Value $batContent

Write-Host "A1-Comfy Deployment Complete!" -ForegroundColor Green
