#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Universal service management for Velociraptor across all platforms.

.DESCRIPTION
    Provides unified service management capabilities for Velociraptor
    across Windows (Services), Linux (systemd), and macOS (launchd).
    Handles installation, configuration, start/stop, and monitoring.

.PARAMETER Action
    Service action: Install, Uninstall, Start, Stop, Restart, Status, Enable, Disable

.PARAMETER ServiceName
    Name of the service (platform-specific defaults apply)

.PARAMETER BinaryPath
    Path to the Velociraptor binary

.PARAMETER ConfigPath
    Path to the configuration file

.PARAMETER WorkingDirectory
    Working directory for the service

.PARAMETER RunAsUser
    User account to run the service as

.PARAMETER AutoStart
    Enable automatic startup

.EXAMPLE
    # Install and start service on any platform
    sudo pwsh ./Manage-VelociraptorService.ps1 -Action Install -BinaryPath "/usr/local/bin/velociraptor" -ConfigPath "/etc/velociraptor/server.yaml"

.EXAMPLE
    # Check service status
    ./Manage-VelociraptorService.ps1 -Action Status

.EXAMPLE
    # Restart service
    sudo pwsh ./Manage-VelociraptorService.ps1 -Action Restart

.NOTES
    Requires appropriate privileges (Administrator/sudo) for service operations
    Automatically detects platform and uses appropriate service manager
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Install', 'Uninstall', 'Start', 'Stop', 'Restart', 'Status', 'Enable', 'Disable', 'Logs')]
    [string]$Action,
    
    [string]$ServiceName = $null,
    [string]$BinaryPath = $null,
    [string]$ConfigPath = $null,
    [string]$WorkingDirectory = $null,
    [string]$RunAsUser = $null,
    [switch]$AutoStart
)

$ErrorActionPreference = 'Stop'

# Import cross-platform utilities
$UtilsPath = Join-Path $PSScriptRoot 'CrossPlatform-Utils.psm1'
if (Test-Path $UtilsPath) {
    Import-Module $UtilsPath -Force
}

#region Platform Detection and Configuration

function Get-ServiceConfiguration {
    <#
    .SYNOPSIS
        Get platform-specific service configuration.
    #>
    
    $platform = Get-PlatformInfo
    $paths = Get-PlatformPaths
    
    $config = @{
        Platform = $platform.OS
        ServiceManager = $platform.ServiceManager
        DefaultServiceName = switch ($platform.OS) {
            'Windows' { 'Velociraptor' }
            'Linux' { 'velociraptor' }
            'macOS' { 'com.velociraptor.server' }
        }
        DefaultBinaryPath = Join-Path $paths.InstallDir $paths.BinaryName
        DefaultConfigPath = switch ($platform.OS) {
            'Windows' { Join-Path $paths.ConfigDir 'server.config.yaml' }
            'Linux' { '/etc/velociraptor/server.config.yaml' }
            'macOS' { '/usr/local/etc/velociraptor/server.config.yaml' }
        }
        DefaultWorkingDir = $paths.DataDir
        DefaultUser = switch ($platform.OS) {
            'Windows' { 'LocalSystem' }
            'Linux' { 'root' }
            'macOS' { 'root' }
        }
        LogPath = switch ($platform.OS) {
            'Windows' { Join-Path $paths.LogDir 'velociraptor.log' }
            'Linux' { '/var/log/velociraptor/velociraptor.log' }
            'macOS' { '/usr/local/var/log/velociraptor.log' }
        }
    }
    
    return $config
}

