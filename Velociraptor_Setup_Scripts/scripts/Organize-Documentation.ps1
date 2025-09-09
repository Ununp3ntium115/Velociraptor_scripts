#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Organize and clean up documentation files in the repository.

.DESCRIPTION
    This script consolidates scattered .md files throughout the repository
    into the organized steering system, archives outdated documents,
    and creates a clean documentation structure.

.PARAMETER Action
    Action to perform: Organize, Archive, Clean, or All

.PARAMETER DryRun
    Show what would be done without making changes

.EXAMPLE
    .\scripts\Organize-Documentation.ps1 -Action All

.EXAMPLE
    .\scripts\Organize-Documentation.ps1 -Action Organize -DryRun
#>

[CmdletBinding()]
param(
    [ValidateSet('Organize', 'Archive', 'Clean', 'All')]
    [string]$Action = 'All',
    
    [switch]$DryRun
)

$ErrorActionPreference = 'Continue'

#region Helper Functions

function Write-OrgLog {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        [ValidateSet('Info', 'Warning', 'Error', 'Success')]
        [string]$Level = 'Info'
    )
    
    $color = switch ($Level) {
        'Success' { 'Green' }
        'Warning' { 'Yellow' }
        'Error' { 'Red' }
        default { 'White' }
    }
    
    $prefix = switch ($Level) {
        'Success' { '✅' }
        'Warning' { '⚠️' }
        'Error' { '❌' }
        default { 'ℹ️' }
    }
    
    Write-Host "$prefix $Message" -ForegroundColor $color
}

function Get-DocumentClassification {
    param([string]$FileName, [string]$Content)
    
    $fileName = $FileName.ToLower()
    $content = $Content.ToLower()
    
    # Classification rules
    if ($fileName -match 'readme') { return 'Core' }
    if ($fileName -match 'roadmap|plan|strategy') { return 'Planning' }
    if ($fileName -match 'release|changelog|notes') { return 'Release' }
    if ($fileName -match 'gui|interface|user') { return 'GUI' }
    if ($fileName -match 'test|qa|quality') { return 'QA' }
    if ($fileName -match 'security|compliance') { return 'Security' }
    if ($fileName -match 'troubleshoot|issue|fix') { return 'Support' }
    if ($fileName -match 'beta|alpha|rc') { return 'Beta' }
    if ($fileName -match 'contribution|develop') { return 'Development' }
    if ($fileName -match 'deployment|install') { return 'Deployment' }
    
    # Content-based classification
    if ($content -match 'pester|test|coverage') { return 'QA' }
    if ($content -match 'gui|windows forms|interface') { return 'GUI' }
    if ($content -match 'security|compliance|hardening') { return 'Security' }
    if ($content -match 'roadmap|future|plan') { return 'Planning' }
    if ($content -match 'release|version|changelog') { return 'Release' }
    
    return 'General'
}

#endregion

#region Document Organization

function Invoke-DocumentOrganization {
    Write-OrgLog "Starting documentation organization..." -Level Info
    
    # Find all .md files in the repository
    $allMdFiles = Get-ChildItem -Path . -Recurse -Filter "*.md" | Where-Object {
        $_.FullName -notmatch '\\\.git\\|\\node_modules\\|\\steering\\' -and
        $_.Name -ne 'README.md' -or $_.Directory.Name -ne 'Velociraptor_Setup_Scripts'
    }
    
    Write-OrgLog "Found $($allMdFiles.Count) markdown files to organize" -Level Info
    
    # Create archive directory structure
    $archiveDir = Join-Path $PWD 'docs\archive'
    $steeringDir = Join-Path $PWD 'steering'
    
    if (-not $DryRun) {
        if (-not (Test-Path $archiveDir)) {
            New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null
        }
        if (-not (Test-Path $steeringDir)) {
            New-Item -ItemType Directory -Path $steeringDir -Force | Out-Null
        }
    }
    
    # Classify and organize documents
    $classifications = @{}
    
    foreach ($file in $allMdFiles) {
        try {
            $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
            $classification = Get-DocumentClassification -FileName $file.Name -Content $content
            
            if (-not $classifications.ContainsKey($classification)) {
                $classifications[$classification] = @()
            }
            
            $classifications[$classification] += @{
                File = $file
                Content = $content
                Size = $file.Length
                LastModified = $file.LastWriteTime
            }
            
            Write-OrgLog "Classified: $($file.Name) -> $classification" -Level Info
        }
        catch {
            Write-OrgLog "Failed to process $($file.Name): $($_.Exception.Message)" -Level Warning
        }
    }
    
    # Display classification summary
    Write-OrgLog "`nClassification Summary:" -Level Info
    foreach ($category in $classifications.Keys | Sort-Object) {
        $count = $classifications[$category].Count
        $totalSize = ($classifications[$category] | Measure-Object -Property Size -Sum).Sum
        Write-OrgLog "  $category`: $count files ($([math]::Round($totalSize/1KB, 1)) KB)" -Level Info
    }
    
    return $classifications
}

