#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Security Setup Helper for Velociraptor Ultimate
    
.DESCRIPTION
    Helps set up GPG keys, certificates, and security configuration
    for the Velociraptor Ultimate platform.
    
    This script will guide you through:
    - GPG key setup and import
    - Code signing certificate configuration
    - Security directory initialization
    - Administrator privilege setup
    
.NOTES
    Run this script to set up your security environment.
    Your private keys will be stored securely and excluded from git.
#>

[CmdletBinding()]
param(
    [switch]$Interactive,
    [switch]$GPGOnly,
    [switch]$CertOnly
)

# Import the security framework
$securityFramework = Join-Path $PSScriptRoot "Security-Framework.ps1"
if (Test-Path $securityFramework) {
    . $securityFramework
} else {
    Write-Error "Security-Framework.ps1 not found. Please ensure it exists in the same directory."
    exit 1
}

function Show-SecuritySetupBanner {
    Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║                 VELOCIRAPTOR ULTIMATE                        ║
║                   SECURITY SETUP                            ║
║                                                              ║
║  This script will help you configure security features:     ║
║  • GPG signing for file integrity                           ║
║  • PowerShell code signing certificates                     ║
║  • Administrator privilege management                       ║
║  • Secure key storage (excluded from git)                  ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan
}

function Test-GPGSetup {
    Write-Host "`n=== GPG Setup Check ===" -ForegroundColor Yellow
    
    if (-not (Test-GPGAvailable)) {
        Write-Host "❌ GPG is not available" -ForegroundColor Red
        Write-Host "   Please install GPG from: https://gnupg.org/download/" -ForegroundColor Yellow
        Write-Host "   Or install via chocolatey: choco install gnupg" -ForegroundColor Yellow
        return $false
    }
    
    Write-Host "✅ GPG is available" -ForegroundColor Green
    
    $keys = Get-GPGKeys
    if ($keys.Count -eq 0) {
        Write-Host "❌ No GPG keys found" -ForegroundColor Red
        Write-Host "   You need to import or generate a GPG key" -ForegroundColor Yellow
        return $false
    }
    
    Write-Host "✅ GPG keys found" -ForegroundColor Green
    return $true
}

function Test-CodeSigningSetup {
    Write-Host "`n=== Code Signing Certificate Check ===" -ForegroundColor Yellow
    
    $cert = Get-CodeSigningCertificate
    if (-not $cert) {
        Write-Host "❌ No code signing certificate found" -ForegroundColor Red
        Write-Host "   You can create a self-signed certificate or import an existing one" -ForegroundColor Yellow
        return $false
    }
    
    Write-Host "✅ Code signing certificate found" -ForegroundColor Green
    Write-Host "   Subject: $($cert.Subject)" -ForegroundColor Gray
    Write-Host "   Expires: $($cert.NotAfter)" -ForegroundColor Gray
    
    if ($cert.NotAfter -lt (Get-Date).AddDays(30)) {
        Write-Host "⚠️  Certificate expires soon!" -ForegroundColor Yellow
    }
    
    return $true
}

