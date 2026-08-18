@echo off
title Human Acceptance Verification Gate
color 0A

echo ======================================================================
echo    HUMAN VERIFICATION GATE
echo    Test the AI-generated build before promoting to repo/
echo ======================================================================
echo.

set "STAGING_ROOT=%~dp0.."
set "POD_ROOT=%STAGING_ROOT%\.."

echo [*] Opening Verification Environment...
call "%POD_ROOT%\runtime\start-dev.bat"

echo.
echo [!] After manual testing:
echo     - If PASS: Run promotion script to sync code to repo/
echo     - If FAIL: Send feedback to AI agent to fix issues in staging/ai/
echo.
pause
