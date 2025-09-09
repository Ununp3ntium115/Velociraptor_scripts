#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Test runner for Velociraptor Setup Scripts

.DESCRIPTION
    Runs all Pester tests for the Velociraptor deployment scripts and modules.
    Supports different test categories and output formats.

.PARAMETER TestType
    Type of tests to run: All, Unit, Integration, Security

.PARAMETER OutputFormat
    Output format: NUnitXml, JUnitXml, Console

.PARAMETER OutputPath
    Path to save test results

.PARAMETER PassThru
    Return test results object

.EXAMPLE
    .\Run-Tests.ps1

.EXAMPLE
    .\Run-Tests.ps1 -TestType Unit -OutputFormat NUnitXml -OutputPath "TestResults.xml"

.EXAMPLE
    .\Run-Tests.ps1 -TestType Security -PassThru
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('All', 'Unit', 'Integration', 'Security')]
    [string]$TestType = 'All',
    
    [Parameter()]
    [ValidateSet('Console', 'NUnitXml', 'JUnitXml')]
    [string]$OutputFormat = 'Console',
    
    [Parameter()]
    [string]$OutputPath,
    
    [Parameter()]
    [switch]$PassThru
)

# Ensure we're in the correct directory
$ScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
Set-Location $ScriptRoot

# Check for Pester module
if (-not (Get-Module -ListAvailable -Name Pester)) {
    Write-Warning "Pester module not found. Installing..."
    try {
        Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser
        Write-Host "Pester module installed successfully" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to install Pester module: $($_.Exception.Message)"
        exit 1
    }
}

# Import Pester
Import-Module Pester -Force

# Define test paths
$TestPaths = @{
    'Unit' = Join-Path $ScriptRoot 'unit'
    'Integration' = Join-Path $ScriptRoot 'integration'
    'Security' = Join-Path $ScriptRoot 'security'
}

# Determine which tests to run
$TestsToRun = switch ($TestType) {
    'All' { $TestPaths.Values }
    'Unit' { $TestPaths.Unit }
    'Integration' { $TestPaths.Integration }
    'Security' { $TestPaths.Security }
}

# Filter existing test paths
$ExistingTests = $TestsToRun | Where-Object { Test-Path $_ }

if (-not $ExistingTests) {
    Write-Error "No test files found for test type: $TestType"
    exit 1
}

Write-Host "Running $TestType tests..." -ForegroundColor Cyan
Write-Host "Test paths: $($ExistingTests -join ', ')" -ForegroundColor Gray

# Configure Pester based on version
$PesterVersion = (Get-Module Pester).Version
Write-Host "Using Pester version: $PesterVersion" -ForegroundColor Gray

