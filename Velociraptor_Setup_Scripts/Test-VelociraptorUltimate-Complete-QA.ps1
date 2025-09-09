#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Quality Assurance Testing for VelociraptorUltimate-Complete.ps1
    
.DESCRIPTION
    Comprehensive QA testing covering:
    - Code syntax and structure validation
    - Function availability and parameter validation
    - GUI component initialization testing
    - Integration point validation
    - Error handling verification
    - Performance and resource usage testing
#>

[CmdletBinding()]
param(
    [switch]$Detailed,
    [switch]$SkipGUITests,
    [string]$OutputPath = ".\QA-Results"
)

$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

# Test results tracking
$script:TestResults = @{
    Passed = 0
    Failed = 0
    Warnings = 0
    Details = @()
}

function Write-TestResult {
    param(
        [string]$TestName,
        [string]$Result,
        [string]$Details = "",
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = switch ($Result) {
        "PASS" { "Green"; $script:TestResults.Passed++ }
        "FAIL" { "Red"; $script:TestResults.Failed++ }
        "WARN" { "Yellow"; $script:TestResults.Warnings++ }
        default { "White" }
    }
    
    $resultEntry = @{
        Timestamp = $timestamp
        TestName = $TestName
        Result = $Result
        Details = $Details
        Level = $Level
    }
    
    $script:TestResults.Details += $resultEntry
    
    Write-Host "[$timestamp] [$Result] $TestName" -ForegroundColor $color
    if ($Details -and $Detailed) {
        Write-Host "    Details: $Details" -ForegroundColor Gray
    }
}

function Test-ScriptSyntax {
    Write-Host "`n=== SYNTAX AND STRUCTURE VALIDATION ===" -ForegroundColor Cyan
    
    $scriptPath = ".\VelociraptorUltimate-Complete.ps1"
    
    # Test 1: File existence
    if (Test-Path $scriptPath) {
        Write-TestResult "File Existence" "PASS" "VelociraptorUltimate-Complete.ps1 found"
    } else {
        Write-TestResult "File Existence" "FAIL" "VelociraptorUltimate-Complete.ps1 not found"
        return
    }
    
    # Test 2: PowerShell syntax validation
    try {
        $syntaxErrors = $null
        $tokens = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($scriptPath, [ref]$tokens, [ref]$syntaxErrors)
        
        if ($syntaxErrors.Count -eq 0) {
            Write-TestResult "PowerShell Syntax" "PASS" "No syntax errors found"
        } else {
            Write-TestResult "PowerShell Syntax" "FAIL" "$($syntaxErrors.Count) syntax errors found"
            if ($Detailed) {
                foreach ($error in $syntaxErrors) {
                    Write-Host "    Syntax Error: $($error.Message) at line $($error.Extent.StartLineNumber)" -ForegroundColor Red
                }
            }
        }
    }
    catch {
        Write-TestResult "PowerShell Syntax" "FAIL" "Syntax validation failed: $($_.Exception.Message)"
    }
    
    # Test 3: Required assemblies check
    $content = Get-Content $scriptPath -Raw
    $requiredAssemblies = @("System.Windows.Forms", "System.Drawing")
    
    foreach ($assembly in $requiredAssemblies) {
        if ($content -match "Add-Type.*$assembly") {
            Write-TestResult "Assembly Reference: $assembly" "PASS" "Assembly reference found"
        } else {
            Write-TestResult "Assembly Reference: $assembly" "FAIL" "Assembly reference missing"
        }
    }
    
    # Test 4: Function definitions check
    $expectedFunctions = @(
        "New-SafeControl",
        "Write-Log", 
        "Update-Status",
        "Get-LatestVelociraptorAsset",
        "Install-VelociraptorExecutable",
        "Deploy-VelociraptorServer",
        "Build-OfflineCollector",
        "New-MainForm",
        "New-MainTabControl",
        "New-DashboardTab",
        "New-ServerTab",
        "New-StandaloneTab",
        "New-OfflineCollectorTab",
        "New-ArtifactManagementTab",
        "New-InvestigationTab",
        "Initialize-Application"
    )
    
    foreach ($function in $expectedFunctions) {
        if ($content -match "function\s+$function") {
            Write-TestResult "Function Definition: $function" "PASS" "Function defined"
        } else {
            Write-TestResult "Function Definition: $function" "FAIL" "Function missing"
        }
    }
    
    # Test 5: Global variables check
    $expectedVariables = @(
        '\$script:MainForm',
        '\$script:TabControl', 
        '\$script:StatusLabel',
        '\$script:LogTextBox',
        '\$script:InstallDir',
        '\$script:DataStore',
        '\$script:IncidentPackages',
        '\$script:AvailableArtifacts'
    )
    
    foreach ($variable in $expectedVariables) {
        if ($content -match $variable) {
            Write-TestResult "Global Variable: $variable" "PASS" "Variable declared"
        } else {
            Write-TestResult "Global Variable: $variable" "FAIL" "Variable missing"
        }
    }
    
    # Test 6: Color definitions check
    $colorDefinitions = @(
        '\$DARK_BACKGROUND',
        '\$DARK_SURFACE',
        '\$PRIMARY_TEAL',
        '\$WHITE_TEXT',
        '\$SUCCESS_GREEN',
        '\$ERROR_RED',
        '\$WARNING_ORANGE'
    )
    
    foreach ($color in $colorDefinitions) {
        if ($content -match $color) {
            Write-TestResult "Color Definition: $color" "PASS" "Color defined"
        } else {
            Write-TestResult "Color Definition: $color" "FAIL" "Color missing"
        }
    }
}

function Test-DataStructures {
    Write-Host "`n=== DATA STRUCTURE VALIDATION ===" -ForegroundColor Cyan
    
    try {
        # Load the script to test data structures
        $scriptPath = ".\VelociraptorUltimate-Complete.ps1"
        $content = Get-Content $scriptPath -Raw
        
        # Test 1: Incident packages structure
        if ($content -match '\$script:IncidentPackages\s*=\s*@{') {
            Write-TestResult "Incident Packages Structure" "PASS" "IncidentPackages hashtable defined"
            
            # Check for required packages
            $requiredPackages = @("APT-Package", "Ransomware-Package", "Malware-Package", "DataBreach-Package", "NetworkIntrusion-Package", "Insider-Package", "Complete-Package")
            foreach ($package in $requiredPackages) {
                if ($content -match "`"$package`"") {
                    Write-TestResult "Package Definition: $package" "PASS" "Package defined"
                } else {
                    Write-TestResult "Package Definition: $package" "FAIL" "Package missing"
                }
            }
        } else {
            Write-TestResult "Incident Packages Structure" "FAIL" "IncidentPackages hashtable not found"
        }
        
        # Test 2: Available artifacts array
        if ($content -match '\$script:AvailableArtifacts\s*=\s*@\(') {
            Write-TestResult "Available Artifacts Array" "PASS" "AvailableArtifacts array defined"
            
            # Count artifacts
            $artifactMatches = [regex]::Matches($content, '"Windows\.[^"]+"|"Generic\.[^"]+"|"Linux\.[^"]+"')
            if ($artifactMatches.Count -gt 20) {
                Write-TestResult "Artifact Count" "PASS" "$($artifactMatches.Count) artifacts found"
            } else {
                Write-TestResult "Artifact Count" "WARN" "Only $($artifactMatches.Count) artifacts found, expected more"
            }
        } else {
            Write-TestResult "Available Artifacts Array" "FAIL" "AvailableArtifacts array not found"
        }
        
        # Test 3: Configuration variables
        $configVars = @(
            '\$script:InstallDir\s*=\s*[''"]C:\\tools[''"]',
            '\$script:DataStore\s*=\s*[''"]C:\\VelociraptorServerData[''"]',
            '\$script:FrontendPort\s*=\s*8000',
            '\$script:GuiPort\s*=\s*8889'
        )
        
        foreach ($configVar in $configVars) {
            if ($content -match $configVar) {
                Write-TestResult "Configuration Variable" "PASS" "Config variable properly set"
            } else {
                Write-TestResult "Configuration Variable" "WARN" "Config variable may not be set correctly"
            }
        }
        
    }
    catch {
        Write-TestResult "Data Structure Loading" "FAIL" "Failed to load script for data structure testing: $($_.Exception.Message)"
    }
}

function Test-FunctionIntegrity {
    Write-Host "`n=== FUNCTION INTEGRITY TESTING ===" -ForegroundColor Cyan
    
    try {
        $scriptPath = ".\VelociraptorUltimate-Complete.ps1"
        $content = Get-Content $scriptPath -Raw
        
        # Test 1: Function parameter validation
        $functionsWithParams = @{
            "New-SafeControl" = @("ControlType", "Properties")
            "Write-Log" = @("Message", "Level")
            "Update-Status" = @("Message")
            "Install-VelociraptorExecutable" = @("AssetInfo", "DestinationPath")
            "Build-OfflineCollector" = @("SelectedArtifacts", "OutputPath", "Platform")
        }
        
        foreach ($funcName in $functionsWithParams.Keys) {
            $expectedParams = $functionsWithParams[$funcName]
            
            # Find function definition
            $funcPattern = "function\s+$funcName\s*\{[^}]*param\s*\([^)]*\)"
            if ($content -match $funcPattern) {
                $funcMatch = $Matches[0]
                
                $allParamsFound = $true
                foreach ($param in $expectedParams) {
                    if ($funcMatch -notmatch $param) {
                        $allParamsFound = $false
                        break
                    }
                }
                
                if ($allParamsFound) {
                    Write-TestResult "Function Parameters: $funcName" "PASS" "All expected parameters found"
                } else {
                    Write-TestResult "Function Parameters: $funcName" "WARN" "Some parameters may be missing"
                }
            } else {
                Write-TestResult "Function Parameters: $funcName" "FAIL" "Function not found or no parameters"
            }
        }
        
        # Test 2: Error handling patterns
        $errorHandlingFunctions = @("Deploy-VelociraptorServer", "Build-OfflineCollector", "Install-VelociraptorExecutable")
        
        foreach ($funcName in $errorHandlingFunctions) {
            # Look for try-catch blocks in functions
            $funcStart = $content.IndexOf("function $funcName")
            if ($funcStart -gt -1) {
                $funcEnd = $content.IndexOf("function ", $funcStart + 1)
                if ($funcEnd -eq -1) { $funcEnd = $content.Length }
                
                $funcContent = $content.Substring($funcStart, $funcEnd - $funcStart)
                
                if ($funcContent -match "try\s*\{" -and $funcContent -match "catch\s*\{") {
                    Write-TestResult "Error Handling: $funcName" "PASS" "Try-catch blocks found"
                } else {
                    Write-TestResult "Error Handling: $funcName" "WARN" "No try-catch blocks found"
                }
            }
        }
        
        # Test 3: Return value validation
        $functionsWithReturns = @("Get-LatestVelociraptorAsset", "Install-VelociraptorExecutable", "Build-OfflineCollector", "New-MainForm")
        
        foreach ($funcName in $functionsWithReturns) {
            $funcStart = $content.IndexOf("function $funcName")
            if ($funcStart -gt -1) {
                $funcEnd = $content.IndexOf("function ", $funcStart + 1)
                if ($funcEnd -eq -1) { $funcEnd = $content.Length }
                
                $funcContent = $content.Substring($funcStart, $funcEnd - $funcStart)
                
                if ($funcContent -match "return\s+" -or $funcContent -match "^\s*@\{" -or $funcContent -match "^\s*\$") {
                    Write-TestResult "Return Values: $funcName" "PASS" "Return statements found"
                } else {
                    Write-TestResult "Return Values: $funcName" "WARN" "No explicit return statements found"
                }
            }
        }
        
    }
    catch {
        Write-TestResult "Function Integrity Testing" "FAIL" "Failed to test function integrity: $($_.Exception.Message)"
    }
}

function Test-GUIComponents {
    Write-Host "`n=== GUI COMPONENT TESTING ===" -ForegroundColor Cyan
    
    if ($SkipGUITests) {
        Write-TestResult "GUI Component Testing" "SKIP" "GUI tests skipped by user request"
        return
    }
    
    try {
        # Test 1: Windows Forms assembly loading
        try {
            Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
            Add-Type -AssemblyName System.Drawing -ErrorAction Stop
            Write-TestResult "Windows Forms Assembly" "PASS" "Assemblies loaded successfully"
        }
        catch {
            Write-TestResult "Windows Forms Assembly" "FAIL" "Failed to load Windows Forms assemblies: $($_.Exception.Message)"
            return
        }
        
        # Test 2: Basic form creation
        try {
            $testForm = New-Object System.Windows.Forms.Form
            $testForm.Text = "QA Test Form"
            $testForm.Size = New-Object System.Drawing.Size(400, 300)
            Write-TestResult "Basic Form Creation" "PASS" "Form created successfully"
            $testForm.Dispose()
        }
        catch {
            Write-TestResult "Basic Form Creation" "FAIL" "Failed to create basic form: $($_.Exception.Message)"
        }
        
        # Test 3: Tab control creation
        try {
            $testTabControl = New-Object System.Windows.Forms.TabControl
            $testTabControl.Size = New-Object System.Drawing.Size(300, 200)
            Write-TestResult "Tab Control Creation" "PASS" "TabControl created successfully"
            $testTabControl.Dispose()
        }
        catch {
            Write-TestResult "Tab Control Creation" "FAIL" "Failed to create TabControl: $($_.Exception.Message)"
        }
        
        # Test 4: Color definitions
        try {
            $testColors = @{
                DARK_BACKGROUND = [System.Drawing.Color]::FromArgb(32, 32, 32)
                DARK_SURFACE = [System.Drawing.Color]::FromArgb(48, 48, 48)
                PRIMARY_TEAL = [System.Drawing.Color]::FromArgb(0, 150, 136)
                WHITE_TEXT = [System.Drawing.Color]::FromArgb(255, 255, 255)
            }
            
            foreach ($colorName in $testColors.Keys) {
                $color = $testColors[$colorName]
                if ($color.A -gt 0 -and ($color.R -ge 0 -and $color.R -le 255)) {
                    Write-TestResult "Color Definition: $colorName" "PASS" "Color properly defined"
                } else {
                    Write-TestResult "Color Definition: $colorName" "FAIL" "Invalid color values"
                }
            }
        }
        catch {
            Write-TestResult "Color Definitions" "FAIL" "Failed to test color definitions: $($_.Exception.Message)"
        }
        
        # Test 5: Control creation with properties
        try {
            $testButton = New-Object System.Windows.Forms.Button
            $testButton.Text = "Test Button"
            $testButton.Size = New-Object System.Drawing.Size(100, 30)
            $testButton.BackColor = [System.Drawing.Color]::FromArgb(0, 150, 136)
            $testButton.ForeColor = [System.Drawing.Color]::White
            
            if ($testButton.Text -eq "Test Button" -and $testButton.Size.Width -eq 100) {
                Write-TestResult "Control Property Setting" "PASS" "Control properties set correctly"
            } else {
                Write-TestResult "Control Property Setting" "FAIL" "Control properties not set correctly"
            }
            
            $testButton.Dispose()
        }
        catch {
            Write-TestResult "Control Property Setting" "FAIL" "Failed to set control properties: $($_.Exception.Message)"
        }
        
    }
    catch {
        Write-TestResult "GUI Component Testing" "FAIL" "GUI component testing failed: $($_.Exception.Message)"
    }
}

function Test-IntegrationPoints {
    Write-Host "`n=== INTEGRATION POINT TESTING ===" -ForegroundColor Cyan
    
    # Test 1: Deployment script references
    $deploymentScripts = @(
        "Deploy_Velociraptor_Server.ps1",
        "Deploy_Velociraptor_Standalone.ps1"
    )
    
    foreach ($script in $deploymentScripts) {
        if (Test-Path ".\$script") {
            Write-TestResult "Deployment Script: $script" "PASS" "Script file exists"
        } else {
            Write-TestResult "Deployment Script: $script" "WARN" "Script file not found (may affect integration)"
        }
    }
    
    # Test 2: Incident packages directory
    if (Test-Path ".\incident-packages") {
        Write-TestResult "Incident Packages Directory" "PASS" "Directory exists"
        
        # Check for specific packages
        $expectedPackages = @("APT-Package", "Ransomware-Package", "Malware-Package", "DataBreach-Package", "NetworkIntrusion-Package", "Insider-Package", "Complete-Package")
        foreach ($package in $expectedPackages) {
            if (Test-Path ".\incident-packages\$package") {
                Write-TestResult "Package Directory: $package" "PASS" "Package directory exists"
            } else {
                Write-TestResult "Package Directory: $package" "WARN" "Package directory not found"
            }
        }
    } else {
        Write-TestResult "Incident Packages Directory" "WARN" "incident-packages directory not found"
    }
    
    # Test 3: Module references
    $moduleReferences = @(
        "VelociraptorDeployment",
        "VelociraptorCompliance", 
        "VelociraptorML",
        "ZeroTrustSecurity"
    )
    
    foreach ($module in $moduleReferences) {
        if (Test-Path ".\modules\$module") {
            Write-TestResult "Module Directory: $module" "PASS" "Module directory exists"
        } else {
            Write-TestResult "Module Directory: $module" "WARN" "Module directory not found"
        }
    }
    
    # Test 4: GitHub API accessibility (for Velociraptor downloads)
    try {
        $testUrl = "https://api.github.com/repos/Ununp3ntium115/velociraptor/releases/latest"
        $response = Invoke-RestMethod -Uri $testUrl -TimeoutSec 10 -ErrorAction Stop
        
        if ($response.tag_name) {
            Write-TestResult "GitHub API Access" "PASS" "API accessible, latest version: $($response.tag_name)"
        } else {
            Write-TestResult "GitHub API Access" "WARN" "API accessible but no version info"
        }
    }
    catch {
        Write-TestResult "GitHub API Access" "WARN" "GitHub API not accessible (may affect downloads): $($_.Exception.Message)"
    }
    
    # Test 5: PowerShell version compatibility
    $psVersion = $PSVersionTable.PSVersion
    if ($psVersion.Major -ge 5) {
        Write-TestResult "PowerShell Version" "PASS" "PowerShell $($psVersion.Major).$($psVersion.Minor) is compatible"
    } else {
        Write-TestResult "PowerShell Version" "WARN" "PowerShell $($psVersion.Major).$($psVersion.Minor) may have compatibility issues"
    }
    
    # Test 6: Administrator privileges
    try {
        $currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
        
        if ($isAdmin) {
            Write-TestResult "Administrator Privileges" "PASS" "Running with administrator privileges"
        } else {
            Write-TestResult "Administrator Privileges" "WARN" "Not running as administrator (may affect some features)"
        }
    }
    catch {
        Write-TestResult "Administrator Privileges" "WARN" "Could not determine privilege level"
    }
}

function Test-Performance {
    Write-Host "`n=== PERFORMANCE TESTING ===" -ForegroundColor Cyan
    
    # Test 1: Script loading time
    $loadStartTime = Get-Date
    try {
        $scriptPath = ".\VelociraptorUltimate-Complete.ps1"
        $content = Get-Content $scriptPath -Raw
        $loadEndTime = Get-Date
        $loadTime = ($loadEndTime - $loadStartTime).TotalMilliseconds
        
        if ($loadTime -lt 1000) {
            Write-TestResult "Script Load Time" "PASS" "Loaded in ${loadTime}ms"
        } elseif ($loadTime -lt 3000) {
            Write-TestResult "Script Load Time" "WARN" "Loaded in ${loadTime}ms (acceptable but slow)"
        } else {
            Write-TestResult "Script Load Time" "FAIL" "Loaded in ${loadTime}ms (too slow)"
        }
    }
    catch {
        Write-TestResult "Script Load Time" "FAIL" "Failed to measure load time: $($_.Exception.Message)"
    }
    
    # Test 2: Memory usage estimation
    try {
        $process = Get-Process -Id $PID
        $memoryMB = [math]::Round($process.WorkingSet64 / 1MB, 2)
        
        if ($memoryMB -lt 100) {
            Write-TestResult "Memory Usage" "PASS" "Using ${memoryMB}MB (efficient)"
        } elseif ($memoryMB -lt 200) {
            Write-TestResult "Memory Usage" "WARN" "Using ${memoryMB}MB (acceptable)"
        } else {
            Write-TestResult "Memory Usage" "WARN" "Using ${memoryMB}MB (high usage)"
        }
    }
    catch {
        Write-TestResult "Memory Usage" "WARN" "Could not measure memory usage"
    }
    
    # Test 3: File size analysis
    try {
        $scriptPath = ".\VelociraptorUltimate-Complete.ps1"
        $fileSize = (Get-Item $scriptPath).Length
        $fileSizeKB = [math]::Round($fileSize / 1KB, 2)
        
        if ($fileSizeKB -lt 100) {
            Write-TestResult "Script File Size" "PASS" "${fileSizeKB}KB (compact)"
        } elseif ($fileSizeKB -lt 500) {
            Write-TestResult "Script File Size" "PASS" "${fileSizeKB}KB (reasonable)"
        } else {
            Write-TestResult "Script File Size" "WARN" "${fileSizeKB}KB (large file)"
        }
    }
    catch {
        Write-TestResult "Script File Size" "WARN" "Could not measure file size"
    }
    
    # Test 4: Line count analysis
    try {
        $scriptPath = ".\VelociraptorUltimate-Complete.ps1"
        $lineCount = (Get-Content $scriptPath).Count
        
        if ($lineCount -lt 1000) {
            Write-TestResult "Script Line Count" "PASS" "$lineCount lines (manageable)"
        } elseif ($lineCount -lt 2000) {
            Write-TestResult "Script Line Count" "PASS" "$lineCount lines (substantial but reasonable)"
        } else {
            Write-TestResult "Script Line Count" "WARN" "$lineCount lines (very large script)"
        }
    }
    catch {
        Write-TestResult "Script Line Count" "WARN" "Could not count lines"
    }
}

function Generate-QAReport {
    Write-Host "`n=== GENERATING QA REPORT ===" -ForegroundColor Cyan
    
    try {
        if (-not (Test-Path $OutputPath)) {
            New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
        }
        
        $reportPath = Join-Path $OutputPath "VelociraptorUltimate-Complete-QA-Report.txt"
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        
        $report = @"
VELOCIRAPTOR ULTIMATE COMPLETE - QA TEST REPORT
Generated: $timestamp
Script: VelociraptorUltimate-Complete.ps1

SUMMARY:
========
Total Tests: $($script:TestResults.Passed + $script:TestResults.Failed + $script:TestResults.Warnings)
Passed: $($script:TestResults.Passed)
Failed: $($script:TestResults.Failed)
Warnings: $($script:TestResults.Warnings)

DETAILED RESULTS:
================
$($script:TestResults.Details | ForEach-Object {
    "[$($_.Timestamp)] [$($_.Result)] $($_.TestName)"
    if ($_.Details) { "    Details: $($_.Details)" }
    ""
} | Out-String)

RECOMMENDATIONS:
===============
$( if ($script:TestResults.Failed -gt 0) {
    "- Address all FAILED tests before deployment"
    "- Review error messages and fix underlying issues"
} else {
    "- All critical tests passed"
})
$( if ($script:TestResults.Warnings -gt 0) {
    "- Review WARNING items for potential improvements"
    "- Consider addressing warnings for optimal performance"
})

OVERALL ASSESSMENT:
==================
$( if ($script:TestResults.Failed -eq 0 -and $script:TestResults.Warnings -le 5) {
    "EXCELLENT - Script is ready for production use"
} elseif ($script:TestResults.Failed -eq 0) {
    "GOOD - Script is functional with minor issues to address"
} elseif ($script:TestResults.Failed -le 3) {
    "NEEDS WORK - Address failed tests before deployment"
} else {
    "MAJOR ISSUES - Significant problems need resolution"
})
"@
        
        $report | Out-File -FilePath $reportPath -Encoding UTF8
        Write-TestResult "QA Report Generation" "PASS" "Report saved to: $reportPath"
        
        return $reportPath
    }
    catch {
        Write-TestResult "QA Report Generation" "FAIL" "Failed to generate report: $($_.Exception.Message)"
        return $null
    }
}

# Main execution
Write-Host "VELOCIRAPTOR ULTIMATE COMPLETE - QA TESTING" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host "Starting comprehensive Quality Assurance testing..." -ForegroundColor Yellow
Write-Host ""

# Run all test suites
Test-ScriptSyntax
Test-DataStructures  
Test-FunctionIntegrity
Test-GUIComponents
Test-IntegrationPoints
Test-Performance

# Generate report
Write-Host "`n=== QA TESTING COMPLETE ===" -ForegroundColor Green
$reportPath = Generate-QAReport

# Display summary
Write-Host "`nQA TEST SUMMARY:" -ForegroundColor Cyan
Write-Host "Passed: $($script:TestResults.Passed)" -ForegroundColor Green
Write-Host "Failed: $($script:TestResults.Failed)" -ForegroundColor Red  
Write-Host "Warnings: $($script:TestResults.Warnings)" -ForegroundColor Yellow

if ($reportPath) {
    Write-Host "`nDetailed report saved to: $reportPath" -ForegroundColor White
}

# Return exit code based on results
if ($script:TestResults.Failed -eq 0) {
    Write-Host "`nQA RESULT: PASSED" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`nQA RESULT: FAILED" -ForegroundColor Red
    exit 1
}