function New-SelfSignedCodeCertificate {
    param([string]$Subject = "CN=Velociraptor Ultimate Code Signing")
    
    Write-Host "`n=== Creating Self-Signed Code Signing Certificate ===" -ForegroundColor Yellow
    
    if (-not (Test-Administrator)) {
        Write-Host "❌ Administrator privileges required to create certificates" -ForegroundColor Red
        return $false
    }
    
    try {
        $cert = New-SelfSignedCertificate -Subject $Subject -Type CodeSigningCert -CertStoreLocation Cert:\CurrentUser\My
        Write-Host "✅ Self-signed certificate created successfully" -ForegroundColor Green
        Write-Host "   Thumbprint: $($cert.Thumbprint)" -ForegroundColor Gray
        Write-Host "   Subject: $($cert.Subject)" -ForegroundColor Gray
        return $true
    }
    catch {
        Write-Host "❌ Failed to create certificate: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Import-GPGKey {
    Write-Host "`n=== GPG Key Import ===" -ForegroundColor Yellow
    
    $keyFile = Read-Host "Enter path to your GPG private key file (or press Enter to skip)"
    if ([string]::IsNullOrWhiteSpace($keyFile)) {
        Write-Host "Skipping GPG key import" -ForegroundColor Yellow
        return
    }
    
    if (-not (Test-Path $keyFile)) {
        Write-Host "❌ Key file not found: $keyFile" -ForegroundColor Red
        return
    }
    
    try {
        Write-Host "Importing GPG key..." -ForegroundColor Yellow
        $result = gpg --import $keyFile 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ GPG key imported successfully" -ForegroundColor Green
            
            # Copy the key to our secure directory
            $secureKeyPath = Join-Path $Script:SecurityConfig.GPGKeyPath (Split-Path $keyFile -Leaf)
            Copy-Item $keyFile $secureKeyPath -Force
            Write-Host "✅ Key copied to secure directory: $secureKeyPath" -ForegroundColor Green
            Write-Host "   (This location is excluded from git)" -ForegroundColor Gray
        } else {
            Write-Host "❌ GPG key import failed: $result" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "❌ GPG import error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Show-SecurityInstructions {
    Write-Host @"

╔══════════════════════════════════════════════════════════════╗
║                    SECURITY SETUP COMPLETE                  ║
╚══════════════════════════════════════════════════════════════╝

Your security environment is now configured. Here's what you can do:

🔐 SIGNING FILES:
   .\Security-Framework.ps1 -Operation sign-gpg -FilePath "script.ps1" -KeyId "YOUR_KEY_ID"
   .\Security-Framework.ps1 -Operation sign-ps1 -FilePath "script.ps1"

🔍 VERIFYING SIGNATURES:
   .\Security-Framework.ps1 -Operation verify-gpg -FilePath "script.ps1"
   .\Security-Framework.ps1 -Operation verify-ps1 -FilePath "script.ps1"

📊 CHECKING STATUS:
   .\Security-Framework.ps1 -Operation status

🔑 LISTING GPG KEYS:
   .\Security-Framework.ps1 -Operation gpg-keys

⚡ ADMIN PRIVILEGES:
   .\Security-Framework.ps1 -Operation admin-check -Force

📁 SECURE DIRECTORIES:
   All private keys and certificates are stored in directories
   that are excluded from git via .gitignore

🛡️ SECURITY NOTES:
   • Never commit private keys or certificates to git
   • Keep your GPG passphrase secure
   • Regularly backup your keys securely
   • Use strong passphrases for all keys

"@ -ForegroundColor Green
}

function Start-InteractiveSetup {
    Show-SecuritySetupBanner
    
    Write-Host "`nStarting interactive security setup..." -ForegroundColor Cyan
    
    # Initialize security directories
    Initialize-SecurityDirectories
    
    # Check current status
    Write-Host "`n=== Current Security Status ===" -ForegroundColor Yellow
    & $securityFramework -Operation status
    
    # GPG Setup
    if (-not $CertOnly) {
        $gpgOk = Test-GPGSetup
        if (-not $gpgOk) {
            $setupGPG = Read-Host "`nWould you like to import a GPG key? (y/N)"
            if ($setupGPG -match '^[Yy]') {
                Import-GPGKey
            }
        }
    }
    
    # Certificate Setup
    if (-not $GPGOnly) {
        $certOk = Test-CodeSigningSetup
        if (-not $certOk) {
            $createCert = Read-Host "`nWould you like to create a self-signed code signing certificate? (y/N)"
            if ($createCert -match '^[Yy]') {
                New-SelfSignedCodeCertificate
            }
        }
    }
    
    # Administrator Check
    Write-Host "`n=== Administrator Privileges ===" -ForegroundColor Yellow
    if (Test-Administrator) {
        Write-Host "✅ Running with administrator privileges" -ForegroundColor Green
    } else {
        Write-Host "❌ Not running with administrator privileges" -ForegroundColor Red
        Write-Host "   Some operations may require administrator rights" -ForegroundColor Yellow
    }
    
    # Final status
    Write-Host "`n=== Final Security Status ===" -ForegroundColor Yellow
    & $securityFramework -Operation status
    
    Show-SecurityInstructions
}

function Start-QuickSetup {
    Show-SecuritySetupBanner
    
    Write-Host "`nRunning quick security setup..." -ForegroundColor Cyan
    
    # Initialize directories
    Initialize-SecurityDirectories
    
    # Show current status
    & $securityFramework -Operation status
    
    Write-Host "`n✅ Security framework initialized" -ForegroundColor Green
    Write-Host "Run with -Interactive for full setup" -ForegroundColor Yellow
}

# Main execution
try {
    if ($Interactive) {
        Start-InteractiveSetup
    } else {
        Start-QuickSetup
    }
}
catch {
    Write-Host "❌ Security setup failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n🎉 Security setup completed!" -ForegroundColor Green