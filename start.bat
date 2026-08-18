@echo off
setlocal enabledelayedexpansion
title HermetiCore - 1-Click Autonomous Workspace
color 0B

echo ======================================================================
echo    HermetiCore (HermetiCore) Autonomous Workstation
echo    Standard: ISO/IEC/IEEE 12207 ^| Zero-Global-Pollution
echo ======================================================================
echo.

set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"

:: Check if Tier 1 Base Tools exist, if not run self-assembling setup.ps1
if not exist "%ROOT%\tools\git\cmd\git.exe" (
    echo [*] First-time setup detected. Initializing entire workspace...
    echo.
    powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%\setup.ps1" -AutoBootstrap
    if %errorlevel% neq 0 (
        echo [ERROR] Setup encountered an issue.
        pause
        exit /b 1
    )
)

:: Inject ephemeral PATH into session memory
set "PATH=%ROOT%\tools\git\cmd;%ROOT%\tools\python;%ROOT%\tools\node;%ROOT%\tools\7zip;%ROOT%\tools\aria2;%PATH%"

echo.
echo ======================================================================
echo  [SUCCESS] HermetiCore Environment Active!
echo ======================================================================
echo.
echo  To connect your AI Agent (Antigravity / Claude / Copilot), send this prompt:
echo.
echo  "Read and execute the rules in AI_BOOTSTRAP_PROTOCOL.md in this directory."
echo.
echo ======================================================================
echo.

:: Launch interactive isolated shell
powershell -NoProfile -NoExit -ExecutionPolicy Bypass -Command ^
    "$env:PATH = '%ROOT%\tools\git\cmd;%ROOT%\tools\python;%ROOT%\tools\node;%ROOT%\tools\7zip;%ROOT%\tools\aria2;' + $env:PATH; " ^
    "Write-Host ' [READY] Ephemeral Shell Active. Type AI commands or explore projects/' -ForegroundColor Cyan"
