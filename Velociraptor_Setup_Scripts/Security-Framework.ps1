#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Velociraptor Security and Signing Framework
    
.DESCRIPTION
    Provides security features including:
    - GPG signing and verification
    - PowerShell script signing
    - Certificate management
    - Secure configuration handling
    - Administrator privilege management
    
.NOTES
    This framework handles sensitive security operations.
    Private keys and certificates are excluded from git via .gitignore
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Operation = "Status",
    
    [Parameter(Mandatory=$false)]
    [string]$FilePath,
    
    [Parameter(Mandatory=$false)]
    [string]$KeyId,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force
)

# Security configuration
$Script:SecurityConfig = @{
    GPGKeyPath = Join-Path $PSScriptRoot "signing\gpg"
    CertificatePath = Join-Path $PSScriptRoot "signing\certificates"
    SecretsPath = Join-Path $PSScriptRoot "secrets"
    SignedScriptsPath = Join-Path $PSScriptRoot "signed"
    LogPath = Join-Path $PSScriptRoot "logs\security.log"
}

# Ensure security directories exist (but are empty in git)
function Initialize-SecurityDirectories {
    $directories = @(
        $Script:SecurityConfig.GPGKeyPath,
        $Script:SecurityConfig.CertificatePath,
        $Script:SecurityConfig.SecretsPath,
        $Script:SecurityConfig.SignedScriptsPath,
        (Split-Path $Script:SecurityConfig.LogPath -Parent)
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Host "Created security directory: $dir" -ForegroundColor Green
            
            # Create .gitkeep file to maintain directory structure
            $gitkeep = Join-Path $dir ".gitkeep"
            "# This directory is maintained for security files but contents are excluded from git" | Out-File $gitkeep -Encoding UTF8
        }
    }
}

# Security logging function
function Write-SecurityLog {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [string]$Operation = "General"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$Level] [$Operation] $Message"
    
    # Ensure log directory exists
    $logDir = Split-Path $Script:SecurityConfig.LogPath -Parent
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    
    # Write to log file
    $logEntry | Out-File $Script:SecurityConfig.LogPath -Append -Encoding UTF8
    
    # Also write to console with colors
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "WARN" { "Yellow" }
        "SUCCESS" { "Green" }
        "SECURITY" { "Magenta" }
        default { "White" }
    }
    
    Write-Host $logEntry -ForegroundColor $color
}

