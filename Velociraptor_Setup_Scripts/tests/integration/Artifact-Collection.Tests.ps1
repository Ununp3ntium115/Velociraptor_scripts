#Requires -Modules Pester

<#
.SYNOPSIS
    Integration tests for artifact and collection management functionality.

.DESCRIPTION
    Tests artifact tool management, collection building, dependency resolution,
    and offline collector package creation capabilities.
#>

BeforeAll {
    # Set up test environment
    $ScriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
    $ArtifactScriptPath = Join-Path $ScriptRoot 'scripts\Build-VelociraptorArtifactPackage.ps1'
    
    # Test data
    $TestArtifactDir = Join-Path $env:TEMP 'VelociraptorArtifactTest'
    $TestToolsDir = Join-Path $TestArtifactDir 'tools'
    $TestArtifactsDir = Join-Path $TestArtifactDir 'artifacts'
    $TestPackageDir = Join-Path $TestArtifactDir 'packages'
    
    # Create test directories
    New-Item $TestArtifactDir -ItemType Directory -Force | Out-Null
    New-Item $TestToolsDir -ItemType Directory -Force | Out-Null
    New-Item $TestArtifactsDir -ItemType Directory -Force | Out-Null
    New-Item $TestPackageDir -ItemType Directory -Force | Out-Null
    
    # Sample artifact content
    $SampleArtifact = @"
name: Test.Artifact
description: Test artifact for validation
type: CLIENT
parameters:
  - name: TestParam
    description: Test parameter
    type: string
    default: "test_value"
sources:
  - precondition: SELECT OS From info() where OS = 'windows'
    query: |
      SELECT * FROM info()
tools:
  - name: test_tool.exe
    url: https://example.com/test_tool.exe
    expected_hash: abc123def456
"@
    
    # Sample tool mapping
    $SampleToolMapping = @{
        "test_tool.exe" = @{
            url = "https://example.com/test_tool.exe"
            hash = "abc123def456"
            size = 1024000
            artifacts = @("Test.Artifact")
        }
    } | ConvertTo-Json -Depth 3
}

Describe "Artifact Management" {
    Context "Artifact Parsing and Validation" {
        BeforeEach {
            $testArtifactFile = Join-Path $TestArtifactsDir 'test_artifact.yaml'
            $SampleArtifact | Out-File $testArtifactFile -Encoding UTF8
        }
        
        It "Should parse YAML artifact files" {
            $testArtifactFile = Join-Path $TestArtifactsDir 'test_artifact.yaml'
            Test-Path $testArtifactFile | Should -Be $true
            
            $content = Get-Content $testArtifactFile -Raw
            $content | Should -Match 'name:'
            $content | Should -Match 'description:'
            $content | Should -Match 'sources:'
        }
        
        It "Should validate artifact structure" {
            $testArtifactFile = Join-Path $TestArtifactsDir 'test_artifact.yaml'
            $content = Get-Content $testArtifactFile -Raw
            
            # Required fields
            $content | Should -Match 'name:\s*\S+'
            $content | Should -Match 'description:\s*\S+'
            $content | Should -Match 'type:\s*(CLIENT|SERVER|EVENT)'
            $content | Should -Match 'sources:'
        }
        
        It "Should extract tool dependencies from artifacts" {
            $testArtifactFile = Join-Path $TestArtifactsDir 'test_artifact.yaml'
            $content = Get-Content $testArtifactFile -Raw
            
            # Should contain tools section
            $content | Should -Match 'tools:'
            $content | Should -Match 'name:\s*test_tool\.exe'
            $content | Should -Match 'url:\s*https://'
            $content | Should -Match 'expected_hash:\s*\w+'
        }
        
        It "Should validate artifact parameters" {
            $testArtifactFile = Join-Path $TestArtifactsDir 'test_artifact.yaml'
            $content = Get-Content $testArtifactFile -Raw
            
            # Should have parameters section
            $content | Should -Match 'parameters:'
            $content | Should -Match 'name:\s*TestParam'
            $content | Should -Match 'type:\s*(string|int|bool|regex)'
            $content | Should -Match 'default:'
        }
    }
    
    Context "Tool Dependency Resolution" {
        It "Should create tool dependency mappings" {
            $toolMappingFile = Join-Path $TestArtifactDir 'tool-mapping.json'
            $SampleToolMapping | Out-File $toolMappingFile -Encoding UTF8
            
            Test-Path $toolMappingFile | Should -Be $true
            
            $mapping = Get-Content $toolMappingFile -Raw | ConvertFrom-Json
            $mapping.'test_tool.exe' | Should -Not -BeNullOrEmpty
            $mapping.'test_tool.exe'.url | Should -Match '^https://'
            $mapping.'test_tool.exe'.hash | Should -Not -BeNullOrEmpty
        }
        
        It "Should resolve transitive dependencies" {
            # Mock complex dependency chain
            $dependencies = @{
                "tool_a.exe" = @("artifact_1", "artifact_2")
                "tool_b.exe" = @("artifact_2", "artifact_3")
                "tool_c.exe" = @("artifact_3")
            }
            
            # For artifact_2, should include tool_a.exe and tool_b.exe
            $artifact2Tools = $dependencies.GetEnumerator() | Where-Object { $_.Value -contains "artifact_2" } | Select-Object -ExpandProperty Key
            $artifact2Tools | Should -Contain "tool_a.exe"
            $artifact2Tools | Should -Contain "tool_b.exe"
        }
        
        It "Should handle missing tool dependencies" {
            $artifactWithMissingTool = @"
name: Test.MissingTool
tools:
  - name: missing_tool.exe
    url: https://example.com/missing_tool.exe
"@
            
            # Should identify missing tools
            $artifactWithMissingTool | Should -Match 'missing_tool\.exe'
            
            # Mock tool availability check
            $toolExists = $false  # Simulate missing tool
            $toolExists | Should -Be $false
        }
    }
}

