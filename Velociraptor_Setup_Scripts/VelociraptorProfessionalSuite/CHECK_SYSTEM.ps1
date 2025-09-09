# System Compatibility Check for Velociraptor Professional Suite
# Run this to verify your system is ready for installation

Clear-Host
Write-Host "🔍 Velociraptor Professional Suite - System Check" -ForegroundColor Green
Write-Host "=" * 55 -ForegroundColor Blue
Write-Host ""

$allChecks = $true

# Check PowerShell version
Write-Host "Checking PowerShell version..." -NoNewline
if ($PSVersionTable.PSVersion.Major -ge 5) {
    Write-Host " ✅ PASS" -ForegroundColor Green
    Write-Host "   Version: $($PSVersionTable.PSVersion)" -ForegroundColor Gray
} else {
    Write-Host " ❌ FAIL" -ForegroundColor Red
    Write-Host "   Current: $($PSVersionTable.PSVersion)" -ForegroundColor Yellow
    Write-Host "   Required: 5.1 or later" -ForegroundColor Yellow
    $allChecks = $false
}

# Check Windows version
Write-Host "Checking Windows version..." -NoNewline
$osVersion = [System.Environment]::OSVersion.Version
if ($osVersion.Major -ge 10) {
    Write-Host " ✅ PASS" -ForegroundColor Green
    Write-Host "   Version: $($osVersion)" -ForegroundColor Gray
} else {
    Write-Host " ⚠️  WARNING" -ForegroundColor Yellow
    Write-Host "   Current: $($osVersion)" -ForegroundColor Yellow
    Write-Host "   Recommended: Windows 10 or Server 2016+" -ForegroundColor Yellow
}

# Check administrator privileges
Write-Host "Checking administrator privileges..." -NoNewline
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host " ✅ PASS" -ForegroundColor Green
    Write-Host "   Running as Administrator" -ForegroundColor Gray
} else {
    Write-Host " ❌ FAIL" -ForegroundColor Red
    Write-Host "   Must run as Administrator" -ForegroundColor Yellow
    $allChecks = $false
}

# Check .NET Framework
Write-Host "Checking .NET Framework..." -NoNewline
try {
    $netVersion = Get-ItemProperty "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" -Name Release -ErrorAction Stop
    if ($netVersion.Release -ge 461808) {  # .NET 4.7.2
        Write-Host " ✅ PASS" -ForegroundColor Green
        Write-Host "   .NET Framework 4.7.2+ detected" -ForegroundColor Gray
    } else {
        Write-Host " ⚠️  WARNING" -ForegroundColor Yellow
        Write-Host "   .NET Framework 4.7.2+ recommended" -ForegroundColor Yellow
    }
} catch {
    Write-Host " ⚠️  WARNING" -ForegroundColor Yellow
    Write-Host "   Could not detect .NET Framework version" -ForegroundColor Yellow
}

# Check available disk space
Write-Host "Checking disk space..." -NoNewline
try {
    $drive = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction Stop
    $freeSpaceGB = [math]::Round($drive.FreeSpace / 1GB, 2)
    if ($freeSpaceGB -ge 2) {
        Write-Host " ✅ PASS" -ForegroundColor Green
        Write-Host "   Available: $freeSpaceGB GB" -ForegroundColor Gray
    } else {
        Write-Host " ⚠️  WARNING" -ForegroundColor Yellow
        Write-Host "   Available: $freeSpaceGB GB (2GB recommended)" -ForegroundColor Yellow
    }
} catch {
    Write-Host " ⚠️  UNKNOWN" -ForegroundColor Yellow
    Write-Host "   Could not check disk space" -ForegroundColor Yellow
}

# Check memory
Write-Host "Checking system memory..." -NoNewline
try {
    $memory = Get-WmiObject -Class Win32_ComputerSystem -ErrorAction Stop
    $memoryGB = [math]::Round($memory.TotalPhysicalMemory / 1GB, 2)
    if ($memoryGB -ge 4) {
        Write-Host " ✅ PASS" -ForegroundColor Green
        Write-Host "   Total RAM: $memoryGB GB" -ForegroundColor Gray
    } else {
        Write-Host " ⚠️  WARNING" -ForegroundColor Yellow
        Write-Host "   Total RAM: $memoryGB GB (4GB recommended)" -ForegroundColor Yellow
    }
} catch {
    Write-Host " ⚠️  UNKNOWN" -ForegroundColor Yellow
    Write-Host "   Could not check memory" -ForegroundColor Yellow
}

# Check Windows Forms availability
Write-Host "Checking Windows Forms..." -NoNewline
try {
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
    Write-Host " ✅ PASS" -ForegroundColor Green
    Write-Host "   Windows Forms available" -ForegroundColor Gray
} catch {
    Write-Host " ❌ FAIL" -ForegroundColor Red
    Write-Host "   Windows Forms not available" -ForegroundColor Yellow
    $allChecks = $false
}

# Check execution policy
Write-Host "Checking execution policy..." -NoNewline
$executionPolicy = Get-ExecutionPolicy
if ($executionPolicy -eq "Unrestricted" -or $executionPolicy -eq "RemoteSigned" -or $executionPolicy -eq "Bypass") {
    Write-Host " ✅ PASS" -ForegroundColor Green
    Write-Host "   Policy: $executionPolicy" -ForegroundColor Gray
} else {
    Write-Host " ⚠️  INFO" -ForegroundColor Yellow
    Write-Host "   Policy: $executionPolicy (will be handled automatically)" -ForegroundColor Yellow
}

# Summary
Write-Host ""
Write-Host "=" * 55 -ForegroundColor Blue
if ($allChecks) {
    Write-Host "🎉 System Check: PASSED" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your system is ready for Velociraptor Professional Suite!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor White
    Write-Host "1. Double-click LAUNCH_INSTALLER.bat" -ForegroundColor Gray
    Write-Host "2. Follow the installation wizard" -ForegroundColor Gray
    Write-Host "3. Enjoy your DFIR platform!" -ForegroundColor Gray
} else {
    Write-Host "⚠️  System Check: ISSUES FOUND" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please resolve the issues marked with ❌ before installing." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Common solutions:" -ForegroundColor White
    Write-Host "• Run this script as Administrator" -ForegroundColor Gray
    Write-Host "• Update PowerShell to version 5.1+" -ForegroundColor Gray
    Write-Host "• Install .NET Framework 4.7.2+" -ForegroundColor Gray
}

Write-Host ""
Read-Host "Press Enter to exit"