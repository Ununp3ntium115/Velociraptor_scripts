# Velociraptor Professional Installer & Management Suite
# Full GUI Application with MSI-style Installation Experience

<#
.SYNOPSIS
    Professional Velociraptor Installer and Management Application
    
.DESCRIPTION
    Complete GUI-based installer and management suite for Velociraptor DFIR platform.
    Features include:
    - MSI-style installation wizard
    - Configuration management
    - Service management
    - Update management
    - Monitoring dashboard
    - Incident response tools
    
.NOTES
    Version: 6.0.0
    Author: Velociraptor Setup Scripts Team
    Requires: PowerShell 5.1+, Windows 10/Server 2016+
#>

param(
    [switch] $Silent,
    [switch] $Uninstall,
    [string] $ConfigFile,
    [switch] $ServiceMode
)

# Add required assemblies for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# Global configuration
$script:Config = @{
    AppName = "Velociraptor Professional Suite"
    Version = "6.0.0"
    Publisher = "Velociraptor DFIR Community"
    InstallPath = "$env:ProgramFiles\Velociraptor"
    ServiceName = "VelociraptorService"
    RegistryPath = "HKLM:\SOFTWARE\Velociraptor"
    Repository = "Ununp3ntium115/velociraptor"
    LogPath = "$env:ProgramData\Velociraptor\Logs"
}

# Import modules and initialize
Import-Module "$PSScriptRoot\modules\VelociraptorDeployment\VelociraptorDeployment.psd1" -Force -ErrorAction SilentlyContinue# 
Main Application Class
class VelociraptorInstallerApp {
    [System.Windows.Forms.Form] $MainForm
    [System.Windows.Forms.TabControl] $TabControl
    [hashtable] $InstallationState
    [object] $ProgressForm
    [System.Threading.Timer] $StatusTimer
    
    VelociraptorInstallerApp() {
        $this.InstallationState = @{
            IsInstalled = $this.CheckInstallation()
            ServiceStatus = $this.GetServiceStatus()
            Version = $this.GetInstalledVersion()
            LastUpdate = $this.GetLastUpdateTime()
        }
        $this.InitializeMainForm()
    }
    
    [void] InitializeMainForm() {
        $this.MainForm = New-Object System.Windows.Forms.Form
        $this.MainForm.Text = $script:Config.AppName
        $this.MainForm.Size = New-Object System.Drawing.Size(900, 700)
        $this.MainForm.StartPosition = "CenterScreen"
        $this.MainForm.FormBorderStyle = "FixedDialog"
        $this.MainForm.MaximizeBox = $false
        $this.MainForm.Icon = $this.CreateApplicationIcon()
        
        # Create tab control
        $this.TabControl = New-Object System.Windows.Forms.TabControl
        $this.TabControl.Dock = "Fill"
        $this.TabControl.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        
        # Add tabs
        $this.CreateWelcomeTab()
        $this.CreateInstallationTab()
        $this.CreateConfigurationTab()
        $this.CreateManagementTab()
        $this.CreateMonitoringTab()
        $this.CreateIncidentResponseTab()
        $this.CreateSettingsTab()
        
        $this.MainForm.Controls.Add($this.TabControl)
        
        # Start status monitoring
        $this.StartStatusMonitoring()
    }
}    [void] 
CreateWelcomeTab() {
        $welcomeTab = New-Object System.Windows.Forms.TabPage
        $welcomeTab.Text = "Welcome"
        $welcomeTab.BackColor = [System.Drawing.Color]::White
        
        # Welcome panel
        $welcomePanel = New-Object System.Windows.Forms.Panel
        $welcomePanel.Dock = "Fill"
        $welcomePanel.Padding = New-Object System.Windows.Forms.Padding(20)
        
        # Logo and title
        $titleLabel = New-Object System.Windows.Forms.Label
        $titleLabel.Text = "Velociraptor Professional Suite"
        $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 24, [System.Drawing.FontStyle]::Bold)
        $titleLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
        $titleLabel.Location = New-Object System.Drawing.Point(20, 20)
        $titleLabel.Size = New-Object System.Drawing.Size(800, 40)
        
        $versionLabel = New-Object System.Windows.Forms.Label
        $versionLabel.Text = "Version $($script:Config.Version) - Enterprise DFIR Platform"
        $versionLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12)
        $versionLabel.ForeColor = [System.Drawing.Color]::Gray
        $versionLabel.Location = New-Object System.Drawing.Point(20, 70)
        $versionLabel.Size = New-Object System.Drawing.Size(800, 25)
        
        # Status panel
        $statusPanel = $this.CreateStatusPanel()
        $statusPanel.Location = New-Object System.Drawing.Point(20, 120)
        
        # Feature highlights
        $featuresLabel = New-Object System.Windows.Forms.Label
        $featuresLabel.Text = "Key Features:"
        $featuresLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
        $featuresLabel.Location = New-Object System.Drawing.Point(20, 280)
        $featuresLabel.Size = New-Object System.Drawing.Size(200, 30)
        
        $featuresText = @"