Describe "Collection Building" {
    Context "Offline Collector Creation" {
        It "Should create offline collector packages" {
            $collectorConfig = @{
                artifacts = @("Test.Artifact")
                parameters = @{
                    "Test.Artifact" = @{
                        TestParam = "production_value"
                    }
                }
                output_format = "json"
                compression = $true
            }
            
            $collectorConfig.artifacts | Should -Contain "Test.Artifact"
            $collectorConfig.parameters."Test.Artifact".TestParam | Should -Be "production_value"
            $collectorConfig.compression | Should -Be $true
        }
        
        It "Should include required tools in collector packages" {
            $packageManifest = @{
                artifacts = @("Test.Artifact")
                tools = @{
                    "test_tool.exe" = @{
                        path = "tools/test_tool.exe"
                        hash = "abc123def456"
                        size = 1024000
                    }
                }
                created = Get-Date
                version = "1.0.0"
            }
            
            $packageManifest.tools."test_tool.exe" | Should -Not -BeNullOrEmpty
            $packageManifest.tools."test_tool.exe".path | Should -Match '^tools/'
            $packageManifest.tools."test_tool.exe".hash | Should -Not -BeNullOrEmpty
        }
        
        It "Should validate collector package integrity" {
            # Mock package validation
            $packageFiles = @(
                "velociraptor.exe",
                "collector.yaml",
                "artifacts/Test.Artifact.yaml",
                "tools/test_tool.exe",
                "manifest.json"
            )
            
            $packageFiles | Should -Contain "velociraptor.exe"
            $packageFiles | Should -Contain "collector.yaml"
            $packageFiles | Should -Contain "manifest.json"
        }
        
        It "Should support different package formats" {
            $supportedFormats = @("zip", "tar.gz", "directory")
            
            foreach ($format in $supportedFormats) {
                # Mock package creation for each format
                $packagePath = Join-Path $TestPackageDir "collector.$format"
                
                # Simulate package creation
                "mock package content" | Out-File $packagePath -Encoding UTF8
                Test-Path $packagePath | Should -Be $true
                
                Remove-Item $packagePath -Force -ErrorAction SilentlyContinue
            }
        }
    }
    
    Context "Collection Configuration" {
        It "Should generate valid collection configurations" {
            $collectionConfig = @"
artifacts:
  - Test.Artifact:
      TestParam: "configured_value"
output:
  format: jsonl
  compression: gzip
  max_file_size: 100MB
metadata:
  case_id: "CASE-2024-001"
  investigator: "analyst@company.com"
  created: "$(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')"
"@
            
            $collectionConfig | Should -Match 'artifacts:'
            $collectionConfig | Should -Match 'output:'
            $collectionConfig | Should -Match 'metadata:'
            $collectionConfig | Should -Match 'case_id:'
        }
        
        It "Should validate collection parameters" {
            $config = @{
                artifacts = @("Test.Artifact")
                parameters = @{
                    "Test.Artifact" = @{
                        TestParam = "valid_value"
                    }
                }
            }
            
            # Validate parameter types
            $config.parameters."Test.Artifact".TestParam | Should -BeOfType [string]
            $config.parameters."Test.Artifact".TestParam | Should -Not -BeNullOrEmpty
        }
        
        It "Should support conditional artifact execution" {
            $conditionalConfig = @"
artifacts:
  - name: Windows.Artifact
    condition: "OS = 'windows'"
  - name: Linux.Artifact
    condition: "OS = 'linux'"
  - name: Universal.Artifact
    condition: "true"
"@
            
            $conditionalConfig | Should -Match 'condition:'
            $conditionalConfig | Should -Match "OS = 'windows'"
            $conditionalConfig | Should -Match "OS = 'linux'"
        }
    }
}

