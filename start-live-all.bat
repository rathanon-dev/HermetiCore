@echo off
title HermetiCore Live Suite Launcher
echo ======================================================================
echo  HermetiCore 3-Tier Live Web & CUDA Suite
echo ======================================================================
echo.

echo [*] Launching Next.js on port 3001...
start /b cmd /c "cd /d "%~dp0projects\Test-NodeJS-1" && "%~dp0tools\node\node.exe" node_modules\next\dist\bin\next dev -p 3001"

echo [*] Launching FastAPI on port 8000...
start /b cmd /c "cd /d "%~dp0projects\Test-Python-Web" && "%~dp0tools\python\python.exe" main.py"

echo [*] Launching CUDA Diagnostic Console on port 8001...
start /b cmd /c "cd /d "%~dp0projects\PyTest-CUDA-Core" && set "PATH=%~dp0projects\PyTest-CUDA-Core\runtime\tools\nvidia\cuda\bin;%~dp0projects\PyTest-CUDA-Core\runtime\tools\nvidia\cudnn\bin;%PATH%" && "%~dp0tools\python\python.exe" main.py"

echo.
echo [*] Waiting 3 seconds for server warm-up...
timeout /t 3 /nobreak >nul

echo [*] Popping up browsers on your desktop...
start http://localhost:3001
start http://localhost:8000
start http://localhost:8001

echo.
echo ======================================================================
echo  [OK] All 3 Live Services are Running & Open in your Desktop Browser!
echo ======================================================================
pause
