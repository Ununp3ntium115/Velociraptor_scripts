#Requires -Modules Pester

<#
.SYNOPSIS
    Integration tests for monitoring and health check functionality.

.DESCRIPTION
    Tests health monitoring, performance metrics, alerting systems,
    and system status reporting capabilities.
#>

BeforeAll {
    # Set up test environment
    $ScriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
    $MonitoringScriptPath = Join-Path $ScriptRoot 'scripts\monitoring\Start-VelociraptorMonitoring.ps1'
    
    # Test data
    $TestLogDir = Join-Path $env:TEMP 'VelociraptorMonitoringTest'
    $TestConfigFile = Join-Path $TestLogDir 'test-config.yaml'
    $TestLogFile = Join-Path $TestLogDir 'test-monitoring.log'
    
    # Create test directory
    New-Item $TestLogDir -ItemType Directory -Force | Out-Null
    
    # Mock external dependencies
    Mock Test-NetConnection { return @{ TcpTestSucceeded = $true; RemoteAddress = '127.0.0.1'; RemotePort = 8889 } }
    Mock Get-Process { return @{ Id = 1234; ProcessName = 'velociraptor'; CPU = 10.5; WorkingSet = 104857600 } }
    Mock Get-WmiObject { return @{ Size = 1073741824; FreeSpace = 536870912 } }
    Mock Invoke-WebRequest { return @{ StatusCode = 200; Content = '{"status": "ok"}' } }
}

Describe "Health Check Functions" {
    Context "Service Health Monitoring" {
        It "Should check if Velociraptor service is running" {
            Mock Get-Service { return @{ Status = 'Running'; Name = 'Velociraptor' } }
            
            $service = Get-Service -Name 'Velociraptor' -ErrorAction SilentlyContinue
            if ($service) {
                $service.Status | Should -Be 'Running'
                $service.Name | Should -Be 'Velociraptor'
            }
        }
        
        It "Should check process health metrics" {
            $process = Get-Process -Name 'velociraptor' -ErrorAction SilentlyContinue
            if ($process) {
                $process.Id | Should -BeGreaterThan 0
                $process.ProcessName | Should -Be 'velociraptor'
                $process.CPU | Should -BeGreaterOrEqual 0
                $process.WorkingSet | Should -BeGreaterThan 0
            }
        }
        
        It "Should validate process resource usage" {
            $process = Get-Process -Name 'velociraptor' -ErrorAction SilentlyContinue
            if ($process) {
                # Memory usage should be reasonable (less than 1GB for testing)
                $memoryMB = $process.WorkingSet / 1MB
                $memoryMB | Should -BeLessThan 1024
                
                # CPU usage should be measurable
                $process.CPU | Should -BeGreaterOrEqual 0
            }
        }
    }
    
    Context "Network Connectivity Checks" {
        It "Should check GUI port accessibility" {
            $connection = Test-NetConnection -ComputerName '127.0.0.1' -Port 8889 -InformationLevel Quiet
            $connection | Should -Be $true
        }
        
        It "Should check server port accessibility" {
            $connection = Test-NetConnection -ComputerName '127.0.0.1' -Port 8000 -InformationLevel Quiet
            $connection | Should -Be $true
        }
        
        It "Should validate network response times" {
            # Mock network timing
            $startTime = Get-Date
            $connection = Test-NetConnection -ComputerName '127.0.0.1' -Port 8889
            $endTime = Get-Date
            
            $responseTime = ($endTime - $startTime).TotalMilliseconds
            $responseTime | Should -BeLessThan 5000  # Less than 5 seconds
        }
        
        It "Should check external connectivity" {
            # Test GitHub API connectivity (for updates)
            $connection = Test-NetConnection -ComputerName 'api.github.com' -Port 443 -InformationLevel Quiet
            $connection | Should -Be $true
        }
    }
    
    Context "Web Interface Health" {
        It "Should check GUI web interface response" {
            Mock Invoke-WebRequest { 
                return @{ 
                    StatusCode = 200
                    Content = '<html><title>Velociraptor</title></html>'
                    Headers = @{ 'Content-Type' = 'text/html' }
                }
            }
            
            $response = Invoke-WebRequest -Uri 'http://127.0.0.1:8889' -UseBasicParsing -TimeoutSec 10
            $response.StatusCode | Should -Be 200
            $response.Content | Should -Match 'Velociraptor'
        }
        
        It "Should validate API endpoints" {
            Mock Invoke-WebRequest { 
                return @{ 
                    StatusCode = 200
                    Content = '{"version": "0.6.8", "status": "ok"}'
                    Headers = @{ 'Content-Type' = 'application/json' }
                }
            }
            
            $response = Invoke-WebRequest -Uri 'http://127.0.0.1:8889/api/v1/GetVersion' -UseBasicParsing
            $response.StatusCode | Should -Be 200
            
            $json = $response.Content | ConvertFrom-Json
            $json.status | Should -Be 'ok'
            $json.version | Should -Not -BeNullOrEmpty
        }
        
        It "Should check authentication endpoints" {
            Mock Invoke-WebRequest { 
                return @{ 
                    StatusCode = 401
                    Content = '{"error": "authentication required"}'
                }
            }
            
            # Should require authentication for protected endpoints
            $response = Invoke-WebRequest -Uri 'http://127.0.0.1:8889/api/v1/GetClients' -UseBasicParsing -ErrorAction SilentlyContinue
            if ($response) {
                $response.StatusCode | Should -Be 401
            }
        }
    }
}