# Run tests with enhanced reporting
try {
    if ($PesterVersion.Major -ge 5) {
        # Pester 5.x configuration with code coverage
        $PesterConfig = @{
            Run = @{
                Path = $ExistingTests
                PassThru = $true
            }
            Output = @{
                Verbosity = 'Detailed'
            }
            CodeCoverage = @{
                Enabled = $true
                Path = @(
                    "$ScriptRoot\..\Deploy_Velociraptor_Standalone.ps1",
                    "$ScriptRoot\..\Deploy_Velociraptor_Server.ps1",
                    "$ScriptRoot\..\modules\**\*.ps1",
                    "$ScriptRoot\..\scripts\**\*.ps1"
                )
                OutputFormat = 'JaCoCo'
                OutputPath = Join-Path $ScriptRoot 'coverage.xml'
            }
        }
        
        # Add output configuration if specified
        if ($OutputFormat -ne 'Console' -and $OutputPath) {
            $PesterConfig.TestResult = @{
                Enabled = $true
                OutputFormat = $OutputFormat
                OutputPath = $OutputPath
            }
            Write-Host "Test results will be saved to: $OutputPath" -ForegroundColor Gray
        }
        
        $TestResults = Invoke-Pester -Configuration $PesterConfig
    } else {
        # Pester 4.x/3.x configuration with code coverage
        $invokeParams = @{
            Script = $ExistingTests
            PassThru = $true
        }
        
        # Add code coverage for Pester 4.x+ only
        if ($PesterVersion.Major -ge 4) {
            $invokeParams.CodeCoverage = @(
                "$ScriptRoot\..\Deploy_Velociraptor_Standalone.ps1",
                "$ScriptRoot\..\Deploy_Velociraptor_Server.ps1",
                "$ScriptRoot\..\modules\**\*.ps1",
                "$ScriptRoot\..\scripts\**\*.ps1"
            )
            $invokeParams.CodeCoverageOutputFile = Join-Path $ScriptRoot 'coverage.xml'
            $invokeParams.CodeCoverageOutputFileFormat = 'JaCoCoXml'
        }
        
        if ($OutputFormat -ne 'Console' -and $OutputPath) {
            $invokeParams.OutputFile = $OutputPath
            $invokeParams.OutputFormat = $OutputFormat
            Write-Host "Test results will be saved to: $OutputPath" -ForegroundColor Gray
        }
        
        $TestResults = Invoke-Pester @invokeParams
    }
    
    # Display summary
    Write-Host "`n" -NoNewline
    Write-Host "Test Summary:" -ForegroundColor Cyan
    Write-Host "  Total Tests: $($TestResults.TotalCount)" -ForegroundColor White
    Write-Host "  Passed: $($TestResults.PassedCount)" -ForegroundColor Green
    Write-Host "  Failed: $($TestResults.FailedCount)" -ForegroundColor $(if ($TestResults.FailedCount -gt 0) { 'Red' } else { 'Green' })
    Write-Host "  Skipped: $($TestResults.SkippedCount)" -ForegroundColor Yellow
    Write-Host "  Duration: $($TestResults.Duration)" -ForegroundColor Gray
    
    # Display code coverage if available (Pester 4.x+ only)
    if ($TestResults.CodeCoverage -and $PesterVersion.Major -ge 4) {
        $coverage = $TestResults.CodeCoverage
        $coveragePercent = if ($coverage.NumberOfCommandsAnalyzed -gt 0) {
            [math]::Round(($coverage.NumberOfCommandsExecuted / $coverage.NumberOfCommandsAnalyzed) * 100, 2)
        } else { 0 }
        
        Write-Host "`nCode Coverage:" -ForegroundColor Cyan
        Write-Host "  Commands Analyzed: $($coverage.NumberOfCommandsAnalyzed)" -ForegroundColor White
        Write-Host "  Commands Executed: $($coverage.NumberOfCommandsExecuted)" -ForegroundColor White
        Write-Host "  Coverage Percentage: $coveragePercent%" -ForegroundColor $(if ($coveragePercent -ge 80) { 'Green' } elseif ($coveragePercent -ge 60) { 'Yellow' } else { 'Red' })
        
        if ($coverage.MissedCommands.Count -gt 0) {
            Write-Host "  Missed Commands: $($coverage.MissedCommands.Count)" -ForegroundColor Red
        }
        
        Write-Host "  Coverage Report: $(Join-Path $ScriptRoot 'coverage.xml')" -ForegroundColor Gray
    } elseif ($PesterVersion.Major -lt 4) {
        Write-Host "`nCode Coverage: Not available (Pester $($PesterVersion) - upgrade to 4.x+ for coverage)" -ForegroundColor Yellow
    }
    
    # Show failed tests if any
    if ($TestResults.FailedCount -gt 0) {
        Write-Host "`nFailed Tests:" -ForegroundColor Red
        $TestResults.Tests | Where-Object { $_.Result -eq 'Failed' } | ForEach-Object {
            Write-Host "  - $($_.ExpandedName)" -ForegroundColor Red
            if ($_.ErrorRecord) {
                Write-Host "    Error: $($_.ErrorRecord.Exception.Message)" -ForegroundColor DarkRed
            }
        }
    }
    
    # Return results if requested
    if ($PassThru) {
        return $TestResults
    }
    
    # Exit with appropriate code
    exit $(if ($TestResults.FailedCount -gt 0) { 1 } else { 0 })
}
catch {
    Write-Error "Test execution failed: $($_.Exception.Message)"
    exit 1
}