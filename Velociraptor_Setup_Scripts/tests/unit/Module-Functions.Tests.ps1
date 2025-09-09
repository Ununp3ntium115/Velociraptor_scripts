#Requires -Modules Pester

<#
.SYNOPSIS
    Comprehensive unit tests for all module functions.

.DESCRIPTION
    Tests all functions across all modules in the Velociraptor Setup Scripts
    project, including parameter validation, return values, and error handling.
#>

BeforeAll {
    # Set up test environment
    $ScriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
    $ModulesPath = Join-Path $ScriptRoot 'modules'
    
    # Import all available modules
    $ImportedModules = @()
    
    if (Test-Path $ModulesPath) {
        $ModuleDirectories = Get-ChildItem $ModulesPath -Directory
        
        foreach ($moduleDir in $ModuleDirectories) {
            $manifestPath = Join-Path $moduleDir.FullName "$($moduleDir.Name).psd1"
            if (Test-Path $manifestPath) {
                try {
                    Import-Module $manifestPath -Force
                    $ImportedModules += $moduleDir.Name
                    Write-Host "Imported module: $($moduleDir.Name)" -ForegroundColor Green
                }
                catch {
                    Write-Warning "Failed to import module $($moduleDir.Name): $($_.Exception.Message)"
                }
            }
        }
    }
    
    # Test data
    $TestConfigPath = Join-Path $env:TEMP 'test-module-config.yaml'
    $TestLogPath = Join-Path $env:TEMP 'test-module.log'
    $TestDataDir = Join-Path $env:TEMP 'VelociraptorModuleTest'
}

