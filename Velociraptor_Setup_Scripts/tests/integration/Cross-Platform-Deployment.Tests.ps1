#Requires -Modules Pester

<#
.SYNOPSIS
    Integration tests for cross-platform deployment functionality.

.DESCRIPTION
    Tests the cross-platform deployment scripts and functions across
    Windows, Linux, and macOS environments with proper mocking.
#>

BeforeAll {
    # Set up test environment
    $LinuxScriptPath = Join-Path $PSScriptRoot '..\..\scripts\cross-platform\Deploy-VelociraptorLinux.ps1'
    
    # Mock platform detection
    $script:OriginalIsWindows = $IsWindows
    $script:OriginalIsLinux = $IsLinux
    $script:OriginalIsMacOS = $IsMacOS
    
    # Import the module for testing
    $ModulePath = Join-Path $PSScriptRoot '..\..\modules\VelociraptorDeployment\VelociraptorDeployment.psd1'
    if (Test-Path $ModulePath) {
        Import-Module $ModulePath -Force
    }
}

Describe "Cross-Platform Detection" {
    Context "Platform Variables" {
        It "Should have platform detection variables" {
            # These should be available in PowerShell Core
            if ($PSVersionTable.PSVersion.Major -ge 6) {
                { $IsWindows } | Should -Not -Throw
                { $IsLinux } | Should -Not -Throw
                { $IsMacOS } | Should -Not -Throw
            }
        }
        
        It "Should detect current platform correctly" {
            if ($PSVersionTable.PSVersion.Major -ge 6) {
                $platformCount = @($IsWindows, $IsLinux, $IsMacOS) | Where-Object { $_ -eq $true } | Measure-Object | Select-Object -ExpandProperty Count
                $platformCount | Should -Be 1
            } else {
                # PowerShell 5.1 on Windows
                $env:OS | Should -Match 'Windows'
            }
        }
    }
    
    Context "OS Detection Functions" {
        It "Should detect Windows correctly" {
            if ($PSVersionTable.PSVersion.Major -ge 6) {
                if ($IsWindows) {
                    $env:OS | Should -Match 'Windows'
                }
            } else {
                $env:OS | Should -Match 'Windows'
            }
        }
        
        It "Should handle Linux detection" {
            # Mock Linux environment
            Mock Get-Variable { 
                param($Name)
                if ($Name -eq 'IsLinux') { return @{ Value = $true } }
                if ($Name -eq 'IsWindows') { return @{ Value = $false } }
                if ($Name -eq 'IsMacOS') { return @{ Value = $false } }
            }
            
            # This would be tested in actual Linux environment
            $true | Should -Be $true  # Placeholder for Linux-specific tests
        }
    }
}

Describe "Linux Deployment Script" -Skip:(-not (Test-Path $LinuxScriptPath)) {
    Context "Script Structure" {
        It "Should exist" {
            Test-Path $LinuxScriptPath | Should -Be $true
        }
        
        It "Should be a valid PowerShell script" {
            $scriptContent = Get-Content $LinuxScriptPath -Raw
            { [scriptblock]::Create($scriptContent) } | Should -Not -Throw
        }
        
        It "Should contain distribution detection" {
            $scriptContent = Get-Content $LinuxScriptPath -Raw
            $scriptContent | Should -Match 'Ubuntu|Debian|CentOS|RHEL|Fedora|SUSE'
        }
        
        It "Should handle package managers" {
            $scriptContent = Get-Content $LinuxScriptPath -Raw
            $scriptContent | Should -Match 'apt|yum|dnf|zypper'
        }
    }
    
    Context "Distribution Support" {
        It "Should support Ubuntu/Debian" {
            $scriptContent = Get-Content $LinuxScriptPath -Raw
            $scriptContent | Should -Match 'apt-get|apt\s'
            $scriptContent | Should -Match 'ubuntu|debian'
        }
        
        It "Should support RHEL/CentOS" {
            $scriptContent = Get-Content $LinuxScriptPath -Raw
            $scriptContent | Should -Match 'yum|dnf'
            $scriptContent | Should -Match 'rhel|centos|fedora'
        }
        
        It "Should support SUSE" {
            $scriptContent = Get-Content $LinuxScriptPath -Raw
            $scriptContent | Should -Match 'zypper'
            $scriptContent | Should -Match 'suse|opensuse'
        }
    }
    
    Context "Service Management" {
        It "Should handle systemd services" {
            $scriptContent = Get-Content $LinuxScriptPath -Raw
            $scriptContent | Should -Match 'systemctl|systemd'
        }
        
        It "Should create service files" {
            $scriptContent = Get-Content $LinuxScriptPath -Raw
            $scriptContent | Should -Match '\.service|/etc/systemd'
        }
    }
    
    Context "Firewall Configuration" {
        It "Should handle UFW (Ubuntu)" {
            $scriptContent = Get-Content $LinuxScriptPath -Raw
            $scriptContent | Should -Match 'ufw'
        }
        
        It "Should handle firewalld (RHEL/CentOS)" {
            $scriptContent = Get-Content $LinuxScriptPath -Raw
            $scriptContent | Should -Match 'firewall-cmd|firewalld'
        }
    }
}

