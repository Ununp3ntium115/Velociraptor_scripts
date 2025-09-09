# User Acceptance Testing Plan for Velociraptor Professional Suite
# Comprehensive testing framework for AMD64 Windows systems

<#
.SYNOPSIS
    User Acceptance Testing framework for Velociraptor Professional Suite
    
.DESCRIPTION
    This script provides comprehensive UAT testing for the GUI installer,
    including system compatibility, installation process, and functionality validation.
    
.PARAMETER TestType
    Type of test to run: All, SystemCheck, Installation, GUI, Functionality
    
.PARAMETER GenerateReport
    Generate detailed HTML test report
    
.EXAMPLE
    .\UAT-Testing-Plan.ps1 -TestType All -GenerateReport
#>

param(
    [ValidateSet("All", "SystemCheck", "Installation", "GUI", "Functionality")]
    [string] $TestType = "All",
    [switch] $GenerateReport,
    [string] $ReportPath = ".\UAT-Test-Report.html"
)

# Test results collection
$script:TestResults = @()
$script:TestStartTime = Get-Date

function Write-TestResult {
    param(
        [string] $TestName,
        [string] $Category,
        [bool] $Passed,
        [string] $Details = "",
        [string] $ExpectedResult = "",
        [string] $ActualResult = ""
    )
    
    $result = @{
        TestName = $TestName
        Category = $Category
        Passed = $Passed
        Status = if ($Passed) { "PASS" } else { "FAIL" }
        Details = $Details
        ExpectedResult = $ExpectedResult
        ActualResult = $ActualResult
        Timestamp = Get-Date
    }
    
    $script:TestResults += $result
    
    $color = if ($Passed) { "Green" } else { "Red" }
    $symbol = if ($Passed) { "✅" } else { "❌" }
    
    Write-Host "$symbol [$Category] $TestName - $($result.Status)" -ForegroundColor $color
    if ($Details) {
        Write-Host "   $Details" -ForegroundColor Gray
    }
}

function Test-SystemCompatibility {
    Write-Host "`n🔍 Testing System Compatibility..." -ForegroundColor Cyan
    
    # Test PowerShell version
    $psVersion = $PSVersionTable.PSVersion
    Write-TestResult -TestName "PowerShell Version Check" -Category "System" -Passed ($psVersion.Major -ge 5) -Details "Version: $psVersion" -ExpectedResult "5.1 or later" -ActualResult "$psVersion"
    
    # Test Windows version
    $osVersion = [System.Environment]::OSVersion.Version
    Write-TestResult -TestName "Windows Version Check" -Category "System" -Passed ($osVersion.Major -ge 10) -Details "Version: $osVersion" -ExpectedResult "Windows 10 or Server 2016+" -ActualResult "$osVersion"
    
    # Test architecture
    $arch = $env:PROCESSOR_ARCHITECTURE
    Write-TestResult -TestName "Architecture Check" -Category "System" -Passed ($arch -eq "AMD64") -Details "Architecture: $arch" -ExpectedResult "AMD64" -ActualResult "$arch"
    
    # Test administrator privileges
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    Write-TestResult -TestName "Administrator Privileges" -Category "System" -Passed $isAdmin -Details "Running as Admin: $isAdmin" -ExpectedResult "True" -ActualResult "$isAdmin"
    
    # Test .NET Framework
    try {
        $netVersion = Get-ItemProperty "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" -Name Release -ErrorAction Stop
        $hasNet472 = $netVersion.Release -ge 461808
        Write-TestResult -TestName ".NET Framework Check" -Category "System" -Passed $hasNet472 -Details "Release: $($netVersion.Release)" -ExpectedResult "461808+ (.NET 4.7.2)" -ActualResult "$($netVersion.Release)"
    }
    catch {
        Write-TestResult -TestName ".NET Framework Check" -Category "System" -Passed $false -Details "Could not detect .NET version" -ExpectedResult ".NET 4.7.2+" -ActualResult "Unknown"
    }
    
    # Test Windows Forms
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        Write-TestResult -TestName "Windows Forms Availability" -Category "System" -Passed $true -Details "Windows Forms loaded successfully" -ExpectedResult "Available" -ActualResult "Available"
    }
    catch {
        Write-TestResult -TestName "Windows Forms Availability" -Category "System" -Passed $false -Details "Failed to load Windows Forms: $($_.Exception.Message)" -ExpectedResult "Available" -ActualResult "Not Available"
    }
    
    # Test disk space
    try {
        $drive = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction Stop
        $freeSpaceGB = [math]::Round($drive.FreeSpace / 1GB, 2)
        Write-TestResult -TestName "Disk Space Check" -Category "System" -Passed ($freeSpaceGB -ge 2) -Details "Free space: $freeSpaceGB GB" -ExpectedResult "2GB+" -ActualResult "$freeSpaceGB GB"
    }
    catch {
        Write-TestResult -TestName "Disk Space Check" -Category "System" -Passed $false -Details "Could not check disk space" -ExpectedResult "2GB+" -ActualResult "Unknown"
    }
    
    # Test memory
    try {
        $memory = Get-WmiObject -Class Win32_ComputerSystem -ErrorAction Stop
        $memoryGB = [math]::Round($memory.TotalPhysicalMemory / 1GB, 2)
        Write-TestResult -TestName "Memory Check" -Category "System" -Passed ($memoryGB -ge 4) -Details "Total RAM: $memoryGB GB" -ExpectedResult "4GB+" -ActualResult "$memoryGB GB"
    }
    catch {
        Write-TestResult -TestName "Memory Check" -Category "System" -Passed $false -Details "Could not check memory" -ExpectedResult "4GB+" -ActualResult "Unknown"
    }
}

