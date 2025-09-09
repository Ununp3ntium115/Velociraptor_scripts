<#
.SYNOPSIS
    Cross-platform utilities for Velociraptor deployment.

.DESCRIPTION
    Shared utilities that work across Windows, Linux, and macOS
    for consistent deployment behavior and platform abstraction.
#>

#region Platform Detection

function Get-PlatformInfo {
    <#
    .SYNOPSIS
        Get detailed platform information.
    #>
    
    $platform = @{
        OS = 'Unknown'
        Architecture = 'Unknown'
        Version = 'Unknown'
        Distribution = 'Unknown'
        PackageManager = 'Unknown'
        ServiceManager = 'Unknown'
        Shell = 'Unknown'
    }
    
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        # PowerShell Core - use built-in variables
        if ($IsWindows) {
            $platform.OS = 'Windows'
            $platform.ServiceManager = 'Services'
            $platform.PackageManager = 'Chocolatey'
            $platform.Shell = 'PowerShell'
            $platform.Version = (Get-WmiObject -Class Win32_OperatingSystem).Version
        }
        elseif ($IsLinux) {
            $platform.OS = 'Linux'
            $platform.ServiceManager = 'systemd'
            $platform.Shell = 'bash'
            
            # Detect Linux distribution
            if (Test-Path '/etc/os-release') {
                $osRelease = Get-Content '/etc/os-release' | ConvertFrom-StringData
                $platform.Distribution = $osRelease.ID
                $platform.Version = $osRelease.VERSION_ID
                
                # Set package manager based on distribution
                $platform.PackageManager = switch ($platform.Distribution) {
                    { $_ -in @('ubuntu', 'debian') } { 'apt' }
                    { $_ -in @('rhel', 'centos', 'fedora') } { 'yum' }
                    { $_ -in @('opensuse', 'sles') } { 'zypper' }
                    default { 'unknown' }
                }
            }
        }
        elseif ($IsMacOS) {
            $platform.OS = 'macOS'
            $platform.ServiceManager = 'launchd'
            $platform.PackageManager = 'brew'
            $platform.Shell = 'zsh'
            
            try {
                $platform.Version = & sw_vers -productVersion
            } catch {
                $platform.Version = 'Unknown'
            }
        }
        
        # Get architecture
        $platform.Architecture = [System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture
    }
    else {
        # PowerShell 5.1 - Windows only
        $platform.OS = 'Windows'
        $platform.ServiceManager = 'Services'
        $platform.PackageManager = 'Chocolatey'
        $platform.Shell = 'PowerShell'
        $platform.Architecture = $env:PROCESSOR_ARCHITECTURE
        $platform.Version = (Get-WmiObject -Class Win32_OperatingSystem).Version
    }
    
    return $platform
}

function Test-PlatformCompatibility {
    <#
    .SYNOPSIS
        Test if current platform is supported.
    #>
    param(
        [string[]]$SupportedPlatforms = @('Windows', 'Linux', 'macOS')
    )
    
    $platform = Get-PlatformInfo
    return $platform.OS -in $SupportedPlatforms
}

#endregion

#region Path Management

function Get-PlatformPaths {
    <#
    .SYNOPSIS
        Get platform-specific standard paths.
    #>
    
    $platform = Get-PlatformInfo
    $paths = @{}
    
    switch ($platform.OS) {
        'Windows' {
            $paths.InstallDir = 'C:\tools'
            $paths.ConfigDir = Join-Path $env:ProgramData 'Velociraptor'
            $paths.DataDir = Join-Path $env:ProgramData 'Velociraptor\Data'
            $paths.LogDir = Join-Path $env:ProgramData 'Velociraptor\Logs'
            $paths.TempDir = $env:TEMP
            $paths.BinaryName = 'velociraptor.exe'
        }
        'Linux' {
            $paths.InstallDir = '/usr/local/bin'
            $paths.ConfigDir = '/etc/velociraptor'
            $paths.DataDir = '/var/lib/velociraptor'
            $paths.LogDir = '/var/log/velociraptor'
            $paths.TempDir = '/tmp'
            $paths.BinaryName = 'velociraptor'
        }
        'macOS' {
            $paths.InstallDir = '/usr/local/bin'
            $paths.ConfigDir = '/usr/local/etc/velociraptor'
            $paths.DataDir = '/usr/local/var/velociraptor'
            $paths.LogDir = '/usr/local/var/log'
            $paths.TempDir = '/tmp'
            $paths.BinaryName = 'velociraptor'
        }
    }
    
    return $paths
}

