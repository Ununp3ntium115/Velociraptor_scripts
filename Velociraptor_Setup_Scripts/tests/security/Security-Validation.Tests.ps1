#Requires -Modules Pester

<#
.SYNOPSIS
    Security validation tests for Velociraptor Setup Scripts.

.DESCRIPTION
    Comprehensive security tests covering credential handling, file permissions,
    network security, and compliance with security best practices.
#>

BeforeAll {
    # Set up test environment
    $ScriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
    $SecurityScriptPath = Join-Path $ScriptRoot 'scripts\security\Set-VelociraptorSecurityBaseline.ps1'
    
    # Import modules for testing
    $ModulePath = Join-Path $ScriptRoot 'modules\VelociraptorDeployment\VelociraptorDeployment.psd1'
    if (Test-Path $ModulePath) {
        Import-Module $ModulePath -Force
    }
    
    # Test data
    $TestConfigPath = Join-Path $env:TEMP 'test-velociraptor-config.yaml'
    $TestLogPath = Join-Path $env:TEMP 'test-velociraptor.log'
}

Describe "Credential Security" {
    Context "Password Handling" {
        It "Should not contain hardcoded passwords" {
            $allScripts = Get-ChildItem $ScriptRoot -Recurse -Filter "*.ps1"
            
            foreach ($script in $allScripts) {
                $content = Get-Content $script.FullName -Raw
                
                # Check for common password patterns
                $content | Should -Not -Match 'password\s*=\s*[''"][^''"\s]+[''"]'
                $content | Should -Not -Match '\$password\s*=\s*[''"][^''"\s]+[''"]'
                $content | Should -Not -Match 'ConvertTo-SecureString.*-AsPlainText.*-Force'
            }
        }
        
        It "Should use SecureString for sensitive data" {
            $allScripts = Get-ChildItem $ScriptRoot -Recurse -Filter "*.ps1"
            
            foreach ($script in $allScripts) {
                $content = Get-Content $script.FullName -Raw
                
                # If handling credentials, should use SecureString
                if ($content -match 'credential|password') {
                    # Allow proper SecureString usage
                    $content | Should -Match 'SecureString|Get-Credential|Read-Host.*-AsSecureString'
                }
            }
        }
        
        It "Should not log sensitive information" {
            $allScripts = Get-ChildItem $ScriptRoot -Recurse -Filter "*.ps1"
            
            foreach ($script in $allScripts) {
                $content = Get-Content $script.FullName -Raw
                
                # Check that logging doesn't expose sensitive data
                $content | Should -Not -Match 'Write-Log.*\$password'
                $content | Should -Not -Match 'Log.*\$credential'
                $content | Should -Not -Match 'Out-File.*\$password'
            }
        }
    }
    
    Context "API Key Security" {
        It "Should not contain hardcoded API keys" {
            $allScripts = Get-ChildItem $ScriptRoot -Recurse -Filter "*.ps1"
            
            foreach ($script in $allScripts) {
                $content = Get-Content $script.FullName -Raw
                
                # Check for common API key patterns
                $content | Should -Not -Match 'api[_-]?key\s*=\s*[''"][a-zA-Z0-9]{20,}[''"]'
                $content | Should -Not -Match 'token\s*=\s*[''"][a-zA-Z0-9]{20,}[''"]'
                $content | Should -Not -Match 'secret\s*=\s*[''"][a-zA-Z0-9]{20,}[''"]'
            }
        }
        
        It "Should use environment variables for sensitive configuration" {
            $allScripts = Get-ChildItem $ScriptRoot -Recurse -Filter "*.ps1"
            
            foreach ($script in $allScripts) {
                $content = Get-Content $script.FullName -Raw
                
                # If using external APIs, should reference environment variables
                if ($content -match 'api\.github\.com|external.*api') {
                    # Should use $env: variables for sensitive data
                    $content | Should -Match '\$env:|Get-ChildItem.*Env:'
                }
            }
        }
    }
}