• Professional MSI-style installation and management
• Comprehensive GUI for all Velociraptor operations
• Real-time monitoring and health dashboards
• Integrated incident response workflows
• AI-powered investigation assistance
• Multi-platform deployment support
• Enterprise security and compliance features
• Automated updates and maintenance
"@
        
        $featuresListBox = New-Object System.Windows.Forms.TextBox
        $featuresListBox.Text = $featuresText
        $featuresListBox.Multiline = $true
        $featuresListBox.ReadOnly = $true
        $featuresListBox.ScrollBars = "Vertical"
        $featuresListBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $featuresListBox.Location = New-Object System.Drawing.Point(20, 320)
        $featuresListBox.Size = New-Object System.Drawing.Size(820, 200)
        $featuresListBox.BorderStyle = "None"
        $featuresListBox.BackColor = [System.Drawing.Color]::White
        
        # Quick action buttons
        $buttonPanel = New-Object System.Windows.Forms.Panel
        $buttonPanel.Location = New-Object System.Drawing.Point(20, 540)
        $buttonPanel.Size = New-Object System.Drawing.Size(820, 60)
        
        if (-not $this.InstallationState.IsInstalled) {
            $installButton = New-Object System.Windows.Forms.Button
            $installButton.Text = "Install Velociraptor"
            $installButton.Size = New-Object System.Drawing.Size(150, 40)
            $installButton.Location = New-Object System.Drawing.Point(0, 10)
            $installButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
            $installButton.ForeColor = [System.Drawing.Color]::White
            $installButton.FlatStyle = "Flat"
            $installButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
            $installButton.Add_Click({ $this.TabControl.SelectedIndex = 1 })
            $buttonPanel.Controls.Add($installButton)
        } else {
            $manageButton = New-Object System.Windows.Forms.Button
            $manageButton.Text = "Manage Service"
            $manageButton.Size = New-Object System.Drawing.Size(150, 40)
            $manageButton.Location = New-Object System.Drawing.Point(0, 10)
            $manageButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
            $manageButton.ForeColor = [System.Drawing.Color]::White
            $manageButton.FlatStyle = "Flat"
            $manageButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
            $manageButton.Add_Click({ $this.TabControl.SelectedIndex = 3 })
            $buttonPanel.Controls.Add($manageButton)
        }
        
        $welcomePanel.Controls.AddRange(@($titleLabel, $versionLabel, $statusPanel, $featuresLabel, $featuresListBox, $buttonPanel))
        $welcomeTab.Controls.Add($welcomePanel)
        $this.TabControl.TabPages.Add($welcomeTab)
    }    