function New-PlatformDirectory {
    <#
    .SYNOPSIS
        Create directory with platform-appropriate permissions.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [string]$Owner = $null,
        [string]$Permissions = $null
    )
    
    $platform = Get-PlatformInfo
    
    if (-not (Test-Path $Path)) {
        $null = New-Item -ItemType Directory -Path $Path -Force
    }
    
    if ($platform.OS -in @('Linux', 'macOS')) {
        if ($Permissions) {
            & chmod $Permissions $Path
        }
        if ($Owner) {
            & chown $Owner $Path
        }
    }
    elseif ($platform.OS -eq 'Windows') {
        # Set Windows ACL if needed
        if ($Owner -or $Permissions) {
            try {
                $acl = Get-Acl $Path
                # Could add specific ACL modifications here
                Set-Acl -Path $Path -AclObject $acl
            }
            catch {
                Write-Warning "Failed to set Windows permissions on $Path"
            }
        }
    }
}

#endregion

#region Service Management

function Start-PlatformService {
    <#
    .SYNOPSIS
        Start service using platform-appropriate method.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$ServiceName,
        [string]$BinaryPath = $null,
        [string]$ConfigPath = $null
    )
    
    $platform = Get-PlatformInfo
    
    switch ($platform.ServiceManager) {
        'Services' {
            # Windows Services
            try {
                Start-Service -Name $ServiceName
                return $true
            }
            catch {
                Write-Error "Failed to start Windows service: $($_.Exception.Message)"
                return $false
            }
        }
        'systemd' {
            # Linux systemd
            try {
                & systemctl start $ServiceName
                return $?
            }
            catch {
                Write-Error "Failed to start systemd service: $($_.Exception.Message)"
                return $false
            }
        }
        'launchd' {
            # macOS launchd
            try {
                & launchctl start $ServiceName
                return $?
            }
            catch {
                Write-Error "Failed to start launchd service: $($_.Exception.Message)"
                return $false
            }
        }
        default {
            Write-Error "Unsupported service manager: $($platform.ServiceManager)"
            return $false
        }
    }
}

function Stop-PlatformService {
    <#
    .SYNOPSIS
        Stop service using platform-appropriate method.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$ServiceName
    )
    
    $platform = Get-PlatformInfo
    
    switch ($platform.ServiceManager) {
        'Services' {
            try {
                Stop-Service -Name $ServiceName -Force
                return $true
            }
            catch {
                Write-Error "Failed to stop Windows service: $($_.Exception.Message)"
                return $false
            }
        }
        'systemd' {
            try {
                & systemctl stop $ServiceName
                return $?
            }
            catch {
                Write-Error "Failed to stop systemd service: $($_.Exception.Message)"
                return $false
            }
        }
        'launchd' {
            try {
                & launchctl stop $ServiceName
                return $?
            }
            catch {
                Write-Error "Failed to stop launchd service: $($_.Exception.Message)"
                return $false
            }
        }
        default {
            Write-Error "Unsupported service manager: $($platform.ServiceManager)"
            return $false
        }
    }
}

