# Import Velociraptor Artifacts from Multiple Repositories
# Comprehensive artifact import system for VelociraptorUltimate

<#
.SYNOPSIS
    Import all Velociraptor artifacts from official and community repositories
    
.DESCRIPTION
    Downloads and imports artifacts from:
    - Official Velociraptor artifact repository
    - Community contributed artifacts
    - Custom artifact repositories
    - Third-party DFIR tool integrations
    
.PARAMETER ImportPath
    Local path to store imported artifacts
    
.PARAMETER RepositoryList
    List of repositories to import from
    
.PARAMETER UpdateExisting
    Update existing artifacts if newer versions available
    
.EXAMPLE
    .\Import-VelociraptorArtifacts.ps1 -ImportPath ".\artifacts" -UpdateExisting
#>

param(
    [ValidateScript({Test-Path (Split-Path $_ -Parent) -PathType Container})]
    [string] $ImportPath = ".\artifacts",
    
    [string[]] $RepositoryList = @(
        "https://github.com/Velocidex/velociraptor",
        "https://github.com/Velocidex/velociraptor-docs", 
        "https://github.com/Velocidex/artifacts",
        "https://github.com/forensicanalysis/artifacts",
        "https://github.com/ForensicArtifacts/artifacts"
    ),
    
    [switch] $UpdateExisting,
    
    [switch] $IncludeCommunity,
    
    [ValidateSet('All', 'Windows', 'Linux', 'MacOS', 'Generic')]
    [string] $Platform = 'All'
)

# Initialize import results
$script:ImportResults = @{
    StartTime = Get-Date
    ImportPath = $ImportPath
    Repositories = @()
    Artifacts = @()
    Summary = @{
        TotalRepos = 0
        SuccessfulRepos = 0
        TotalArtifacts = 0
        ImportedArtifacts = 0
        UpdatedArtifacts = 0
        SkippedArtifacts = 0
        Errors = @()
    }
}

function Write-ImportLog {
    param(
        [string] $Message,
        [string] $Level = "Info"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "Info" { Write-Host $logEntry -ForegroundColor Cyan }
        "Success" { Write-Host $logEntry -ForegroundColor Green }
        "Warning" { Write-Host $logEntry -ForegroundColor Yellow }
        "Error" { Write-Host $logEntry -ForegroundColor Red }
    }
}

function Initialize-ArtifactDirectories {
    Write-ImportLog "Initializing artifact directory structure..."
    
    $directories = @(
        $ImportPath,
        "$ImportPath\Windows",
        "$ImportPath\Linux", 
        "$ImportPath\MacOS",
        "$ImportPath\Generic",
        "$ImportPath\Community",
        "$ImportPath\Custom",
        "$ImportPath\ThirdParty"
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            try {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
                Write-ImportLog "Created directory: $dir" "Success"
            } catch {
                Write-ImportLog "Failed to create directory $dir`: $($_.Exception.Message)" "Error"
                $script:ImportResults.Summary.Errors += "Directory creation failed: $dir"
            }
        }
    }
}

function Get-GitHubRepositoryContent {
    param(
        [string] $RepoUrl,
        [string] $Path = "",
        [string] $Branch = "master"
    )
    
    try {
        # Convert GitHub URL to API URL
        $repoPath = $RepoUrl -replace "https://github.com/", ""
        $apiUrl = "https://api.github.com/repos/$repoPath/contents/$Path"
        
        if ($Branch -ne "master") {
            $apiUrl += "?ref=$Branch"
        }
        
        Write-ImportLog "Fetching repository content from: $apiUrl"
        
        $headers = @{
            'User-Agent' = 'VelociraptorUltimate-ArtifactImporter'
            'Accept' = 'application/vnd.github.v3+json'
        }
        
        $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -ErrorAction Stop
        return $response
        
    } catch {
        Write-ImportLog "Failed to fetch repository content: $($_.Exception.Message)" "Error"
        return $null
    }
}

function Download-ArtifactFile {
    param(
        [string] $DownloadUrl,
        [string] $LocalPath,
        [string] $FileName
    )
    
    try {
        $fullPath = Join-Path $LocalPath $FileName
        
        Write-ImportLog "Downloading: $FileName"
        
        $headers = @{
            'User-Agent' = 'VelociraptorUltimate-ArtifactImporter'
        }
        
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $fullPath -Headers $headers -ErrorAction Stop
        
        Write-ImportLog "Downloaded: $FileName" "Success"
        return $true
        
    } catch {
        Write-ImportLog "Failed to download $FileName`: $($_.Exception.Message)" "Error"
        return $false
    }
}

