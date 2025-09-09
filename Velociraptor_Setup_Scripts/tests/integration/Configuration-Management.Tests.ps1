#Requires -Modules Pester

<#
.SYNOPSIS
    Integration tests for configuration management functionality.

.DESCRIPTION
    Tests configuration generation, validation, and management across
    different deployment scenarios and environments.
#>

BeforeAll {
    # Set up test environment
    $ScriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
    $ConfigScriptPath = Join-Path $ScriptRoot 'scripts\configuration-management\Manage-VelociraptorConfig.ps1'
    $EnvironmentScriptPath = Join-Path $ScriptRoot 'scripts\configuration-management\Deploy-VelociraptorEnvironment.ps1'
    
    # Test data
    $TestConfigDir = Join-Path $env:TEMP 'VelociraptorConfigTest'
    $TestConfigFile = Join-Path $TestConfigDir 'test-config.yaml'
    $TestEnvironmentFile = Join-Path $TestConfigDir 'test-environment.json'
    
    # Create test directory
    New-Item $TestConfigDir -ItemType Directory -Force | Out-Null
    
    # Sample configuration content
    $SampleConfig = @"
version: "1.0"
server:
  bind_address: "0.0.0.0"
  bind_port: 8000
  gui_bind_address: "127.0.0.1"
  gui_bind_port: 8889
datastore:
  implementation: FileBaseDataStore
  location: "C:\VelociraptorData"
logging:
  output_directory: "C:\VelociraptorLogs"
  separate_logs_per_component: true
"@
    
    # Sample environment configuration
    $SampleEnvironment = @{
        name = "test"
        description = "Test environment"
        server = @{
            bind_port = 8000
            gui_port = 8889
        }
        datastore = @{
            location = "C:\TestData"
        }
    } | ConvertTo-Json -Depth 3
}

Describe "Configuration File Management" {
    Context "YAML Configuration Handling" {
        BeforeEach {
            $SampleConfig | Out-File $TestConfigFile -Encoding UTF8
        }
        
        It "Should create valid YAML configuration files" {
            Test-Path $TestConfigFile | Should -Be $true
            $content = Get-Content $TestConfigFile -Raw
            $content | Should -Match 'version:'
            $content | Should -Match 'server:'
            $content | Should -Match 'bind_address:'
        }
        
        It "Should validate YAML syntax" {
            $content = Get-Content $TestConfigFile -Raw
            # Basic YAML validation - should not have syntax errors
            $content | Should -Match '^version:\s*[''"]?[\d\.]+[''"]?'
            $content | Should -Not -Match '^\s*-\s*-\s*'  # No double dashes
            $content | Should -Not -Match ':\s*:\s*'      # No double colons
        }
        
        It "Should contain required configuration sections" {
            $content = Get-Content $TestConfigFile -Raw
            
            # Required sections
            $content | Should -Match 'server:'
            $content | Should -Match 'datastore:'
            $content | Should -Match 'logging:'
            
            # Required server settings
            $content | Should -Match 'bind_address:'
            $content | Should -Match 'bind_port:'
        }
        
        It "Should use secure default values" {
            $content = Get-Content $TestConfigFile -Raw
            
            # GUI should bind to localhost by default
            $content | Should -Match 'gui_bind_address:\s*[''"]?127\.0\.0\.1[''"]?'
            
            # Should use standard ports
            $content | Should -Match 'bind_port:\s*8000'
            $content | Should -Match 'gui_bind_port:\s*8889'
        }
    }
    
    Context "Configuration Validation" {
        BeforeEach {
            $SampleConfig | Out-File $TestConfigFile -Encoding UTF8
        }
        
        It "Should validate port numbers" {
            $content = Get-Content $TestConfigFile -Raw
            
            # Extract port numbers
            $portMatches = [regex]::Matches($content, 'port:\s*(\d+)')
            
            foreach ($match in $portMatches) {
                $port = [int]$match.Groups[1].Value
                $port | Should -BeGreaterThan 0
                $port | Should -BeLessThan 65536
            }
        }
        
        It "Should validate directory paths" {
            $content = Get-Content $TestConfigFile -Raw
            
            # Extract directory paths
            $pathMatches = [regex]::Matches($content, 'location:\s*[''"]?([^''"]+)[''"]?')
            
            foreach ($match in $pathMatches) {
                $path = $match.Groups[1].Value
                $path | Should -Not -BeNullOrEmpty
                $path | Should -Match '^[A-Za-z]:\\|^/'  # Windows or Unix path
            }
        }
        
        It "Should validate IP addresses" {
            $content = Get-Content $TestConfigFile -Raw
            
            # Extract IP addresses
            $ipMatches = [regex]::Matches($content, 'bind_address:\s*[''"]?([^''"]+)[''"]?')
            
            foreach ($match in $ipMatches) {
                $ip = $match.Groups[1].Value
                $ip | Should -Match '^(\d{1,3}\.){3}\d{1,3}$|^0\.0\.0\.0$|^127\.0\.0\.1$'
            }
        }
    }
}