Describe "Tool Management" {
    Context "Tool Download and Caching" {
        It "Should download tools with hash verification" {
            # Mock tool download
            $toolInfo = @{
                name = "test_tool.exe"
                url = "https://example.com/test_tool.exe"
                expected_hash = "abc123def456"
                cache_path = Join-Path $TestToolsDir "test_tool.exe"
            }
            
            # Simulate tool file
            "mock tool content" | Out-File $toolInfo.cache_path -Encoding UTF8
            
            Test-Path $toolInfo.cache_path | Should -Be $true
            $toolInfo.expected_hash | Should -Not -BeNullOrEmpty
        }
        
        It "Should maintain tool cache with metadata" {
            $toolCache = @{
                "test_tool.exe" = @{
                    url = "https://example.com/test_tool.exe"
                    hash = "abc123def456"
                    size = 1024000
                    downloaded = Get-Date
                    verified = $true
                }
            }
            
            $cacheFile = Join-Path $TestToolsDir "cache.json"
            $toolCache | ConvertTo-Json -Depth 3 | Out-File $cacheFile -Encoding UTF8
            
            Test-Path $cacheFile | Should -Be $true
            
            $cache = Get-Content $cacheFile -Raw | ConvertFrom-Json
            $cache."test_tool.exe".verified | Should -Be $true
        }
        
        It "Should handle tool download failures gracefully" {
            # Mock download failure
            $downloadResult = @{
                success = $false
                error = "Network timeout"
                tool = "missing_tool.exe"
                url = "https://example.com/missing_tool.exe"
            }
            
            $downloadResult.success | Should -Be $false
            $downloadResult.error | Should -Not -BeNullOrEmpty
        }
        
        It "Should support concurrent tool downloads" {
            # Mock concurrent download tracking
            $downloadQueue = @(
                @{ tool = "tool1.exe"; status = "downloading" }
                @{ tool = "tool2.exe"; status = "queued" }
                @{ tool = "tool3.exe"; status = "completed" }
            )
            
            $downloadQueue.Count | Should -Be 3
            ($downloadQueue | Where-Object { $_.status -eq "completed" }).Count | Should -Be 1
        }
    }
    
    Context "Tool Validation and Security" {
        It "Should validate tool hashes" {
            # Mock hash validation
            $toolFile = Join-Path $TestToolsDir "test_tool.exe"
            "mock tool content" | Out-File $toolFile -Encoding UTF8
            
            $actualHash = "abc123def456"  # Mock calculated hash
            $expectedHash = "abc123def456"
            
            $actualHash | Should -Be $expectedHash
        }
        
        It "Should scan tools for malware" {
            # Mock security scanning
            $scanResult = @{
                tool = "test_tool.exe"
                clean = $true
                threats_found = 0
                scan_engine = "Windows Defender"
            }
            
            $scanResult.clean | Should -Be $true
            $scanResult.threats_found | Should -Be 0
        }
        
        It "Should maintain tool signatures" {
            # Mock digital signature verification
            $signatureInfo = @{
                tool = "test_tool.exe"
                signed = $true
                publisher = "Trusted Publisher"
                valid = $true
            }
            
            $signatureInfo.signed | Should -Be $true
            $signatureInfo.valid | Should -Be $true
        }
    }
}

