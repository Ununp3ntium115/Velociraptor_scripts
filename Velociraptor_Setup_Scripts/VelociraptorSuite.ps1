# Velociraptor Suite - Unified GUI Launcher
# Simple launcher for all 3 Velociraptor GUI applications

<#
.SYNOPSIS
    Velociraptor Suite - Unified GUI Launcher
    
.DESCRIPTION
    Simple launcher that provides access to all 3 Velociraptor GUI applications:
    1. Investigations - Investigation management and incident response
    2. Offline Worker - Portable evidence collection
    3. Server Setup - Installation and configuration
#>

# Add required assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Global configuration
$script:Config = @{
    AppName = "Velociraptor Suite"
    Version = "6.0.0"
    ScriptPath = $PSScriptRoot
}

# Main Launcher Class
class VelociraptorSuiteLauncher {
    [System.Windows.Forms.Form] $MainForm
    
    VelociraptorSuiteLauncher() {
        $this.InitializeMainForm()
    }
    
    [void] InitializeMainForm() {
        $this.MainForm = New-Object System.Windows.Forms.Form
        $this.MainForm.Text = $script:Config.AppName
        $this.MainForm.Size = New-Object System.Drawing.Size(600, 500)
        $this.MainForm.StartPosition = "CenterScreen"
        $this.MainForm.FormBorderStyle = "FixedDialog"
        $this.MainForm.MaximizeBox = $false
        $this.MainForm.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        
        # Create main layout
        $this.CreateHeader()
        $this.CreateApplicationButtons()
        $this.CreateFooter()
    }
    
    [void] CreateHeader() {
        $headerPanel = New-Object System.Windows.Forms.Panel
        $headerPanel.Height = 100
        $headerPanel.Dock = "Top"
        $headerPanel.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
        
        $titleLabel = New-Object System.Windows.Forms.Label
        $titleLabel.Text = "🦖 Velociraptor Suite"
        $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 24, [System.Drawing.FontStyle]::Bold)
        $titleLabel.ForeColor = [System.Drawing.Color]::White
        $titleLabel.Location = New-Object System.Drawing.Point(20, 20)
        $titleLabel.Size = New-Object System.Drawing.Size(400, 40)
        