# Check if running as administrator
function Test-Administrator {
    $currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# Prompt for administrator privileges
function Request-Administrator {
    param([string]$Reason = "Security operations require administrator privileges")
    
    if (-not (Test-Administrator)) {
        Write-SecurityLog "Administrator privileges required: $Reason" "WARN" "Security"
        
        $choice = Read-Host "This operation requires administrator privileges. Restart as admin? (y/N)"
        if ($choice -match '^[Yy]') {
            $scriptPath = $MyInvocation.ScriptName
            $arguments = $MyInvocation.BoundParameters.Keys | ForEach-Object { "-$_ $($MyInvocation.BoundParameters[$_])" }
            
            Start-Process PowerShell -ArgumentList "-NoExit", "-File", "`"$scriptPath`"", $arguments -Verb RunAs
            exit 0
        } else {
            Write-SecurityLog "Administrator privileges declined by user" "WARN" "Security"
            return $false
        }
    }
    return $true
}

# GPG Operations
function Test-GPGAvailable {
    try {
        $gpgVersion = gpg --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-SecurityLog "GPG is available: $($gpgVersion[0])" "SUCCESS" "GPG"
            return $true
        }
    }
    catch {
        Write-SecurityLog "GPG is not available or not in PATH" "WARN" "GPG"
    }
    return $false
}

function Get-GPGKeys {
    if (-not (Test-GPGAvailable)) {
        return @()
    }
    
    try {
        $keys = gpg --list-secret-keys --keyid-format LONG 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-SecurityLog "Retrieved GPG key list" "SUCCESS" "GPG"
            return $keys
        }
    }
    catch {
        Write-SecurityLog "Failed to retrieve GPG keys: $($_.Exception.Message)" "ERROR" "GPG"
    }
    return @()
}

function Sign-FileWithGPG {
    param(
        [Parameter(Mandatory)]
        [string]$FilePath,
        
        [Parameter(Mandatory)]
        [string]$KeyId
    )
    
    if (-not (Test-Path $FilePath)) {
        Write-SecurityLog "File not found for signing: $FilePath" "ERROR" "GPG"
        return $false
    }
    
    if (-not (Test-GPGAvailable)) {
        Write-SecurityLog "GPG not available for signing" "ERROR" "GPG"
        return $false
    }
    
    try {
        $signatureFile = "$FilePath.asc"
        $result = gpg --armor --detach-sign --default-key $KeyId --output $signatureFile $FilePath 2>&1
        
        if ($LASTEXITCODE -eq 0 -and (Test-Path $signatureFile)) {
            Write-SecurityLog "Successfully signed file: $FilePath" "SUCCESS" "GPG"
            Write-SecurityLog "Signature created: $signatureFile" "SUCCESS" "GPG"
            return $true
        } else {
            Write-SecurityLog "GPG signing failed: $result" "ERROR" "GPG"
            return $false
        }
    }
    catch {
        Write-SecurityLog "GPG signing error: $($_.Exception.Message)" "ERROR" "GPG"
        return $false
    }
}

function Test-GPGSignature {
    param(
        [Parameter(Mandatory)]
        [string]$FilePath,
        
        [string]$SignatureFile = "$FilePath.asc"
    )
    
    if (-not (Test-Path $FilePath)) {
        Write-SecurityLog "File not found for verification: $FilePath" "ERROR" "GPG"
        return $false
    }
    
    if (-not (Test-Path $SignatureFile)) {
        Write-SecurityLog "Signature file not found: $SignatureFile" "ERROR" "GPG"
        return $false
    }
    
    if (-not (Test-GPGAvailable)) {
        Write-SecurityLog "GPG not available for verification" "ERROR" "GPG"
        return $false
    }
    
    try {
        $result = gpg --verify $SignatureFile $FilePath 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-SecurityLog "GPG signature verification successful: $FilePath" "SUCCESS" "GPG"
            return $true
        } else {
            Write-SecurityLog "GPG signature verification failed: $result" "ERROR" "GPG"
            return $false
        }
    }
    catch {
        Write-SecurityLog "GPG verification error: $($_.Exception.Message)" "ERROR" "GPG"
        return $false
    }
}

# PowerShell Script Signing
function Get-CodeSigningCertificate {
    try {
        $certs = Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert
        if ($certs.Count -gt 0) {
            Write-SecurityLog "Found $($certs.Count) code signing certificate(s)" "SUCCESS" "CodeSigning"
            return $certs[0]  # Return the first valid certificate
        } else {
            Write-SecurityLog "No code signing certificates found in CurrentUser\My" "WARN" "CodeSigning"
        }
    }
    catch {
        Write-SecurityLog "Error retrieving code signing certificates: $($_.Exception.Message)" "ERROR" "CodeSigning"
    }
    return $null
}

function Sign-PowerShellScript {
    param(
        [Parameter(Mandatory)]
        [string]$ScriptPath,
        
        [string]$CertificatePath,
        
        [switch]$TimestampServer
    )
    
    if (-not (Test-Path $ScriptPath)) {
        Write-SecurityLog "Script not found for signing: $ScriptPath" "ERROR" "CodeSigning"
        return $false
    }
    
    try {
        $cert = $null
        
        if ($CertificatePath -and (Test-Path $CertificatePath)) {
            $cert = Get-PfxCertificate -FilePath $CertificatePath
            Write-SecurityLog "Using certificate from file: $CertificatePath" "INFO" "CodeSigning"
        } else {
            $cert = Get-CodeSigningCertificate
            if (-not $cert) {
                Write-SecurityLog "No suitable code signing certificate available" "ERROR" "CodeSigning"
                return $false
            }
        }
        
        $signParams = @{
            FilePath = $ScriptPath
            Certificate = $cert
        }
        
        if ($TimestampServer) {
            $signParams.TimestampServer = "http://timestamp.digicert.com"
        }
        
        $result = Set-AuthenticodeSignature @signParams
        
        if ($result.Status -eq "Valid") {
            Write-SecurityLog "Successfully signed PowerShell script: $ScriptPath" "SUCCESS" "CodeSigning"
            return $true
        } else {
            Write-SecurityLog "PowerShell script signing failed: $($result.StatusMessage)" "ERROR" "CodeSigning"
            return $false
        }
    }
    catch {
        Write-SecurityLog "PowerShell signing error: $($_.Exception.Message)" "ERROR" "CodeSigning"
        return $false
    }
}

function Test-PowerShellSignature {
    param(
        [Parameter(Mandatory)]
        [string]$ScriptPath
    )
    
    if (-not (Test-Path $ScriptPath)) {
        Write-SecurityLog "Script not found for verification: $ScriptPath" "ERROR" "CodeSigning"
        return $false
    }
    
    try {
        $signature = Get-AuthenticodeSignature -FilePath $ScriptPath
        
        switch ($signature.Status) {
            "Valid" {
                Write-SecurityLog "PowerShell script signature is valid: $ScriptPath" "SUCCESS" "CodeSigning"
                Write-SecurityLog "Signed by: $($signature.SignerCertificate.Subject)" "INFO" "CodeSigning"
                return $true
            }
            "NotSigned" {
                Write-SecurityLog "PowerShell script is not signed: $ScriptPath" "WARN" "CodeSigning"
                return $false
            }
            default {
                Write-SecurityLog "PowerShell script signature status: $($signature.Status)" "ERROR" "CodeSigning"
                Write-SecurityLog "Status message: $($signature.StatusMessage)" "ERROR" "CodeSigning"
                return $false
            }
        }
    }
    catch {
        Write-SecurityLog "PowerShell signature verification error: $($_.Exception.Message)" "ERROR" "CodeSigning"
        return $false
    }
}

# Main operation dispatcher
function Invoke-SecurityOperation {
    param([string]$Operation)
    
    Initialize-SecurityDirectories
    
    switch ($Operation.ToLower()) {
        "status" {
            Write-SecurityLog "=== SECURITY FRAMEWORK STATUS ===" "INFO" "Status"
            Write-SecurityLog "Administrator: $(Test-Administrator)" "INFO" "Status"
            Write-SecurityLog "GPG Available: $(Test-GPGAvailable)" "INFO" "Status"
            
            $cert = Get-CodeSigningCertificate
            Write-SecurityLog "Code Signing Certificate: $($cert -ne $null)" "INFO" "Status"
            
            if ($cert) {
                Write-SecurityLog "Certificate Subject: $($cert.Subject)" "INFO" "Status"
                Write-SecurityLog "Certificate Expires: $($cert.NotAfter)" "INFO" "Status"
            }
            
            Write-SecurityLog "Security directories initialized" "SUCCESS" "Status"
        }
        
        "gpg-keys" {
            Write-SecurityLog "=== GPG KEYS ===" "INFO" "GPG"
            $keys = Get-GPGKeys
            if ($keys.Count -gt 0) {
                $keys | ForEach-Object { Write-SecurityLog $_ "INFO" "GPG" }
            } else {
                Write-SecurityLog "No GPG keys found" "WARN" "GPG"
            }
        }
        
        "sign-gpg" {
            if (-not $FilePath -or -not $KeyId) {
                Write-SecurityLog "GPG signing requires -FilePath and -KeyId parameters" "ERROR" "GPG"
                return
            }
            
            $success = Sign-FileWithGPG -FilePath $FilePath -KeyId $KeyId
            if ($success) {
                Write-SecurityLog "GPG signing completed successfully" "SUCCESS" "GPG"
            } else {
                Write-SecurityLog "GPG signing failed" "ERROR" "GPG"
            }
        }
        
        "verify-gpg" {
            if (-not $FilePath) {
                Write-SecurityLog "GPG verification requires -FilePath parameter" "ERROR" "GPG"
                return
            }
            
            $success = Test-GPGSignature -FilePath $FilePath
            if ($success) {
                Write-SecurityLog "GPG verification successful" "SUCCESS" "GPG"
            } else {
                Write-SecurityLog "GPG verification failed" "ERROR" "GPG"
            }
        }
        
        "sign-ps1" {
            if (-not $FilePath) {
                Write-SecurityLog "PowerShell signing requires -FilePath parameter" "ERROR" "CodeSigning"
                return
            }
            
            $success = Sign-PowerShellScript -ScriptPath $FilePath -TimestampServer
            if ($success) {
                Write-SecurityLog "PowerShell signing completed successfully" "SUCCESS" "CodeSigning"
            } else {
                Write-SecurityLog "PowerShell signing failed" "ERROR" "CodeSigning"
            }
        }
        
        "verify-ps1" {
            if (-not $FilePath) {
                Write-SecurityLog "PowerShell verification requires -FilePath parameter" "ERROR" "CodeSigning"
                return
            }
            
            $success = Test-PowerShellSignature -ScriptPath $FilePath
            if ($success) {
                Write-SecurityLog "PowerShell verification successful" "SUCCESS" "CodeSigning"
            } else {
                Write-SecurityLog "PowerShell verification failed" "ERROR" "CodeSigning"
            }
        }
        
        "admin-check" {
            if (Test-Administrator) {
                Write-SecurityLog "Running with administrator privileges" "SUCCESS" "Security"
            } else {
                Write-SecurityLog "NOT running with administrator privileges" "WARN" "Security"
                if ($Force) {
                    Request-Administrator -Reason "Requested by user with -Force parameter"
                }
            }
        }
        
        default {
            Write-SecurityLog "Unknown operation: $Operation" "ERROR" "General"
            Write-SecurityLog "Available operations: status, gpg-keys, sign-gpg, verify-gpg, sign-ps1, verify-ps1, admin-check" "INFO" "General"
        }
    }
}

# Execute the requested operation
try {
    Invoke-SecurityOperation -Operation $Operation
}
catch {
    Write-SecurityLog "Security framework error: $($_.Exception.Message)" "ERROR" "General"
    exit 1
}

<#
.EXAMPLE
    .\Security-Framework.ps1 -Operation status
    Shows the current security framework status
    
.EXAMPLE
    .\Security-Framework.ps1 -Operation gpg-keys
    Lists available GPG keys
    
.EXAMPLE
    .\Security-Framework.ps1 -Operation sign-gpg -FilePath "script.ps1" -KeyId "YOUR_KEY_ID"
    Signs a file with GPG
    
.EXAMPLE
    .\Security-Framework.ps1 -Operation sign-ps1 -FilePath "script.ps1"
    Signs a PowerShell script with code signing certificate
    
.EXAMPLE
    .\Security-Framework.ps1 -Operation admin-check -Force
    Checks for admin privileges and prompts to elevate if needed
#>