[object] CreateStatusPanel() {
        $statusPanel = New-Object System.Windows.Forms.GroupBox
        $statusPanel.Text = "System Status"
        $statusPanel.Size = New-Object System.Drawing.Size(820, 140)
        $statusPanel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        # Installation status
        $installStatusLabel = New-Object System.Windows.Forms.Label
        $installStatusLabel.Text = "Installation:"
        $installStatusLabel.Location = New-Object System.Drawing.Point(20, 30)
        $installStatusLabel.Size = New-Object System.Drawing.Size(100, 20)
        $installStatusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        
        $installStatusValue = New-Object System.Windows.Forms.Label
        if ($this.InstallationState.IsInstalled) {
            $installStatusValue.Text = "✓ Installed (v$($this.InstallationState.Version))"
            $installStatusValue.ForeColor = [System.Drawing.Color]::Green
        } else {
            $installStatusValue.Text = "✗ Not Installed"
            $installStatusValue.ForeColor = [System.Drawing.Color]::Red
        }
        $installStatusValue.Location = New-Object System.Drawing.Point(120, 30)
        $installStatusValue.Size = New-Object System.Drawing.Size(200, 20)
        $installStatusValue.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
        
        # Service status
        $serviceStatusLabel = New-Object System.Windows.Forms.Label
        $serviceStatusLabel.Text = "Service:"
        $serviceStatusLabel.Location = New-Object System.Drawing.Point(20, 60)
        $serviceStatusLabel.Size = New-Object System.Drawing.Size(100, 20)
        $serviceStatusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        
        $serviceStatusValue = New-Object System.Windows.Forms.Label
        switch ($this.InstallationState.ServiceStatus) {
            "Running" { 
                $serviceStatusValue.Text = "✓ Running"
                $serviceStatusValue.ForeColor = [System.Drawing.Color]::Green
            }
            "Stopped" { 
                $serviceStatusValue.Text = "⏸ Stopped"
                $serviceStatusValue.ForeColor = [System.Drawing.Color]::Orange
            }
            default { 
                $serviceStatusValue.Text = "✗ Not Available"
                $serviceStatusValue.ForeColor = [System.Drawing.Color]::Red
            }
        }
        $serviceStatusValue.Location = New-Object System.Drawing.Point(120, 60)
        $serviceStatusValue.Size = New-Object System.Drawing.Size(200, 20)
        $serviceStatusValue.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
        
        # Last update
        $updateStatusLabel = New-Object System.Windows.Forms.Label
        $updateStatusLabel.Text = "Last Update:"
        $updateStatusLabel.Location = New-Object System.Drawing.Point(20, 90)
        $updateStatusLabel.Size = New-Object System.Drawing.Size(100, 20)
        $updateStatusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        
        $updateStatusValue = New-Object System.Windows.Forms.Label
        if ($this.InstallationState.LastUpdate) {
            $updateStatusValue.Text = $this.InstallationState.LastUpdate.ToString("yyyy-MM-dd HH:mm")
        } else {
            $updateStatusValue.Text = "Never"
        }
        $updateStatusValue.Location = New-Object System.Drawing.Point(120, 90)
        $updateStatusValue.Size = New-Object System.Drawing.Size(200, 20)
        $updateStatusValue.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        
        $statusPanel.Controls.AddRange(@($installStatusLabel, $installStatusValue, $serviceStatusLabel, $serviceStatusValue, $updateStatusLabel, $updateStatusValue))
        return $statusPanel
    }   
 [void] CreateInstallationTab() {
        $installTab = New-Object System.Windows.Forms.TabPage
        $installTab.Text = "Installation"
        $installTab.BackColor = [System.Drawing.Color]::White
        
        # Installation wizard panel
        $wizardPanel = New-Object System.Windows.Forms.Panel
        $wizardPanel.Dock = "Fill"
        $wizardPanel.Padding = New-Object System.Windows.Forms.Padding(20)
        
        # Title
        $titleLabel = New-Object System.Windows.Forms.Label
        $titleLabel.Text = "Velociraptor Installation Wizard"
        $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
        $titleLabel.Location = New-Object System.Drawing.Point(20, 20)
        $titleLabel.Size = New-Object System.Drawing.Size(400, 30)
        
        # Installation type selection
        $typeGroupBox = New-Object System.Windows.Forms.GroupBox
        $typeGroupBox.Text = "Installation Type"
        $typeGroupBox.Location = New-Object System.Drawing.Point(20, 70)
        $typeGroupBox.Size = New-Object System.Drawing.Size(820, 120)
        $typeGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        $standaloneRadio = New-Object System.Windows.Forms.RadioButton
        $standaloneRadio.Text = "Standalone Client - For single machine DFIR analysis"
        $standaloneRadio.Location = New-Object System.Drawing.Point(20, 30)
        $standaloneRadio.Size = New-Object System.Drawing.Size(780, 25)
        $standaloneRadio.Checked = $true
        $standaloneRadio.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        
        $serverRadio = New-Object System.Windows.Forms.RadioButton
        $serverRadio.Text = "Server Installation - For enterprise deployment with multiple clients"
        $serverRadio.Location = New-Object System.Drawing.Point(20, 60)
        $serverRadio.Size = New-Object System.Drawing.Size(780, 25)
        $serverRadio.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        
        $typeGroupBox.Controls.AddRange(@($standaloneRadio, $serverRadio))
        
        # Installation path
        $pathGroupBox = New-Object System.Windows.Forms.GroupBox
        $pathGroupBox.Text = "Installation Directory"
        $pathGroupBox.Location = New-Object System.Drawing.Point(20, 210)
        $pathGroupBox.Size = New-Object System.Drawing.Size(820, 80)
        $pathGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        $pathTextBox = New-Object System.Windows.Forms.TextBox
        $pathTextBox.Text = $script:Config.InstallPath
        $pathTextBox.Location = New-Object System.Drawing.Point(20, 30)
        $pathTextBox.Size = New-Object System.Drawing.Size(650, 25)
        $pathTextBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        
        $browseButton = New-Object System.Windows.Forms.Button
        $browseButton.Text = "Browse..."
        $browseButton.Location = New-Object System.Drawing.Point(680, 28)
        $browseButton.Size = New-Object System.Drawing.Size(100, 28)
        $browseButton.Add_Click({
            $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
            $folderDialog.Description = "Select installation directory"
            $folderDialog.SelectedPath = $pathTextBox.Text
            if ($folderDialog.ShowDialog() -eq "OK") {
                $pathTextBox.Text = $folderDialog.SelectedPath
            }
        })
        
        $pathGroupBox.Controls.AddRange(@($pathTextBox, $browseButton))
        
        # Advanced options
        $advancedGroupBox = New-Object System.Windows.Forms.GroupBox
        $advancedGroupBox.Text = "Advanced Options"
        $advancedGroupBox.Location = New-Object System.Drawing.Point(20, 310)
        $advancedGroupBox.Size = New-Object System.Drawing.Size(820, 120)
        $advancedGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        $serviceCheckBox = New-Object System.Windows.Forms.CheckBox
        $serviceCheckBox.Text = "Install as Windows Service (Recommended)"
        $serviceCheckBox.Location = New-Object System.Drawing.Point(20, 30)
        $serviceCheckBox.Size = New-Object System.Drawing.Size(400, 25)
        $serviceCheckBox.Checked = $true
        $serviceCheckBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        
        $firewallCheckBox = New-Object System.Windows.Forms.CheckBox
        $firewallCheckBox.Text = "Configure Windows Firewall rules"
        $firewallCheckBox.Location = New-Object System.Drawing.Point(20, 60)
        $firewallCheckBox.Size = New-Object System.Drawing.Size(400, 25)
        $firewallCheckBox.Checked = $true
        $firewallCheckBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        
        $desktopCheckBox = New-Object System.Windows.Forms.CheckBox
        $desktopCheckBox.Text = "Create desktop shortcut"
        $desktopCheckBox.Location = New-Object System.Drawing.Point(20, 90)
        $desktopCheckBox.Size = New-Object System.Drawing.Size(400, 25)
        $desktopCheckBox.Checked = $true
        $desktopCheckBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        
        $advancedGroupBox.Controls.AddRange(@($serviceCheckBox, $firewallCheckBox, $desktopCheckBox))
        
        # Installation buttons
        $buttonPanel = New-Object System.Windows.Forms.Panel
        $buttonPanel.Location = New-Object System.Drawing.Point(20, 450)
        $buttonPanel.Size = New-Object System.Drawing.Size(820, 60)
        
        $installButton = New-Object System.Windows.Forms.Button
        $installButton.Text = "Install Velociraptor"
        $installButton.Size = New-Object System.Drawing.Size(150, 40)
        $installButton.Location = New-Object System.Drawing.Point(0, 10)
        $installButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
        $installButton.ForeColor = [System.Drawing.Color]::White
        $installButton.FlatStyle = "Flat"
        $installButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $installButton.Add_Click({
            $this.StartInstallation($standaloneRadio.Checked, $pathTextBox.Text, $serviceCheckBox.Checked, $firewallCheckBox.Checked, $desktopCheckBox.Checked)
        })
        
        $cancelButton = New-Object System.Windows.Forms.Button
        $cancelButton.Text = "Cancel"
        $cancelButton.Size = New-Object System.Drawing.Size(100, 40)
        $cancelButton.Location = New-Object System.Drawing.Point(170, 10)
        $cancelButton.BackColor = [System.Drawing.Color]::Gray
        $cancelButton.ForeColor = [System.Drawing.Color]::White
        $cancelButton.FlatStyle = "Flat"
        $cancelButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        
        $buttonPanel.Controls.AddRange(@($installButton, $cancelButton))
        
        $wizardPanel.Controls.AddRange(@($titleLabel, $typeGroupBox, $pathGroupBox, $advancedGroupBox, $buttonPanel))
        $installTab.Controls.Add($wizardPanel)
        $this.TabControl.TabPages.Add($installTab)
    }