function Get-PlatformServiceStatus {
    <#
    .SYNOPSIS
        Get service status using platform-appropriate method.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$ServiceName
    )
    
    $platform = Get-PlatformInfo
    
    switch ($platform.ServiceManager) {
        'Services' {
            try {
                $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
                return @{
                    Name = $ServiceName
                    Status = $service.Status
                    Running = $service.Status -eq 'Running'
                }
            }
            catch {
                return @{
                    Name = $ServiceName
                    Status = 'Unknown'
                    Running = $false
                }
            }
        }
        'systemd' {
            try {
                $status = & systemctl is-active $ServiceName 2>/dev/null
                return @{
                    Name = $ServiceName
                    Status = $status
                    Running = $status -eq 'active'
                }
            }
            catch {
                return @{
                    Name = $ServiceName
                    Status = 'Unknown'
                    Running = $false
                }
            }
        }
        'launchd' {
            try {
                $status = & launchctl list | Select-String $ServiceName
                return @{
                    Name = $ServiceName
                    Status = if ($status) { 'loaded' } else { 'unloaded' }
                    Running = [bool]$status
                }
            }
            catch {
                return @{
                    Name = $ServiceName
                    Status = 'Unknown'
                    Running = $false
                }
            }
        }
        default {
            return @{
                Name = $ServiceName
                Status = 'Unsupported'
                Running = $false
            }
        }
    }
}

#endregion

#region Network Utilities

function Test-PlatformConnectivity {
    <#
    .SYNOPSIS
        Test network connectivity using platform-appropriate method.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$HostName,
        [int]$Port = 443,
        [int]$TimeoutSeconds = 10
    )
    
    $platform = Get-PlatformInfo
    
    if ($platform.OS -eq 'Windows' -and $PSVersionTable.PSVersion.Major -ge 4) {
        # Use Test-NetConnection on Windows PowerShell 4+
        try {
            $result = Test-NetConnection -ComputerName $HostName -Port $Port -InformationLevel Quiet -WarningAction SilentlyContinue
            return $result
        }
        catch {
            # Fallback method
        }
    }
    
    # Cross-platform fallback using System.Net.Sockets
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $asyncResult = $tcpClient.BeginConnect($HostName, $Port, $null, $null)
        $wait = $asyncResult.AsyncWaitHandle.WaitOne($TimeoutSeconds * 1000, $false)
        
        if ($wait) {
            try {
                $tcpClient.EndConnect($asyncResult)
                $connected = $tcpClient.Connected
            }
            catch {
                $connected = $false
            }
        }
        else {
            $connected = $false
        }
        
        $tcpClient.Close()
        return $connected
    }
    catch {
        return $false
    }
}

#endregion

#region Package Management

function Install-PlatformPackage {
    <#
    .SYNOPSIS
        Install package using platform-appropriate package manager.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$PackageName,
        [switch]$Force
    )
    
    $platform = Get-PlatformInfo
    
    switch ($platform.PackageManager) {
        'apt' {
            $cmd = if ($Force) { 'apt-get install -y' } else { 'apt-get install' }
            & sudo $cmd.Split() $PackageName
            return $?
        }
        'yum' {
            $cmd = if ($Force) { 'yum install -y' } else { 'yum install' }
            & sudo $cmd.Split() $PackageName
            return $?
        }
        'zypper' {
            $cmd = if ($Force) { 'zypper install -y' } else { 'zypper install' }
            & sudo $cmd.Split() $PackageName
            return $?
        }
        'brew' {
            & brew install $PackageName
            return $?
        }
        'Chocolatey' {
            if (Get-Command choco -ErrorAction SilentlyContinue) {
                $cmd = if ($Force) { 'choco install -y' } else { 'choco install' }
                & $cmd.Split() $PackageName
                return $?
            }
            else {
                Write-Warning "Chocolatey not installed"
                return $false
            }
        }
        default {
            Write-Warning "No supported package manager found"
            return $false
        }
    }
}

#endregion

# Export functions
Export-ModuleMember -Function @(
    'Get-PlatformInfo',
    'Test-PlatformCompatibility',
    'Get-PlatformPaths',
    'New-PlatformDirectory',
    'Start-PlatformService',
    'Stop-PlatformService',
    'Get-PlatformServiceStatus',
    'Test-PlatformConnectivity',
    'Install-PlatformPackage'
)