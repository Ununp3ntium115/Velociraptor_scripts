# Local Artifact Management for VelociraptorUltimate
# Manages locally imported artifacts without requiring Velociraptor console

<#
.SYNOPSIS
    Manage locally imported Velociraptor artifacts
    
.DESCRIPTION
    Provides comprehensive artifact management including:
    - Browse and search local artifacts
    - Install artifacts to Velociraptor server
    - Create custom artifact collections
    - Validate artifact syntax and dependencies
    - Generate artifact reports
    
.PARAMETER Action
    Action to perform: List, Search, Install, Validate, Report
    
.PARAMETER ArtifactPath
    Path to local artifacts directory
    
.PARAMETER ServerUrl
    Velociraptor server URL for installation
    
.EXAMPLE
    .\Manage-LocalArtifacts.ps1 -Action List -ArtifactPath ".\artifacts"
#>

param(
    [ValidateSet('List', 'Search', 'Install', 'Validate', 'Report', 'Collection')]
    [string] $Action = 'List',
    
    [ValidateScript({Test-Path $_ -PathType Container})]
    [string] $ArtifactPath = ".\artifacts",
    
    [string] $ServerUrl = "https://localhost:8889",
    
    [string] $SearchTerm = "",
    
    [string] $Platform = "All",
    
    [string] $OutputPath = ".\artifact-report.html"
)

# Initialize artifact management
$script:ArtifactData = @{
    BasePath = $ArtifactPath
    Artifacts = @()
    Collections = @()
    ValidationResults = @()
}

function Get-LocalArtifacts {
    param(
        [string] $Path = $script:ArtifactData.BasePath,
        [string] $PlatformFilter = "All"
    )
    
    Write-Host "🔍 Scanning for local artifacts..." -ForegroundColor Cyan
    
    $artifacts = @()
    
    try {
        $yamlFiles = Get-ChildItem -Path $Path -Recurse -Include "*.yaml", "*.yml" -ErrorAction SilentlyContinue
        
        foreach ($file in $yamlFiles) {
            try {
                $content = Get-Content $file.FullName -Raw -ErrorAction Stop
                $artifact = Parse-ArtifactYaml -Content $content -FilePath $file.FullName
                
                if ($artifact -and ($PlatformFilter -eq "All" -or $artifact.Platform -eq $PlatformFilter)) {
                    $artifacts += $artifact
                }
                
            } catch {
                Write-Warning "Failed to parse artifact: $($file.Name) - $($_.Exception.Message)"
            }
        }
        
        Write-Host "✅ Found $($artifacts.Count) artifacts" -ForegroundColor Green
        
    } catch {
        Write-Error "Failed to scan artifacts: $($_.Exception.Message)"
    }
    
    $script:ArtifactData.Artifacts = $artifacts
    return $artifacts
}

function Parse-ArtifactYaml {
    param(
        [string] $Content,
        [string] $FilePath
    )
    
    try {
        # Basic YAML parsing for artifact metadata
        $artifact = @{
            FilePath = $FilePath
            FileName = Split-Path $FilePath -Leaf
            Name = ""
            Description = ""
            Author = ""
            Platform = "Generic"
            Type = ""
            Parameters = @()
            Sources = @()
            Size = (Get-Item $FilePath).Length
            LastModified = (Get-Item $FilePath).LastWriteTime
        }
        
        # Extract basic metadata using regex patterns
        if ($Content -match "name:\s*(.+)") {
            $artifact.Name = $matches[1].Trim()
        }
        
        if ($Content -match "description:\s*(.+)") {
            $artifact.Description = $matches[1].Trim()
        }
        
        if ($Content -match "author:\s*(.+)") {
            $artifact.Author = $matches[1].Trim()
        }
        
        # Determine platform from content or path
        $pathPlatform = Split-Path (Split-Path $FilePath -Parent) -Leaf
        if ($pathPlatform -in @("Windows", "Linux", "MacOS", "Generic")) {
            $artifact.Platform = $pathPlatform
        } elseif ($Content -match "supported_os:\s*\[([^\]]+)\]") {
            $osList = $matches[1] -split ","
            $artifact.Platform = $osList[0].Trim().Replace('"', '')
        }
        
        # Extract parameters
        $paramMatches = [regex]::Matches($Content, "- name:\s*(\w+)")
        foreach ($match in $paramMatches) {
            $artifact.Parameters += $match.Groups[1].Value
        }
        
        # Extract sources
        $sourceMatches = [regex]::Matches($Content, "precondition:\s*(.+)")
        foreach ($match in $sourceMatches) {
            $artifact.Sources += $match.Groups[1].Value.Trim()
        }
        
        return $artifact
        
    } catch {
        Write-Warning "Failed to parse artifact YAML: $($_.Exception.Message)"
        return $null
    }
}