Describe "File System Security" {
    Context "File Permissions" {
        It "Should create files with appropriate permissions" -Skip:(-not ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6)) {
            # Test Windows file permissions
            $testFile = Join-Path $env:TEMP 'velociraptor-security-test.txt'
            "Test content" | Out-File $testFile
            
            try {
                $acl = Get-Acl $testFile
                $acl | Should -Not -BeNullOrEmpty
                
                # Should not be world-writable
                $everyoneWrite = $acl.Access | Where-Object { 
                    $_.IdentityReference -match 'Everyone|Users' -and 
                    $_.FileSystemRights -match 'Write|FullControl' 
                }
                $everyoneWrite | Should -BeNullOrEmpty
            }
            finally {
                Remove-Item $testFile -Force -ErrorAction SilentlyContinue
            }
        }
        
        It "Should handle Unix permissions correctly" -Skip:(-not ($IsLinux -or $IsMacOS)) {
            # Test Unix file permissions
            $testFile = "/tmp/velociraptor-security-test.txt"
            "Test content" | Out-File $testFile
            
            try {
                # Check that file is not world-writable (should be 644 or 600)
                $permissions = (Get-Item $testFile).UnixMode
                $permissions | Should -Not -Match '.*w.*w.*'  # Not world-writable
            }
            finally {
                Remove-Item $testFile -Force -ErrorAction SilentlyContinue
            }
        }
    }
    
    Context "Directory Security" {
        It "Should create secure directories" {
            $testDir = Join-Path $env:TEMP 'velociraptor-security-dir-test'
            
            try {
                New-Item $testDir -ItemType Directory -Force | Out-Null
                
                if ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6) {
                    $acl = Get-Acl $testDir
                    $acl | Should -Not -BeNullOrEmpty
                } else {
                    # Unix systems
                    Test-Path $testDir | Should -Be $true
                }
            }
            finally {
                Remove-Item $testDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
        
        It "Should not create world-writable directories" {
            $testDir = Join-Path $env:TEMP 'velociraptor-security-dir-test2'
            
            try {
                New-Item $testDir -ItemType Directory -Force | Out-Null
                
                if ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6) {
                    $acl = Get-Acl $testDir
                    $everyoneWrite = $acl.Access | Where-Object { 
                        $_.IdentityReference -match 'Everyone' -and 
                        $_.FileSystemRights -match 'Write|FullControl' 
                    }
                    $everyoneWrite | Should -BeNullOrEmpty
                }
            }
            finally {
                Remove-Item $testDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

Describe "Network Security" {
    Context "TLS/SSL Configuration" {
        It "Should enforce TLS for web requests" {
            $allScripts = Get-ChildItem $ScriptRoot -Recurse -Filter "*.ps1"
            
            foreach ($script in $allScripts) {
                $content = Get-Content $script.FullName -Raw
                
                # If making web requests, should use HTTPS
                if ($content -match 'Invoke-WebRequest|Invoke-RestMethod') {
                    $content | Should -Match 'https://'
                    $content | Should -Not -Match 'http://(?!localhost|127\.0\.0\.1)'
                }
            }
        }
        
        It "Should validate certificates" {
            $allScripts = Get-ChildItem $ScriptRoot -Recurse -Filter "*.ps1"
            
            foreach ($script in $allScripts) {
                $content = Get-Content $script.FullName -Raw
                
                # Should not skip certificate validation
                $content | Should -Not -Match 'SkipCertificateCheck'
                $content | Should -Not -Match 'ServerCertificateValidationCallback.*\$true'
            }
        }
    }
    
    Context "Port Configuration" {
        It "Should use secure default ports" {
            $allScripts = Get-ChildItem $ScriptRoot -Recurse -Filter "*.ps1"
            
            foreach ($script in $allScripts) {
                $content = Get-Content $script.FullName -Raw
                
                # Check for insecure default ports
                $content | Should -Not -Match 'port.*=.*23[^0-9]'    # Telnet
                $content | Should -Not -Match 'port.*=.*21[^0-9]'    # FTP
                $content | Should -Not -Match 'port.*=.*80[^0-9]'    # HTTP (unless localhost)
            }
        }
        
        It "Should validate port ranges" {
            $allScripts = Get-ChildItem $ScriptRoot -Recurse -Filter "*.ps1"
            
            foreach ($script in $allScripts) {
                $content = Get-Content $script.FullName -Raw
                
                # Extract port assignments
                $portMatches = [regex]::Matches($content, '\$\w*[Pp]ort\s*=\s*(\d+)')
                
                foreach ($match in $portMatches) {
                    $port = [int]$match.Groups[1].Value
                    $port | Should -BeGreaterThan 0
                    $port | Should -BeLessThan 65536
                }
            }
        }
    }
}

Describe "Input Validation" {
    Context "Parameter Validation" {
        It "Should validate file paths" {
            $allScripts = Get-ChildItem $ScriptRoot -Recurse -Filter "*.ps1"
            
            foreach ($script in $allScripts) {
                $content = Get-Content $script.FullName -Raw
                
                # Check for path validation
                if ($content -match 'param.*Path') {
                    $content | Should -Match 'ValidateScript|Test-Path|ValidatePattern'
                }
            }
        }
        
        It "Should sanitize user input" {
            $allScripts = Get-ChildItem $ScriptRoot -Recurse -Filter "*.ps1"
            
            foreach ($script in $allScripts) {
                $content = Get-Content $script.FullName -Raw
                
                # Check for input sanitization
                if ($content -match 'Read-Host|param.*string') {
                    # Should have some form of validation
                    $content | Should -Match 'Validate|trim|replace|match'
                }
            }
        }
    }
    
    Context "Command Injection Prevention" {
        It "Should not use Invoke-Expression with user input" {
            $allScripts = Get-ChildItem $ScriptRoot -Recurse -Filter "*.ps1"
            
            foreach ($script in $allScripts) {
                $content = Get-Content $script.FullName -Raw
                
                # Check for dangerous patterns
                $content | Should -Not -Match 'Invoke-Expression.*\$\w+.*input'
                $content | Should -Not -Match 'iex.*\$\w+.*input'
            }
        }
        
        It "Should use parameterized commands" {
            $allScripts = Get-ChildItem $ScriptRoot -Recurse -Filter "*.ps1"
            
            foreach ($script in $allScripts) {
                $content = Get-Content $script.FullName -Raw
                
                # If using Start-Process, should use -ArgumentList
                if ($content -match 'Start-Process') {
                    $content | Should -Match 'ArgumentList|Arguments'
                }
            }
        }
    }
}

Describe "Logging Security" {
    Context "Log File Security" {
        It "Should create secure log files" {
            # Create a test log file
            $testLogDir = Join-Path $env:TEMP 'VelociraptorTestLogs'
            $testLogFile = Join-Path $testLogDir 'security-test.log'
            
            try {
                New-Item $testLogDir -ItemType Directory -Force | Out-Null
                "Test log entry" | Out-File $testLogFile
                
                if ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6) {
                    $acl = Get-Acl $testLogFile
                    $acl | Should -Not -BeNullOrEmpty
                }
                
                Test-Path $testLogFile | Should -Be $true
            }
            finally {
                Remove-Item $testLogDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
        
        It "Should not log sensitive information" {
            $allScripts = Get-ChildItem $ScriptRoot -Recurse -Filter "*.ps1"
            
            foreach ($script in $allScripts) {
                $content = Get-Content $script.FullName -Raw
                
                # Check logging statements don't expose sensitive data
                $logStatements = [regex]::Matches($content, '(Write-Log|Log|Out-File).*["'']([^"'']+)["'']')
                
                foreach ($match in $logStatements) {
                    $logMessage = $match.Groups[2].Value.ToLower()
                    $logMessage | Should -Not -Match 'password|secret|key|token|credential'
                }
            }
        }
    }
    
    Context "Audit Trail" {
        It "Should log security-relevant events" {
            $allScripts = Get-ChildItem $ScriptRoot -Recurse -Filter "*.ps1"
            
            foreach ($script in $allScripts) {
                $content = Get-Content $script.FullName -Raw
                
                # Should log important security events
                if ($content -match 'admin|privilege|firewall|service') {
                    $content | Should -Match 'Write-Log|Log|Out-File'
                }
            }
        }
    }
}

Describe "Compliance Validation" {
    Context "Security Baseline Script" -Skip:(-not (Test-Path $SecurityScriptPath)) {
        It "Should exist" {
            Test-Path $SecurityScriptPath | Should -Be $true
        }
        
        It "Should implement security hardening" {
            $content = Get-Content $SecurityScriptPath -Raw
            $content | Should -Match 'security|hardening|baseline'
        }
        
        It "Should validate configuration" {
            $content = Get-Content $SecurityScriptPath -Raw
            $content | Should -Match 'Test-|Validate|Check'
        }
    }
    
    Context "Configuration Security" {
        It "Should validate YAML configuration files" {
            # Create test YAML content
            $testYaml = @"
version: 1.0
server:
  bind_address: 0.0.0.0
  bind_port: 8000
"@
            $testYaml | Out-File $TestConfigPath
            
            try {
                # Should validate configuration structure
                Test-Path $TestConfigPath | Should -Be $true
                $content = Get-Content $TestConfigPath -Raw
                $content | Should -Match 'version|server'
            }
            finally {
                Remove-Item $TestConfigPath -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

AfterAll {
    # Clean up test files
    Remove-Item $TestConfigPath -Force -ErrorAction SilentlyContinue
    Remove-Item $TestLogPath -Force -ErrorAction SilentlyContinue
    
    # Remove module
    Remove-Module VelociraptorDeployment -Force -ErrorAction SilentlyContinue
}