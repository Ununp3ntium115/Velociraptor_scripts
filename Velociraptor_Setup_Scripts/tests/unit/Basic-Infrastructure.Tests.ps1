#Requires -Modules Pester

<#
.SYNOPSIS
    Basic infrastructure tests compatible with Pester 3.x.

.DESCRIPTION
    Simple tests to validate the basic project structure and
    core functionality without advanced Pester features.
#>

Describe "Project Structure Validation" {
    Context "Core Files Existence" {
        It "Should have main deployment scripts" {
            $scriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
            
            $mainScripts = @(
                'Deploy_Velociraptor_Standalone.ps1',
                'Deploy_Velociraptor_Server.ps1'
            )
            
            foreach ($script in $mainScripts) {
                $scriptPath = Join-Path $scriptRoot $script
                Test-Path $scriptPath | Should Be $true
            }
        }
        
        It "Should have modules directory" {
            $scriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
            $modulesPath = Join-Path $scriptRoot 'modules'
            Test-Path $modulesPath | Should Be $true
        }
        
        It "Should have scripts directory" {
            $scriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
            $scriptsPath = Join-Path $scriptRoot 'scripts'
            Test-Path $scriptsPath | Should Be $true
        }
        
        It "Should have tests directory" {
            $scriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
            $testsPath = Join-Path $scriptRoot 'tests'
            Test-Path $testsPath | Should Be $true
        }
    }
    
    Context "Configuration Files" {
        It "Should have package.json" {
            $scriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
            $packagePath = Join-Path $scriptRoot 'package.json'
            Test-Path $packagePath | Should Be $true
        }
        
        It "Should have module manifest" {
            $scriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
            $manifestPath = Join-Path $scriptRoot 'VelociraptorSetupScripts.psd1'
            Test-Path $manifestPath | Should Be $true
        }
        
        It "Should have README documentation" {
            $scriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
            $readmePath = Join-Path $scriptRoot 'README.md'
            Test-Path $readmePath | Should Be $true
        }
    }
}

Describe "Script Syntax Validation" {
    Context "PowerShell Script Syntax" {
        It "Should have valid PowerShell syntax in main scripts" {
            $scriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
            
            $mainScripts = @(
                'Deploy_Velociraptor_Standalone.ps1',
                'Deploy_Velociraptor_Server.ps1'
            )
            
            foreach ($script in $mainScripts) {
                $scriptPath = Join-Path $scriptRoot $script
                if (Test-Path $scriptPath) {
                    $content = Get-Content $scriptPath -Raw
                    { [scriptblock]::Create($content) } | Should Not Throw
                }
            }
        }
        
        It "Should contain required functions in deployment scripts" {
            $scriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
            $standalonePath = Join-Path $scriptRoot 'Deploy_Velociraptor_Standalone.ps1'
            
            if (Test-Path $standalonePath) {
                $content = Get-Content $standalonePath -Raw
                $content | Should Match 'function.*Write-Log|Write-VelociraptorLog'
                $content | Should Match 'function.*Test-AdminPrivileges|Test-VelociraptorAdminPrivileges'
            }
        }
    }
    
    Context "Configuration Validation" {
        It "Should have valid JSON in package.json" {
            $scriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
            $packagePath = Join-Path $scriptRoot 'package.json'
            
            if (Test-Path $packagePath) {
                $content = Get-Content $packagePath -Raw
                { $content | ConvertFrom-Json } | Should Not Throw
            }
        }
        
        It "Should have valid PowerShell data in module manifest" {
            $scriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
            $manifestPath = Join-Path $scriptRoot 'VelociraptorSetupScripts.psd1'
            
            if (Test-Path $manifestPath) {
                { Test-ModuleManifest $manifestPath } | Should Not Throw
            }
        }
    }
}

Describe "Repository Configuration" {
    Context "Velociraptor Source Repository" {
        It "Should use custom Velociraptor repository in deployment scripts" {
            $scriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
            
            $deploymentScripts = @(
                'Deploy_Velociraptor_Standalone.ps1',
                'Deploy_Velociraptor_Server.ps1'
            )
            
            foreach ($script in $deploymentScripts) {
                $scriptPath = Join-Path $scriptRoot $script
                if (Test-Path $scriptPath) {
                    $content = Get-Content $scriptPath -Raw
                    $content | Should Match 'Ununp3ntium115/velociraptor'
                    $content | Should Not Match 'Velocidx/velociraptor'
                    $content | Should Not Match 'Velocidex/velociraptor'
                }
            }
        }
        
        It "Should use correct GitHub API URL format" {
            $scriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
            $standalonePath = Join-Path $scriptRoot 'Deploy_Velociraptor_Standalone.ps1'
            
            if (Test-Path $standalonePath) {
                $content = Get-Content $standalonePath -Raw
                $content | Should Match 'api\.github\.com/repos/Ununp3ntium115/velociraptor'
            }
        }
    }
    
    Context "Project Metadata" {
        It "Should have correct version information" {
            $scriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
            $versionPath = Join-Path $scriptRoot 'VERSION'
            
            if (Test-Path $versionPath) {
                $version = Get-Content $versionPath -Raw
                $version.Trim() | Should Match '^\d+\.\d+\.\d+.*'
            }
        }
        
        It "Should have project description in package.json" {
            $scriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
            $packagePath = Join-Path $scriptRoot 'package.json'
            
            if (Test-Path $packagePath) {
                $package = Get-Content $packagePath -Raw | ConvertFrom-Json
                $package.description | Should Not BeNullOrEmpty
                $package.description | Should Match 'Velociraptor'
            }
        }
    }
}

Describe "Security Configuration" {
    Context "Script Security" {
        It "Should not contain hardcoded credentials" {
            $scriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
            
            $allScripts = Get-ChildItem $scriptRoot -Recurse -Filter "*.ps1" | Select-Object -First 10
            
            foreach ($script in $allScripts) {
                $content = Get-Content $script.FullName -Raw
                
                # Check for common credential patterns
                $content | Should Not Match 'password\s*=\s*[''"][^''"\s]+[''"]'
                $content | Should Not Match '\$password\s*=\s*[''"][^''"\s]+[''"]'
            }
        }
        
        It "Should use HTTPS for external requests" {
            $scriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
            $standalonePath = Join-Path $scriptRoot 'Deploy_Velociraptor_Standalone.ps1'
            
            if (Test-Path $standalonePath) {
                $content = Get-Content $standalonePath -Raw
                
                # Should use HTTPS for GitHub API
                $content | Should Match 'https://api\.github\.com'
                $content | Should Not Match 'http://(?!localhost|127\.0\.0\.1)'
            }
        }
    }
    
    Context "Error Handling" {
        It "Should have error handling in main scripts" {
            $scriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
            
            $mainScripts = @(
                'Deploy_Velociraptor_Standalone.ps1',
                'Deploy_Velociraptor_Server.ps1'
            )
            
            foreach ($script in $mainScripts) {
                $scriptPath = Join-Path $scriptRoot $script
                if (Test-Path $scriptPath) {
                    $content = Get-Content $scriptPath -Raw
                    $content | Should Match 'try\s*\{'
                    $content | Should Match 'catch\s*\{'
                }
            }
        }
        
        It "Should set ErrorActionPreference appropriately" {
            $scriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
            $standalonePath = Join-Path $scriptRoot 'Deploy_Velociraptor_Standalone.ps1'
            
            if (Test-Path $standalonePath) {
                $content = Get-Content $standalonePath -Raw
                $content | Should Match '\$ErrorActionPreference.*Stop'
            }
        }
    }
}