function Move-DocumentsToArchive {
    param([hashtable]$Classifications)
    
    Write-OrgLog "`nMoving documents to archive..." -Level Info
    
    $archiveDir = Join-Path $PWD 'docs\archive'
    $movedCount = 0
    
    # Categories to archive (not move to steering)
    $archiveCategories = @('Beta', 'Release', 'QA', 'Support', 'General', 'Planning')
    
    foreach ($category in $archiveCategories) {
        if ($Classifications.ContainsKey($category)) {
            $categoryDir = Join-Path $archiveDir $category.ToLower()
            
            if (-not $DryRun -and -not (Test-Path $categoryDir)) {
                New-Item -ItemType Directory -Path $categoryDir -Force | Out-Null
            }
            
            foreach ($doc in $Classifications[$category]) {
                $sourcePath = $doc.File.FullName
                $targetPath = Join-Path $categoryDir $doc.File.Name
                
                if ($DryRun) {
                    Write-OrgLog "Would move: $($doc.File.Name) -> archive/$($category.ToLower())/" -Level Info
                } else {
                    try {
                        Copy-Item $sourcePath $targetPath -Force
                        Remove-Item $sourcePath -Force
                        $movedCount++
                        Write-OrgLog "Moved: $($doc.File.Name) -> archive/$($category.ToLower())/" -Level Success
                    }
                    catch {
                        Write-OrgLog "Failed to move $($doc.File.Name): $($_.Exception.Message)" -Level Error
                    }
                }
            }
        }
    }
    
    Write-OrgLog "Moved $movedCount files to archive" -Level Success
}

#endregion

#region Steering System Creation

function Create-SteeringIndex {
    Write-OrgLog "Creating comprehensive steering index..." -Level Info
    
    $steeringFiles = Get-ChildItem -Path "steering" -Filter "*.md" | Where-Object { $_.Name -ne 'README.md' }
    
    $indexContent = @"
# 🧭 Steering System Quick Reference

**Last Updated**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

## 📋 Active Documents

"@
    
    foreach ($file in $steeringFiles | Sort-Object Name) {
        $content = Get-Content $file.FullName -Raw
        
        # Extract code and description from first line
        if ($content -match '# (\w+) - (.+)') {
            $code = $matches[1]
            $description = $matches[2]
            $indexContent += "- **[$code]** - [$($file.BaseName)]($($file.Name)) - $description`n"
        } else {
            $indexContent += "- **[????]** - [$($file.BaseName)]($($file.Name)) - No description`n"
        }
    }
    
    $indexContent += @"

## 🔍 Quick Access Commands

``````powershell
# View any document by code
Get-Content steering/[CODE].md

# Examples:
Get-Content steering/product.md     # [PROD] Product overview
Get-Content steering/tech.md        # [TECH] Technology stack
Get-Content steering/roadmap.md     # [ROAD] Development roadmap
Get-Content steering/security.md    # [SECU] Security guidelines
``````

## 📊 Statistics

- **Total Documents**: $($steeringFiles.Count)
- **Categories**: $(($steeringFiles | ForEach-Object { (Get-Content $_.FullName -Raw) -match '# (\w+) -' | Out-Null; $matches[1] } | Group-Object | Measure-Object).Count)
- **Total Size**: $([math]::Round(($steeringFiles | Measure-Object -Property Length -Sum).Sum / 1KB, 1)) KB
- **Last Updated**: $(Get-Date -Format 'yyyy-MM-dd')
"@
    
    if (-not $DryRun) {
        $indexContent | Out-File "steering/INDEX.md" -Encoding UTF8
        Write-OrgLog "Created steering index: steering/INDEX.md" -Level Success
    } else {
        Write-OrgLog "Would create steering index with $($steeringFiles.Count) documents" -Level Info
    }
}