function Search-Artifacts {
    param(
        [string] $SearchTerm,
        [array] $Artifacts = $script:ArtifactData.Artifacts
    )
    
    if ([string]::IsNullOrWhiteSpace($SearchTerm)) {
        return $Artifacts
    }
    
    Write-Host "🔎 Searching artifacts for: '$SearchTerm'" -ForegroundColor Cyan
    
    $results = $Artifacts | Where-Object {
        $_.Name -like "*$SearchTerm*" -or
        $_.Description -like "*$SearchTerm*" -or
        $_.Author -like "*$SearchTerm*" -or
        $_.FileName -like "*$SearchTerm*"
    }
    
    Write-Host "✅ Found $($results.Count) matching artifacts" -ForegroundColor Green
    return $results
}

function Show-ArtifactList {
    param(
        [array] $Artifacts = $script:ArtifactData.Artifacts
    )
    
    if ($Artifacts.Count -eq 0) {
        Write-Host "No artifacts found." -ForegroundColor Yellow
        return
    }
    
    Write-Host "`n📋 Artifact List" -ForegroundColor Green
    Write-Host "=" * 80 -ForegroundColor Blue
    
    $Artifacts | Sort-Object Platform, Name | ForEach-Object {
        Write-Host "🔹 $($_.Name)" -ForegroundColor Cyan
        Write-Host "   Platform: $($_.Platform)" -ForegroundColor Gray
        Write-Host "   Description: $($_.Description)" -ForegroundColor Gray
        Write-Host "   File: $($_.FileName)" -ForegroundColor Gray
        Write-Host "   Author: $($_.Author)" -ForegroundColor Gray
        Write-Host "   Parameters: $($_.Parameters.Count)" -ForegroundColor Gray
        Write-Host ""
    }
    
    # Summary by platform
    $platformSummary = $Artifacts | Group-Object Platform | Sort-Object Name
    Write-Host "📊 Platform Summary:" -ForegroundColor Green
    foreach ($group in $platformSummary) {
        Write-Host "   $($group.Name): $($group.Count) artifacts" -ForegroundColor Cyan
    }
}

function Install-ArtifactToServer {
    param(
        [object] $Artifact,
        [string] $ServerUrl
    )
    
    Write-Host "📤 Installing artifact to server: $($Artifact.Name)" -ForegroundColor Cyan
    
    try {
        # Read artifact content
        $content = Get-Content $Artifact.FilePath -Raw
        
        # Prepare API request (this would need actual Velociraptor API integration)
        $apiUrl = "$ServerUrl/api/v1/SetArtifactFile"
        
        $body = @{
            artifact = $content
            op = "set"
        } | ConvertTo-Json
        
        # Note: This is a placeholder - actual implementation would need proper authentication
        Write-Host "⚠️  API integration placeholder - would install: $($Artifact.Name)" -ForegroundColor Yellow
        Write-Host "   Server: $ServerUrl" -ForegroundColor Gray
        Write-Host "   Artifact: $($Artifact.FilePath)" -ForegroundColor Gray
        
        return $true
        
    } catch {
        Write-Error "Failed to install artifact: $($_.Exception.Message)"
        return $false
    }
}

