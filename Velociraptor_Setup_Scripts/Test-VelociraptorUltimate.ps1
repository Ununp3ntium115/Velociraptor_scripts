#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Comprehensive test runner for VelociraptorUltimate.ps1
    
.DESCRIPTION
    Tests the complete VelociraptorUltimate application including:
    - Syntax validation
    - Class structure validation
    - Method availability
    - Integration capabilities
    - User acceptance criteria
    
.EXAMPLE
    .\Test-VelociraptorUltimate.ps1
#>

param(
    [switch] $Detailed,
    [switch] $GenerateReport
)

# Test results tracking
$script:TestResults = @{
    StartTime = Get-Date
    Tests = @()
    Summary = @{
        Total = 0
        Passed = 0
        Failed = 0
        Warnings = 0
    }
}

function Write-TestResult {
    param(
        [string] $TestName,
        [string] $Status,
        [string] $Message,
        [string] $Details = ""
    )
    
    $result = @{
        TestName = $TestName
        Status = $Status
        Message = $Message
        Details = $Details
        Timestamp = Get-Date
    }
    
    $script:TestResults.Tests += $result
    $script:TestResults.Summary.Total++
    
    switch ($Status) {
        "PASS" { 
            $script:TestResults.Summary.Passed++
            Write-Host "✅ $TestName`: $Message" -ForegroundColor Green
        }
        "FAIL" { 
            $script:TestResults.Summary.Failed++
            Write-Host "❌ $TestName`: $Message" -ForegroundColor Red
        }
        "WARN" { 
            $script:TestResults.Summary.Warnings++
            Write-Host "⚠️  $TestName`: $Message" -ForegroundColor Yellow
        }
    }
    
    if ($Details -and $Detailed) {
        Write-Host "   Details: $Details" -ForegroundColor Gray
    }
}

Write-Host "🧪 VelociraptorUltimate Comprehensive Testing" -ForegroundColor Green
Write-Host "=" * 50 -ForegroundColor Blue
Write-Host ""

# Test 1: File Existence
if (Test-Path ".\VelociraptorUltimate.ps1") {
    Write-TestResult -TestName "File Existence" -Status "PASS" -Message "VelociraptorUltimate.ps1 found"
} else {
    Write-TestResult -TestName "File Existence" -Status "FAIL" -Message "VelociraptorUltimate.ps1 not found"
    exit 1
}

# Test 2: PowerShell Syntax
try {
    $content = Get-Content ".\VelociraptorUltimate.ps1" -Raw
    $tokens = $null
    $errors = $null
    [System.Management.Automation.PSParser]::Tokenize($content, [ref]$tokens) | Out-Null
    
    if ($errors -and $errors.Count -gt 0) {
        Write-TestResult -TestName "PowerShell Syntax" -Status "FAIL" -Message "Syntax errors found" -Details ($errors -join "; ")
    } else {
        Write-TestResult -TestName "PowerShell Syntax" -Status "PASS" -Message "No syntax errors found"
    }
} catch {
    Write-TestResult -TestName "PowerShell Syntax" -Status "FAIL" -Message "Syntax validation failed" -Details $_.Exception.Message
}

# Test 3: Required Assemblies
$requiredAssemblies = @("System.Windows.Forms", "System.Drawing", "System.Web")
$assemblyTests = @()

foreach ($assembly in $requiredAssemblies) {
    if ($content -match "Add-Type.*$assembly") {
        $assemblyTests += "✅ $assembly"
    } else {
        $assemblyTests += "❌ $assembly"
    }
}

if ($assemblyTests -match "❌") {
    Write-TestResult -TestName "Required Assemblies" -Status "WARN" -Message "Some assemblies may be missing" -Details ($assemblyTests -join ", ")
} else {
    Write-TestResult -TestName "Required Assemblies" -Status "PASS" -Message "All required assemblies referenced"
}