function Import-VelociraptorRepository {
    param(
        [string] $RepoUrl
    )
    
    Write-ImportLog "Processing repository: $RepoUrl"
    
    $repoResult = @{
        Url = $RepoUrl
        Success = $false
        ArtifactsFound = 0
        ArtifactsImported = 0
        Errors = @()
    }
    
    try {
        # Get repository content
        $content = Get-GitHubRepositoryContent -RepoUrl $RepoUrl
        
        if ($null -eq $content) {
            $repoResult.Errors += "Failed to fetch repository content"
            return $repoResult
        }
        
        # Look for artifact directories
        $artifactDirs = @("artifacts", "Artifacts", "ARTIFACTS", "yaml", "YAML")
        
        foreach ($dir in $artifactDirs) {
            $dirContent = $content | Where-Object { $_.name -eq $dir -and $_.type -eq "dir" }
            
            if ($dirContent) {
                Write-ImportLog "Found artifact directory: $dir"
                $imported = Import-ArtifactsFromDirectory -RepoUrl $RepoUrl -DirectoryPath $dir
                $repoResult.ArtifactsFound += $imported.Found
                $repoResult.ArtifactsImported += $imported.Imported
            }
        }
        
        # Also check root directory for .yaml files
        $yamlFiles = $content | Where-Object { $_.name -like "*.yaml" -or $_.name -like "*.yml" }
        
        foreach ($file in $yamlFiles) {
            $platform = Get-ArtifactPlatform -FileName $file.name
            $targetDir = Join-Path $ImportPath $platform
            
            if (Download-ArtifactFile -DownloadUrl $file.download_url -LocalPath $targetDir -FileName $file.name) {
                $repoResult.ArtifactsFound++
                $repoResult.ArtifactsImported++
                
                $script:ImportResults.Artifacts += @{
                    Name = $file.name
                    Source = $RepoUrl
                    Platform = $platform
                    Size = $file.size
                    ImportTime = Get-Date
                }
            }
        }
        
        $repoResult.Success = $true
        Write-ImportLog "Repository processed successfully: $($repoResult.ArtifactsImported) artifacts imported" "Success"
        
    } catch {
        $error = "Repository processing failed: $($_.Exception.Message)"
        $repoResult.Errors += $error
        Write-ImportLog $error "Error"
    }
    
    $script:ImportResults.Repositories += $repoResult
    return $repoResult
}

function Import-ArtifactsFromDirectory {
    param(
        [string] $RepoUrl,
        [string] $DirectoryPath
    )
    
    $result = @{ Found = 0; Imported = 0 }
    
    try {
        $dirContent = Get-GitHubRepositoryContent -RepoUrl $RepoUrl -Path $DirectoryPath
        
        if ($null -eq $dirContent) {
            return $result
        }
        
        foreach ($item in $dirContent) {
            if ($item.type -eq "file" -and ($item.name -like "*.yaml" -or $item.name -like "*.yml")) {
                $result.Found++
                
                # Determine platform and target directory
                $platform = Get-ArtifactPlatform -FileName $item.name -Content $item
                $targetDir = Join-Path $ImportPath $platform
                
                # Check if we should import based on platform filter
                if ($Platform -ne 'All' -and $platform -ne $Platform) {
                    Write-ImportLog "Skipping $($item.name) - platform filter ($Platform)" "Warning"
                    continue
                }
                
                # Check if file already exists and if we should update
                $localPath = Join-Path $targetDir $item.name
                if ((Test-Path $localPath) -and -not $UpdateExisting) {
                    Write-ImportLog "Skipping $($item.name) - already exists" "Warning"
                    $script:ImportResults.Summary.SkippedArtifacts++
                    continue
                }
                
                if (Download-ArtifactFile -DownloadUrl $item.download_url -LocalPath $targetDir -FileName $item.name) {
                    $result.Imported++
                    
                    if (Test-Path $localPath) {
                        $script:ImportResults.Summary.UpdatedArtifacts++
                    } else {
                        $script:ImportResults.Summary.ImportedArtifacts++
                    }
                    
                    $script:ImportResults.Artifacts += @{
                        Name = $item.name
                        Source = $RepoUrl
                        Platform = $platform
                        Size = $item.size
                        ImportTime = Get-Date
                    }
                }
            } elseif ($item.type -eq "dir") {
                # Recursively process subdirectories
                $subResult = Import-ArtifactsFromDirectory -RepoUrl $RepoUrl -DirectoryPath "$DirectoryPath/$($item.name)"
                $result.Found += $subResult.Found
                $result.Imported += $subResult.Imported
            }
        }
        
    } catch {
        Write-ImportLog "Failed to process directory $DirectoryPath`: $($_.Exception.Message)" "Error"
    }
    
    return $result
}

function Get-ArtifactPlatform {
    param(
        [string] $FileName,
        [object] $Content = $null
    )
    
    # Determine platform based on filename patterns
    if ($FileName -match "windows|win32|win64|ntfs|registry|wmi|powershell") {
        return "Windows"
    } elseif ($FileName -match "linux|unix|bash|systemd") {
        return "Linux"
    } elseif ($FileName -match "macos|darwin|osx|mac") {
        return "MacOS"
    } elseif ($FileName -match "generic|cross|multi|universal") {
        return "Generic"
    } else {
        # Default to Generic for unknown platforms
        return "Generic"
    }
}