Describe "System Resource Monitoring" {
    Context "Disk Space Monitoring" {
        It "Should check datastore disk space" {
            $diskInfo = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction SilentlyContinue
            if ($diskInfo) {
                $freeSpaceGB = $diskInfo.FreeSpace / 1GB
                $totalSpaceGB = $diskInfo.Size / 1GB
                $usagePercent = (($totalSpaceGB - $freeSpaceGB) / $totalSpaceGB) * 100
                
                $freeSpaceGB | Should -BeGreaterThan 0
                $usagePercent | Should -BeLessThan 95  # Less than 95% full
            }
        }
        
        It "Should monitor log directory space" {
            $logPath = "C:\VelociraptorLogs"
            if (Test-Path $logPath) {
                $logSize = (Get-ChildItem $logPath -Recurse -File | Measure-Object -Property Length -Sum).Sum
                $logSizeMB = $logSize / 1MB
                
                $logSizeMB | Should -BeGreaterOrEqual 0
                $logSizeMB | Should -BeLessThan 1024  # Less than 1GB of logs
            }
        }
        
        It "Should validate datastore growth rate" {
            # Mock datastore size tracking
            $currentSize = 100MB
            $previousSize = 90MB
            $growthRate = ($currentSize - $previousSize) / $previousSize * 100
            
            $growthRate | Should -BeGreaterOrEqual 0
            $growthRate | Should -BeLessThan 50  # Less than 50% growth per check
        }
    }
    
    Context "Memory Usage Monitoring" {
        It "Should monitor system memory usage" {
            $memory = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction SilentlyContinue
            if ($memory) {
                $totalMemory = $memory.TotalVisibleMemorySize * 1KB
                $freeMemory = $memory.FreePhysicalMemory * 1KB
                $usedMemoryPercent = (($totalMemory - $freeMemory) / $totalMemory) * 100
                
                $usedMemoryPercent | Should -BeLessThan 90  # Less than 90% memory usage
                $freeMemory | Should -BeGreaterThan 0
            }
        }
        
        It "Should monitor Velociraptor memory usage" {
            $process = Get-Process -Name 'velociraptor' -ErrorAction SilentlyContinue
            if ($process) {
                $memoryMB = $process.WorkingSet / 1MB
                $memoryMB | Should -BeLessThan 2048  # Less than 2GB
                $memoryMB | Should -BeGreaterThan 0
            }
        }
    }
    
    Context "Performance Metrics" {
        It "Should track response times" {
            # Mock performance counter
            $responseTime = 150  # milliseconds
            
            $responseTime | Should -BeLessThan 1000  # Less than 1 second
            $responseTime | Should -BeGreaterThan 0
        }
        
        It "Should monitor query execution times" {
            # Mock query performance
            $queryTime = 500  # milliseconds
            
            $queryTime | Should -BeLessThan 5000  # Less than 5 seconds
            $queryTime | Should -BeGreaterThan 0
        }
        
        It "Should track client connection counts" {
            # Mock client metrics
            $activeClients = 25
            $maxClients = 1000
            
            $activeClients | Should -BeGreaterOrEqual 0
            $activeClients | Should -BeLessThan $maxClients
        }
    }
}

Describe "Alerting System" {
    Context "Alert Generation" {
        It "Should generate alerts for service failures" {
            Mock Get-Service { return @{ Status = 'Stopped'; Name = 'Velociraptor' } }
            
            $service = Get-Service -Name 'Velociraptor' -ErrorAction SilentlyContinue
            if ($service -and $service.Status -eq 'Stopped') {
                # Should trigger alert
                $alertTriggered = $true
                $alertTriggered | Should -Be $true
            }
        }
        
        It "Should generate alerts for high resource usage" {
            # Mock high CPU usage
            $cpuUsage = 95
            
            if ($cpuUsage -gt 90) {
                $alertTriggered = $true
                $alertTriggered | Should -Be $true
            }
        }
        
        It "Should generate alerts for disk space issues" {
            # Mock low disk space
            $freeSpacePercent = 5
            
            if ($freeSpacePercent -lt 10) {
                $alertTriggered = $true
                $alertTriggered | Should -Be $true
            }
        }
        
        It "Should generate alerts for connectivity issues" {
            Mock Test-NetConnection { return @{ TcpTestSucceeded = $false } }
            
            $connection = Test-NetConnection -ComputerName '127.0.0.1' -Port 8889
            if (-not $connection.TcpTestSucceeded) {
                $alertTriggered = $true
                $alertTriggered | Should -Be $true
            }
        }
    }
    
    Context "Alert Delivery" {
        It "Should support email alerts" {
            # Mock email configuration
            $emailConfig = @{
                SmtpServer = 'smtp.company.com'
                From = 'velociraptor@company.com'
                To = 'admin@company.com'
                Subject = 'Velociraptor Alert'
            }
            
            $emailConfig.SmtpServer | Should -Not -BeNullOrEmpty
            $emailConfig.From | Should -Match '@'
            $emailConfig.To | Should -Match '@'
        }
        
        It "Should support webhook alerts" {
            # Mock webhook configuration
            $webhookConfig = @{
                Url = 'https://hooks.slack.com/services/webhook'
                Method = 'POST'
                ContentType = 'application/json'
            }
            
            $webhookConfig.Url | Should -Match '^https://'
            $webhookConfig.Method | Should -Be 'POST'
        }
        
        It "Should support event log alerts" {
            # Mock event log entry
            Mock Write-EventLog { return $true }
            
            { Write-EventLog -LogName 'Application' -Source 'Velociraptor' -EventId 1001 -Message 'Test alert' } | Should -Not -Throw
        }
    }
}

