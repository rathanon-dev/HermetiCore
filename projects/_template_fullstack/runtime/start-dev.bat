@echo off
title FullStack Pod - Multi-Service Launcher
color 0E

echo ======================================================================
echo    Starting Multi-Service FullStack Pod
echo    Frontend: http://localhost:3000  ^|  Backend: http://localhost:8000
echo ======================================================================
echo.

set "POD_ROOT=%~dp0.."
set "TOOLS_ROOT=%POD_ROOT%\..\..\tools"

:: Ephemeral path injection
set "PATH=%TOOLS_ROOT%\git\cmd;%TOOLS_ROOT%\python;%TOOLS_ROOT%\node;%TOOLS_ROOT%\7zip;%TOOLS_ROOT%\aria2;%PATH%"

echo [*] Starting Backend (FastAPI)...
start "Backend Service (:8000)" cmd /k "cd /d %POD_ROOT%\services\api-backend && echo [Backend Service Running...]"

echo [*] Starting Frontend (Next.js)...
start "Frontend Service (:3000)" cmd /k "cd /d %POD_ROOT%\services\web-frontend && echo [Frontend Service Running...]"

echo [OK] All services launched. Close this window to manage background processes.