function Create-ShorthandReference {
    Write-OrgLog "Creating shorthand reference system..." -Level Info
    
    $shorthandContent = @"
# 📝 Shorthand Reference System

## 🎯 Usage in Code Comments

``````powershell
# Follow [ARCH] structure conventions
function New-VelociraptorConfig {
    # Security per [SECU] guidelines
    # Testing per [TEST] standards
    # Deployment per [DEPL] procedures
}
``````

## 📖 Usage in Documentation

``````markdown
<!-- Cross-reference other documents -->
See [TECH] for technology details
Refer to [ROAD] for roadmap information
Check [QASY] for QA processes
Follow [SECU] security guidelines
``````

## 🔍 Quick Lookup

| Code | Command | Description |
|------|---------|-------------|
| PROD | ``Get-Content steering/product.md`` | Product overview |
| TECH | ``Get-Content steering/tech.md`` | Technology stack |
| ARCH | ``Get-Content steering/structure.md`` | Architecture |
| ROAD | ``Get-Content steering/roadmap.md`` | Development roadmap |
| SECU | ``Get-Content steering/security.md`` | Security guidelines |
| TEST | ``Get-Content steering/testing.md`` | Testing standards |
| DEPL | ``Get-Content steering/deployment.md`` | Deployment guide |
| TROU | ``Get-Content steering/troubleshooting.md`` | Troubleshooting |
| GUIS | ``Get-Content steering/gui-system.md`` | GUI architecture |
| QASY | ``Get-Content steering/qa-system.md`` | QA processes |

## 🔄 Maintenance

When adding new steering documents:
1. Use 4-letter code format
2. Include code in document header
3. Update this reference
4. Add cross-references in related docs
"@
    
    if (-not $DryRun) {
        $shorthandContent | Out-File "steering/SHORTHAND.md" -Encoding UTF8
        Write-OrgLog "Created shorthand reference: steering/SHORTHAND.md" -Level Success
    } else {
        Write-OrgLog "Would create shorthand reference system" -Level Info
    }
}

#endregion

#region Main Execution

Write-OrgLog "🧭 Documentation Organization System" -Level Info
Write-OrgLog "Action: $Action | Dry Run: $DryRun" -Level Info

switch ($Action) {
    'Organize' {
        $classifications = Invoke-DocumentOrganization
        Create-SteeringIndex
        Create-ShorthandReference
    }
    
    'Archive' {
        $classifications = Invoke-DocumentOrganization
        Move-DocumentsToArchive -Classifications $classifications
    }
    
    'Clean' {
        Write-OrgLog "Cleaning up temporary and duplicate files..." -Level Info
        
        # Remove duplicate and temporary files
        $tempFiles = Get-ChildItem -Recurse -Filter "*temp*", "*backup*", "*old*", "*-old.*" | 
                     Where-Object { $_.Extension -eq '.md' }
        
        foreach ($file in $tempFiles) {
            if ($DryRun) {
                Write-OrgLog "Would remove: $($file.Name)" -Level Warning
            } else {
                Remove-Item $file.FullName -Force
                Write-OrgLog "Removed: $($file.Name)" -Level Success
            }
        }
    }
    
    'All' {
        $classifications = Invoke-DocumentOrganization
        Move-DocumentsToArchive -Classifications $classifications
        Create-SteeringIndex
        Create-ShorthandReference
        
        # Clean up
        Write-OrgLog "Cleaning up temporary files..." -Level Info
        $tempFiles = Get-ChildItem -Filter "*temp*", "*backup*", "*-old.*" | 
                     Where-Object { $_.Extension -eq '.md' -and $_.Directory.Name -eq 'Velociraptor_Setup_Scripts' }
        
        foreach ($file in $tempFiles) {
            if ($DryRun) {
                Write-OrgLog "Would remove: $($file.Name)" -Level Warning
            } else {
                Remove-Item $file.FullName -Force -ErrorAction SilentlyContinue
                Write-OrgLog "Cleaned: $($file.Name)" -Level Success
            }
        }
    }
}

Write-OrgLog "`n🎉 Documentation organization complete!" -Level Success
Write-OrgLog "Steering system available at: steering/README.md" -Level Info
Write-OrgLog "Quick reference available at: steering/SHORTHAND.md" -Level Info

#endregion