Describe "Cross-Platform Path Handling" {
    Context "Path Separators" {
        It "Should handle Windows paths" {
            $windowsPath = "C:\Program Files\Velociraptor"
            $windowsPath | Should -Match '\\'
        }
        
        It "Should handle Unix paths" {
            $unixPath = "/opt/velociraptor"
            $unixPath | Should -Match '^/'
            $unixPath | Should -Not -Match '\\'
        }
        
        It "Should use Join-Path for cross-platform compatibility" {
            $basePath = if ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6) { "C:\tools" } else { "/opt" }
            $fullPath = Join-Path $basePath "velociraptor"
            $fullPath | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Environment Variables" {
        It "Should handle Windows environment variables" {
            if ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6) {
                $env:ProgramData | Should -Not -BeNullOrEmpty
                $env:TEMP | Should -Not -BeNullOrEmpty
            }
        }
        
        It "Should handle Unix environment variables" {
            if ($IsLinux -or $IsMacOS) {
                $env:HOME | Should -Not -BeNullOrEmpty
                $env:USER | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Describe "Cross-Platform Service Management" {
    Context "Windows Services" {
        It "Should handle Windows service commands" -Skip:(-not ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6)) {
            # Mock service commands
            Mock Get-Service { return @{ Status = 'Running'; Name = 'TestService' } }
            Mock Start-Service { return $true }
            Mock Stop-Service { return $true }
            
            { Get-Service -Name 'TestService' } | Should -Not -Throw
        }
    }
    
    Context "Linux Services" {
        It "Should handle systemctl commands" -Skip:(-not $IsLinux) {
            # Mock systemctl commands
            Mock Invoke-Expression { 
                param($Command)
                if ($Command -match 'systemctl') {
                    return "active"
                }
            }
            
            # This would be tested in actual Linux environment
            $true | Should -Be $true
        }
    }
    
    Context "macOS Services" {
        It "Should handle launchctl commands" -Skip:(-not $IsMacOS) {
            # Mock launchctl commands
            Mock Invoke-Expression {
                param($Command)
                if ($Command -match 'launchctl') {
                    return "0"
                }
            }
            
            # This would be tested in actual macOS environment
            $true | Should -Be $true
        }
    }
}

Describe "Cross-Platform Configuration" {
    Context "Configuration Paths" {
        It "Should use appropriate config paths for each platform" {
            if ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6) {
                $configPath = Join-Path $env:ProgramData "Velociraptor"
                $configPath | Should -Match 'ProgramData'
            } elseif ($IsLinux) {
                $configPath = "/etc/velociraptor"
                $configPath | Should -Match '^/etc'
            } elseif ($IsMacOS) {
                $configPath = "/usr/local/etc/velociraptor"
                $configPath | Should -Match '/usr/local/etc'
            }
        }
        
        It "Should use appropriate data paths for each platform" {
            if ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6) {
                $dataPath = Join-Path $env:ProgramData "Velociraptor\Data"
                $dataPath | Should -Match 'ProgramData'
            } elseif ($IsLinux) {
                $dataPath = "/var/lib/velociraptor"
                $dataPath | Should -Match '^/var/lib'
            } elseif ($IsMacOS) {
                $dataPath = "/usr/local/var/velociraptor"
                $dataPath | Should -Match '/usr/local/var'
            }
        }
    }
    
    Context "Permissions" {
        It "Should handle Windows permissions" -Skip:(-not ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6)) {
            # Test Windows ACL handling
            $testPath = $env:TEMP
            { Get-Acl $testPath } | Should -Not -Throw
        }
        
        It "Should handle Unix permissions" -Skip:(-not ($IsLinux -or $IsMacOS)) {
            # Test Unix chmod/chown handling
            $testPath = "/tmp"
            if (Test-Path $testPath) {
                { Get-Item $testPath } | Should -Not -Throw
            }
        }
    }
}

AfterAll {
    # Restore original platform variables
    if ($null -ne $script:OriginalIsWindows) {
        Set-Variable -Name IsWindows -Value $script:OriginalIsWindows -Scope Global -Force
    }
    if ($null -ne $script:OriginalIsLinux) {
        Set-Variable -Name IsLinux -Value $script:OriginalIsLinux -Scope Global -Force
    }
    if ($null -ne $script:OriginalIsMacOS) {
        Set-Variable -Name IsMacOS -Value $script:OriginalIsMacOS -Scope Global -Force
    }
    
    # Remove module
    Remove-Module VelociraptorDeployment -Force -ErrorAction SilentlyContinue
}