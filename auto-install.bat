@echo off
setlocal
cd /d "%~dp0"
echo ======================================================================
echo  HermetiCore (HermetiCore) Auto Installer
echo ======================================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "setup.ps1" -AutoBootstrap
if %errorlevel% neq 0 (
    echo [ERROR] Installation failed.
    pause
    exit /b 1
)

echo.
echo [SUCCESS] Installation completed!
echo Running start-workspace.bat...
call start-workspace.bat