function Import-CommunityRepositories {
    if (-not $IncludeCommunity) {
        return
    }
    
    Write-ImportLog "Importing community repositories..."
    
    $communityRepos = @(
        "https://github.com/Velocidex/velociraptor-docs",
        "https://github.com/forensicanalysis/artifacts",
        "https://github.com/ForensicArtifacts/artifacts",
        "https://github.com/google/grr",
        "https://github.com/sleuthkit/autopsy"
    )
    
    foreach ($repo in $communityRepos) {
        try {
            Import-VelociraptorRepository -RepoUrl $repo
        } catch {
            Write-ImportLog "Failed to import community repository $repo`: $($_.Exception.Message)" "Error"
        }
    }
}

function Generate-ArtifactIndex {
    Write-ImportLog "Generating artifact index..."
    
    try {
        $indexPath = Join-Path $ImportPath "artifact-index.json"
        
        $index = @{
            GeneratedTime = Get-Date
            TotalArtifacts = $script:ImportResults.Summary.ImportedArtifacts + $script:ImportResults.Summary.UpdatedArtifacts
            Platforms = @{}
            Sources = @{}
            Artifacts = $script:ImportResults.Artifacts
        }
        
        # Group by platform
        $platformGroups = $script:ImportResults.Artifacts | Group-Object Platform
        foreach ($group in $platformGroups) {
            $index.Platforms[$group.Name] = $group.Count
        }
        
        # Group by source
        $sourceGroups = $script:ImportResults.Artifacts | Group-Object Source
        foreach ($group in $sourceGroups) {
            $index.Sources[$group.Name] = $group.Count
        }
        
        $index | ConvertTo-Json -Depth 10 | Out-File -FilePath $indexPath -Encoding UTF8
        
        Write-ImportLog "Artifact index generated: $indexPath" "Success"
        
    } catch {
        Write-ImportLog "Failed to generate artifact index: $($_.Exception.Message)" "Error"
    }
}

function Show-ImportSummary {
    $endTime = Get-Date
    $duration = $endTime - $script:ImportResults.StartTime
    
    Write-Host "`n" -NoNewline
    Write-Host "📊 Artifact Import Summary" -ForegroundColor Green
    Write-Host "=" * 40 -ForegroundColor Blue
    Write-Host "Import Path: $ImportPath" -ForegroundColor Cyan
    Write-Host "Duration: $($duration.ToString('mm\:ss'))" -ForegroundColor Cyan
    Write-Host "Repositories Processed: $($script:ImportResults.Summary.SuccessfulRepos)/$($script:ImportResults.Summary.TotalRepos)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Artifacts Imported: $($script:ImportResults.Summary.ImportedArtifacts)" -ForegroundColor Green
    Write-Host "Artifacts Updated: $($script:ImportResults.Summary.UpdatedArtifacts)" -ForegroundColor Yellow
    Write-Host "Artifacts Skipped: $($script:ImportResults.Summary.SkippedArtifacts)" -ForegroundColor Gray
    Write-Host "Total Artifacts: $($script:ImportResults.Summary.ImportedArtifacts + $script:ImportResults.Summary.UpdatedArtifacts)" -ForegroundColor Cyan
    
    if ($script:ImportResults.Summary.Errors.Count -gt 0) {
        Write-Host "`nErrors Encountered:" -ForegroundColor Red
        foreach ($error in $script:ImportResults.Summary.Errors) {
            Write-Host "  - $error" -ForegroundColor Red
        }
    }
    
    Write-Host "`n✅ Artifact import completed!" -ForegroundColor Green
}

# Main execution
Write-Host "🔄 Velociraptor Artifact Import System" -ForegroundColor Green
Write-Host "=" * 50 -ForegroundColor Blue
Write-Host "Import Path: $ImportPath" -ForegroundColor Cyan
Write-Host "Platform Filter: $Platform" -ForegroundColor Cyan
Write-Host "Update Existing: $UpdateExisting" -ForegroundColor Cyan
Write-Host "Include Community: $IncludeCommunity" -ForegroundColor Cyan
Write-Host ""

# Initialize directories
Initialize-ArtifactDirectories

# Process each repository
$script:ImportResults.Summary.TotalRepos = $RepositoryList.Count

foreach ($repo in $RepositoryList) {
    try {
        $result = Import-VelociraptorRepository -RepoUrl $repo
        if ($result.Success) {
            $script:ImportResults.Summary.SuccessfulRepos++
        }
        $script:ImportResults.Summary.TotalArtifacts += $result.ArtifactsFound
    } catch {
        Write-ImportLog "Critical error processing repository $repo`: $($_.Exception.Message)" "Error"
        $script:ImportResults.Summary.Errors += "Repository error: $repo"
    }
}

# Import community repositories if requested
Import-CommunityRepositories

# Generate artifact index
Generate-ArtifactIndex

# Show summary
Show-ImportSummary