function Test-InstallerFiles {
    Write-Host "`n📁 Testing Installer Files..." -ForegroundColor Cyan
    
    $requiredFiles = @(
        "VelociraptorProfessionalSuite\LAUNCH_INSTALLER.bat",
        "VelociraptorProfessionalSuite\LAUNCH_INSTALLER.ps1",
        "VelociraptorProfessionalSuite\VelociraptorInstaller.ps1",
        "VelociraptorProfessionalSuite\CHECK_SYSTEM.ps1",
        "VelociraptorProfessionalSuite\README.md"
    )
    
    foreach ($file in $requiredFiles) {
        $exists = Test-Path $file
        Write-TestResult -TestName "File Exists: $(Split-Path $file -Leaf)" -Category "Installation" -Passed $exists -Details "Path: $file" -ExpectedResult "File exists" -ActualResult $(if ($exists) { "Exists" } else { "Missing" })
    }
    
    # Test modules directory
    $modulesPath = "VelociraptorProfessionalSuite\modules"
    $modulesExist = Test-Path $modulesPath
    Write-TestResult -TestName "Modules Directory" -Category "Installation" -Passed $modulesExist -Details "Path: $modulesPath" -ExpectedResult "Directory exists" -ActualResult $(if ($modulesExist) { "Exists" } else { "Missing" })
    
    if ($modulesExist) {
        $expectedModules = @("VelociraptorDeployment", "VelociraptorML", "VelociraptorCompliance", "VelociraptorGovernance", "ZeroTrustSecurity")
        foreach ($module in $expectedModules) {
            $modulePath = Join-Path $modulesPath $module
            $exists = Test-Path $modulePath
            Write-TestResult -TestName "Module: $module" -Category "Installation" -Passed $exists -Details "Path: $modulePath" -ExpectedResult "Module exists" -ActualResult $(if ($exists) { "Exists" } else { "Missing" })
        }
    }
}

function Test-ScriptSyntax {
    Write-Host "`n🔍 Testing Script Syntax..." -ForegroundColor Cyan
    
    $scriptsToTest = @(
        "VelociraptorProfessionalSuite\LAUNCH_INSTALLER.ps1",
        "VelociraptorProfessionalSuite\VelociraptorInstaller.ps1",
        "VelociraptorProfessionalSuite\CHECK_SYSTEM.ps1"
    )
    
    foreach ($script in $scriptsToTest) {
        if (Test-Path $script) {
            try {
                $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $script -Raw), [ref]$null)
                Write-TestResult -TestName "Syntax Check: $(Split-Path $script -Leaf)" -Category "Installation" -Passed $true -Details "PowerShell syntax is valid" -ExpectedResult "Valid syntax" -ActualResult "Valid"
            }
            catch {
                Write-TestResult -TestName "Syntax Check: $(Split-Path $script -Leaf)" -Category "Installation" -Passed $false -Details "Syntax error: $($_.Exception.Message)" -ExpectedResult "Valid syntax" -ActualResult "Invalid"
            }
        }
    }
}

