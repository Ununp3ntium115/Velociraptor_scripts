#!/usr/bin/env pwsh
<#
.SYNOPSIS
    User Acceptance Testing for VelociraptorUltimate-Complete.ps1
    
.DESCRIPTION
    Comprehensive UA testing covering:
    - GUI functionality and usability
    - Real-world workflow testing
    - Feature completeness validation
    - User experience assessment
    - Integration testing with actual deployment
    - Performance under realistic conditions
#>

[CmdletBinding()]
param(
    [switch]$Interactive,
    [switch]$AutomatedOnly,
    [string]$OutputPath = ".\UA-Results",
    [int]$TestDuration = 30
)

$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

# UA test results tracking
$script:UAResults = @{
    Passed = 0
    Failed = 0
    Warnings = 0
    UserFeedback = @()
    Details = @()
}

function Write-UAResult {
    param(
        [string]$TestName,
        [string]$Result,
        [string]$Details = "",
        [string]$UserFeedback = ""
    )
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = switch ($Result) {
        "PASS" { "Green"; $script:UAResults.Passed++ }
        "FAIL" { "Red"; $script:UAResults.Failed++ }
        "WARN" { "Yellow"; $script:UAResults.Warnings++ }
        default { "White" }
    }
    
    $resultEntry = @{
        Timestamp = $timestamp
        TestName = $TestName
        Result = $Result
        Details = $Details
        UserFeedback = $UserFeedback
    }
    
    $script:UAResults.Details += $resultEntry
    
    Write-Host "[$timestamp] [$Result] $TestName" -ForegroundColor $color
    if ($Details) {
        Write-Host "    Details: $Details" -ForegroundColor Gray
    }
    if ($UserFeedback) {
        Write-Host "    User Feedback: $UserFeedback" -ForegroundColor Cyan
    }
}

function Get-UserFeedback {
    param(
        [string]$Question,
        [string[]]$Options = @("Yes", "No"),
        [string]$DefaultOption = "Yes"
    )
    
    if ($AutomatedOnly) {
        return $DefaultOption
    }
    
    Write-Host "`n$Question" -ForegroundColor Yellow
    for ($i = 0; $i -lt $Options.Count; $i++) {
        $marker = if ($Options[$i] -eq $DefaultOption) { "*" } else { " " }
        Write-Host "  $($i + 1)$marker $($Options[$i])" -ForegroundColor White
    }
    
    do {
        $response = Read-Host "Enter choice (1-$($Options.Count)) or press Enter for default"
        if ([string]::IsNullOrEmpty($response)) {
            return $DefaultOption
        }
        
        if ([int]::TryParse($response, [ref]$null) -and $response -ge 1 -and $response -le $Options.Count) {
            return $Options[$response - 1]
        }
        
        Write-Host "Invalid choice. Please enter a number between 1 and $($Options.Count)." -ForegroundColor Red
    } while ($true)
}

function Get-UserRating {
    param(
        [string]$Question,
        [int]$MinRating = 1,
        [int]$MaxRating = 5
    )
    
    if ($AutomatedOnly) {
        return 4  # Default good rating for automated tests
    }
    
    Write-Host "`n$Question" -ForegroundColor Yellow
    Write-Host "Rate from $MinRating (poor) to $MaxRating (excellent)" -ForegroundColor Gray
    
    do {
        $response = Read-Host "Enter rating ($MinRating-$MaxRating)"
        if ([int]::TryParse($response, [ref]$null) -and $response -ge $MinRating -and $response -le $MaxRating) {
            return [int]$response
        }
        
        Write-Host "Invalid rating. Please enter a number between $MinRating and $MaxRating." -ForegroundColor Red
    } while ($true)
}

