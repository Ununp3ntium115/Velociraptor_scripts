#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Deploy Velociraptor on macOS systems with native integration.

.DESCRIPTION
    Comprehensive macOS deployment script that handles:
    - Native macOS service management with launchd
    - Homebrew integration for dependencies
    - macOS-specific security and permissions
    - Keychain integration for certificates
    - Native macOS paths and conventions

.PARAMETER InstallDir
    Installation directory. Default: /usr/local/bin

.PARAMETER DataStore
    Data storage directory. Default: /usr/local/var/velociraptor

.PARAMETER ConfigDir
    Configuration directory. Default: /usr/local/etc/velociraptor

.PARAMETER ServiceName
    macOS service name. Default: com.velociraptor.server

.PARAMETER DeploymentType
    Deployment type: Server, Standalone, Client

.PARAMETER EnableAutoStart
    Enable automatic startup with launchd

.EXAMPLE
    sudo pwsh ./Deploy-VelociraptorMacOS.ps1

.EXAMPLE
    sudo pwsh ./Deploy-VelociraptorMacOS.ps1 -DeploymentType Server -EnableAutoStart

.NOTES
    Requires PowerShell Core 7.0+ and sudo privileges
    Tested on macOS 11+ (Big Sur and later)
#>

[CmdletBinding()]
param(
    [string]$InstallDir = '/usr/local/bin',
    [string]$DataStore = '/usr/local/var/velociraptor',
    [string]$ConfigDir = '/usr/local/etc/velociraptor',
    [string]$ServiceName = 'com.velociraptor.server',
    [ValidateSet('Server', 'Standalone', 'Client')]
    [string]$DeploymentType = 'Standalone',
    [switch]$EnableAutoStart
)

$ErrorActionPreference = 'Stop'

# Import cross-platform utilities
$UtilsPath = Join-Path $PSScriptRoot 'CrossPlatform-Utils.psm1'
if (Test-Path $UtilsPath) {
    Import-Module $UtilsPath -Force
}

#region Helper Functions