function Test-GUIComponents {
    Write-Host "`n🖥️ Testing GUI Components..." -ForegroundColor Cyan
    
    try {
        # Test Windows Forms creation
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        
        $testForm = New-Object System.Windows.Forms.Form
        $testForm.Text = "UAT Test Form"
        $testForm.Size = New-Object System.Drawing.Size(300, 200)
        
        Write-TestResult -TestName "Form Creation" -Category "GUI" -Passed $true -Details "Successfully created test form" -ExpectedResult "Form created" -ActualResult "Success"
        
        # Test TabControl
        $tabControl = New-Object System.Windows.Forms.TabControl
        $tabControl.Dock = "Fill"
        $testForm.Controls.Add($tabControl)
        
        Write-TestResult -TestName "TabControl Creation" -Category "GUI" -Passed $true -Details "Successfully created TabControl" -ExpectedResult "TabControl created" -ActualResult "Success"
        
        # Test Button
        $button = New-Object System.Windows.Forms.Button
        $button.Text = "Test Button"
        $button.Size = New-Object System.Drawing.Size(100, 30)
        
        Write-TestResult -TestName "Button Creation" -Category "GUI" -Passed $true -Details "Successfully created Button" -ExpectedResult "Button created" -ActualResult "Success"
        
        # Test Label
        $label = New-Object System.Windows.Forms.Label
        $label.Text = "Test Label"
        $label.Size = New-Object System.Drawing.Size(100, 20)
        
        Write-TestResult -TestName "Label Creation" -Category "GUI" -Passed $true -Details "Successfully created Label" -ExpectedResult "Label created" -ActualResult "Success"
        
        # Test TextBox
        $textBox = New-Object System.Windows.Forms.TextBox
        $textBox.Text = "Test TextBox"
        
        Write-TestResult -TestName "TextBox Creation" -Category "GUI" -Passed $true -Details "Successfully created TextBox" -ExpectedResult "TextBox created" -ActualResult "Success"
        
        # Clean up
        $testForm.Dispose()
    }
    catch {
        Write-TestResult -TestName "GUI Components Test" -Category "GUI" -Passed $false -Details "Failed to create GUI components: $($_.Exception.Message)" -ExpectedResult "All components created" -ActualResult "Failed"
    }
}

function Test-LauncherFunctionality {
    Write-Host "`n🚀 Testing Launcher Functionality..." -ForegroundColor Cyan
    
    # Test CHECK_SYSTEM.ps1 execution
    if (Test-Path "VelociraptorProfessionalSuite\CHECK_SYSTEM.ps1") {
        try {
            $checkResult = & "VelociraptorProfessionalSuite\CHECK_SYSTEM.ps1" -ErrorAction Stop 2>&1
            Write-TestResult -TestName "System Check Script Execution" -Category "Functionality" -Passed $true -Details "System check script ran successfully" -ExpectedResult "Script executes" -ActualResult "Success"
        }
        catch {
            Write-TestResult -TestName "System Check Script Execution" -Category "Functionality" -Passed $false -Details "Failed to run system check: $($_.Exception.Message)" -ExpectedResult "Script executes" -ActualResult "Failed"
        }
    }
    
    # Test PowerShell execution policy handling
    $currentPolicy = Get-ExecutionPolicy
    Write-TestResult -TestName "Execution Policy Check" -Category "Functionality" -Passed $true -Details "Current policy: $currentPolicy" -ExpectedResult "Policy detected" -ActualResult "$currentPolicy"
    
    # Test module loading capability
    $modulePath = "VelociraptorProfessionalSuite\modules\VelociraptorDeployment"
    if (Test-Path "$modulePath\VelociraptorDeployment.psd1") {
        try {
            Test-ModuleManifest "$modulePath\VelociraptorDeployment.psd1" -ErrorAction Stop | Out-Null
            Write-TestResult -TestName "Module Manifest Validation" -Category "Functionality" -Passed $true -Details "VelociraptorDeployment manifest is valid" -ExpectedResult "Valid manifest" -ActualResult "Valid"
        }
        catch {
            Write-TestResult -TestName "Module Manifest Validation" -Category "Functionality" -Passed $false -Details "Invalid manifest: $($_.Exception.Message)" -ExpectedResult "Valid manifest" -ActualResult "Invalid"
        }
    }
}