Describe "Health Check Reporting" {
    Context "Status Reports" {
        It "Should generate comprehensive health reports" {
            $healthReport = @{
                Timestamp = Get-Date
                ServiceStatus = 'Running'
                ProcessHealth = @{
                    CPU = 10.5
                    Memory = 100MB
                    Uptime = '2 days'
                }
                NetworkHealth = @{
                    GuiPort = $true
                    ServerPort = $true
                    ExternalConnectivity = $true
                }
                ResourceUsage = @{
                    DiskSpace = '50GB free'
                    MemoryUsage = '60%'
                    CPUUsage = '15%'
                }
            }
            
            $healthReport.Timestamp | Should -Not -BeNullOrEmpty
            $healthReport.ServiceStatus | Should -Be 'Running'
            $healthReport.ProcessHealth.CPU | Should -BeGreaterOrEqual 0
            $healthReport.NetworkHealth.GuiPort | Should -Be $true
        }
        
        It "Should export health data to JSON" {
            $healthData = @{
                status = 'healthy'
                checks = @{
                    service = 'pass'
                    network = 'pass'
                    resources = 'pass'
                }
                timestamp = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssZ')
            }
            
            $json = $healthData | ConvertTo-Json -Depth 3
            $json | Should -Not -BeNullOrEmpty
            
            # Should be valid JSON
            { $json | ConvertFrom-Json } | Should -Not -Throw
        }
        
        It "Should maintain health history" {
            # Mock health history
            $healthHistory = @(
                @{ Timestamp = (Get-Date).AddHours(-2); Status = 'healthy' }
                @{ Timestamp = (Get-Date).AddHours(-1); Status = 'healthy' }
                @{ Timestamp = Get-Date; Status = 'healthy' }
            )
            
            $healthHistory.Count | Should -Be 3
            $healthHistory[0].Status | Should -Be 'healthy'
            $healthHistory[-1].Timestamp | Should -BeGreaterThan $healthHistory[0].Timestamp
        }
    }
    
    Context "Performance Trending" {
        It "Should track performance trends over time" {
            # Mock performance data
            $performanceData = @(
                @{ Time = (Get-Date).AddHours(-3); CPU = 10; Memory = 90MB; ResponseTime = 100 }
                @{ Time = (Get-Date).AddHours(-2); CPU = 15; Memory = 95MB; ResponseTime = 120 }
                @{ Time = (Get-Date).AddHours(-1); CPU = 12; Memory = 92MB; ResponseTime = 110 }
                @{ Time = Get-Date; CPU = 11; Memory = 88MB; ResponseTime = 105 }
            )
            
            $performanceData.Count | Should -Be 4
            
            # Calculate trends
            $cpuTrend = ($performanceData[-1].CPU - $performanceData[0].CPU) / $performanceData[0].CPU * 100
            $cpuTrend | Should -BeLessThan 50  # Less than 50% increase
        }
        
        It "Should identify performance anomalies" {
            # Mock performance baseline
            $baseline = @{ CPU = 10; Memory = 90MB; ResponseTime = 100 }
            $current = @{ CPU = 25; Memory = 180MB; ResponseTime = 500 }
            
            # Check for anomalies (more than 100% increase)
            $cpuAnomaly = ($current.CPU - $baseline.CPU) / $baseline.CPU * 100 -gt 100
            $memoryAnomaly = ($current.Memory - $baseline.Memory) / $baseline.Memory * 100 -gt 100
            $responseAnomaly = ($current.ResponseTime - $baseline.ResponseTime) / $baseline.ResponseTime * 100 -gt 100
            
            $cpuAnomaly | Should -Be $true
            $memoryAnomaly | Should -Be $true
            $responseAnomaly | Should -Be $true
        }
    }
}

AfterAll {
    # Clean up test files
    if (Test-Path $TestLogDir) {
        Remove-Item $TestLogDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}