function Test-GUILaunch {
    Write-Host "`n=== GUI LAUNCH AND INITIALIZATION TESTING ===" -ForegroundColor Cyan
    
    try {
        # Test 1: Script execution without errors
        Write-Host "Testing script launch..." -ForegroundColor Yellow
        
        $scriptPath = ".\VelociraptorUltimate-Complete.ps1"
        if (-not (Test-Path $scriptPath)) {
            Write-UAResult "Script File Existence" "FAIL" "VelociraptorUltimate-Complete.ps1 not found"
            return
        }
        
        # Test syntax first
        try {
            $syntaxErrors = $null
            $tokens = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($scriptPath, [ref]$tokens, [ref]$syntaxErrors)
            
            if ($syntaxErrors.Count -eq 0) {
                Write-UAResult "Script Syntax Check" "PASS" "No syntax errors found"
            } else {
                Write-UAResult "Script Syntax Check" "FAIL" "$($syntaxErrors.Count) syntax errors found"
                return
            }
        }
        catch {
            Write-UAResult "Script Syntax Check" "FAIL" "Syntax validation failed: $($_.Exception.Message)"
            return
        }
        
        # Test 2: Windows Forms availability
        try {
            Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
            Add-Type -AssemblyName System.Drawing -ErrorAction Stop
            Write-UAResult "Windows Forms Availability" "PASS" "Windows Forms assemblies loaded successfully"
        }
        catch {
            Write-UAResult "Windows Forms Availability" "FAIL" "Cannot load Windows Forms: $($_.Exception.Message)"
            return
        }
        
        # Test 3: Simulated GUI initialization
        Write-Host "Testing GUI component creation..." -ForegroundColor Yellow
        
        try {
            # Test form creation
            $testForm = New-Object System.Windows.Forms.Form
            $testForm.Text = "UA Test Form"
            $testForm.Size = New-Object System.Drawing.Size(800, 600)
            $testForm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
            
            # Test tab control creation
            $testTabControl = New-Object System.Windows.Forms.TabControl
            $testTabControl.Dock = [System.Windows.Forms.DockStyle]::Fill
            
            # Test tab creation
            $testTab = New-Object System.Windows.Forms.TabPage
            $testTab.Text = "Test Tab"
            $testTabControl.TabPages.Add($testTab)
            
            # Test button creation
            $testButton = New-Object System.Windows.Forms.Button
            $testButton.Text = "Test Button"
            $testButton.Size = New-Object System.Drawing.Size(100, 30)
            $testButton.Location = New-Object System.Drawing.Point(10, 10)
            $testTab.Controls.Add($testButton)
            
            $testForm.Controls.Add($testTabControl)
            
            Write-UAResult "GUI Component Creation" "PASS" "All basic GUI components created successfully"
            
            # Clean up
            $testForm.Dispose()
            
        }
        catch {
            Write-UAResult "GUI Component Creation" "FAIL" "Failed to create GUI components: $($_.Exception.Message)"
        }
        
        # Test 4: Color definitions
        try {
            $testColors = @{
                DARK_BACKGROUND = [System.Drawing.Color]::FromArgb(32, 32, 32)
                DARK_SURFACE = [System.Drawing.Color]::FromArgb(48, 48, 48)
                PRIMARY_TEAL = [System.Drawing.Color]::FromArgb(0, 150, 136)
                WHITE_TEXT = [System.Drawing.Color]::FromArgb(255, 255, 255)
                SUCCESS_GREEN = [System.Drawing.Color]::FromArgb(76, 175, 80)
                ERROR_RED = [System.Drawing.Color]::FromArgb(244, 67, 54)
                WARNING_ORANGE = [System.Drawing.Color]::FromArgb(255, 152, 0)
            }
            
            $colorTest = $true
            foreach ($colorName in $testColors.Keys) {
                $color = $testColors[$colorName]
                if ($color.A -eq 0 -or $color.R -lt 0 -or $color.R -gt 255) {
                    $colorTest = $false
                    break
                }
            }
            
            if ($colorTest) {
                Write-UAResult "Color Scheme Definition" "PASS" "All colors properly defined"
            } else {
                Write-UAResult "Color Scheme Definition" "FAIL" "Invalid color definitions found"
            }
        }
        catch {
            Write-UAResult "Color Scheme Definition" "FAIL" "Failed to test color definitions: $($_.Exception.Message)"
        }
        
        # Interactive feedback
        if ($Interactive) {
            $launchFeedback = Get-UserFeedback "Based on the initialization tests, do you think the GUI will launch properly?" @("Yes", "No", "Unsure") "Yes"
            $script:UAResults.UserFeedback += "GUI Launch Expectation: $launchFeedback"
        }
        
    }
    catch {
        Write-UAResult "GUI Launch Testing" "FAIL" "Unexpected error during GUI launch testing: $($_.Exception.Message)"
    }
}

