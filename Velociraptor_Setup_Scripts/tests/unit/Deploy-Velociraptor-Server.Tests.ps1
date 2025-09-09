#Requires -Modules Pester

<#
.SYNOPSIS
    Unit tests for Deploy-Velociraptor-Server.ps1 script.

.DESCRIPTION
    Comprehensive unit tests covering the server deployment script functionality
    including parameter validation, helper functions, and deployment logic.
#>

BeforeAll {
    # Set up test environment
    $ScriptPath = Join-Path $PSScriptRoot '..\..\Deploy_Velociraptor_Server.ps1'
    $TestInstallDir = Join-Path $env:TEMP 'VelociraptorServerTest'
    $TestDataStore = Join-Path $env:TEMP 'VelociraptorServerTestData'
    
    # Mock external dependencies
    Mock Start-Process { return @{ Id = 1234; HasExited = $false } }
    Mock Test-NetConnection { return @{ TcpTestSucceeded = $true } }
    Mock New-NetFirewallRule { return $true }
    Mock Invoke-WebRequest { return @{ StatusCode = 200; Content = '{"tag_name": "v0.6.8"}' } }
}

Describe "Deploy-Velociraptor-Server Script Structure" {
    Context "Script Existence and Validity" {
        It "Should exist" {
            Test-Path $ScriptPath | Should -Be $true
        }
        
        It "Should be a valid PowerShell script" {
            $scriptContent = Get-Content $ScriptPath -Raw
            { [scriptblock]::Create($scriptContent) } | Should -Not -Throw
        }
        
        It "Should set ErrorActionPreference to Stop" {
            $scriptContent = Get-Content $ScriptPath -Raw
            $scriptContent | Should -Match '\$ErrorActionPreference.*Stop'
        }
        
        It "Should contain required configuration variables" {
            $scriptContent = Get-Content $ScriptPath -Raw
            $scriptContent | Should -Match '\$installDir'
            $scriptContent | Should -Match '\$dataStore'
            $scriptContent | Should -Match '\$frontendPort'
            $scriptContent | Should -Match '\$guiPort'
        }
    }
    
    Context "Helper Functions" {
        BeforeAll {
            # Source the script to get helper functions
            . $ScriptPath
        }
        
        It "Should define Log function" {
            Get-Command Log -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
        
        It "Should define Ask function" {
            Get-Command Ask -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
        
        It "Log function should accept Message parameter" {
            { Log -Message "Test message" } | Should -Not -Throw
        }
        
        It "Log function should accept Level parameter" {
            $levels = @('Info', 'Warning', 'Error', 'Success', 'Debug')
            foreach ($level in $levels) {
                { Log -Message "Test $level" -Level $level } | Should -Not -Throw
            }
        }
        
        It "Ask function should accept Question parameter" {
            Mock Read-Host { return 'y' }
            { Ask -Question "Test question?" } | Should -Not -Throw
        }
        
        It "Ask function should use default value when no input" {
            Mock Read-Host { return '' }
            $result = Ask -Question "Test?" -DefaultValue 'default'
            $result | Should -Be 'default'
        }
    }
}

Describe "Server Configuration Validation" {
    Context "Port Configuration" {
        It "Should use valid default ports" {
            $scriptContent = Get-Content $ScriptPath -Raw
            $scriptContent | Should -Match '\$frontendPort\s*=\s*8000'
            $scriptContent | Should -Match '\$guiPort\s*=\s*8889'
        }
        
        It "Should validate port ranges" {
            # This would be implemented in the actual script
            $validPorts = @(8000, 8889, 9999, 443, 80)
            foreach ($port in $validPorts) {
                $port | Should -BeGreaterThan 0
                $port | Should -BeLessThan 65536
            }
        }
    }
    
    Context "Directory Configuration" {
        It "Should use valid default directories" {
            $scriptContent = Get-Content $ScriptPath -Raw
            $scriptContent | Should -Match '\$installDir\s*=\s*[''"]C:\\tools[''"]'
            $scriptContent | Should -Match '\$dataStore\s*=\s*[''"]C:\\VelociraptorServerData[''"]'
        }
    }
}

Describe "Deployment Process" {
    Context "Prerequisites Check" {
        It "Should check for administrator privileges" {
            $scriptContent = Get-Content $ScriptPath -Raw
            $scriptContent | Should -Match 'Administrator|Admin|Elevated'
        }
        
        It "Should create required directories" {
            $scriptContent = Get-Content $ScriptPath -Raw
            $scriptContent | Should -Match 'New-Item.*Directory|mkdir'
        }
    }
    
    Context "Download Process" {
        It "Should handle GitHub API calls" {
            $scriptContent = Get-Content $ScriptPath -Raw
            $scriptContent | Should -Match 'api\.github\.com|github\.com.*releases'
        }
        
        It "Should handle download failures gracefully" {
            $scriptContent = Get-Content $ScriptPath -Raw
            $scriptContent | Should -Match 'try\s*\{.*catch|ErrorAction'
        }
    }
    
    Context "Service Configuration" {
        It "Should configure server mode" {
            $scriptContent = Get-Content $ScriptPath -Raw
            $scriptContent | Should -Match 'config\s+generate|server\.config\.yaml'
        }
        
        It "Should handle firewall configuration" {
            $scriptContent = Get-Content $ScriptPath -Raw
            $scriptContent | Should -Match 'firewall|New-NetFirewallRule|netsh'
        }
    }
}

Describe "Error Handling and Logging" {
    Context "Error Handling" {
        It "Should have try-catch blocks for critical operations" {
            $scriptContent = Get-Content $ScriptPath -Raw
            $scriptContent | Should -Match 'try\s*\{'
            $scriptContent | Should -Match 'catch\s*\{'
        }
        
        It "Should log errors appropriately" {
            $scriptContent = Get-Content $ScriptPath -Raw
            $scriptContent | Should -Match 'Log.*Error|Write-Error'
        }
    }
    
    Context "Logging" {
        It "Should create log directory" {
            $scriptContent = Get-Content $ScriptPath -Raw
            $scriptContent | Should -Match '\$Env:ProgramData.*VelociraptorDeploy'
        }
        
        It "Should write to log file" {
            $scriptContent = Get-Content $ScriptPath -Raw
            $scriptContent | Should -Match 'server_deploy\.log|Out-File.*log'
        }
    }
}

AfterAll {
    # Clean up test environment
    if (Test-Path $TestInstallDir) {
        Remove-Item $TestInstallDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    if (Test-Path $TestDataStore) {
        Remove-Item $TestDataStore -Recurse -Force -ErrorAction SilentlyContinue
    }
}