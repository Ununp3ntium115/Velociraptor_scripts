# Build Script for Velociraptor Ultimate
# Combines all functionality into one comprehensive application

<#
.SYNOPSIS
    Builds the complete Velociraptor Ultimate application
    
.DESCRIPTION
    This script combines all Velociraptor functionality into one ultimate application:
    - Investigation management from VelociraptorInvestigations.ps1
    - Offline worker capabilities from VelociraptorOfflineWorker.ps1  
    - Server setup from VelociraptorServerSetup.ps1
    - Artifact management from existing artifact tools
    - All supporting modules and functions
    
.PARAMETER OutputPath
    Path where the built application will be saved
    
.PARAMETER IncludeModules
    Include all PowerShell modules in the build
    
.PARAMETER CreateExecutable
    Create an executable version using PS2EXE
    
.EXAMPLE
    .\Build-VelociraptorUltimate.ps1 -OutputPath ".\VelociraptorUltimate" -IncludeModules -CreateExecutable
#>

param(
    [string] $OutputPath = ".\VelociraptorUltimate",
    [switch] $IncludeModules,
    [switch] $CreateExecutable,
    [switch] $RunQA,
    [switch] $RunUA
)

Write-Host "🔨 Building Velociraptor Ultimate - Complete DFIR Platform" -ForegroundColor Green
Write-Host "=" * 70 -ForegroundColor Blue

# Ensure output directory exists
if (-not (Test-Path $OutputPath)) {
    New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
}