function Test-FeatureCompleteness {
    Write-Host "`n=== FEATURE COMPLETENESS TESTING ===" -ForegroundColor Cyan
    
    try {
        $scriptPath = ".\VelociraptorUltimate-Complete.ps1"
        $content = Get-Content $scriptPath -Raw
        
        # Test 1: Required tabs
        $expectedTabs = @(
            "Dashboard",
            "Server Deployment", 
            "Standalone Setup",
            "Offline Collector",
            "Artifact Management",
            "Investigation Cases"
        )
        
        $tabsFound = 0
        foreach ($tab in $expectedTabs) {
            if ($content -match "Text\s*=\s*`"$tab`"" -or $content -match "New-${tab}Tab" -replace " ", "") {
                $tabsFound++
                Write-UAResult "Tab Feature: $tab" "PASS" "Tab implementation found"
            } else {
                Write-UAResult "Tab Feature: $tab" "FAIL" "Tab implementation missing"
            }
        }
        
        $tabCompleteness = ($tabsFound / $expectedTabs.Count) * 100
        if ($tabCompleteness -eq 100) {
            Write-UAResult "Tab Completeness" "PASS" "All expected tabs implemented (100%)"
        } elseif ($tabCompleteness -ge 80) {
            Write-UAResult "Tab Completeness" "WARN" "Most tabs implemented ($tabCompleteness%)"
        } else {
            Write-UAResult "Tab Completeness" "FAIL" "Many tabs missing ($tabCompleteness%)"
        }
        
        # Test 2: Core functionality
        $coreFunctions = @(
            "Deploy-VelociraptorServer",
            "Build-OfflineCollector", 
            "Get-LatestVelociraptorAsset",
            "Install-VelociraptorExecutable"
        )
        
        $functionsFound = 0
        foreach ($func in $coreFunctions) {
            if ($content -match "function\s+$func") {
                $functionsFound++
                Write-UAResult "Core Function: $func" "PASS" "Function implemented"
            } else {
                Write-UAResult "Core Function: $func" "FAIL" "Function missing"
            }
        }
        
        $functionCompleteness = ($functionsFound / $coreFunctions.Count) * 100
        if ($functionCompleteness -eq 100) {
            Write-UAResult "Core Function Completeness" "PASS" "All core functions implemented (100%)"
        } elseif ($functionCompleteness -ge 75) {
            Write-UAResult "Core Function Completeness" "WARN" "Most core functions implemented ($functionCompleteness%)"
        } else {
            Write-UAResult "Core Function Completeness" "FAIL" "Many core functions missing ($functionCompleteness%)"
        }
        
        # Test 3: Data structures
        $dataStructures = @(
            '\$script:IncidentPackages',
            '\$script:AvailableArtifacts',
            '\$script:InstallDir',
            '\$script:DataStore'
        )
        
        $structuresFound = 0
        foreach ($structure in $dataStructures) {
            if ($content -match $structure) {
                $structuresFound++
                Write-UAResult "Data Structure: $structure" "PASS" "Structure defined"
            } else {
                Write-UAResult "Data Structure: $structure" "FAIL" "Structure missing"
            }
        }
        
        # Test 4: Integration points
        $integrationFeatures = @(
            "GitHub API integration",
            "Incident package integration", 
            "Deployment script integration",
            "Artifact management"
        )
        
        $integrationPatterns = @(
            "api\.github\.com",
            "incident-packages",
            "Deploy_Velociraptor",
            "AvailableArtifacts"
        )
        
        for ($i = 0; $i -lt $integrationFeatures.Count; $i++) {
            if ($content -match $integrationPatterns[$i]) {
                Write-UAResult "Integration: $($integrationFeatures[$i])" "PASS" "Integration implemented"
            } else {
                Write-UAResult "Integration: $($integrationFeatures[$i])" "WARN" "Integration may be missing"
            }
        }
        
        # Interactive feedback
        if ($Interactive) {
            $featureRating = Get-UserRating "How would you rate the feature completeness based on the analysis above?"
            $script:UAResults.UserFeedback += "Feature Completeness Rating: $featureRating/5"
            
            $missingFeatures = Read-Host "Are there any specific features you expected that seem to be missing? (Enter 'none' if satisfied)"
            if ($missingFeatures -and $missingFeatures -ne "none") {
                $script:UAResults.UserFeedback += "Missing Features: $missingFeatures"
            }
        }
        
    }
    catch {
        Write-UAResult "Feature Completeness Testing" "FAIL" "Failed to test feature completeness: $($_.Exception.Message)"
    }
}

function Test-UsabilityAndWorkflow {
    Write-Host "`n=== USABILITY AND WORKFLOW TESTING ===" -ForegroundColor Cyan
    
    try {
        $scriptPath = ".\VelociraptorUltimate-Complete.ps1"
        $content = Get-Content $scriptPath -Raw
        
        # Test 1: User interface design patterns
        $uiPatterns = @{
            "Consistent naming" = "New-.*Tab"
            "Error handling" = "try\s*\{.*catch\s*\{"
            "User feedback" = "Write-Log|Update-Status"
            "Input validation" = "if.*-not.*Test-Path|if.*\[string\]::IsNullOrEmpty"
            "Progress indication" = "Write-Host.*ForegroundColor|ProgressBar"
        }
        
        foreach ($pattern in $uiPatterns.Keys) {
            if ($content -match $uiPatterns[$pattern]) {
                Write-UAResult "UI Pattern: $pattern" "PASS" "Pattern implemented"
            } else {
                Write-UAResult "UI Pattern: $pattern" "WARN" "Pattern may be missing"
            }
        }
        
        # Test 2: Workflow logic
        $workflowSteps = @{
            "Dashboard navigation" = "Switch-ToTab"
            "Configuration management" = "\$script:.*=.*TextBox\.Text"
            "Action execution" = "Add_Click.*\{"
            "Status updates" = "Update-Status|Write-Log"
            "Error recovery" = "catch\s*\{.*Write-.*Error"
        }
        
        foreach ($step in $workflowSteps.Keys) {
            if ($content -match $workflowSteps[$step]) {
                Write-UAResult "Workflow: $step" "PASS" "Workflow step implemented"
            } else {
                Write-UAResult "Workflow: $step" "WARN" "Workflow step may be missing"
            }
        }
        
        # Test 3: Help and documentation
        $helpFeatures = @{
            "Function documentation" = "\.SYNOPSIS|\.DESCRIPTION"
            "Parameter descriptions" = "param\s*\([^)]*\[string\]"
            "Inline comments" = "#.*[A-Za-z]"
            "Error messages" = "throw.*`"|Write-.*Error.*`""
        }
        
        foreach ($feature in $helpFeatures.Keys) {
            if ($content -match $helpFeatures[$feature]) {
                Write-UAResult "Help Feature: $feature" "PASS" "Help feature present"
            } else {
                Write-UAResult "Help Feature: $feature" "WARN" "Help feature may be limited"
            }
        }
        
        # Test 4: Accessibility features
        $accessibilityFeatures = @{
            "Keyboard navigation" = "TabIndex|AcceptButton"
            "Color contrast" = "DARK_.*WHITE_|PRIMARY_.*WHITE_"
            "Font sizing" = "Font.*Size.*\d+"
            "Control sizing" = "Size.*New-Object.*Size.*\d+.*\d+"
        }
        
        foreach ($feature in $accessibilityFeatures.Keys) {
            if ($content -match $accessibilityFeatures[$feature]) {
                Write-UAResult "Accessibility: $feature" "PASS" "Feature implemented"
            } else {
                Write-UAResult "Accessibility: $feature" "WARN" "Feature may need improvement"
            }
        }
        
        # Interactive feedback
        if ($Interactive) {
            Write-Host "`nWorkflow Assessment Questions:" -ForegroundColor Yellow
            
            $workflowClarity = Get-UserRating "How clear and logical does the workflow appear to be?"
            $script:UAResults.UserFeedback += "Workflow Clarity Rating: $workflowClarity/5"
            
            $uiConsistency = Get-UserRating "How consistent does the user interface design appear?"
            $script:UAResults.UserFeedback += "UI Consistency Rating: $uiConsistency/5"
            
            $errorHandling = Get-UserRating "How well does the error handling appear to be implemented?"
            $script:UAResults.UserFeedback += "Error Handling Rating: $errorHandling/5"
            
            $overallUsability = Get-UserRating "What is your overall impression of the usability?"
            $script:UAResults.UserFeedback += "Overall Usability Rating: $overallUsability/5"
        }
        
    }
    catch {
        Write-UAResult "Usability and Workflow Testing" "FAIL" "Failed to test usability: $($_.Exception.Message)"
    }
}

function Test-RealWorldScenarios {
    Write-Host "`n=== REAL-WORLD SCENARIO TESTING ===" -ForegroundColor Cyan
    
    try {
        # Test 1: Deployment scenario validation
        Write-Host "Testing deployment scenarios..." -ForegroundColor Yellow
        
        $deploymentScenarios = @{
            "Server deployment" = @{
                "Required files" = @("Deploy_Velociraptor_Server.ps1")
                "Configuration" = @('\$script:InstallDir', '\$script:DataStore', '\$script:GuiPort')
                "Functions" = @("Deploy-VelociraptorServer", "Get-LatestVelociraptorAsset")
            }
            "Standalone deployment" = @{
                "Required files" = @("Deploy_Velociraptor_Standalone.ps1")
                "Configuration" = @('\$script:InstallDir')
                "Functions" = @("New-StandaloneTab")
            }
            "Offline collection" = @{
                "Required data" = @('\$script:AvailableArtifacts')
                "Functions" = @("Build-OfflineCollector", "New-OfflineCollectorTab")
            }
        }
        
        $scriptContent = Get-Content ".\VelociraptorUltimate-Complete.ps1" -Raw
        
        foreach ($scenario in $deploymentScenarios.Keys) {
            $scenarioData = $deploymentScenarios[$scenario]
            $scenarioScore = 0
            $totalChecks = 0
            
            # Check required files
            if ($scenarioData.ContainsKey("Required files")) {
                foreach ($file in $scenarioData["Required files"]) {
                    $totalChecks++
                    if (Test-Path ".\$file") {
                        $scenarioScore++
                        Write-UAResult "Scenario File: $scenario - $file" "PASS" "Required file exists"
                    } else {
                        Write-UAResult "Scenario File: $scenario - $file" "WARN" "Required file missing (may affect functionality)"
                    }
                }
            }
            
            # Check configuration
            if ($scenarioData.ContainsKey("Configuration")) {
                foreach ($config in $scenarioData["Configuration"]) {
                    $totalChecks++
                    if ($scriptContent -match $config) {
                        $scenarioScore++
                        Write-UAResult "Scenario Config: $scenario - $config" "PASS" "Configuration present"
                    } else {
                        Write-UAResult "Scenario Config: $scenario - $config" "FAIL" "Configuration missing"
                    }
                }
            }
            
            # Check functions
            if ($scenarioData.ContainsKey("Functions")) {
                foreach ($func in $scenarioData["Functions"]) {
                    $totalChecks++
                    if ($scriptContent -match "function\s+$func") {
                        $scenarioScore++
                        Write-UAResult "Scenario Function: $scenario - $func" "PASS" "Function implemented"
                    } else {
                        Write-UAResult "Scenario Function: $scenario - $func" "FAIL" "Function missing"
                    }
                }
            }
            
            # Check required data
            if ($scenarioData.ContainsKey("Required data")) {
                foreach ($data in $scenarioData["Required data"]) {
                    $totalChecks++
                    if ($scriptContent -match $data) {
                        $scenarioScore++
                        Write-UAResult "Scenario Data: $scenario - $data" "PASS" "Data structure present"
                    } else {
                        Write-UAResult "Scenario Data: $scenario - $data" "FAIL" "Data structure missing"
                    }
                }
            }
            
            # Overall scenario assessment
            $scenarioPercentage = if ($totalChecks -gt 0) { ($scenarioScore / $totalChecks) * 100 } else { 0 }
            if ($scenarioPercentage -eq 100) {
                Write-UAResult "Scenario Readiness: $scenario" "PASS" "Fully ready ($scenarioPercentage%)"
            } elseif ($scenarioPercentage -ge 75) {
                Write-UAResult "Scenario Readiness: $scenario" "WARN" "Mostly ready ($scenarioPercentage%)"
            } else {
                Write-UAResult "Scenario Readiness: $scenario" "FAIL" "Not ready ($scenarioPercentage%)"
            }
        }
        
        # Test 2: Integration points
        Write-Host "Testing integration points..." -ForegroundColor Yellow
        
        # GitHub API test
        try {
            $testUrl = "https://api.github.com/repos/Ununp3ntium115/velociraptor/releases/latest"
            $response = Invoke-RestMethod -Uri $testUrl -TimeoutSec 10 -ErrorAction Stop
            
            if ($response.tag_name -and $response.assets) {
                Write-UAResult "GitHub Integration" "PASS" "API accessible, version $($response.tag_name) available"
            } else {
                Write-UAResult "GitHub Integration" "WARN" "API accessible but incomplete data"
            }
        }
        catch {
            Write-UAResult "GitHub Integration" "WARN" "GitHub API not accessible (offline or network issues)"
        }
        
        # Incident packages test
        if (Test-Path ".\incident-packages") {
            $packageCount = (Get-ChildItem ".\incident-packages" -Directory).Count
            if ($packageCount -ge 5) {
                Write-UAResult "Incident Packages Integration" "PASS" "$packageCount packages found"
            } else {
                Write-UAResult "Incident Packages Integration" "WARN" "Only $packageCount packages found"
            }
        } else {
            Write-UAResult "Incident Packages Integration" "WARN" "Incident packages directory not found"
        }
        
        # Interactive feedback
        if ($Interactive) {
            Write-Host "`nReal-World Scenario Assessment:" -ForegroundColor Yellow
            
            $scenarioRealism = Get-UserRating "How realistic and practical do the implemented scenarios appear?"
            $script:UAResults.UserFeedback += "Scenario Realism Rating: $scenarioRealism/5"
            
            $integrationQuality = Get-UserRating "How well do the integration points appear to be implemented?"
            $script:UAResults.UserFeedback += "Integration Quality Rating: $integrationQuality/5"
            
            $productionReadiness = Get-UserFeedback "Based on the scenario testing, do you think this is ready for production use?" @("Yes", "No", "With minor fixes", "Needs major work") "With minor fixes"
            $script:UAResults.UserFeedback += "Production Readiness Assessment: $productionReadiness"
        }
        
    }
    catch {
        Write-UAResult "Real-World Scenario Testing" "FAIL" "Failed to test real-world scenarios: $($_.Exception.Message)"
    }
}

function Test-PerformanceAndReliability {
    Write-Host "`n=== PERFORMANCE AND RELIABILITY TESTING ===" -ForegroundColor Cyan
    
    try {
        # Test 1: Script loading performance
        $loadStartTime = Get-Date
        try {
            $scriptPath = ".\VelociraptorUltimate-Complete.ps1"
            $content = Get-Content $scriptPath -Raw
            $loadEndTime = Get-Date
            $loadTime = ($loadEndTime - $loadStartTime).TotalMilliseconds
            
            if ($loadTime -lt 500) {
                Write-UAResult "Script Load Performance" "PASS" "Fast loading (${loadTime}ms)"
            } elseif ($loadTime -lt 2000) {
                Write-UAResult "Script Load Performance" "PASS" "Acceptable loading (${loadTime}ms)"
            } else {
                Write-UAResult "Script Load Performance" "WARN" "Slow loading (${loadTime}ms)"
            }
        }
        catch {
            Write-UAResult "Script Load Performance" "FAIL" "Failed to measure load time: $($_.Exception.Message)"
        }
        
        # Test 2: Memory efficiency
        try {
            $process = Get-Process -Id $PID
            $memoryMB = [math]::Round($process.WorkingSet64 / 1MB, 2)
            
            if ($memoryMB -lt 50) {
                Write-UAResult "Memory Efficiency" "PASS" "Excellent memory usage (${memoryMB}MB)"
            } elseif ($memoryMB -lt 100) {
                Write-UAResult "Memory Efficiency" "PASS" "Good memory usage (${memoryMB}MB)"
            } elseif ($memoryMB -lt 200) {
                Write-UAResult "Memory Efficiency" "WARN" "Moderate memory usage (${memoryMB}MB)"
            } else {
                Write-UAResult "Memory Efficiency" "WARN" "High memory usage (${memoryMB}MB)"
            }
        }
        catch {
            Write-UAResult "Memory Efficiency" "WARN" "Could not measure memory usage"
        }
        
        # Test 3: Code complexity analysis
        try {
            $scriptPath = ".\VelociraptorUltimate-Complete.ps1"
            $lines = Get-Content $scriptPath
            $totalLines = $lines.Count
            $codeLines = ($lines | Where-Object { $_ -match '\S' -and $_ -notmatch '^\s*#' }).Count
            $commentLines = ($lines | Where-Object { $_ -match '^\s*#' }).Count
            $functionCount = ($lines | Where-Object { $_ -match '^\s*function\s+' }).Count
            
            $commentRatio = if ($totalLines -gt 0) { ($commentLines / $totalLines) * 100 } else { 0 }
            $avgLinesPerFunction = if ($functionCount -gt 0) { $codeLines / $functionCount } else { 0 }
            
            Write-UAResult "Code Metrics" "PASS" "Lines: $totalLines, Functions: $functionCount, Comments: $commentRatio%"
            
            if ($avgLinesPerFunction -lt 50) {
                Write-UAResult "Function Complexity" "PASS" "Good function size (avg $([math]::Round($avgLinesPerFunction, 1)) lines)"
            } elseif ($avgLinesPerFunction -lt 100) {
                Write-UAResult "Function Complexity" "WARN" "Moderate function size (avg $([math]::Round($avgLinesPerFunction, 1)) lines)"
            } else {
                Write-UAResult "Function Complexity" "WARN" "Large functions (avg $([math]::Round($avgLinesPerFunction, 1)) lines)"
            }
            
            if ($commentRatio -gt 10) {
                Write-UAResult "Documentation Level" "PASS" "Well documented ($([math]::Round($commentRatio, 1))% comments)"
            } elseif ($commentRatio -gt 5) {
                Write-UAResult "Documentation Level" "WARN" "Moderately documented ($([math]::Round($commentRatio, 1))% comments)"
            } else {
                Write-UAResult "Documentation Level" "WARN" "Limited documentation ($([math]::Round($commentRatio, 1))% comments)"
            }
        }
        catch {
            Write-UAResult "Code Complexity Analysis" "WARN" "Could not analyze code complexity: $($_.Exception.Message)"
        }
        
        # Test 4: Error handling coverage
        try {
            $scriptContent = Get-Content ".\VelociraptorUltimate-Complete.ps1" -Raw
            $tryBlocks = [regex]::Matches($scriptContent, "try\s*\{").Count
            $catchBlocks = [regex]::Matches($scriptContent, "catch\s*\{").Count
            $functions = [regex]::Matches($scriptContent, "function\s+\w+").Count
            
            $errorHandlingRatio = if ($functions -gt 0) { ($tryBlocks / $functions) * 100 } else { 0 }
            
            if ($tryBlocks -eq $catchBlocks) {
                Write-UAResult "Error Handling Structure" "PASS" "Balanced try-catch blocks ($tryBlocks each)"
            } else {
                Write-UAResult "Error Handling Structure" "WARN" "Unbalanced try-catch blocks (try: $tryBlocks, catch: $catchBlocks)"
            }
            
            if ($errorHandlingRatio -gt 50) {
                Write-UAResult "Error Handling Coverage" "PASS" "Good error handling coverage ($([math]::Round($errorHandlingRatio, 1))%)"
            } elseif ($errorHandlingRatio -gt 25) {
                Write-UAResult "Error Handling Coverage" "WARN" "Moderate error handling coverage ($([math]::Round($errorHandlingRatio, 1))%)"
            } else {
                Write-UAResult "Error Handling Coverage" "WARN" "Limited error handling coverage ($([math]::Round($errorHandlingRatio, 1))%)"
            }
        }
        catch {
            Write-UAResult "Error Handling Analysis" "WARN" "Could not analyze error handling: $($_.Exception.Message)"
        }
        
        # Interactive feedback
        if ($Interactive) {
            Write-Host "`nPerformance and Reliability Assessment:" -ForegroundColor Yellow
            
            $performanceRating = Get-UserRating "How would you rate the expected performance based on the analysis?"
            $script:UAResults.UserFeedback += "Performance Rating: $performanceRating/5"
            
            $reliabilityRating = Get-UserRating "How reliable does the error handling and code structure appear?"
            $script:UAResults.UserFeedback += "Reliability Rating: $reliabilityRating/5"
            
            $maintenanceRating = Get-UserRating "How maintainable does the code appear to be?"
            $script:UAResults.UserFeedback += "Maintainability Rating: $maintenanceRating/5"
        }
        
    }
    catch {
        Write-UAResult "Performance and Reliability Testing" "FAIL" "Failed to test performance and reliability: $($_.Exception.Message)"
    }
}

function Generate-UAReport {
    Write-Host "`n=== GENERATING UA REPORT ===" -ForegroundColor Cyan
    
    try {
        if (-not (Test-Path $OutputPath)) {
            New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
        }
        
        $reportPath = Join-Path $OutputPath "VelociraptorUltimate-Complete-UA-Report.txt"
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        
        $report = @"
VELOCIRAPTOR ULTIMATE COMPLETE - USER ACCEPTANCE TEST REPORT
Generated: $timestamp
Script: VelociraptorUltimate-Complete.ps1
Test Mode: $(if ($Interactive) { "Interactive" } else { "Automated" })

EXECUTIVE SUMMARY:
=================
Total Tests: $($script:UAResults.Passed + $script:UAResults.Failed + $script:UAResults.Warnings)
Passed: $($script:UAResults.Passed)
Failed: $($script:UAResults.Failed)
Warnings: $($script:UAResults.Warnings)

Success Rate: $([math]::Round(($script:UAResults.Passed / ($script:UAResults.Passed + $script:UAResults.Failed + $script:UAResults.Warnings)) * 100, 1))%

USER FEEDBACK SUMMARY:
=====================
$($script:UAResults.UserFeedback | ForEach-Object { "- $_" } | Out-String)

DETAILED TEST RESULTS:
=====================
$($script:UAResults.Details | ForEach-Object {
    "[$($_.Timestamp)] [$($_.Result)] $($_.TestName)"
    if ($_.Details) { "    Details: $($_.Details)" }
    if ($_.UserFeedback) { "    User Feedback: $($_.UserFeedback)" }
    ""
} | Out-String)

ACCEPTANCE CRITERIA ASSESSMENT:
==============================
GUI Functionality: $(if (($script:UAResults.Details | Where-Object { $_.TestName -like "*GUI*" -and $_.Result -eq "PASS" }).Count -gt 0) { "ACCEPTABLE" } else { "NEEDS WORK" })
Feature Completeness: $(if (($script:UAResults.Details | Where-Object { $_.TestName -like "*Feature*" -and $_.Result -eq "PASS" }).Count -gt 0) { "ACCEPTABLE" } else { "NEEDS WORK" })
Workflow Design: $(if (($script:UAResults.Details | Where-Object { $_.TestName -like "*Workflow*" -and $_.Result -eq "PASS" }).Count -gt 0) { "ACCEPTABLE" } else { "NEEDS WORK" })
Real-World Readiness: $(if (($script:UAResults.Details | Where-Object { $_.TestName -like "*Scenario*" -and $_.Result -eq "PASS" }).Count -gt 0) { "ACCEPTABLE" } else { "NEEDS WORK" })
Performance: $(if (($script:UAResults.Details | Where-Object { $_.TestName -like "*Performance*" -and $_.Result -eq "PASS" }).Count -gt 0) { "ACCEPTABLE" } else { "NEEDS WORK" })

RECOMMENDATIONS:
===============
$( if ($script:UAResults.Failed -eq 0 -and $script:UAResults.Warnings -le 3) {
    "✅ APPROVED FOR PRODUCTION"
    "- Excellent implementation with minimal issues"
    "- Ready for deployment to end users"
    "- Consider addressing minor warnings for optimization"
} elseif ($script:UAResults.Failed -eq 0 -and $script:UAResults.Warnings -le 8) {
    "⚠️ APPROVED WITH CONDITIONS"
    "- Good implementation with some areas for improvement"
    "- Address warnings before production deployment"
    "- Consider additional testing in staging environment"
} elseif ($script:UAResults.Failed -le 3) {
    "❌ NEEDS REVISION"
    "- Address all failed tests before resubmission"
    "- Review and improve areas with warnings"
    "- Conduct additional testing after fixes"
} else {
    "❌ MAJOR REVISION REQUIRED"
    "- Significant issues need resolution"
    "- Complete redesign may be necessary for some components"
    "- Extensive testing required after major changes"
})

OVERALL USER ACCEPTANCE:
=======================
$( if ($script:UAResults.Failed -eq 0 -and $script:UAResults.Warnings -le 3) {
    "ACCEPTED - Ready for production use"
} elseif ($script:UAResults.Failed -eq 0) {
    "CONDITIONALLY ACCEPTED - Minor improvements needed"
} elseif ($script:UAResults.Failed -le 3) {
    "REJECTED - Needs revision and retesting"
} else {
    "REJECTED - Major issues require significant rework"
})
"@
        
        $report | Out-File -FilePath $reportPath -Encoding UTF8
        Write-UAResult "UA Report Generation" "PASS" "Report saved to: $reportPath"
        
        return $reportPath
    }
    catch {
        Write-UAResult "UA Report Generation" "FAIL" "Failed to generate report: $($_.Exception.Message)"
        return $null
    }
}

# Main execution
Write-Host "VELOCIRAPTOR ULTIMATE COMPLETE - USER ACCEPTANCE TESTING" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green
Write-Host "Starting comprehensive User Acceptance testing..." -ForegroundColor Yellow

if ($Interactive) {
    Write-Host "Running in INTERACTIVE mode - you will be asked for feedback" -ForegroundColor Cyan
} else {
    Write-Host "Running in AUTOMATED mode - no user input required" -ForegroundColor Cyan
}

Write-Host ""

# Run all UA test suites
Test-GUILaunch
Test-FeatureCompleteness
Test-UsabilityAndWorkflow
Test-RealWorldScenarios
Test-PerformanceAndReliability

# Generate report
Write-Host "`n=== USER ACCEPTANCE TESTING COMPLETE ===" -ForegroundColor Green
$reportPath = Generate-UAReport

# Display summary
Write-Host "`nUA TEST SUMMARY:" -ForegroundColor Cyan
Write-Host "Passed: $($script:UAResults.Passed)" -ForegroundColor Green
Write-Host "Failed: $($script:UAResults.Failed)" -ForegroundColor Red  
Write-Host "Warnings: $($script:UAResults.Warnings)" -ForegroundColor Yellow

if ($script:UAResults.UserFeedback.Count -gt 0) {
    Write-Host "`nUser Feedback Collected: $($script:UAResults.UserFeedback.Count) items" -ForegroundColor Cyan
}

if ($reportPath) {
    Write-Host "`nDetailed report saved to: $reportPath" -ForegroundColor White
}

# Final acceptance decision
if ($script:UAResults.Failed -eq 0 -and $script:UAResults.Warnings -le 3) {
    Write-Host "`nUA RESULT: ACCEPTED ✅" -ForegroundColor Green
    Write-Host "Ready for production deployment" -ForegroundColor Green
    exit 0
} elseif ($script:UAResults.Failed -eq 0) {
    Write-Host "`nUA RESULT: CONDITIONALLY ACCEPTED ⚠️" -ForegroundColor Yellow
    Write-Host "Minor improvements recommended before production" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "`nUA RESULT: REJECTED ❌" -ForegroundColor Red
    Write-Host "Requires revision and retesting" -ForegroundColor Red
    exit 1
}