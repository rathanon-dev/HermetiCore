@echo off
title HermetiCore Live Suite Launcher
echo ======================================================================
echo  HermetiCore 3-Tier Live Web ^& CUDA Suite
echo ======================================================================
echo.

:: Verify Tier 2 runtimes exist before launching
if not exist "%~dp0projects\Test-NodeJS-1\runtime\tools\node\node.exe" (
    echo [ERROR] Test-NodeJS-1 Tier 2 runtime not found.
    echo [HINT]  Run: .\.skills\hermeticore-runtimes\Runtime-Node.ps1 -TargetProjectName "Test-NodeJS-1"
    goto :launch_python
)
echo [*] Launching Node.js ^(server.js^) on port 3001 via Tier 2 runtime...
start /b cmd /c "cd /d "%~dp0projects\Test-NodeJS-1" && "%~dp0projects\Test-NodeJS-1\runtime\tools\node\node.exe" server.js"

:launch_python
if not exist "%~dp0projects\Test-Python-Web\runtime\tools\python\python.exe" (
    echo [ERROR] Test-Python-Web Tier 2 runtime not found.
    echo [HINT]  Run: .\.skills\hermeticore-runtimes\Runtime-Python.ps1 -TargetProjectName "Test-Python-Web" -InstallPackages "fastapi uvicorn"
    goto :launch_cuda
)
echo [*] Launching FastAPI on port 8000 via Tier 2 runtime...
start /b cmd /c "cd /d "%~dp0projects\Test-Python-Web" && "%~dp0projects\Test-Python-Web\runtime\tools\python\python.exe" main.py"

:launch_cuda
if not exist "%~dp0projects\PyTest-CUDA-Core\runtime\tools\python\python.exe" (
    echo [ERROR] PyTest-CUDA-Core Tier 2 runtime not found.
    echo [HINT]  Run: .\.skills\hermeticore-runtimes\Runtime-Python-CUDA.ps1 -TargetProjectName "PyTest-CUDA-Core"
    goto :done
)
echo [*] Launching CUDA Diagnostic Console on port 8001 via Tier 2 runtime...
start /b cmd /c "cd /d "%~dp0projects\PyTest-CUDA-Core" && set "PATH=%~dp0projects\PyTest-CUDA-Core\runtime\tools\nvidia\cuda\bin;%~dp0projects\PyTest-CUDA-Core\runtime\tools\nvidia\cudnn\bin;%PATH%" && "%~dp0projects\PyTest-CUDA-Core\runtime\tools\python\python.exe" main.py"

:done
echo.
echo [*] Waiting 3 seconds for server warm-up...
timeout /t 3 /nobreak >nul

echo [*] Popping up browsers on your desktop...
start http://localhost:3001
start http://localhost:8000
start http://localhost:8001

echo.
echo ======================================================================
echo  [OK] All 3 Live Services launched. Check for [ERROR] lines above.
echo ======================================================================
pause