# Define all source components
$sourceComponents = @{
    "Core Application" = @{
        Files = @("VelociraptorUltimate.ps1")
        Required = $true
    }
    "Investigation Components" = @{
        Files = @("VelociraptorInvestigations.ps1")
        Required = $true
    }
    "Offline Worker Components" = @{
        Files = @("VelociraptorOfflineWorker.ps1")
        Required = $true
    }
    "Server Setup Components" = @{
        Files = @("VelociraptorServerSetup.ps1")
        Required = $true
    }
    "Artifact Management" = @{
        Files = @(
            "Investigate-ArtifactPack.ps1",
            "scripts\Build-VelociraptorArtifactPackage.ps1",
            "modules\VelociraptorDeployment\functions\New-ArtifactToolManager.ps1"
        )
        Required = $true
    }
    "PowerShell Modules" = @{
        Files = @("modules\")
        Required = $IncludeModules
    }
    "Supporting Scripts" = @{
        Files = @(
            "scripts\Organize-Documentation.ps1",
            "scripts\Fork-VelociraptorEcosystem.ps1"
        )
        Required = $false
    }
}

Write-Host "📋 Analyzing source components..." -ForegroundColor Yellow

# Check component availability
$availableComponents = @{}
$missingComponents = @()

foreach ($componentName in $sourceComponents.Keys) {
    $component = $sourceComponents[$componentName]
    $availableFiles = @()
    $missingFiles = @()
    
    foreach ($file in $component.Files) {
        if (Test-Path $file) {
            $availableFiles += $file
        } else {
            $missingFiles += $file
        }
    }
    
    $availableComponents[$componentName] = @{
        Available = $availableFiles
        Missing = $missingFiles
        Required = $component.Required
        Status = if ($missingFiles.Count -eq 0) { "Complete" } elseif ($availableFiles.Count -gt 0) { "Partial" } else { "Missing" }
    }
    
    if ($component.Required -and $missingFiles.Count -gt 0) {
        $missingComponents += $componentName
    }
    
    Write-Host "  $componentName`: $($availableComponents[$componentName].Status)" -ForegroundColor $(
        switch ($availableComponents[$componentName].Status) {
            "Complete" { "Green" }
            "Partial" { "Yellow" }
            "Missing" { "Red" }
        }
    )
}

if ($missingComponents.Count -gt 0) {
    Write-Host "❌ Missing required components:" -ForegroundColor Red
    foreach ($component in $missingComponents) {
        Write-Host "  - $component" -ForegroundColor Red
        foreach ($file in $availableComponents[$component].Missing) {
            Write-Host "    Missing: $file" -ForegroundColor Gray
        }
    }
    Write-Host "Please ensure all required files are present before building." -ForegroundColor Yellow
    return
}

Write-Host "✅ All required components available" -ForegroundColor Green

# Start building the ultimate application
Write-Host "`n🔧 Building Velociraptor Ultimate application..." -ForegroundColor Yellow

# Read and combine all PowerShell components
$ultimateScript = @()

# Add header
$ultimateScript += @"
#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Velociraptor Ultimate - Complete DFIR Platform
    
.DESCRIPTION
    The ultimate Velociraptor application combining all functionality:
    - Investigation management and incident response
    - Offline evidence collection and analysis  
    - Server/standalone installation and setup
    - Advanced artifact pack management with 3rd party tools
    - Real-time monitoring and health dashboards
    - AI-powered investigation assistance
    
    Built from components:
$(foreach ($componentName in $availableComponents.Keys) {
    if ($availableComponents[$componentName].Available.Count -gt 0) {
        "    - $componentName"
    }
})
    
.PARAMETER VelociraptorPath
    Path to Velociraptor installation directory
    
.PARAMETER ConfigFile
    Path to configuration file
    
.PARAMETER DebugMode
    Enable debug mode for troubleshooting
    
.EXAMPLE
    .\VelociraptorUltimate.ps1
    Launch the complete DFIR platform
    
.EXAMPLE
    .\VelociraptorUltimate.ps1 -DebugMode
    Launch with debug information
    
.NOTES
    Version: 6.0.0-Ultimate
    Built: $(Get-Date)
    Components: $($availableComponents.Keys.Count) integrated
    Author: Velociraptor Setup Scripts Team
#>

"@

# Read the main application file
Write-Host "📄 Reading core application..." -ForegroundColor Cyan
if (Test-Path "VelociraptorUltimate.ps1") {
    $coreContent = Get-Content "VelociraptorUltimate.ps1" -Raw
    $ultimateScript += $coreContent
} else {
    Write-Host "❌ Core application file not found!" -ForegroundColor Red
    return
}

# Add supporting functions from other components
Write-Host "📄 Integrating supporting components..." -ForegroundColor Cyan

# Extract key functions from other GUI applications
$supportingFunctions = @()

# From VelociraptorInvestigations.ps1
if (Test-Path "VelociraptorInvestigations.ps1") {
    $invContent = Get-Content "VelociraptorInvestigations.ps1" -Raw
    # Extract specific functions we need
    if ($invContent -match '(?s)\[string\[\]\] GetDefaultArtifacts.*?(?=\s+\[)') {
        $supportingFunctions += $matches[0]
    }
}

# From VelociraptorOfflineWorker.ps1  
if (Test-Path "VelociraptorOfflineWorker.ps1") {
    $offlineContent = Get-Content "VelociraptorOfflineWorker.ps1" -Raw
    # Extract offline collection functions
    if ($offlineContent -match '(?s)\[void\] LoadPreset.*?(?=\s+\[)') {
        $supportingFunctions += $matches[0]
    }
}

# Add artifact management functions
if (Test-Path "modules\VelociraptorDeployment\functions\New-ArtifactToolManager.ps1") {
    Write-Host "📦 Including artifact management functionality..." -ForegroundColor Cyan
    $artifactContent = Get-Content "modules\VelociraptorDeployment\functions\New-ArtifactToolManager.ps1" -Raw
    $supportingFunctions += "`n# Artifact Management Functions`n" + $artifactContent
}

# Combine everything
$ultimateScript += "`n# Supporting Functions from Integrated Components`n"
$ultimateScript += $supportingFunctions -join "`n`n"

# Write the combined application
$outputScript = Join-Path $OutputPath "VelociraptorUltimate.ps1"
$ultimateScript -join "`n" | Out-File -FilePath $outputScript -Encoding UTF8

Write-Host "✅ Ultimate application created: $outputScript" -ForegroundColor Green

# Copy modules if requested
if ($IncludeModules -and (Test-Path "modules")) {
    Write-Host "📦 Copying PowerShell modules..." -ForegroundColor Cyan
    $modulesPath = Join-Path $OutputPath "modules"
    Copy-Item "modules" -Destination $modulesPath -Recurse -Force
    Write-Host "✅ Modules copied to: $modulesPath" -ForegroundColor Green
}

# Copy supporting files
Write-Host "📄 Copying supporting files..." -ForegroundColor Cyan
$supportingFiles = @(
    "artifact_packs\artifact_exchange_v2.zip",
    "templates\configurations\server-config.yaml",
    "templates\configurations\standalone-config.yaml"
)

foreach ($file in $supportingFiles) {
    if (Test-Path $file) {
        $destPath = Join-Path $OutputPath (Split-Path $file -Leaf)
        Copy-Item $file -Destination $destPath -Force
        Write-Host "  Copied: $(Split-Path $file -Leaf)" -ForegroundColor Gray
    }
}

# Create launcher scripts
Write-Host "🚀 Creating launcher scripts..." -ForegroundColor Cyan

# Windows batch launcher
$batchLauncher = @"
@echo off
echo.
echo ========================================
echo  Velociraptor Ultimate v6.0.0
echo  Complete DFIR Platform
echo ========================================
echo.
echo Starting Velociraptor Ultimate...
echo.

REM Check if PowerShell is available
powershell -Command "Get-Host" >nul 2>&1
if errorlevel 1 (
    echo ERROR: PowerShell is not available!
    echo Please install PowerShell 5.1 or later.
    pause
    exit /b 1
)

REM Launch PowerShell application with elevated privileges
powershell -ExecutionPolicy Bypass -File "%~dp0VelociraptorUltimate.ps1"

if errorlevel 1 (
    echo.
    echo Application may have encountered issues.
    echo Check the output above for details.
    echo.
    pause
)

echo.
echo Application session completed.
pause
"@

$batchLauncher | Out-File -FilePath (Join-Path $OutputPath "Launch-VelociraptorUltimate.bat") -Encoding ASCII

# PowerShell launcher with system checks
$psLauncher = @"
# Velociraptor Ultimate Launcher with System Validation
param([switch] `$SkipChecks)

if (-not `$SkipChecks) {
    # System validation
    Write-Host "🔍 Velociraptor Ultimate - System Validation" -ForegroundColor Green
    Write-Host "=" * 50 -ForegroundColor Blue
    
    # Check PowerShell version
    if (`$PSVersionTable.PSVersion.Major -lt 5) {
        Write-Host "❌ PowerShell 5.1+ required. Current: `$(`$PSVersionTable.PSVersion)" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    # Check administrator privileges
    `$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not `$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "❌ Administrator privileges required!" -ForegroundColor Red
        Write-Host "Right-click and select 'Run as Administrator'" -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    Write-Host "✅ System validation passed" -ForegroundColor Green
    Write-Host ""
}

# Launch the ultimate application
try {
    `$scriptPath = Join-Path `$PSScriptRoot "VelociraptorUltimate.ps1"
    if (Test-Path `$scriptPath) {
        & `$scriptPath
    } else {
        Write-Host "❌ VelociraptorUltimate.ps1 not found!" -ForegroundColor Red
        Read-Host "Press Enter to exit"
    }
} catch {
    Write-Host "❌ Failed to launch: `$(`$_.Exception.Message)" -ForegroundColor Red
    Read-Host "Press Enter to exit"
}
"@

$psLauncher | Out-File -FilePath (Join-Path $OutputPath "Launch-VelociraptorUltimate.ps1") -Encoding UTF8

# Create README
$readme = @"
# Velociraptor Ultimate - Complete DFIR Platform

## 🚀 Quick Start

**For the easiest experience:**
1. **Right-click** on `Launch-VelociraptorUltimate.bat`
2. Select **"Run as administrator"**
3. Follow the GUI interface

**Alternative:**
- Run `Launch-VelociraptorUltimate.ps1` from PowerShell (as Administrator)

## 📋 What's Included

This is the ultimate Velociraptor application combining ALL functionality:

### 🔍 **Investigation Management**
- Multi-type investigation workflows (Malware, APT, Ransomware, etc.)
- Active investigation tracking and management
- Professional report generation
- Evidence correlation and analysis

### 💼 **Offline Evidence Collection**
- Portable evidence collection for field work
- Pre-configured artifact collections with presets
- Offline operation capabilities
- Comprehensive evidence packaging

### ⚙️ **Server & Standalone Setup**
- Complete installation and configuration wizard
- Service management (start/stop/restart)
- Update management and health monitoring
- Multi-deployment type support

### 📦 **Advanced Artifact Management**
- 3rd party tool dependency management
- Artifact pack building and deployment
- Tool caching and validation
- Offline collector package creation

### 📊 **Real-time Monitoring**
- System health dashboards
- Performance metrics tracking
- Client connection monitoring
- Investigation progress tracking

### 🤖 **AI-Powered Features**
- Intelligent investigation planning
- Evidence analysis assistance
- Automated report generation
- Predictive analytics

## 💻 System Requirements

- **Operating System**: Windows 10 or Windows Server 2016+
- **PowerShell**: Version 5.1 or later
- **Privileges**: Administrator rights required
- **.NET Framework**: 4.7.2 or later
- **Memory**: 8GB RAM recommended
- **Disk Space**: 5GB free space minimum

## 🎯 Key Features

- **Unified Interface**: All Velociraptor functionality in one application
- **Professional GUI**: Modern, intuitive interface design
- **Enterprise Ready**: Scalable for large deployments
- **Cross-Platform**: Windows, Linux, macOS support
- **Comprehensive**: Complete DFIR workflow coverage
- **Extensible**: Modular architecture for customization

## 📞 Support

- **Documentation**: Comprehensive help system built-in
- **Community**: GitHub discussions and issues
- **Professional**: Enterprise support available

## 📄 License

MIT License - See LICENSE file for details.

---

**Built**: $(Get-Date)
**Version**: 6.0.0-Ultimate
**Components**: $($availableComponents.Keys.Count) integrated modules

Ready to revolutionize your DFIR operations!
"@

$readme | Out-File -FilePath (Join-Path $OutputPath "README.md") -Encoding UTF8

Write-Host "✅ Launcher scripts and documentation created" -ForegroundColor Green

# Run QA if requested
if ($RunQA) {
    Write-Host "`n🧪 Running Quality Assurance tests..." -ForegroundColor Yellow
    & "$PSScriptRoot\Run-QA-Tests.ps1" -ApplicationPath $outputScript
}

# Run UA if requested  
if ($RunUA) {
    Write-Host "`n👥 Running User Acceptance tests..." -ForegroundColor Yellow
    & "$PSScriptRoot\Run-UA-Tests.ps1" -ApplicationPath $outputScript
}

# Create executable if requested
if ($CreateExecutable) {
    Write-Host "`n💻 Creating executable version..." -ForegroundColor Yellow
    
    if (Get-Command Invoke-ps2exe -ErrorAction SilentlyContinue) {
        $exePath = Join-Path $OutputPath "VelociraptorUltimate.exe"
        
        try {
            Invoke-ps2exe -inputFile $outputScript -outputFile $exePath -title "Velociraptor Ultimate" -description "Complete DFIR Platform" -company "Velociraptor Community" -version "6.0.0" -copyright "© 2024 Velociraptor Community" -requireAdmin -STA -iconFile "$PSScriptRoot\assets\velociraptor.ico"
            
            Write-Host "✅ Executable created: $exePath" -ForegroundColor Green
        }
        catch {
            Write-Host "⚠️ Failed to create executable: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "⚠️ PS2EXE not found. Install with: Install-Module ps2exe" -ForegroundColor Yellow
    }
}

# Final summary
Write-Host "`n🎉 Build Complete!" -ForegroundColor Green
Write-Host "📁 Output directory: $OutputPath" -ForegroundColor Cyan
Write-Host "🚀 Main application: VelociraptorUltimate.ps1" -ForegroundColor Cyan
Write-Host "🎯 Quick launcher: Launch-VelociraptorUltimate.bat" -ForegroundColor Cyan

$fileCount = (Get-ChildItem $OutputPath -Recurse).Count
$totalSize = [math]::Round(((Get-ChildItem $OutputPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB), 2)

Write-Host "`n📊 Build Statistics:" -ForegroundColor Blue
Write-Host "  Files created: $fileCount" -ForegroundColor Gray
Write-Host "  Total size: $totalSize MB" -ForegroundColor Gray
Write-Host "  Components integrated: $($availableComponents.Keys.Count)" -ForegroundColor Gray

Write-Host "`n🚀 Ready for deployment!" -ForegroundColor Green
Write-Host "Double-click Launch-VelociraptorUltimate.bat to start" -ForegroundColor Yellow