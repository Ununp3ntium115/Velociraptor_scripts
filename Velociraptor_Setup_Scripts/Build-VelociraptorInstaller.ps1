# Build Script for Velociraptor Professional Installer
# Combines all parts into a single executable installer

<#
.SYNOPSIS
    Builds the complete Velociraptor Professional Installer
    
.DESCRIPTION
    This script combines all installer components into a single PowerShell script
    and optionally creates an MSI package using WiX Toolset or PS2EXE
    
.PARAMETER OutputPath
    Path where the built installer will be saved
    
.PARAMETER CreateMSI
    Create an MSI package (requires WiX Toolset)
    
.PARAMETER CreateEXE
    Create an EXE package (requires PS2EXE)
    
.EXAMPLE
    .\Build-VelociraptorInstaller.ps1 -OutputPath ".\dist" -CreateEXE
#>

param(
    [string] $OutputPath = ".\dist",
    [switch] $CreateMSI,
    [switch] $CreateEXE,
    [switch] $IncludeModules
)

# Ensure output directory exists
if (-not (Test-Path $OutputPath)) {
    New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
}

Write-Host "🔨 Building Velociraptor Professional Installer..." -ForegroundColor Green

# Combine all installer parts
$installerParts = @(
    "VelociraptorInstaller.ps1",
    "VelociraptorInstaller-Part2.ps1", 
    "VelociraptorInstaller-Part3.ps1",
    "VelociraptorInstaller-Final.ps1"
)

$combinedScript = @()

# Add header
$combinedScript += @"
#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Velociraptor Professional Installer & Management Suite
    
.DESCRIPTION
    Complete GUI-based installer and management suite for Velociraptor DFIR platform.
    
    Features:
    • MSI-style installation wizard
    • Professional GUI interface
    • Service management
    • Configuration management
    • Real-time monitoring
    • Incident response tools
    • Automated updates
    
.PARAMETER Silent
    Run in silent installation mode
    
.PARAMETER Uninstall
    Uninstall Velociraptor
    
.PARAMETER ConfigFile
    Path to configuration file
    
.PARAMETER ServiceMode
    Run in service mode
    
.EXAMPLE
    .\VelociraptorInstaller.ps1
    Launch the GUI installer
    
.EXAMPLE
    .\VelociraptorInstaller.ps1 -Silent
    Perform silent installation
    
.EXAMPLE
    .\VelociraptorInstaller.ps1 -Uninstall
    Uninstall Velociraptor
    
.NOTES
    Version: 6.0.0
    Author: Velociraptor Setup Scripts Team
    Requires: PowerShell 5.1+, Windows 10/Server 2016+, Administrator privileges
#>

"@

# Read and combine all parts
foreach ($part in $installerParts) {
    if (Test-Path $part) {
        Write-Host "📄 Adding $part..."
        $content = Get-Content $part -Raw
        
        # Remove duplicate headers and param blocks (except first)
        if ($part -ne $installerParts[0]) {
            # Remove everything before the first class or function definition
            $content = $content -replace '(?s)^.*?(?=class|function|\[void\])', ''
        }
        
        $combinedScript += $content
    } else {
        Write-Warning "⚠️  Part file not found: $part"
    }
}

# Write combined script
$outputScript = Join-Path $OutputPath "VelociraptorInstaller.ps1"
$combinedScript -join "`n" | Out-File -FilePath $outputScript -Encoding UTF8

Write-Host "✅ Combined installer created: $outputScript" -ForegroundColor Green

# Include modules if requested
if ($IncludeModules) {
    Write-Host "📦 Including PowerShell modules..."
    $modulesPath = Join-Path $OutputPath "modules"
    if (Test-Path ".\modules") {
        Copy-Item ".\modules" -Destination $modulesPath -Recurse -Force
        Write-Host "✅ Modules copied to: $modulesPath" -ForegroundColor Green
    }
}

# Create EXE if requested
if ($CreateEXE) {
    Write-Host "🔧 Creating EXE package..."
    
    # Check if PS2EXE is available
    if (Get-Command Invoke-ps2exe -ErrorAction SilentlyContinue) {
        $exePath = Join-Path $OutputPath "VelociraptorInstaller.exe"
        
        try {
            Invoke-ps2exe -inputFile $outputScript -outputFile $exePath -iconFile ".\assets\velociraptor.ico" -title "Velociraptor Professional Installer" -description "Velociraptor DFIR Platform Installer" -company "Velociraptor Community" -version "6.0.0" -copyright "© 2024 Velociraptor Community" -requireAdmin -STA
            
            Write-Host "✅ EXE package created: $exePath" -ForegroundColor Green
        }
        catch {
            Write-Warning "⚠️  Failed to create EXE: $($_.Exception.Message)"
        }
    } else {
        Write-Warning "⚠️  PS2EXE not found. Install with: Install-Module ps2exe"
    }
}