function Write-ServiceLog {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        [ValidateSet('Info', 'Warning', 'Error', 'Success')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = "[$timestamp] [$Level] $Message"
    
    $color = switch ($Level) {
        'Success' { 'Green' }
        'Warning' { 'Yellow' }
        'Error' { 'Red' }
        default { 'White' }
    }
    
    Write-Host $logEntry -ForegroundColor $color
}

#endregion

#region Windows Service Management

function Install-WindowsService {
    param($Config, $ServiceConfig)
    
    Write-ServiceLog "Installing Windows service: $($ServiceConfig.ServiceName)" -Level Info
    
    try {
        # Check if service already exists
        $existingService = Get-Service -Name $ServiceConfig.ServiceName -ErrorAction SilentlyContinue
        if ($existingService) {
            Write-ServiceLog "Service already exists, removing first..." -Level Warning
            Uninstall-WindowsService -Config $Config -ServiceConfig $ServiceConfig
        }
        
        # Create service using sc.exe
        $scArgs = @(
            'create',
            $ServiceConfig.ServiceName,
            "binPath= `"$($ServiceConfig.BinaryPath)`" --config `"$($ServiceConfig.ConfigPath)`" frontend",
            "DisplayName= `"Velociraptor DFIR Platform`"",
            "start= auto"
        )
        
        $result = & sc.exe @scArgs
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to create service: $result"
        }
        
        # Set service description
        & sc.exe description $ServiceConfig.ServiceName "Velociraptor Digital Forensics and Incident Response Platform"
        
        # Configure service recovery
        & sc.exe failure $ServiceConfig.ServiceName reset= 86400 actions= restart/60000/restart/60000/restart/60000
        
        Write-ServiceLog "Windows service installed successfully" -Level Success
        
        if ($AutoStart) {
            Start-WindowsService -Config $Config -ServiceConfig $ServiceConfig
        }
        
        return $true
    }
    catch {
        Write-ServiceLog "Failed to install Windows service: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Uninstall-WindowsService {
    param($Config, $ServiceConfig)
    
    Write-ServiceLog "Uninstalling Windows service: $($ServiceConfig.ServiceName)" -Level Info
    
    try {
        # Stop service if running
        $service = Get-Service -Name $ServiceConfig.ServiceName -ErrorAction SilentlyContinue
        if ($service -and $service.Status -eq 'Running') {
            Stop-Service -Name $ServiceConfig.ServiceName -Force
            Start-Sleep -Seconds 3
        }
        
        # Delete service
        $result = & sc.exe delete $ServiceConfig.ServiceName
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to delete service: $result"
        }
        
        Write-ServiceLog "Windows service uninstalled successfully" -Level Success
        return $true
    }
    catch {
        Write-ServiceLog "Failed to uninstall Windows service: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Start-WindowsService {
    param($Config, $ServiceConfig)
    
    try {
        Start-Service -Name $ServiceConfig.ServiceName
        Write-ServiceLog "Windows service started successfully" -Level Success
        return $true
    }
    catch {
        Write-ServiceLog "Failed to start Windows service: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Stop-WindowsService {
    param($Config, $ServiceConfig)
    
    try {
        Stop-Service -Name $ServiceConfig.ServiceName -Force
        Write-ServiceLog "Windows service stopped successfully" -Level Success
        return $true
    }
    catch {
        Write-ServiceLog "Failed to stop Windows service: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Get-WindowsServiceStatus {
    param($Config, $ServiceConfig)
    
    try {
        $service = Get-Service -Name $ServiceConfig.ServiceName -ErrorAction SilentlyContinue
        if ($service) {
            return @{
                Name = $service.Name
                Status = $service.Status
                StartType = $service.StartType
                Running = $service.Status -eq 'Running'
                Exists = $true
            }
        } else {
            return @{
                Name = $ServiceConfig.ServiceName
                Status = 'Not Installed'
                StartType = 'Unknown'
                Running = $false
                Exists = $false
            }
        }
    }
    catch {
        Write-ServiceLog "Failed to get Windows service status: $($_.Exception.Message)" -Level Error
        return @{
            Name = $ServiceConfig.ServiceName
            Status = 'Error'
            StartType = 'Unknown'
            Running = $false
            Exists = $false
        }
    }
}

#endregion

#region Linux systemd Service Management

function Install-SystemdService {
    param($Config, $ServiceConfig)
    
    Write-ServiceLog "Installing systemd service: $($ServiceConfig.ServiceName)" -Level Info
    
    try {
        # Create systemd service file
        $serviceFile = "/etc/systemd/system/$($ServiceConfig.ServiceName).service"
        
        $serviceContent = @"
[Unit]
Description=Velociraptor DFIR Platform
After=network.target
Wants=network.target

[Service]
Type=simple
User=$($ServiceConfig.RunAsUser)
WorkingDirectory=$($ServiceConfig.WorkingDirectory)
ExecStart=$($ServiceConfig.BinaryPath) --config $($ServiceConfig.ConfigPath) frontend -v
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=velociraptor

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$($ServiceConfig.WorkingDirectory)

[Install]
WantedBy=multi-user.target
"@
        
        # Write service file
        $serviceContent | Out-File -FilePath $serviceFile -Encoding UTF8
        
        # Set permissions
        & chmod 644 $serviceFile
        
        # Reload systemd
        & systemctl daemon-reload
        
        Write-ServiceLog "systemd service installed successfully" -Level Success
        
        if ($AutoStart) {
            # Enable and start service
            & systemctl enable $ServiceConfig.ServiceName
            Start-SystemdService -Config $Config -ServiceConfig $ServiceConfig
        }
        
        return $true
    }
    catch {
        Write-ServiceLog "Failed to install systemd service: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Uninstall-SystemdService {
    param($Config, $ServiceConfig)
    
    Write-ServiceLog "Uninstalling systemd service: $($ServiceConfig.ServiceName)" -Level Info
    
    try {
        # Stop and disable service
        & systemctl stop $ServiceConfig.ServiceName 2>/dev/null
        & systemctl disable $ServiceConfig.ServiceName 2>/dev/null
        
        # Remove service file
        $serviceFile = "/etc/systemd/system/$($ServiceConfig.ServiceName).service"
        if (Test-Path $serviceFile) {
            Remove-Item $serviceFile -Force
        }
        
        # Reload systemd
        & systemctl daemon-reload
        & systemctl reset-failed 2>/dev/null
        
        Write-ServiceLog "systemd service uninstalled successfully" -Level Success
        return $true
    }
    catch {
        Write-ServiceLog "Failed to uninstall systemd service: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Start-SystemdService {
    param($Config, $ServiceConfig)
    
    try {
        & systemctl start $ServiceConfig.ServiceName
        if ($LASTEXITCODE -eq 0) {
            Write-ServiceLog "systemd service started successfully" -Level Success
            return $true
        } else {
            throw "systemctl start failed with exit code $LASTEXITCODE"
        }
    }
    catch {
        Write-ServiceLog "Failed to start systemd service: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Stop-SystemdService {
    param($Config, $ServiceConfig)
    
    try {
        & systemctl stop $ServiceConfig.ServiceName
        if ($LASTEXITCODE -eq 0) {
            Write-ServiceLog "systemd service stopped successfully" -Level Success
            return $true
        } else {
            throw "systemctl stop failed with exit code $LASTEXITCODE"
        }
    }
    catch {
        Write-ServiceLog "Failed to stop systemd service: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Get-SystemdServiceStatus {
    param($Config, $ServiceConfig)
    
    try {
        $status = & systemctl is-active $ServiceConfig.ServiceName 2>/dev/null
        $enabled = & systemctl is-enabled $ServiceConfig.ServiceName 2>/dev/null
        
        return @{
            Name = $ServiceConfig.ServiceName
            Status = $status
            StartType = $enabled
            Running = $status -eq 'active'
            Exists = $true
        }
    }
    catch {
        return @{
            Name = $ServiceConfig.ServiceName
            Status = 'inactive'
            StartType = 'disabled'
            Running = $false
            Exists = $false
        }
    }
}

#endregion

#region macOS launchd Service Management

function Install-LaunchdService {
    param($Config, $ServiceConfig)
    
    Write-ServiceLog "Installing launchd service: $($ServiceConfig.ServiceName)" -Level Info
    
    try {
        # Create launchd plist file
        $plistPath = "/Library/LaunchDaemons/$($ServiceConfig.ServiceName).plist"
        
        $plistContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$($ServiceConfig.ServiceName)</string>
    <key>ProgramArguments</key>
    <array>
        <string>$($ServiceConfig.BinaryPath)</string>
        <string>--config</string>
        <string>$($ServiceConfig.ConfigPath)</string>
        <string>frontend</string>
        <string>-v</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$($Config.LogPath)</string>
    <key>StandardErrorPath</key>
    <string>$($Config.LogPath).error</string>
    <key>WorkingDirectory</key>
    <string>$($ServiceConfig.WorkingDirectory)</string>
    <key>UserName</key>
    <string>$($ServiceConfig.RunAsUser)</string>
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
        
        Write-ServiceLog "launchd service installed successfully" -Level Success
        
        if ($AutoStart) {
            Start-LaunchdService -Config $Config -ServiceConfig $ServiceConfig
        }
        
        return $true
    }
    catch {
        Write-ServiceLog "Failed to install launchd service: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Uninstall-LaunchdService {
    param($Config, $ServiceConfig)
    
    Write-ServiceLog "Uninstalling launchd service: $($ServiceConfig.ServiceName)" -Level Info
    
    try {
        $plistPath = "/Library/LaunchDaemons/$($ServiceConfig.ServiceName).plist"
        
        # Stop and unload service
        & launchctl stop $ServiceConfig.ServiceName 2>/dev/null
        & launchctl unload $plistPath 2>/dev/null
        
        # Remove plist file
        if (Test-Path $plistPath) {
            Remove-Item $plistPath -Force
        }
        
        Write-ServiceLog "launchd service uninstalled successfully" -Level Success
        return $true
    }
    catch {
        Write-ServiceLog "Failed to uninstall launchd service: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Start-LaunchdService {
    param($Config, $ServiceConfig)
    
    try {
        & launchctl start $ServiceConfig.ServiceName
        if ($LASTEXITCODE -eq 0) {
            Write-ServiceLog "launchd service started successfully" -Level Success
            return $true
        } else {
            throw "launchctl start failed with exit code $LASTEXITCODE"
        }
    }
    catch {
        Write-ServiceLog "Failed to start launchd service: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Stop-LaunchdService {
    param($Config, $ServiceConfig)
    
    try {
        & launchctl stop $ServiceConfig.ServiceName
        if ($LASTEXITCODE -eq 0) {
            Write-ServiceLog "launchd service stopped successfully" -Level Success
            return $true
        } else {
            throw "launchctl stop failed with exit code $LASTEXITCODE"
        }
    }
    catch {
        Write-ServiceLog "Failed to stop launchd service: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Get-LaunchdServiceStatus {
    param($Config, $ServiceConfig)
    
    try {
        $status = & launchctl list | Select-String $ServiceConfig.ServiceName
        
        return @{
            Name = $ServiceConfig.ServiceName
            Status = if ($status) { 'loaded' } else { 'unloaded' }
            StartType = if ($status) { 'enabled' } else { 'disabled' }
            Running = [bool]$status
            Exists = [bool]$status
        }
    }
    catch {
        return @{
            Name = $ServiceConfig.ServiceName
            Status = 'unloaded'
            StartType = 'disabled'
            Running = $false
            Exists = $false
        }
    }
}

#endregion

#region Main Service Management Logic

function Invoke-ServiceAction {
    param($Action, $Config, $ServiceConfig)
    
    $platform = $Config.Platform
    $result = $false
    
    switch ($Action) {
        'Install' {
            $result = switch ($platform) {
                'Windows' { Install-WindowsService -Config $Config -ServiceConfig $ServiceConfig }
                'Linux' { Install-SystemdService -Config $Config -ServiceConfig $ServiceConfig }
                'macOS' { Install-LaunchdService -Config $Config -ServiceConfig $ServiceConfig }
                default { Write-ServiceLog "Unsupported platform: $platform" -Level Error; $false }
            }
        }
        
        'Uninstall' {
            $result = switch ($platform) {
                'Windows' { Uninstall-WindowsService -Config $Config -ServiceConfig $ServiceConfig }
                'Linux' { Uninstall-SystemdService -Config $Config -ServiceConfig $ServiceConfig }
                'macOS' { Uninstall-LaunchdService -Config $Config -ServiceConfig $ServiceConfig }
                default { Write-ServiceLog "Unsupported platform: $platform" -Level Error; $false }
            }
        }
        
        'Start' {
            $result = switch ($platform) {
                'Windows' { Start-WindowsService -Config $Config -ServiceConfig $ServiceConfig }
                'Linux' { Start-SystemdService -Config $Config -ServiceConfig $ServiceConfig }
                'macOS' { Start-LaunchdService -Config $Config -ServiceConfig $ServiceConfig }
                default { Write-ServiceLog "Unsupported platform: $platform" -Level Error; $false }
            }
        }
        
        'Stop' {
            $result = switch ($platform) {
                'Windows' { Stop-WindowsService -Config $Config -ServiceConfig $ServiceConfig }
                'Linux' { Stop-SystemdService -Config $Config -ServiceConfig $ServiceConfig }
                'macOS' { Stop-LaunchdService -Config $Config -ServiceConfig $ServiceConfig }
                default { Write-ServiceLog "Unsupported platform: $platform" -Level Error; $false }
            }
        }
        
        'Restart' {
            Write-ServiceLog "Restarting service..." -Level Info
            $stopResult = Invoke-ServiceAction -Action 'Stop' -Config $Config -ServiceConfig $ServiceConfig
            Start-Sleep -Seconds 3
            $startResult = Invoke-ServiceAction -Action 'Start' -Config $Config -ServiceConfig $ServiceConfig
            $result = $stopResult -and $startResult
        }
        
        'Status' {
            $status = switch ($platform) {
                'Windows' { Get-WindowsServiceStatus -Config $Config -ServiceConfig $ServiceConfig }
                'Linux' { Get-SystemdServiceStatus -Config $Config -ServiceConfig $ServiceConfig }
                'macOS' { Get-LaunchdServiceStatus -Config $Config -ServiceConfig $ServiceConfig }
                default { @{ Name = 'Unknown'; Status = 'Unsupported'; Running = $false; Exists = $false } }
            }
            
            Write-ServiceLog "Service Status Report:" -Level Info
            Write-ServiceLog "  Name: $($status.Name)" -Level Info
            Write-ServiceLog "  Status: $($status.Status)" -Level Info
            Write-ServiceLog "  Start Type: $($status.StartType)" -Level Info
            Write-ServiceLog "  Running: $($status.Running)" -Level Info
            Write-ServiceLog "  Exists: $($status.Exists)" -Level Info
            
            return $status
        }
        
        'Logs' {
            Write-ServiceLog "Displaying service logs..." -Level Info
            Show-ServiceLogs -Config $Config -ServiceConfig $ServiceConfig
            $result = $true
        }
        
        default {
            Write-ServiceLog "Unknown action: $Action" -Level Error
            $result = $false
        }
    }
    
    return $result
}

function Show-ServiceLogs {
    param($Config, $ServiceConfig)
    
    $platform = $Config.Platform
    
    try {
        switch ($platform) {
            'Windows' {
                # Show Windows Event Log entries
                Get-EventLog -LogName Application -Source "Velociraptor*" -Newest 20 -ErrorAction SilentlyContinue |
                    Format-Table TimeGenerated, EntryType, Message -AutoSize
            }
            'Linux' {
                # Show systemd journal entries
                & journalctl -u $ServiceConfig.ServiceName -n 20 --no-pager
            }
            'macOS' {
                # Show log file contents
                if (Test-Path $Config.LogPath) {
                    Get-Content $Config.LogPath -Tail 20
                } else {
                    Write-ServiceLog "Log file not found: $($Config.LogPath)" -Level Warning
                }
            }
        }
    }
    catch {
        Write-ServiceLog "Failed to retrieve logs: $($_.Exception.Message)" -Level Error
    }
}

#endregion

#region Main Execution

Write-ServiceLog "Velociraptor Service Manager - $Action" -Level Info

# Get platform configuration
$config = Get-ServiceConfiguration

# Build service configuration
$serviceConfig = @{
    ServiceName = if ($ServiceName) { $ServiceName } else { $config.DefaultServiceName }
    BinaryPath = if ($BinaryPath) { $BinaryPath } else { $config.DefaultBinaryPath }
    ConfigPath = if ($ConfigPath) { $ConfigPath } else { $config.DefaultConfigPath }
    WorkingDirectory = if ($WorkingDirectory) { $WorkingDirectory } else { $config.DefaultWorkingDir }
    RunAsUser = if ($RunAsUser) { $RunAsUser } else { $config.DefaultUser }
}

Write-ServiceLog "Platform: $($config.Platform) ($($config.ServiceManager))" -Level Info
Write-ServiceLog "Service: $($serviceConfig.ServiceName)" -Level Info

# Validate required parameters for install action
if ($Action -eq 'Install') {
    if (-not (Test-Path $serviceConfig.BinaryPath)) {
        Write-ServiceLog "Binary not found: $($serviceConfig.BinaryPath)" -Level Error
        exit 1
    }
    
    if (-not (Test-Path $serviceConfig.ConfigPath)) {
        Write-ServiceLog "Configuration not found: $($serviceConfig.ConfigPath)" -Level Error
        exit 1
    }
}

# Execute the requested action
try {
    $result = Invoke-ServiceAction -Action $Action -Config $config -ServiceConfig $serviceConfig
    
    if ($result) {
        Write-ServiceLog "Action '$Action' completed successfully" -Level Success
        exit 0
    } else {
        Write-ServiceLog "Action '$Action' failed" -Level Error
        exit 1
    }
}
catch {
    Write-ServiceLog "Action '$Action' failed with error: $($_.Exception.Message)" -Level Error
    exit 1
}

#endregion