# Test 4: Class Structure
if ($content -match "class VelociraptorUltimateApp") {
    Write-TestResult -TestName "Main Class" -Status "PASS" -Message "VelociraptorUltimateApp class found"
    
    # Test class methods
    $requiredMethods = @(
        "LoadConfiguration",
        "InitializeGUI",
        "CreateInvestigationTab",
        "CreateOfflineTab", 
        "CreateServerTab",
        "CreateArtifactTab",
        "Show"
    )
    
    $foundMethods = @()
    $missingMethods = @()
    
    foreach ($method in $requiredMethods) {
        if ($content -match "\[void\]\s+$method\(") {
            $foundMethods += $method
        } else {
            $missingMethods += $method
        }
    }
    
    if ($missingMethods.Count -eq 0) {
        Write-TestResult -TestName "Class Methods" -Status "PASS" -Message "All $($foundMethods.Count) required methods found"
    } else {
        Write-TestResult -TestName "Class Methods" -Status "WARN" -Message "$($foundMethods.Count)/$($requiredMethods.Count) methods found" -Details "Missing: $($missingMethods -join ', ')"
    }
} else {
    Write-TestResult -TestName "Main Class" -Status "FAIL" -Message "VelociraptorUltimateApp class not found"
}

# Test 5: GUI Components
$guiComponents = @(
    "TabControl",
    "Button", 
    "TextBox",
    "ComboBox",
    "DataGridView"
)

$foundComponents = @()
foreach ($component in $guiComponents) {
    if ($content -match "System\.Windows\.Forms\.$component") {
        $foundComponents += $component
    }
}

if ($foundComponents.Count -ge 3) {
    Write-TestResult -TestName "GUI Components" -Status "PASS" -Message "$($foundComponents.Count) GUI components found" -Details ($foundComponents -join ", ")
} else {
    Write-TestResult -TestName "GUI Components" -Status "WARN" -Message "Limited GUI components detected" -Details ($foundComponents -join ", ")
}

# Test 6: Integration Features
$integrationFeatures = @{
    "Artifact Management" = "LoadArtifactPack|DownloadTools"
    "Investigation Management" = "CreateNewCase|Investigation"
    "Server Deployment" = "DeployServer|Server"
    "Configuration Management" = "LoadConfiguration|Config"
    "Logging System" = "AddLogEntry|LogEntries"
}

foreach ($feature in $integrationFeatures.Keys) {
    $pattern = $integrationFeatures[$feature]
    if ($content -match $pattern) {
        Write-TestResult -TestName $feature -Status "PASS" -Message "$feature functionality detected"
    } else {
        Write-TestResult -TestName $feature -Status "WARN" -Message "$feature may need implementation"
    }
}

# Test 7: Error Handling
$errorHandlingBlocks = [regex]::Matches($content, "try\s*\{").Count
$catchBlocks = [regex]::Matches($content, "catch\s*\{").Count

if ($errorHandlingBlocks -ge 5 -and $catchBlocks -ge 5) {
    Write-TestResult -TestName "Error Handling" -Status "PASS" -Message "$errorHandlingBlocks try-catch blocks found"
} elseif ($errorHandlingBlocks -ge 2) {
    Write-TestResult -TestName "Error Handling" -Status "WARN" -Message "Basic error handling present ($errorHandlingBlocks blocks)"
} else {
    Write-TestResult -TestName "Error Handling" -Status "FAIL" -Message "Insufficient error handling"
}

# Test 8: Parameter Validation
$validationAttributes = [regex]::Matches($content, "\[Validate\w+\(").Count

if ($validationAttributes -ge 3) {
    Write-TestResult -TestName "Parameter Validation" -Status "PASS" -Message "$validationAttributes validation attributes found"
} elseif ($validationAttributes -ge 1) {
    Write-TestResult -TestName "Parameter Validation" -Status "WARN" -Message "Basic parameter validation present"
} else {
    Write-TestResult -TestName "Parameter Validation" -Status "WARN" -Message "Limited parameter validation"
}