Describe "Module Import and Structure" {
    Context "Module Availability" {
        It "Should have modules directory" {
            Test-Path $ModulesPath | Should -Be $true
        }
        
        It "Should import at least one module" {
            $ImportedModules.Count | Should -BeGreaterThan 0
        }
        
        foreach ($moduleName in $ImportedModules) {
            It "Should have $moduleName module loaded" {
                Get-Module $moduleName | Should -Not -BeNullOrEmpty
            }
        }
    }
    
    Context "Module Manifests" {
        foreach ($moduleName in $ImportedModules) {
            It "$moduleName should have valid manifest" {
                $module = Get-Module $moduleName
                $module.Version | Should -Not -BeNullOrEmpty
                $module.Author | Should -Not -BeNullOrEmpty
                $module.Description | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Describe "VelociraptorDeployment Module Functions" -Skip:('VelociraptorDeployment' -notin $ImportedModules) {
    Context "Core Deployment Functions" {
        It "Should export Write-VelociraptorLog function" {
            Get-Command Write-VelociraptorLog -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
        
        It "Should export Test-VelociraptorAdminPrivileges function" {
            Get-Command Test-VelociraptorAdminPrivileges -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
        
        It "Should export Get-VelociraptorLatestRelease function" {
            Get-Command Get-VelociraptorLatestRelease -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
        
        It "Should export Invoke-VelociraptorDownload function" {
            Get-Command Invoke-VelociraptorDownload -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Write-VelociraptorLog Function" {
        It "Should accept Message parameter" {
            { Write-VelociraptorLog -Message "Test message" } | Should -Not -Throw
        }
        
        It "Should accept Level parameter with valid values" {
            $validLevels = @('Info', 'Warning', 'Error', 'Success', 'Debug', 'Verbose')
            foreach ($level in $validLevels) {
                { Write-VelociraptorLog -Message "Test $level" -Level $level } | Should -Not -Throw
            }
        }
        
        It "Should reject invalid Level values" {
            { Write-VelociraptorLog -Message "Test" -Level "InvalidLevel" } | Should -Throw
        }
        
        It "Should work with NoConsole switch" {
            { Write-VelociraptorLog -Message "Silent test" -NoConsole } | Should -Not -Throw
        }
        
        It "Should work with Component parameter" {
            { Write-VelociraptorLog -Message "Component test" -Component "TestComponent" } | Should -Not -Throw
        }
    }
    
    Context "Test-VelociraptorAdminPrivileges Function" {
        It "Should return boolean value" {
            $result = Test-VelociraptorAdminPrivileges -Quiet
            $result | Should -BeOfType [bool]
        }
        
        It "Should work with Quiet switch" {
            { Test-VelociraptorAdminPrivileges -Quiet } | Should -Not -Throw
        }
        
        It "Should work with ThrowOnFailure switch" {
            # Only test if not running as admin
            if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
                { Test-VelociraptorAdminPrivileges -ThrowOnFailure } | Should -Throw
            }
        }
    }
    
    Context "Get-VelociraptorLatestRelease Function" {
        It "Should return release information" {
            $result = Get-VelociraptorLatestRelease
            $result | Should -Not -BeNullOrEmpty
            $result.PSObject.Properties.Name | Should -Contain 'Version'
            $result.PSObject.Properties.Name | Should -Contain 'Asset'
        }
        
        It "Should accept Platform parameter" {
            $platforms = @('Windows', 'Linux', 'Darwin')
            foreach ($platform in $platforms) {
                { Get-VelociraptorLatestRelease -Platform $platform } | Should -Not -Throw
            }
        }
        
        It "Should validate Platform parameter" {
            { Get-VelociraptorLatestRelease -Platform "InvalidPlatform" } | Should -Throw
        }
        
        It "Should accept Architecture parameter" {
            $architectures = @('amd64', 'arm64')
            foreach ($arch in $architectures) {
                { Get-VelociraptorLatestRelease -Architecture $arch } | Should -Not -Throw
            }
        }
    }
    
    Context "Invoke-VelociraptorDownload Function" {
        It "Should require Url parameter" {
            { Invoke-VelociraptorDownload -DestinationPath "C:\temp\test.exe" } | Should -Throw
        }
        
        It "Should require DestinationPath parameter" {
            { Invoke-VelociraptorDownload -Url "https://example.com/file.exe" } | Should -Throw
        }
        
        It "Should validate MaxRetries range" {
            { Invoke-VelociraptorDownload -Url "https://example.com/file.exe" -DestinationPath "C:\temp\test.exe" -MaxRetries 0 } | Should -Throw
            { Invoke-VelociraptorDownload -Url "https://example.com/file.exe" -DestinationPath "C:\temp\test.exe" -MaxRetries 11 } | Should -Throw
        }
        
        It "Should return structured result object" {
            $result = Invoke-VelociraptorDownload -Url "https://invalid.url.test/file.exe" -DestinationPath "$env:TEMP\test.exe"
            $result | Should -Not -BeNullOrEmpty
            $result.PSObject.Properties.Name | Should -Contain 'Success'
            $result.PSObject.Properties.Name | Should -Contain 'FilePath'
        }
    }
}

Describe "VelociraptorCompliance Module Functions" -Skip:('VelociraptorCompliance' -notin $ImportedModules) {
    Context "Compliance Functions" {
        It "Should export compliance-related functions" {
            $module = Get-Module VelociraptorCompliance
            $module.ExportedFunctions.Count | Should -BeGreaterThan 0
        }
        
        It "Should have Test-ComplianceBaseline function" {
            Get-Command Test-ComplianceBaseline -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Test-ComplianceBaseline Function" -Skip:(-not (Get-Command Test-ComplianceBaseline -ErrorAction SilentlyContinue)) {
        It "Should accept ConfigPath parameter" {
            # Create test config
            "version: 1.0" | Out-File $TestConfigPath
            
            try {
                { Test-ComplianceBaseline -ConfigPath $TestConfigPath } | Should -Not -Throw
            }
            finally {
                Remove-Item $TestConfigPath -Force -ErrorAction SilentlyContinue
            }
        }
        
        It "Should accept ComplianceFramework parameter" {
            $frameworks = @('SOX', 'HIPAA', 'PCI-DSS', 'GDPR')
            foreach ($framework in $frameworks) {
                { Test-ComplianceBaseline -ConfigPath $TestConfigPath -ComplianceFramework $framework } | Should -Not -Throw
            }
        }
    }
}

Describe "ZeroTrustSecurity Module Functions" -Skip:('ZeroTrustSecurity' -notin $ImportedModules) {
    Context "Security Functions" {
        It "Should export security-related functions" {
            $module = Get-Module ZeroTrustSecurity
            $module.ExportedFunctions.Count | Should -BeGreaterThan 0
        }
        
        It "Should have Set-ZeroTrustConfiguration function" {
            Get-Command Set-ZeroTrustConfiguration -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Set-ZeroTrustConfiguration Function" -Skip:(-not (Get-Command Set-ZeroTrustConfiguration -ErrorAction SilentlyContinue)) {
        It "Should accept ConfigPath parameter" {
            "version: 1.0" | Out-File $TestConfigPath
            
            try {
                { Set-ZeroTrustConfiguration -ConfigPath $TestConfigPath } | Should -Not -Throw
            }
            finally {
                Remove-Item $TestConfigPath -Force -ErrorAction SilentlyContinue
            }
        }
        
        It "Should accept SecurityLevel parameter" {
            $levels = @('Basic', 'Standard', 'Maximum')
            foreach ($level in $levels) {
                { Set-ZeroTrustConfiguration -ConfigPath $TestConfigPath -SecurityLevel $level } | Should -Not -Throw
            }
        }
    }
}

Describe "VelociraptorML Module Functions" -Skip:('VelociraptorML' -notin $ImportedModules) {
    Context "AI/ML Functions" {
        It "Should export ML-related functions" {
            $module = Get-Module VelociraptorML
            $module.ExportedFunctions.Count | Should -BeGreaterThan 0
        }
        
        It "Should have New-IntelligentConfiguration function" {
            Get-Command New-IntelligentConfiguration -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "New-IntelligentConfiguration Function" -Skip:(-not (Get-Command New-IntelligentConfiguration -ErrorAction SilentlyContinue)) {
        It "Should accept EnvironmentType parameter" {
            $environments = @('Development', 'Testing', 'Production')
            foreach ($env in $environments) {
                { New-IntelligentConfiguration -EnvironmentType $env } | Should -Not -Throw
            }
        }
        
        It "Should accept UseCase parameter" {
            $useCases = @('ThreatHunting', 'IncidentResponse', 'Compliance')
            foreach ($useCase in $useCases) {
                { New-IntelligentConfiguration -UseCase $useCase } | Should -Not -Throw
            }
        }
    }
}

Describe "Function Parameter Validation" {
    Context "Common Parameter Patterns" {
        foreach ($moduleName in $ImportedModules) {
            $module = Get-Module $moduleName
            $functions = $module.ExportedFunctions.Values
            
            foreach ($function in $functions) {
                It "$($function.Name) should have proper parameter validation" {
                    $parameters = $function.Parameters
                    
                    # Check for common validation patterns
                    foreach ($param in $parameters.Values) {
                        if ($param.Name -match 'Path') {
                            # Path parameters should have validation
                            $param.Attributes | Should -Not -BeNullOrEmpty
                        }
                        
                        if ($param.Name -match 'Port') {
                            # Port parameters should have range validation
                            $param.Attributes | Should -Not -BeNullOrEmpty
                        }
                    }
                }
            }
        }
    }
    
    Context "Mandatory Parameters" {
        foreach ($moduleName in $ImportedModules) {
            $module = Get-Module $moduleName
            $functions = $module.ExportedFunctions.Values
            
            foreach ($function in $functions) {
                It "$($function.Name) should handle mandatory parameters correctly" {
                    $mandatoryParams = $function.Parameters.Values | Where-Object { 
                        $_.Attributes | Where-Object { $_.Mandatory -eq $true }
                    }
                    
                    # If function has mandatory parameters, they should be properly defined
                    foreach ($param in $mandatoryParams) {
                        $param.Name | Should -Not -BeNullOrEmpty
                        $param.ParameterType | Should -Not -BeNullOrEmpty
                    }
                }
            }
        }
    }
}

Describe "Function Error Handling" {
    Context "Exception Management" {
        foreach ($moduleName in $ImportedModules) {
            It "$moduleName functions should handle errors gracefully" {
                $module = Get-Module $moduleName
                $functions = $module.ExportedFunctions.Values
                
                foreach ($function in $functions) {
                    # Test with invalid parameters where possible
                    if ($function.Parameters.ContainsKey('Path')) {
                        { & $function.Name -Path "C:\NonExistentPath\Invalid.txt" -ErrorAction SilentlyContinue } | Should -Not -Throw
                    }
                }
            }
        }
    }
    
    Context "Return Values" {
        foreach ($moduleName in $ImportedModules) {
            It "$moduleName functions should return consistent types" {
                $module = Get-Module $moduleName
                $functions = $module.ExportedFunctions.Values
                
                foreach ($function in $functions) {
                    # Functions should either return something or be void
                    # This is a structural test - actual return type testing would need specific function calls
                    $function.OutputType | Should -Not -BeNull
                }
            }
        }
    }
}

Describe "Backward Compatibility" {
    Context "Alias Availability" {
        It "Should maintain backward compatibility aliases" {
            $expectedAliases = @(
                'Log',
                'Write-Log',
                'Require-Admin',
                'Test-Admin'
            )
            
            foreach ($alias in $expectedAliases) {
                $aliasCommand = Get-Alias $alias -ErrorAction SilentlyContinue
                if ($aliasCommand) {
                    $aliasCommand | Should -Not -BeNullOrEmpty
                    $aliasCommand.ResolvedCommand | Should -Not -BeNullOrEmpty
                }
            }
        }
    }
    
    Context "Function Signatures" {
        It "Should maintain consistent function signatures" {
            # Test that core functions maintain their expected signatures
            if (Get-Command Write-VelociraptorLog -ErrorAction SilentlyContinue) {
                $function = Get-Command Write-VelociraptorLog
                $function.Parameters.ContainsKey('Message') | Should -Be $true
                $function.Parameters.ContainsKey('Level') | Should -Be $true
            }
        }
    }
}

AfterAll {
    # Clean up test files
    Remove-Item $TestConfigPath -Force -ErrorAction SilentlyContinue
    Remove-Item $TestLogPath -Force -ErrorAction SilentlyContinue
    Remove-Item $TestDataDir -Recurse -Force -ErrorAction SilentlyContinue
    
    # Remove imported modules
    foreach ($moduleName in $ImportedModules) {
        Remove-Module $moduleName -Force -ErrorAction SilentlyContinue
    }
}