function Test-NetworkConnectivity {
    Write-Host "`n🌐 Testing Network Connectivity..." -ForegroundColor Cyan
    
    # Test GitHub API access (for Velociraptor downloads)
    try {
        $response = Invoke-WebRequest -Uri "https://api.github.com/repos/Ununp3ntium115/velociraptor/releases/latest" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        $canDownload = $response.StatusCode -eq 200
        Write-TestResult -TestName "GitHub API Access" -Category "Functionality" -Passed $canDownload -Details "Status: $($response.StatusCode)" -ExpectedResult "200 OK" -ActualResult "$($response.StatusCode)"
    }
    catch {
        Write-TestResult -TestName "GitHub API Access" -Category "Functionality" -Passed $false -Details "Failed to access GitHub API: $($_.Exception.Message)" -ExpectedResult "200 OK" -ActualResult "Failed"
    }
    
    # Test DNS resolution
    try {
        $dnsResult = Resolve-DnsName "github.com" -ErrorAction Stop
        Write-TestResult -TestName "DNS Resolution" -Category "Functionality" -Passed $true -Details "Successfully resolved github.com" -ExpectedResult "DNS resolves" -ActualResult "Success"
    }
    catch {
        Write-TestResult -TestName "DNS Resolution" -Category "Functionality" -Passed $false -Details "DNS resolution failed: $($_.Exception.Message)" -ExpectedResult "DNS resolves" -ActualResult "Failed"
    }
}