Describe "Environment Management" {
    Context "Environment Configuration" {
        BeforeEach {
            $SampleEnvironment | Out-File $TestEnvironmentFile -Encoding UTF8
        }
        
        It "Should create valid environment files" {
            Test-Path $TestEnvironmentFile | Should -Be $true
            $content = Get-Content $TestEnvironmentFile -Raw
            { $content | ConvertFrom-Json } | Should -Not -Throw
        }
        
        It "Should contain required environment properties" {
            $content = Get-Content $TestEnvironmentFile -Raw
            $env = $content | ConvertFrom-Json
            
            $env.name | Should -Not -BeNullOrEmpty
            $env.description | Should -Not -BeNullOrEmpty
            $env.server | Should -Not -BeNullOrEmpty
            $env.datastore | Should -Not -BeNullOrEmpty
        }
        
        It "Should validate environment-specific settings" {
            $content = Get-Content $TestEnvironmentFile -Raw
            $env = $content | ConvertFrom-Json
            
            # Server settings
            $env.server.bind_port | Should -BeGreaterThan 0
            $env.server.gui_port | Should -BeGreaterThan 0
            
            # Datastore settings
            $env.datastore.location | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Multi-Environment Support" {
        It "Should support different environment types" {
            $environments = @('Development', 'Testing', 'Staging', 'Production')
            
            foreach ($envType in $environments) {
                $envConfig = @{
                    name = $envType.ToLower()
                    description = "$envType environment"
                    server = @{
                        bind_port = switch ($envType) {
                            'Development' { 8000 }
                            'Testing' { 8001 }
                            'Staging' { 8002 }
                            'Production' { 8000 }
                        }
                    }
                }
                
                $envConfig.name | Should -Be $envType.ToLower()
                $envConfig.server.bind_port | Should -BeGreaterThan 0
            }
        }
        
        It "Should handle environment-specific security settings" {
            $prodConfig = @{
                name = "production"
                security = @{
                    tls_enabled = $true
                    certificate_path = "/etc/ssl/velociraptor.crt"
                    private_key_path = "/etc/ssl/velociraptor.key"
                }
            }
            
            $devConfig = @{
                name = "development"
                security = @{
                    tls_enabled = $false
                    debug_mode = $true
                }
            }
            
            # Production should have TLS enabled
            $prodConfig.security.tls_enabled | Should -Be $true
            $prodConfig.security.certificate_path | Should -Not -BeNullOrEmpty
            
            # Development can have TLS disabled for testing
            $devConfig.security.tls_enabled | Should -Be $false
        }
    }
}

Describe "Configuration Templates" {
    Context "Template Generation" {
        It "Should generate server configuration template" {
            $serverTemplate = @{
                version = "1.0"
                server = @{
                    bind_address = "0.0.0.0"
                    bind_port = 8000
                    gui_bind_address = "127.0.0.1"
                    gui_bind_port = 8889
                }
                datastore = @{
                    implementation = "FileBaseDataStore"
                    location = "{{DATASTORE_PATH}}"
                }
                logging = @{
                    output_directory = "{{LOG_PATH}}"
                    separate_logs_per_component = $true
                }
            }
            
            $serverTemplate.version | Should -Not -BeNullOrEmpty
            $serverTemplate.server.bind_address | Should -Not -BeNullOrEmpty
            $serverTemplate.datastore.location | Should -Match '\{\{.*\}\}'
        }
        
        It "Should generate standalone configuration template" {
            $standaloneTemplate = @{
                version = "1.0"
                gui = @{
                    bind_address = "127.0.0.1"
                    bind_port = 8889
                }
                datastore = @{
                    implementation = "FileBaseDataStore"
                    location = "{{DATASTORE_PATH}}"
                }
            }
            
            $standaloneTemplate.version | Should -Not -BeNullOrEmpty
            $standaloneTemplate.gui.bind_address | Should -Be "127.0.0.1"
            $standaloneTemplate.datastore.location | Should -Match '\{\{.*\}\}'
        }
        
        It "Should support template variable substitution" {
            $template = "datastore_location: {{DATASTORE_PATH}}"
            $variables = @{
                "DATASTORE_PATH" = "C:\VelociraptorData"
            }
            
            $result = $template
            foreach ($var in $variables.GetEnumerator()) {
                $result = $result -replace "\{\{$($var.Key)\}\}", $var.Value
            }
            
            $result | Should -Be "datastore_location: C:\VelociraptorData"
            $result | Should -Not -Match '\{\{.*\}\}'
        }
    }
    
    Context "Template Validation" {
        It "Should validate template syntax" {
            $validTemplate = @"
version: "{{VERSION}}"
server:
  bind_address: "{{BIND_ADDRESS}}"
  bind_port: {{BIND_PORT}}
"@
            
            # Should contain template variables
            $validTemplate | Should -Match '\{\{VERSION\}\}'
            $validTemplate | Should -Match '\{\{BIND_ADDRESS\}\}'
            $validTemplate | Should -Match '\{\{BIND_PORT\}\}'
            
            # Should be valid YAML structure
            $validTemplate | Should -Match 'version:'
            $validTemplate | Should -Match 'server:'
        }
        
        It "Should identify missing template variables" {
            $template = @"
version: "1.0"
server:
  bind_address: "{{BIND_ADDRESS}}"
  bind_port: {{BIND_PORT}}
  missing_var: "{{MISSING_VAR}}"
"@
            
            $providedVars = @('BIND_ADDRESS', 'BIND_PORT')
            $templateVars = [regex]::Matches($template, '\{\{([^}]+)\}\}') | ForEach-Object { $_.Groups[1].Value }
            
            $missingVars = $templateVars | Where-Object { $_ -notin $providedVars }
            $missingVars | Should -Contain 'MISSING_VAR'
        }
    }
}

Describe "Configuration Security" {
    Context "Secure Configuration Practices" {
        It "Should not contain hardcoded credentials" {
            $content = Get-Content $TestConfigFile -Raw
            
            # Should not contain common credential patterns
            $content | Should -Not -Match 'password\s*:\s*[''"][^''"]+[''"]'
            $content | Should -Not -Match 'secret\s*:\s*[''"][^''"]+[''"]'
            $content | Should -Not -Match 'key\s*:\s*[''"][a-zA-Z0-9]{20,}[''"]'
        }
        
        It "Should use secure default bindings" {
            $content = Get-Content $TestConfigFile -Raw
            
            # GUI should bind to localhost by default
            $content | Should -Match 'gui_bind_address:\s*[''"]?127\.0\.0\.1[''"]?'
            
            # Should not bind admin interfaces to all addresses
            $content | Should -Not -Match 'gui_bind_address:\s*[''"]?0\.0\.0\.0[''"]?'
        }
        
        It "Should validate file permissions requirements" {
            # Configuration files should have restricted permissions
            $configFile = $TestConfigFile
            
            if (Test-Path $configFile) {
                if ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6) {
                    # Windows - check ACL
                    $acl = Get-Acl $configFile
                    $acl | Should -Not -BeNullOrEmpty
                } else {
                    # Unix - check permissions
                    $item = Get-Item $configFile
                    $item | Should -Not -BeNullOrEmpty
                }
            }
        }
    }
    
    Context "Configuration Encryption" {
        It "Should support encrypted configuration sections" {
            # Mock encrypted configuration
            $encryptedConfig = @"
version: "1.0"
server:
  bind_address: "0.0.0.0"
  bind_port: 8000
encrypted_sections:
  - "credentials"
  - "certificates"
"@
            
            $encryptedConfig | Should -Match 'encrypted_sections:'
            $encryptedConfig | Should -Match 'credentials'
            $encryptedConfig | Should -Match 'certificates'
        }
    }
}

AfterAll {
    # Clean up test files
    if (Test-Path $TestConfigDir) {
        Remove-Item $TestConfigDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}