@echo off
setlocal enabledelayedexpansion
title MetaBase AI - Ephemeral Session Launcher
color 0A

echo ======================================================================
echo    METABASE AI (LabBase-5) Active Session
echo    Standard: ISO/IEC/IEEE 12207 ^| Zero-Global-Pollution
echo ======================================================================
echo.

set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"

:: Check if Tier 1 tools exist
if not exist "%ROOT%\tools\git\cmd\git.exe" (
    echo [!] Tools not found. Bootstrapping first...
    powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%\setup.ps1" -AutoBootstrap
)

:: Inject ephemeral PATH into session memory only
set "PATH=%ROOT%\tools\git\cmd;%ROOT%\tools\python;%ROOT%\tools\node;%ROOT%\tools\7zip;%ROOT%\tools\aria2;%PATH%"

echo [OK] Ephemeral PATH injected. Launching Workspace Shell...
echo.

powershell -NoProfile -NoExit -ExecutionPolicy Bypass -Command ^
    "$env:PATH = '%ROOT%\tools\git\cmd;%ROOT%\tools\python;%ROOT%\tools\node;%ROOT%\tools\7zip;%ROOT%\tools\aria2;' + $env:PATH; " ^
    "Write-Host ' [READY] MetaBase AI Session Active. Type exit to leave.' -ForegroundColor Green"