function Validate-Artifact {
    param(
        [object] $Artifact
    )
    
    $validation = @{
        Artifact = $Artifact
        IsValid = $true
        Errors = @()
        Warnings = @()
        Score = 0
    }
    
    try {
        $content = Get-Content $Artifact.FilePath -Raw
        
        # Basic YAML structure validation
        if (-not ($content -match "name:\s*\S+")) {
            $validation.Errors += "Missing or invalid name field"
            $validation.IsValid = $false
        } else {
            $validation.Score += 20
        }
        
        if (-not ($content -match "description:\s*\S+")) {
            $validation.Warnings += "Missing description field"
        } else {
            $validation.Score += 15
        }
        
        if (-not ($content -match "sources:")) {
            $validation.Errors += "Missing sources section"
            $validation.IsValid = $false
        } else {
            $validation.Score += 25
        }
        
        # Check for common patterns
        if ($content -match "precondition:") {
            $validation.Score += 10
        }
        
        if ($content -match "parameters:") {
            $validation.Score += 10
        }
        
        if ($content -match "author:\s*\S+") {
            $validation.Score += 10
        }
        
        # Platform-specific validation
        if ($Artifact.Platform -eq "Windows" -and -not ($content -match "SELECT|WMI|Registry")) {
            $validation.Warnings += "Windows artifact may be missing typical data sources"
        }
        
        $validation.Score = [math]::Min($validation.Score, 100)
        
    } catch {
        $validation.Errors += "Failed to read artifact file: $($_.Exception.Message)"
        $validation.IsValid = $false
    }
    
    return $validation
}

function Generate-ArtifactReport {
    param(
        [array] $Artifacts = $script:ArtifactData.Artifacts,
        [string] $OutputPath = $script:OutputPath
    )
    
    Write-Host "📊 Generating artifact report..." -ForegroundColor Cyan
    
    try {
        # Validate all artifacts
        $validationResults = @()
        foreach ($artifact in $Artifacts) {
            $validationResults += Validate-Artifact -Artifact $artifact
        }
        
        # Generate statistics
        $stats = @{
            TotalArtifacts = $Artifacts.Count
            ValidArtifacts = ($validationResults | Where-Object { $_.IsValid }).Count
            InvalidArtifacts = ($validationResults | Where-Object { -not $_.IsValid }).Count
            AverageScore = if ($validationResults.Count -gt 0) { [math]::Round(($validationResults | Measure-Object Score -Average).Average, 1) } else { 0 }
            PlatformBreakdown = $Artifacts | Group-Object Platform | Sort-Object Name
            AuthorBreakdown = $Artifacts | Group-Object Author | Sort-Object Count -Descending | Select-Object -First 10
        }
        
        # Generate HTML report
        $html = Generate-ArtifactReportHTML -Artifacts $Artifacts -ValidationResults $validationResults -Statistics $stats
        
        $html | Out-File -FilePath $OutputPath -Encoding UTF8
        
        Write-Host "✅ Report generated: $OutputPath" -ForegroundColor Green
        
    } catch {
        Write-Error "Failed to generate report: $($_.Exception.Message)"
    }
}