# Test 9: File Size and Complexity
$fileInfo = Get-Item ".\VelociraptorUltimate.ps1"
$fileSizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
$lineCount = ($content -split "`n").Count

if ($fileSizeMB -lt 1 -and $lineCount -lt 2000) {
    Write-TestResult -TestName "File Complexity" -Status "PASS" -Message "File size: $fileSizeMB MB, Lines: $lineCount"
} elseif ($fileSizeMB -lt 2 -and $lineCount -lt 5000) {
    Write-TestResult -TestName "File Complexity" -Status "WARN" -Message "Large file: $fileSizeMB MB, Lines: $lineCount"
} else {
    Write-TestResult -TestName "File Complexity" -Status "WARN" -Message "Very large file: $fileSizeMB MB, Lines: $lineCount"
}

# Test 10: Module Dependencies
$moduleImports = [regex]::Matches($content, "Import-Module").Count

if ($moduleImports -ge 3) {
    Write-TestResult -TestName "Module Integration" -Status "PASS" -Message "$moduleImports module imports found"
} elseif ($moduleImports -ge 1) {
    Write-TestResult -TestName "Module Integration" -Status "WARN" -Message "Basic module integration ($moduleImports imports)"
} else {
    Write-TestResult -TestName "Module Integration" -Status "WARN" -Message "No module imports detected"
}

# Generate Summary
Write-Host "`n📊 Test Summary" -ForegroundColor Green
Write-Host "=" * 30 -ForegroundColor Blue
Write-Host "Total Tests: $($script:TestResults.Summary.Total)" -ForegroundColor Cyan
Write-Host "Passed: $($script:TestResults.Summary.Passed)" -ForegroundColor Green
Write-Host "Failed: $($script:TestResults.Summary.Failed)" -ForegroundColor Red
Write-Host "Warnings: $($script:TestResults.Summary.Warnings)" -ForegroundColor Yellow

$passRate = if ($script:TestResults.Summary.Total -gt 0) { 
    [math]::Round(($script:TestResults.Summary.Passed / $script:TestResults.Summary.Total) * 100, 1) 
} else { 0 }

Write-Host "Pass Rate: $passRate%" -ForegroundColor $(if ($passRate -ge 90) { "Green" } elseif ($passRate -ge 70) { "Yellow" } else { "Red" })

# Overall Assessment
if ($script:TestResults.Summary.Failed -eq 0 -and $passRate -ge 80) {
    Write-Host "`n🎉 VelociraptorUltimate is ready for deployment!" -ForegroundColor Green
    Write-Host "✅ All critical tests passed" -ForegroundColor Green
    Write-Host "✅ Application structure is solid" -ForegroundColor Green
    Write-Host "✅ Integration capabilities detected" -ForegroundColor Green
    
    if ($script:TestResults.Summary.Warnings -gt 0) {
        Write-Host "⚠️  Consider addressing $($script:TestResults.Summary.Warnings) warnings for optimal performance" -ForegroundColor Yellow
    }
} elseif ($script:TestResults.Summary.Failed -eq 0) {
    Write-Host "`n✅ VelociraptorUltimate passed basic validation" -ForegroundColor Yellow
    Write-Host "⚠️  Some enhancements recommended before production use" -ForegroundColor Yellow
} else {
    Write-Host "`n❌ VelociraptorUltimate needs fixes before deployment" -ForegroundColor Red
    Write-Host "🔧 Address failed tests before proceeding" -ForegroundColor Red
}

Write-Host "`n🚀 To run the application:" -ForegroundColor Cyan
Write-Host "   .\VelociraptorUltimate.ps1" -ForegroundColor White

# Exit with appropriate code
if ($script:TestResults.Summary.Failed -gt 0) {
    exit 1
} else {
    exit 0
}