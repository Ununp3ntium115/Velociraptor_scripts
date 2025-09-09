@echo off
REM Velociraptor Professional Suite - Windows Batch Launcher
REM Double-click this file to start the installer

echo.
echo ========================================
echo  Velociraptor Professional Suite v6.0.0
echo ========================================
echo.
echo Starting PowerShell installer...
echo.

REM Check if PowerShell is available
powershell -Command "Get-Host" >nul 2>&1
if errorlevel 1 (
    echo ERROR: PowerShell is not available!
    echo Please install PowerShell 5.1 or later.
    pause
    exit /b 1
)

REM Launch PowerShell installer with elevated privileges
powershell -ExecutionPolicy Bypass -File "%~dp0LAUNCH_INSTALLER.ps1"

REM Check if installer ran successfully
if errorlevel 1 (
    echo.
    echo Installation may have encountered issues.
    echo Check the output above for details.
    echo.
    pause
)

echo.
echo Installation process completed.
pause