function Generate-TestReport {
    Write-Host "`n📊 Generating Test Report..." -ForegroundColor Cyan
    
    $totalTests = $script:TestResults.Count
    $passedTests = ($script:TestResults | Where-Object { $_.Passed }).Count
    $failedTests = $totalTests - $passedTests
    $passRate = if ($totalTests -gt 0) { [math]::Round(($passedTests / $totalTests) * 100, 2) } else { 0 }
    
    $testEndTime = Get-Date
    $testDuration = $testEndTime - $script:TestStartTime
    
    $htmlReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>Velociraptor Professional Suite - UAT Test Report</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .header { background-color: #0078d4; color: white; padding: 20px; border-radius: 5px; margin-bottom: 20px; }
        .summary { background-color: white; padding: 20px; border-radius: 5px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .test-category { background-color: white; margin-bottom: 20px; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .category-header { background-color: #f8f9fa; padding: 15px; border-bottom: 1px solid #dee2e6; font-weight: bold; }
        .test-result { padding: 10px 15px; border-bottom: 1px solid #f0f0f0; }
        .test-result:last-child { border-bottom: none; }
        .pass { color: #28a745; }
        .fail { color: #dc3545; }
        .test-name { font-weight: bold; }
        .test-details { color: #6c757d; font-size: 0.9em; margin-top: 5px; }
        .stats { display: flex; justify-content: space-around; text-align: center; }
        .stat { background-color: #f8f9fa; padding: 15px; border-radius: 5px; }
        .stat-number { font-size: 2em; font-weight: bold; }
        .pass-rate { color: $(if ($passRate -ge 80) { '#28a745' } elseif ($passRate -ge 60) { '#ffc107' } else { '#dc3545' }); }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 Velociraptor Professional Suite</h1>
        <h2>User Acceptance Testing Report</h2>
        <p>Generated: $testEndTime</p>
        <p>Test Duration: $($testDuration.ToString("hh\:mm\:ss"))</p>
        <p>System: $env:COMPUTERNAME ($env:PROCESSOR_ARCHITECTURE)</p>
    </div>
    
    <div class="summary">
        <h3>📊 Test Summary</h3>
        <div class="stats">
            <div class="stat">
                <div class="stat-number">$totalTests</div>
                <div>Total Tests</div>
            </div>
            <div class="stat">
                <div class="stat-number pass">$passedTests</div>
                <div>Passed</div>
            </div>
            <div class="stat">
                <div class="stat-number fail">$failedTests</div>
                <div>Failed</div>
            </div>
            <div class="stat">
                <div class="stat-number pass-rate">$passRate%</div>
                <div>Pass Rate</div>
            </div>
        </div>
    </div>
"@

    # Group results by category
    $categories = $script:TestResults | Group-Object Category
    
    foreach ($category in $categories) {
        $htmlReport += @"
    <div class="test-category">
        <div class="category-header">$($category.Name) Tests</div>
"@
        
        foreach ($test in $category.Group) {
            $statusClass = if ($test.Passed) { "pass" } else { "fail" }
            $statusSymbol = if ($test.Passed) { "✅" } else { "❌" }
            
            $htmlReport += @"
        <div class="test-result">
            <div class="test-name $statusClass">$statusSymbol $($test.TestName)</div>
            <div class="test-details">
                <strong>Expected:</strong> $($test.ExpectedResult)<br>
                <strong>Actual:</strong> $($test.ActualResult)<br>
                <strong>Details:</strong> $($test.Details)<br>
                <strong>Time:</strong> $($test.Timestamp.ToString("HH:mm:ss"))
            </div>
        </div>
"@
        }
        
        $htmlReport += "    </div>"
    }
    
    $htmlReport += @"
    
    <div class="summary">
        <h3>🎯 Recommendations</h3>
        <ul>
"@
    
    if ($passRate -ge 90) {
        $htmlReport += "<li><strong>✅ Excellent:</strong> System is ready for production deployment</li>"
    } elseif ($passRate -ge 80) {
        $htmlReport += "<li><strong>✅ Good:</strong> System is ready with minor issues to address</li>"
    } elseif ($passRate -ge 60) {
        $htmlReport += "<li><strong>⚠️ Caution:</strong> Address failed tests before deployment</li>"
    } else {
        $htmlReport += "<li><strong>❌ Not Ready:</strong> Significant issues must be resolved</li>"
    }
    
    $failedCategories = $script:TestResults | Where-Object { -not $_.Passed } | Group-Object Category
    foreach ($failedCategory in $failedCategories) {
        $htmlReport += "<li><strong>$($failedCategory.Name):</strong> $($failedCategory.Count) failed test(s) need attention</li>"
    }
    
    $htmlReport += @"
        </ul>
    </div>
</body>
</html>
"@
    
    $htmlReport | Out-File -FilePath $ReportPath -Encoding UTF8
    Write-Host "✅ Test report generated: $ReportPath" -ForegroundColor Green
}

# Main execution
Clear-Host
Write-Host "🧪 Velociraptor Professional Suite - User Acceptance Testing" -ForegroundColor Green
Write-Host "=" * 65 -ForegroundColor Blue
Write-Host "Test Type: $TestType" -ForegroundColor Cyan
Write-Host "Start Time: $script:TestStartTime" -ForegroundColor Cyan
Write-Host ""

# Run tests based on type
if ($TestType -eq "All" -or $TestType -eq "SystemCheck") {
    Test-SystemCompatibility
}

if ($TestType -eq "All" -or $TestType -eq "Installation") {
    Test-InstallerFiles
    Test-ScriptSyntax
}

if ($TestType -eq "All" -or $TestType -eq "GUI") {
    Test-GUIComponents
}

if ($TestType -eq "All" -or $TestType -eq "Functionality") {
    Test-LauncherFunctionality
    Test-NetworkConnectivity
}

# Generate summary
Write-Host "`n" + "=" * 65 -ForegroundColor Blue
Write-Host "📊 Test Summary" -ForegroundColor Green

$totalTests = $script:TestResults.Count
$passedTests = ($script:TestResults | Where-Object { $_.Passed }).Count
$failedTests = $totalTests - $passedTests
$passRate = if ($totalTests -gt 0) { [math]::Round(($passedTests / $totalTests) * 100, 2) } else { 0 }

Write-Host "Total Tests: $totalTests" -ForegroundColor White
Write-Host "Passed: $passedTests" -ForegroundColor Green
Write-Host "Failed: $failedTests" -ForegroundColor Red
Write-Host "Pass Rate: $passRate%" -ForegroundColor $(if ($passRate -ge 80) { "Green" } elseif ($passRate -ge 60) { "Yellow" } else { "Red" })

if ($GenerateReport) {
    Generate-TestReport
}

Write-Host "`n🎉 UAT Testing Complete!" -ForegroundColor Green

# Return results for automation
return @{
    TotalTests = $totalTests
    PassedTests = $passedTests
    FailedTests = $failedTests
    PassRate = $passRate
    Results = $script:TestResults
}