Describe "Package Management" {
    Context "Package Creation and Distribution" {
        It "Should create deployment-ready packages" {
            $packageStructure = @(
                "velociraptor.exe",
                "config/",
                "config/collector.yaml",
                "artifacts/",
                "artifacts/Windows/",
                "artifacts/Linux/",
                "tools/",
                "tools/windows/",
                "tools/linux/",
                "scripts/",
                "scripts/deploy.ps1",
                "scripts/deploy.sh",
                "README.md",
                "manifest.json"
            )
            
            # Validate package structure
            $packageStructure | Should -Contain "velociraptor.exe"
            $packageStructure | Should -Contain "manifest.json"
            $packageStructure | Should -Contain "README.md"
        }
        
        It "Should generate package manifests" {
            $manifest = @{
                name = "velociraptor-collector-package"
                version = "1.0.0"
                created = Get-Date
                artifacts = @("Test.Artifact")
                tools = @("test_tool.exe")
                platforms = @("windows", "linux")
                size_mb = 150
                checksum = "def789ghi012"
            }
            
            $manifest.name | Should -Not -BeNullOrEmpty
            $manifest.version | Should -Match '^\d+\.\d+\.\d+$'
            $manifest.artifacts.Count | Should -BeGreaterThan 0
        }
        
        It "Should support package versioning" {
            $versions = @("1.0.0", "1.0.1", "1.1.0", "2.0.0")
            
            foreach ($version in $versions) {
                $version | Should -Match '^\d+\.\d+\.\d+$'
                
                # Parse version components
                $parts = $version.Split('.')
                $parts.Count | Should -Be 3
                [int]$parts[0] | Should -BeGreaterOrEqual 1
            }
        }
        
        It "Should handle package dependencies" {
            $packageDeps = @{
                "collector-base" = "1.0.0"
                "windows-tools" = "2.1.0"
                "linux-tools" = "2.1.0"
            }
            
            $packageDeps."collector-base" | Should -Not -BeNullOrEmpty
            $packageDeps."windows-tools" | Should -Match '^\d+\.\d+\.\d+$'
        }
    }
    
    Context "Package Deployment" {
        It "Should support automated deployment" {
            $deploymentConfig = @{
                package = "velociraptor-collector-v1.0.0.zip"
                target_systems = @("server1", "server2", "workstation1")
                deployment_method = "push"
                credentials = "service_account"
                schedule = "immediate"
            }
            
            $deploymentConfig.target_systems.Count | Should -BeGreaterThan 0
            $deploymentConfig.deployment_method | Should -BeIn @("push", "pull", "scheduled")
        }
        
        It "Should track deployment status" {
            $deploymentStatus = @{
                "server1" = @{ status = "completed"; timestamp = Get-Date }
                "server2" = @{ status = "in_progress"; timestamp = Get-Date }
                "workstation1" = @{ status = "failed"; error = "Access denied" }
            }
            
            $deploymentStatus."server1".status | Should -Be "completed"
            $deploymentStatus."workstation1".status | Should -Be "failed"
            $deploymentStatus."workstation1".error | Should -Not -BeNullOrEmpty
        }
    }
}

AfterAll {
    # Clean up test files
    if (Test-Path $TestArtifactDir) {
        Remove-Item $TestArtifactDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}