# Create MSI if requested
if ($CreateMSI) {
    Write-Host "🔧 Creating MSI package..."
    
    # Check if WiX is available
    if (Test-Path "${env:ProgramFiles(x86)}\WiX Toolset v3.11\bin\candle.exe") {
        Write-Host "📝 Generating WiX source..."
        
        # Create WiX source file
        $wixSource = @"
<?xml version="1.0" encoding="UTF-8"?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">
  <Product Id="*" Name="Velociraptor Professional Suite" Language="1033" Version="6.0.0" 
           Manufacturer="Velociraptor Community" UpgradeCode="12345678-1234-1234-1234-123456789012">
    
    <Package InstallerVersion="200" Compressed="yes" InstallScope="perMachine" />
    
    <MajorUpgrade DowngradeErrorMessage="A newer version of [ProductName] is already installed." />
    <MediaTemplate EmbedCab="yes" />
    
    <Feature Id="ProductFeature" Title="Velociraptor Professional Suite" Level="1">
      <ComponentGroupRef Id="ProductComponents" />
    </Feature>
    
    <Directory Id="TARGETDIR" Name="SourceDir">
      <Directory Id="ProgramFilesFolder">
        <Directory Id="INSTALLFOLDER" Name="Velociraptor" />
      </Directory>
      <Directory Id="ProgramMenuFolder">
        <Directory Id="ApplicationProgramsFolder" Name="Velociraptor Professional Suite"/>
      </Directory>
    </Directory>
    
    <ComponentGroup Id="ProductComponents" Directory="INSTALLFOLDER">
      <Component Id="MainExecutable" Guid="*">
        <File Id="VelociraptorInstaller" Source="$outputScript" KeyPath="yes" />
      </Component>
    </ComponentGroup>
    
    <Icon Id="VelociraptorIcon" SourceFile=".\assets\velociraptor.ico" />
    <Property Id="ARPPRODUCTICON" Value="VelociraptorIcon" />
    
  </Product>
</Wix>
"@
        
        $wixFile = Join-Path $OutputPath "VelociraptorInstaller.wxs"
        $wixSource | Out-File -FilePath $wixFile -Encoding UTF8
        
        try {
            # Compile WiX
            $candlePath = "${env:ProgramFiles(x86)}\WiX Toolset v3.11\bin\candle.exe"
            $lightPath = "${env:ProgramFiles(x86)}\WiX Toolset v3.11\bin\light.exe"
            
            & $candlePath $wixFile -out "$OutputPath\VelociraptorInstaller.wixobj"
            & $lightPath "$OutputPath\VelociraptorInstaller.wixobj" -out "$OutputPath\VelociraptorInstaller.msi"
            
            Write-Host "✅ MSI package created: $OutputPath\VelociraptorInstaller.msi" -ForegroundColor Green
        }
        catch {
            Write-Warning "⚠️  Failed to create MSI: $($_.Exception.Message)"
        }
    } else {
        Write-Warning "⚠️  WiX Toolset not found. Download from: https://wixtoolset.org/"
    }
}

# Create installation package
Write-Host "📦 Creating installation package..."
$packagePath = Join-Path $OutputPath "VelociraptorProfessionalSuite-v6.0.0.zip"

$filesToPackage = @(
    $outputScript
)

if ($IncludeModules -and (Test-Path (Join-Path $OutputPath "modules"))) {
    $filesToPackage += Join-Path $OutputPath "modules"
}

# Add README
$readmeContent = @"
# Velociraptor Professional Suite v6.0.0

## Installation Instructions

1. Extract all files to a directory
2. Right-click on VelociraptorInstaller.ps1 and select "Run with PowerShell"
3. Or run from an elevated PowerShell prompt: .\VelociraptorInstaller.ps1

## System Requirements

- Windows 10 or Windows Server 2016 or later
- PowerShell 5.1 or later
- Administrator privileges
- .NET Framework 4.7.2 or later

## Features

- Professional MSI-style installation wizard
- Complete GUI management interface
- Service management and monitoring
- Configuration management
- Real-time system monitoring
- Incident response tools
- Automated updates
- Backup and restore functionality

## Support

For support and documentation, visit:
https://github.com/Ununp3ntium115/Velociraptor_Setup_Scripts

## License

MIT License - See LICENSE file for details
"@

$readmePath = Join-Path $OutputPath "README.txt"
$readmeContent | Out-File -FilePath $readmePath -Encoding UTF8

try {
    Compress-Archive -Path $filesToPackage, $readmePath -DestinationPath $packagePath -Force
    Write-Host "✅ Installation package created: $packagePath" -ForegroundColor Green
}
catch {
    Write-Warning "⚠️  Failed to create package: $($_.Exception.Message)"
}

# Summary
Write-Host "`n🎉 Build Complete!" -ForegroundColor Green
Write-Host "📁 Output directory: $OutputPath" -ForegroundColor Cyan
Write-Host "📄 Main installer: $(Split-Path $outputScript -Leaf)" -ForegroundColor Cyan

if ($CreateEXE -and (Test-Path (Join-Path $OutputPath "VelociraptorInstaller.exe"))) {
    Write-Host "💻 EXE installer: VelociraptorInstaller.exe" -ForegroundColor Cyan
}

if ($CreateMSI -and (Test-Path (Join-Path $OutputPath "VelociraptorInstaller.msi"))) {
    Write-Host "📦 MSI installer: VelociraptorInstaller.msi" -ForegroundColor Cyan
}

Write-Host "📦 Installation package: $(Split-Path $packagePath -Leaf)" -ForegroundColor Cyan

Write-Host "`n🚀 Ready for distribution!" -ForegroundColor Green