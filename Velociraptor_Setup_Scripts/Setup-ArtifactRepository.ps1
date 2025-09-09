# Setup Local Artifact Repository for VelociraptorUltimate
# Quick setup script to initialize local artifact management

<#
.SYNOPSIS
    Initialize local artifact repository for VelociraptorUltimate
    
.DESCRIPTION
    Sets up the local artifact management system by:
    - Creating directory structure
    - Downloading sample artifacts
    - Configuring artifact management
    - Integrating with VelociraptorUltimate.ps1
    
.EXAMPLE
    .\Setup-ArtifactRepository.ps1
#>

param(
    [string] $ArtifactPath = ".\artifacts",
    [switch] $IncludeSamples
)

Write-Host "🚀 Setting up Velociraptor Artifact Repository" -ForegroundColor Green
Write-Host "=" * 50 -ForegroundColor Blue

# Create directory structure
$directories = @(
    $ArtifactPath,
    "$ArtifactPath\Windows",
    "$ArtifactPath\Linux", 
    "$ArtifactPath\MacOS",
    "$ArtifactPath\Generic",
    "$ArtifactPath\Community",
    "$ArtifactPath\Custom"
)

Write-Host "📁 Creating directory structure..." -ForegroundColor Cyan
foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "   Created: $dir" -ForegroundColor Green
    } else {
        Write-Host "   Exists: $dir" -ForegroundColor Yellow
    }
}

# Create sample artifacts if requested
if ($IncludeSamples) {
    Write-Host "📝 Creating sample artifacts..." -ForegroundColor Cyan
    
    # Windows sample artifact
    $windowsSample = @"
name: Windows.System.ProcessList
description: List running processes on Windows systems
author: VelociraptorUltimate
type: CLIENT
parameters:
  - name: ProcessNameRegex
    description: Regex to match process names
    default: ".*"
    type: regex

sources:
  - precondition: SELECT OS From info() where OS = 'windows'
    query: |
      SELECT Name, Pid, Ppid, CommandLine, CreateTime
      FROM pslist()
      WHERE Name =~ ProcessNameRegex
"@
    
    $windowsSample | Out-File -FilePath "$ArtifactPath\Windows\ProcessList.yaml" -Encoding UTF8
    
    # Linux sample artifact
    $linuxSample = @"
name: Linux.System.ProcessList
description: List running processes on Linux systems
author: VelociraptorUltimate
type: CLIENT
parameters:
  - name: ProcessNameRegex
    description: Regex to match process names
    default: ".*"
    type: regex

sources:
  - precondition: SELECT OS From info() where OS = 'linux'
    query: |
      SELECT Name, Pid, Ppid, Cmdline, CreateTime
      FROM pslist()
      WHERE Name =~ ProcessNameRegex
"@
    
    $linuxSample | Out-File -FilePath "$ArtifactPath\Linux\ProcessList.yaml" -Encoding UTF8
    
    Write-Host "   Created sample artifacts" -ForegroundColor Green
}

# Create artifact index
Write-Host "📊 Creating artifact index..." -ForegroundColor Cyan
$index = @{
    CreatedTime = Get-Date
    Version = "1.0.0"
    Description = "Local Velociraptor Artifact Repository"
    Directories = $directories
    Tools = @{
        ImportScript = "Import-VelociraptorArtifacts.ps1"
        ManageScript = "Manage-LocalArtifacts.ps1"
        SetupScript = "Setup-ArtifactRepository.ps1"
    }
    Integration = @{
        VelociraptorUltimate = "VelociraptorUltimate.ps1"
        ArtifactTab = "Artifacts"
        LocalManagement = $true
    }
}

$index | ConvertTo-Json -Depth 10 | Out-File -FilePath "$ArtifactPath\repository-info.json" -Encoding UTF8

Write-Host "✅ Artifact repository setup completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Run Import-VelociraptorArtifacts.ps1 to download artifacts from repositories" -ForegroundColor White
Write-Host "2. Use Manage-LocalArtifacts.ps1 to browse and manage artifacts" -ForegroundColor White
Write-Host "3. Launch VelociraptorUltimate.ps1 and use the Artifacts tab" -ForegroundColor White
Write-Host ""
Write-Host "Repository Path: $ArtifactPath" -ForegroundColor Yellow