@echo off
title HermetiCore - 1-Click Autonomous Workstation Installer
color 0B

echo ======================================================================
echo    HermetiCore (HermetiCore) Autonomous Foundation Installer
echo    Standard: ISO/IEC/IEEE 12207 ^| Twelve-Factor App ^| Zero-Pollution
echo ======================================================================
echo.

set "SCRIPT_DIR=%~dp0"

echo [*] Initializing Tier 1 AI Base Tools, Logging System, and Skills...
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%setup.ps1" -AutoBootstrap

echo.
echo ======================================================================
echo  [READY] Foundation is 100%% initialized!
echo  To start your AI development session, run: start-workspace.bat
echo ======================================================================
echo.
pause