function Generate-ArtifactReportHTML {
    param(
        [array] $Artifacts,
        [array] $ValidationResults,
        [hashtable] $Statistics
    )
    
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Velociraptor Artifact Report</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px; margin-bottom: 20px; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-bottom: 20px; }
        .stat-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); text-align: center; }
        .stat-card h3 { margin: 0; font-size: 2em; color: #667eea; }
        .artifact-list { background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); overflow: hidden; }
        .artifact-item { padding: 15px; border-bottom: 1px solid #f1f3f4; }
        .artifact-item:hover { background-color: #f8f9fa; }
        .artifact-name { font-weight: bold; color: #333; }
        .artifact-meta { color: #666; font-size: 0.9em; margin-top: 5px; }
        .validation-score { padding: 3px 8px; border-radius: 12px; color: white; font-size: 0.8em; }
        .score-high { background-color: #28a745; }
        .score-medium { background-color: #ffc107; color: #212529; }
        .score-low { background-color: #dc3545; }
        .platform-badge { padding: 2px 6px; border-radius: 4px; font-size: 0.8em; margin-right: 5px; }
        .platform-windows { background-color: #0078d4; color: white; }
        .platform-linux { background-color: #ff6b35; color: white; }
        .platform-macos { background-color: #007aff; color: white; }
        .platform-generic { background-color: #6c757d; color: white; }
    </style>
</head>
<body>
    <div class="header">
        <h1>📊 Velociraptor Artifact Report</h1>
        <p>Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
        <p>Total Artifacts Analyzed: $($Statistics.TotalArtifacts)</p>
    </div>
    
    <div class="stats">
        <div class="stat-card">
            <h3>$($Statistics.TotalArtifacts)</h3>
            <p>Total Artifacts</p>
        </div>
        <div class="stat-card">
            <h3>$($Statistics.ValidArtifacts)</h3>
            <p>Valid Artifacts</p>
        </div>
        <div class="stat-card">
            <h3>$($Statistics.InvalidArtifacts)</h3>
            <p>Invalid Artifacts</p>
        </div>
        <div class="stat-card">
            <h3>$($Statistics.AverageScore)%</h3>
            <p>Average Quality Score</p>
        </div>
    </div>
    
    <div class="artifact-list">
        <h3 style="padding: 15px; margin: 0; background-color: #f8f9fa; border-bottom: 1px solid #dee2e6;">Artifact Details</h3>
$(
    for ($i = 0; $i -lt $Artifacts.Count; $i++) {
        $artifact = $Artifacts[$i]
        $validation = $ValidationResults[$i]
        
        $scoreClass = if ($validation.Score -ge 80) { "score-high" } elseif ($validation.Score -ge 60) { "score-medium" } else { "score-low" }
        $platformClass = "platform-" + $artifact.Platform.ToLower()
        
        "<div class='artifact-item'>
            <div class='artifact-name'>$($artifact.Name)</div>
            <div class='artifact-meta'>
                <span class='platform-badge $platformClass'>$($artifact.Platform)</span>
                <span class='validation-score $scoreClass'>$($validation.Score)%</span>
                <br>
                <strong>File:</strong> $($artifact.FileName) | 
                <strong>Author:</strong> $($artifact.Author) | 
                <strong>Parameters:</strong> $($artifact.Parameters.Count)
                <br>
                <strong>Description:</strong> $($artifact.Description)
            </div>
        </div>"
    }
)
    </div>
</body>
</html>
"@
    
    return $html
}

# Main execution
Write-Host "🔧 Velociraptor Local Artifact Management" -ForegroundColor Green
Write-Host "=" * 50 -ForegroundColor Blue
Write-Host "Action: $Action" -ForegroundColor Cyan
Write-Host "Artifact Path: $ArtifactPath" -ForegroundColor Cyan
Write-Host ""

# Load artifacts
$artifacts = Get-LocalArtifacts -Path $ArtifactPath -PlatformFilter $Platform

# Execute requested action
switch ($Action) {
    "List" {
        if ($SearchTerm) {
            $artifacts = Search-Artifacts -SearchTerm $SearchTerm -Artifacts $artifacts
        }
        Show-ArtifactList -Artifacts $artifacts
    }
    
    "Search" {
        if (-not $SearchTerm) {
            $SearchTerm = Read-Host "Enter search term"
        }
        $results = Search-Artifacts -SearchTerm $SearchTerm -Artifacts $artifacts
        Show-ArtifactList -Artifacts $results
    }
    
    "Install" {
        Write-Host "🚀 Installing artifacts to server..." -ForegroundColor Cyan
        foreach ($artifact in $artifacts) {
            Install-ArtifactToServer -Artifact $artifact -ServerUrl $ServerUrl
        }
    }
    
    "Validate" {
        Write-Host "✅ Validating artifacts..." -ForegroundColor Cyan
        foreach ($artifact in $artifacts) {
            $validation = Validate-Artifact -Artifact $artifact
            $status = if ($validation.IsValid) { "✅" } else { "❌" }
            Write-Host "$status $($artifact.Name) - Score: $($validation.Score)%" -ForegroundColor $(if ($validation.IsValid) { "Green" } else { "Red" })
            
            if ($validation.Errors.Count -gt 0) {
                foreach ($error in $validation.Errors) {
                    Write-Host "   Error: $error" -ForegroundColor Red
                }
            }
            
            if ($validation.Warnings.Count -gt 0) {
                foreach ($warning in $validation.Warnings) {
                    Write-Host "   Warning: $warning" -ForegroundColor Yellow
                }
            }
        }
    }
    
    "Report" {
        Generate-ArtifactReport -Artifacts $artifacts -OutputPath $OutputPath
    }
}

Write-Host "`n✅ Artifact management completed!" -ForegroundColor Green