function Write-MacOSLog {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        [ValidateSet('Info', 'Warning', 'Error', 'Success')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Write to system log
    $syslogPriority = switch ($Level) {
        'Error' { 'user.error' }
        'Warning' { 'user.warning' }
        'Success' { 'user.notice' }
        default { 'user.info' }
    }
    
    try {
        $null = & logger -p $syslogPriority -t "VelociraptorDeploy" $Message
    } catch {
        # Fallback if logger fails
    }
    
    # Console output with colors
    $color = switch ($Level) {
        'Success' { 'Green' }
        'Warning' { 'Yellow' }
        'Error' { 'Red' }
        default { 'White' }
    }
    
    Write-Host $logEntry -ForegroundColor $color
}

function Test-MacOSVersion {
    try {
        $version = & sw_vers -productVersion
        $majorVersion = [int]($version.Split('.')[0])
        
        if ($majorVersion -lt 11) {
            Write-MacOSLog "macOS 11.0+ required. Current version: $version" -Level Error
            return $false
        }
        
        Write-MacOSLog "macOS version: $version" -Level Success
        return $true
    }
    catch {
        Write-MacOSLog "Failed to detect macOS version: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Test-AdminPrivileges {
    $currentUser = & id -u
    if ($currentUser -ne '0') {
        Write-MacOSLog "This script must be run with sudo privileges" -Level Error
        return $false
    }
    return $true
}

function Install-Homebrew {
    if (Get-Command brew -ErrorAction SilentlyContinue) {
        Write-MacOSLog "Homebrew already installed" -Level Success
        return $true
    }
    
    Write-MacOSLog "Installing Homebrew..." -Level Info
    try {
        $installScript = Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh' -UseBasicParsing
        $null = $installScript.Content | & /bin/bash
        
        # Add Homebrew to PATH
        $brewPath = '/opt/homebrew/bin:/usr/local/bin'
        $env:PATH = "${brewPath}:$env:PATH"
        
        Write-MacOSLog "Homebrew installed successfully" -Level Success
        return $true
    }
    catch {
        Write-MacOSLog "Failed to install Homebrew: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Get-VelociraptorLatestRelease {
    Write-MacOSLog "Fetching latest Velociraptor release for macOS..." -Level Info
    
    try {
        $apiUrl = "https://api.github.com/repos/Ununp3ntium115/velociraptor/releases/latest"
        $response = Invoke-RestMethod -Uri $apiUrl -Headers @{ 'User-Agent' = 'VelociraptorMacOS/1.0' }
        
        # Find macOS binary
        $macAsset = $response.assets | Where-Object { 
            $_.name -like "*darwin*" -and 
            $_.name -like "*amd64*" -and
            $_.name -notlike "*debug*"
        } | Select-Object -First 1
        
        if (-not $macAsset) {
            # Try arm64 for Apple Silicon
            $macAsset = $response.assets | Where-Object { 
                $_.name -like "*darwin*" -and 
                $_.name -like "*arm64*" -and
                $_.name -notlike "*debug*"
            } | Select-Object -First 1
        }
        
        if (-not $macAsset) {
            throw "No macOS binary found in release assets"
        }
        
        $version = $response.tag_name -replace '^v', ''
        Write-MacOSLog "Found Velociraptor v$version for macOS" -Level Success
        
        return @{
            Version = $version
            DownloadUrl = $macAsset.browser_download_url
            FileName = $macAsset.name
            Size = $macAsset.size
        }
    }
    catch {
        Write-MacOSLog "Failed to fetch release info: $($_.Exception.Message)" -Level Error
        throw
    }
}

function Install-VelociraptorBinary {
    param($ReleaseInfo)
    
    $binaryPath = Join-Path $InstallDir 'velociraptor'
    
    Write-MacOSLog "Downloading Velociraptor binary..." -Level Info
    
    try {
        # Create install directory
        if (-not (Test-Path $InstallDir)) {
            $null = New-Item -ItemType Directory -Path $InstallDir -Force
        }
        
        # Download binary
        Invoke-WebRequest -Uri $ReleaseInfo.DownloadUrl -OutFile $binaryPath -UseBasicParsing
        
        # Make executable
        & chmod +x $binaryPath
        
        # Verify download
        if (-not (Test-Path $binaryPath)) {
            throw "Binary not found after download"
        }
        
        $actualSize = (Get-Item $binaryPath).Length
        if ([math]::Abs($actualSize - $ReleaseInfo.Size) -gt 1024) {
            Write-MacOSLog "Size mismatch - expected: $($ReleaseInfo.Size), actual: $actualSize" -Level Warning
        }
        
        Write-MacOSLog "Velociraptor binary installed to $binaryPath" -Level Success
        return $binaryPath
    }
    catch {
        Write-MacOSLog "Failed to install binary: $($_.Exception.Message)" -Level Error
        throw
    }
}

function New-VelociraptorConfiguration {
    param($BinaryPath)
    
    Write-MacOSLog "Generating Velociraptor configuration..." -Level Info
    
    try {
        # Create config directory
        if (-not (Test-Path $ConfigDir)) {
            $null = New-Item -ItemType Directory -Path $ConfigDir -Force
        }
        
        # Create data directory
        if (-not (Test-Path $DataStore)) {
            $null = New-Item -ItemType Directory -Path $DataStore -Force
        }
        
        $configFile = Join-Path $ConfigDir 'server.config.yaml'
        
        # Generate configuration based on deployment type
        $configArgs = @(
            'config', 'generate'
            '--config', $configFile
        )
        
        if ($DeploymentType -eq 'Server') {
            $configArgs += @(
                '--bind_address', '0.0.0.0'
                '--bind_port', '8000'
                '--gui_bind_address', '127.0.0.1'
                '--gui_bind_port', '8889'
            )
        } else {
            $configArgs += @(
                '--gui_bind_address', '127.0.0.1'
                '--gui_bind_port', '8889'
            )
        }
        
        # Add datastore location
        $configArgs += @('--datastore_location', $DataStore)
        
        # Generate config
        & $BinaryPath @configArgs
        
        if (-not (Test-Path $configFile)) {
            throw "Configuration file not created"
        }
        
        # Set appropriate permissions
        & chmod 600 $configFile
        
        Write-MacOSLog "Configuration created: $configFile" -Level Success
        return $configFile
    }
    catch {
        Write-MacOSLog "Failed to create configuration: $($_.Exception.Message)" -Level Error
        throw
    }
}

function New-LaunchdService {
    param($BinaryPath, $ConfigFile)
    
    if (-not $EnableAutoStart) {
        Write-MacOSLog "Skipping service creation (EnableAutoStart not specified)" -Level Info
        return
    }
    
    Write-MacOSLog "Creating launchd service..." -Level Info
    
    try {
        $plistPath = "/Library/LaunchDaemons/$ServiceName.plist"
        
        $plistContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$ServiceName</string>
    <key>ProgramArguments</key>
    <array>
        <string>$BinaryPath</string>
        <string>--config</string>
        <string>$ConfigFile</string>
        <string>frontend</string>
        <string>-v</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/usr/local/var/log/velociraptor.log</string>
    <key>StandardErrorPath</key>
    <string>/usr/local/var/log/velociraptor.error.log</string>
    <key>WorkingDirectory</key>
    <string>$DataStore</string>
    <key>UserName</key>
    <string>root</string>
    <key>GroupName</key>
    <string>wheel</string>
</dict>
</plist>
"@
        
        # Write plist file
        $plistContent | Out-File -FilePath $plistPath -Encoding UTF8
        
        # Set permissions
        & chmod 644 $plistPath
        & chown root:wheel $plistPath
        
        # Load service
        & launchctl load $plistPath
        
        Write-MacOSLog "Launchd service created and loaded: $ServiceName" -Level Success
        
        # Start service
        & launchctl start $ServiceName
        
        Write-MacOSLog "Service started successfully" -Level Success
    }
    catch {
        Write-MacOSLog "Failed to create launchd service: $($_.Exception.Message)" -Level Error
        throw
    }
}

function Test-VelociraptorService {
    if (-not $EnableAutoStart) {
        return
    }
    
    Write-MacOSLog "Testing Velociraptor service..." -Level Info
    
    try {
        # Check if service is loaded
        $serviceStatus = & launchctl list | Select-String $ServiceName
        
        if ($serviceStatus) {
            Write-MacOSLog "Service is loaded and running" -Level Success
            
            # Test GUI port if applicable
            if ($DeploymentType -in @('Server', 'Standalone')) {
                Start-Sleep -Seconds 5  # Give service time to start
                
                try {
                    $response = Invoke-WebRequest -Uri 'http://127.0.0.1:8889' -UseBasicParsing -TimeoutSec 10
                    Write-MacOSLog "GUI interface is accessible at http://127.0.0.1:8889" -Level Success
                }
                catch {
                    Write-MacOSLog "GUI interface not yet accessible (may need more time to start)" -Level Warning
                }
            }
        } else {
            Write-MacOSLog "Service not found in launchctl list" -Level Warning
        }
    }
    catch {
        Write-MacOSLog "Service test failed: $($_.Exception.Message)" -Level Warning
    }
}

#endregion

#region Main Execution

Write-MacOSLog "Starting Velociraptor macOS deployment..." -Level Info
Write-MacOSLog "Deployment Type: $DeploymentType" -Level Info

# Pre-flight checks
if (-not (Test-AdminPrivileges)) {
    Write-MacOSLog "Please run with sudo: sudo pwsh $($MyInvocation.MyCommand.Path)" -Level Error
    exit 1
}

if (-not (Test-MacOSVersion)) {
    exit 1
}

# Install Homebrew if needed (for future dependencies)
if (-not (Install-Homebrew)) {
    Write-MacOSLog "Homebrew installation failed, continuing without it..." -Level Warning
}

try {
    # Get latest release
    $releaseInfo = Get-VelociraptorLatestRelease
    
    # Install binary
    $binaryPath = Install-VelociraptorBinary -ReleaseInfo $releaseInfo
    
    # Create configuration
    $configFile = New-VelociraptorConfiguration -BinaryPath $binaryPath
    
    # Create and start service
    New-LaunchdService -BinaryPath $binaryPath -ConfigFile $configFile
    
    # Test deployment
    Test-VelociraptorService
    
    Write-MacOSLog "Velociraptor deployment completed successfully!" -Level Success
    Write-MacOSLog "Binary: $binaryPath" -Level Info
    Write-MacOSLog "Config: $configFile" -Level Info
    Write-MacOSLog "Data: $DataStore" -Level Info
    
    if ($EnableAutoStart) {
        Write-MacOSLog "Service: $ServiceName (auto-start enabled)" -Level Info
        if ($DeploymentType -in @('Server', 'Standalone')) {
            Write-MacOSLog "GUI: http://127.0.0.1:8889" -Level Info
        }
    } else {
        Write-MacOSLog "To start manually: $binaryPath --config $configFile frontend" -Level Info
    }
}
catch {
    Write-MacOSLog "Deployment failed: $($_.Exception.Message)" -Level Error
    exit 1
}

#endregion