        $subtitleLabel = New-Object System.Windows.Forms.Label
        $subtitleLabel.Text = "Professional DFIR Platform v$($script:Config.Version)"
        $subtitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12)
        $subtitleLabel.ForeColor = [System.Drawing.Color]::LightGray
        $subtitleLabel.Location = New-Object System.Drawing.Point(20, 65)
        $subtitleLabel.Size = New-Object System.Drawing.Size(400, 25)
        
        $headerPanel.Controls.AddRange(@($titleLabel, $subtitleLabel))
        $this.MainForm.Controls.Add($headerPanel)
    }
    
    [void] CreateApplicationButtons() {
        $mainPanel = New-Object System.Windows.Forms.Panel
        $mainPanel.Location = New-Object System.Drawing.Point(0, 100)
        $mainPanel.Size = New-Object System.Drawing.Size(600, 320)
        $mainPanel.BackColor = [System.Drawing.Color]::White
        
        # Application descriptions
        $descriptionLabel = New-Object System.Windows.Forms.Label
        $descriptionLabel.Text = "Choose the Velociraptor application you need:"
        $descriptionLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
        $descriptionLabel.Location = New-Object System.Drawing.Point(50, 20)
        $descriptionLabel.Size = New-Object System.Drawing.Size(500, 25)
        
        # Investigations button
        $investigationsButton = New-Object System.Windows.Forms.Button
        $investigationsButton.Text = @"
🔍 INVESTIGATIONS
Investigation Management & Incident Response

• Manage active DFIR investigations
• Quick response for malware, APT, ransomware
• Investigation tracking and reporting
• Evidence analysis and correlation
"@
        $investigationsButton.Size = New-Object System.Drawing.Size(500, 70)
        $investigationsButton.Location = New-Object System.Drawing.Point(50, 60)
        $investigationsButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
        $investigationsButton.ForeColor = [System.Drawing.Color]::White
        $investigationsButton.FlatStyle = "Flat"
        $investigationsButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $investigationsButton.TextAlign = "MiddleLeft"
        $investigationsButton.Add_Click({ $this.LaunchInvestigations() })
        
        # Offline Worker button
        $offlineButton = New-Object System.Windows.Forms.Button
        $offlineButton.Text = @"
💼 OFFLINE WORKER
Portable Evidence Collection & Analysis

• Offline evidence collection for field work
• Pre-configured artifact collections
• Portable investigation capabilities
• No network connectivity required
"@
        $offlineButton.Size = New-Object System.Drawing.Size(500, 70)
        $offlineButton.Location = New-Object System.Drawing.Point(50, 140)
        $offlineButton.BackColor = [System.Drawing.Color]::FromArgb(34, 139, 34)
        $offlineButton.ForeColor = [System.Drawing.Color]::White
        $offlineButton.FlatStyle = "Flat"
        $offlineButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $offlineButton.TextAlign = "MiddleLeft"
        $offlineButton.Add_Click({ $this.LaunchOfflineWorker() })
        
        # Server Setup button
        $serverButton = New-Object System.Windows.Forms.Button
        $serverButton.Text = @"
⚙️ SERVER SETUP
Installation, Configuration & Management

• Install Velociraptor server or standalone
• Configure server settings and database
• Service management and updates
• System administration tools
"@
        $serverButton.Size = New-Object System.Drawing.Size(500, 70)
        $serverButton.Location = New-Object System.Drawing.Point(50, 220)
        $serverButton.BackColor = [System.Drawing.Color]::FromArgb(70, 130, 180)
        $serverButton.ForeColor = [System.Drawing.Color]::White
        $serverButton.FlatStyle = "Flat"
        $serverButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $serverButton.TextAlign = "MiddleLeft"
        $serverButton.Add_Click({ $this.LaunchServerSetup() })
        
        $mainPanel.Controls.AddRange(@($descriptionLabel, $investigationsButton, $offlineButton, $serverButton))
        $this.MainForm.Controls.Add($mainPanel)
    }
    
    [void] CreateFooter() {
        $footerPanel = New-Object System.Windows.Forms.Panel
        $footerPanel.Height = 80
        $footerPanel.Dock = "Bottom"
        $footerPanel.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
        
        $infoLabel = New-Object System.Windows.Forms.Label
        $infoLabel.Text = @"
Velociraptor Professional Suite - Enterprise DFIR Platform
Built on the powerful Velociraptor framework for digital forensics and incident response
© 2024 Velociraptor Community - Open Source DFIR Tools
"@
        $infoLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $infoLabel.ForeColor = [System.Drawing.Color]::Gray
        $infoLabel.Location = New-Object System.Drawing.Point(20, 10)
        $infoLabel.Size = New-Object System.Drawing.Size(560, 60)
        $infoLabel.TextAlign = "MiddleCenter"
        
        $footerPanel.Controls.Add($infoLabel)
        $this.MainForm.Controls.Add($footerPanel)
    }
    
    [void] LaunchInvestigations() {
        try {
            $investigationsPath = Join-Path $script:Config.ScriptPath "VelociraptorInvestigations.ps1"
            if (Test-Path $investigationsPath) {
                Start-Process "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$investigationsPath`""
            } else {
                [System.Windows.Forms.MessageBox]::Show("VelociraptorInvestigations.ps1 not found in the same directory.", "File Not Found", "OK", "Error")
            }
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Failed to launch Investigations: $($_.Exception.Message)", "Launch Error", "OK", "Error")
        }
    }
    
    [void] LaunchOfflineWorker() {
        try {
            $offlinePath = Join-Path $script:Config.ScriptPath "VelociraptorOfflineWorker.ps1"
            if (Test-Path $offlinePath) {
                Start-Process "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$offlinePath`""
            } else {
                [System.Windows.Forms.MessageBox]::Show("VelociraptorOfflineWorker.ps1 not found in the same directory.", "File Not Found", "OK", "Error")
            }
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Failed to launch Offline Worker: $($_.Exception.Message)", "Launch Error", "OK", "Error")
        }
    }
    
    [void] LaunchServerSetup() {
        try {
            $serverPath = Join-Path $script:Config.ScriptPath "VelociraptorServerSetup.ps1"
            if (Test-Path $serverPath) {
                # Server setup needs admin privileges
                Start-Process "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$serverPath`"" -Verb RunAs
            } else {
                [System.Windows.Forms.MessageBox]::Show("VelociraptorServerSetup.ps1 not found in the same directory.", "File Not Found", "OK", "Error")
            }
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Failed to launch Server Setup: $($_.Exception.Message)", "Launch Error", "OK", "Error")
        }
    }
    
    [void] Show() {
        [System.Windows.Forms.Application]::Run($this.MainForm)
    }
}

# Main execution
function Start-VelociraptorSuite {
    try {
        $launcher = [VelociraptorSuiteLauncher]::new()
        $launcher.Show()
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to start Velociraptor Suite: $($_.Exception.Message)", "Application Error", "OK", "Error")
        Write-Error $_.Exception.Message
    }
}

# Entry point
if ($MyInvocation.InvocationName -ne '.') {
    Start-VelociraptorSuite
}