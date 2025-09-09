# Velociraptor Professional Suite - Easy Launcher
# Double-click this file to start the installer

<#
.SYNOPSIS
    Easy launcher for Velociraptor Professional Suite
    
.DESCRIPTION
    This script provides an easy way to launch the Velociraptor installer
    with proper error handling and user guidance.
#>

# Set execution policy for current process
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Check if running as administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "🔐 Administrator privileges required!" -ForegroundColor Yellow
    Write-Host "Right-click this file and select 'Run as Administrator'" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Or run from an elevated PowerShell prompt:" -ForegroundColor Cyan
    Write-Host "  .\LAUNCH_INSTALLER.ps1" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Welcome message
Clear-Host
Write-Host "🚀 Velociraptor Professional Suite v6.0.0" -ForegroundColor Green
Write-Host "=" * 50 -ForegroundColor Blue
Write-Host ""
Write-Host "Welcome to the Velociraptor Professional Installer!" -ForegroundColor Cyan
Write-Host ""
Write-Host "This installer provides:" -ForegroundColor White
Write-Host "• Professional GUI installation wizard" -ForegroundColor Gray
Write-Host "• Complete service management" -ForegroundColor Gray
Write-Host "• Real-time monitoring dashboard" -ForegroundColor Gray
Write-Host "• Incident response tools" -ForegroundColor Gray
Write-Host "• Configuration management" -ForegroundColor Gray
Write-Host ""

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "❌ PowerShell 5.1 or later is required!" -ForegroundColor Red
    Write-Host "Current version: $($PSVersionTable.PSVersion)" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check Windows version
$osVersion = [System.Environment]::OSVersion.Version
if ($osVersion.Major -lt 10) {
    Write-Host "⚠️  Windows 10 or Server 2016+ recommended" -ForegroundColor Yellow
    Write-Host "Current version: $($osVersion)" -ForegroundColor Gray
    $continue = Read-Host "Continue anyway? (y/N)"
    if ($continue -ne 'y' -and $continue -ne 'Y') {
        exit 1
    }
}

Write-Host "✅ System checks passed!" -ForegroundColor Green
Write-Host ""

# Launch the main installer
try {
    $installerPath = Join-Path $PSScriptRoot "VelociraptorInstaller.ps1"
    
    if (-not (Test-Path $installerPath)) {
        throw "Installer not found: $installerPath"
    }
    
    Write-Host "🎯 Launching Velociraptor Professional Installer..." -ForegroundColor Cyan
    Write-Host ""
    
    # Execute the installer
    & $installerPath
}
catch {
    Write-Host "❌ Failed to launch installer!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Cyan
    Write-Host "1. Ensure you're running as Administrator" -ForegroundColor Gray
    Write-Host "2. Check that all files are present" -ForegroundColor Gray
    Write-Host "3. Verify PowerShell execution policy" -ForegroundColor Gray
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}