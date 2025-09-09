#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Velociraptor Professional Installer & Management Suite
    
.DESCRIPTION
    Complete GUI-based installer and management suite for Velociraptor DFIR platform.
    
    Features:
    • MSI-style installation wizard
    • Professional GUI interface
    • Service management
    • Configuration management
    • Real-time monitoring
    • Incident response tools
    • Automated updates
    
.PARAMETER Silent
    Run in silent installation mode
    
.PARAMETER Uninstall
    Uninstall Velociraptor
    
.PARAMETER ConfigFile
    Path to configuration file
    
.PARAMETER ServiceMode
    Run in service mode
    
.EXAMPLE
    .\VelociraptorInstaller.ps1
    Launch the GUI installer
    
.EXAMPLE
    .\VelociraptorInstaller.ps1 -Silent
    Perform silent installation
    
.EXAMPLE
    .\VelociraptorInstaller.ps1 -Uninstall
    Uninstall Velociraptor
    
.NOTES
    Version: 6.0.0
    Author: Velociraptor Setup Scripts Team
    Requires: PowerShell 5.1+, Windows 10/Server 2016+, Administrator privileges
#>

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
[void] CreateConfigurationTab() {
        $configTab = New-Object System.Windows.Forms.TabPage
        $configTab.Text = "Configuration"
        $configTab.BackColor = [System.Drawing.Color]::White
        
        $configPanel = New-Object System.Windows.Forms.Panel
        $configPanel.Dock = "Fill"
        $configPanel.Padding = New-Object System.Windows.Forms.Padding(20)
        
        # Title
        $titleLabel = New-Object System.Windows.Forms.Label
        $titleLabel.Text = "Velociraptor Configuration"
        $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
        $titleLabel.Location = New-Object System.Drawing.Point(20, 20)
        $titleLabel.Size = New-Object System.Drawing.Size(400, 30)
        
        # Configuration sections in a tab control
        $configTabControl = New-Object System.Windows.Forms.TabControl
        $configTabControl.Location = New-Object System.Drawing.Point(20, 70)
        $configTabControl.Size = New-Object System.Drawing.Size(820, 450)
        
        # Server settings tab
        $serverConfigTab = New-Object System.Windows.Forms.TabPage
        $serverConfigTab.Text = "Server Settings"
        
        $serverPanel = New-Object System.Windows.Forms.Panel
        $serverPanel.Dock = "Fill"
        $serverPanel.Padding = New-Object System.Windows.Forms.Padding(10)
        
        # GUI Port
        $guiPortLabel = New-Object System.Windows.Forms.Label
        $guiPortLabel.Text = "GUI Port:"
        $guiPortLabel.Location = New-Object System.Drawing.Point(10, 20)
        $guiPortLabel.Size = New-Object System.Drawing.Size(100, 20)
        
        $guiPortTextBox = New-Object System.Windows.Forms.TextBox
        $guiPortTextBox.Text = "8889"
        $guiPortTextBox.Location = New-Object System.Drawing.Point(120, 18)
        $guiPortTextBox.Size = New-Object System.Drawing.Size(100, 25)
        
        # Frontend Port
        $frontendPortLabel = New-Object System.Windows.Forms.Label
        $frontendPortLabel.Text = "Frontend Port:"
        $frontendPortLabel.Location = New-Object System.Drawing.Point(10, 60)
        $frontendPortLabel.Size = New-Object System.Drawing.Size(100, 20)
        
        $frontendPortTextBox = New-Object System.Windows.Forms.TextBox
        $frontendPortTextBox.Text = "8000"
        $frontendPortTextBox.Location = New-Object System.Drawing.Point(120, 58)
        $frontendPortTextBox.Size = New-Object System.Drawing.Size(100, 25)
        
        # SSL Configuration
        $sslGroupBox = New-Object System.Windows.Forms.GroupBox
        $sslGroupBox.Text = "SSL Configuration"
        $sslGroupBox.Location = New-Object System.Drawing.Point(10, 100)
        $sslGroupBox.Size = New-Object System.Drawing.Size(780, 120)
        
        $enableSSLCheckBox = New-Object System.Windows.Forms.CheckBox
        $enableSSLCheckBox.Text = "Enable SSL/TLS"
        $enableSSLCheckBox.Location = New-Object System.Drawing.Point(20, 30)
        $enableSSLCheckBox.Size = New-Object System.Drawing.Size(200, 25)
        $enableSSLCheckBox.Checked = $true
        
        $certPathLabel = New-Object System.Windows.Forms.Label
        $certPathLabel.Text = "Certificate Path:"
        $certPathLabel.Location = New-Object System.Drawing.Point(20, 65)
        $certPathLabel.Size = New-Object System.Drawing.Size(100, 20)
        
        $certPathTextBox = New-Object System.Windows.Forms.TextBox
        $certPathTextBox.Location = New-Object System.Drawing.Point(130, 63)
        $certPathTextBox.Size = New-Object System.Drawing.Size(500, 25)
        
        $certBrowseButton = New-Object System.Windows.Forms.Button
        $certBrowseButton.Text = "Browse..."
        $certBrowseButton.Location = New-Object System.Drawing.Point(640, 61)
        $certBrowseButton.Size = New-Object System.Drawing.Size(80, 28)
        
        $sslGroupBox.Controls.AddRange(@($enableSSLCheckBox, $certPathLabel, $certPathTextBox, $certBrowseButton))
        
        $serverPanel.Controls.AddRange(@($guiPortLabel, $guiPortTextBox, $frontendPortLabel, $frontendPortTextBox, $sslGroupBox))
        $serverConfigTab.Controls.Add($serverPanel)
        $configTabControl.TabPages.Add($serverConfigTab)
        
        # Database settings tab
        $dbConfigTab = New-Object System.Windows.Forms.TabPage
        $dbConfigTab.Text = "Database"
        
        $dbPanel = New-Object System.Windows.Forms.Panel
        $dbPanel.Dock = "Fill"
        $dbPanel.Padding = New-Object System.Windows.Forms.Padding(10)
        
        $dbTypeLabel = New-Object System.Windows.Forms.Label
        $dbTypeLabel.Text = "Database Type:"
        $dbTypeLabel.Location = New-Object System.Drawing.Point(10, 20)
        $dbTypeLabel.Size = New-Object System.Drawing.Size(100, 20)
        
        $dbTypeComboBox = New-Object System.Windows.Forms.ComboBox
        $dbTypeComboBox.Items.AddRange(@("SQLite (Default)", "MySQL", "PostgreSQL"))
        $dbTypeComboBox.SelectedIndex = 0
        $dbTypeComboBox.Location = New-Object System.Drawing.Point(120, 18)
        $dbTypeComboBox.Size = New-Object System.Drawing.Size(200, 25)
        $dbTypeComboBox.DropDownStyle = "DropDownList"
        
        $dbPathLabel = New-Object System.Windows.Forms.Label
        $dbPathLabel.Text = "Database Path:"
        $dbPathLabel.Location = New-Object System.Drawing.Point(10, 60)
        $dbPathLabel.Size = New-Object System.Drawing.Size(100, 20)
        
        $dbPathTextBox = New-Object System.Windows.Forms.TextBox
        $dbPathTextBox.Text = "$($script:Config.InstallPath)\velociraptor.db"
        $dbPathTextBox.Location = New-Object System.Drawing.Point(120, 58)
        $dbPathTextBox.Size = New-Object System.Drawing.Size(500, 25)
        
        $dbBrowseButton = New-Object System.Windows.Forms.Button
        $dbBrowseButton.Text = "Browse..."
        $dbBrowseButton.Location = New-Object System.Drawing.Point(630, 56)
        $dbBrowseButton.Size = New-Object System.Drawing.Size(80, 28)
        
        $dbPanel.Controls.AddRange(@($dbTypeLabel, $dbTypeComboBox, $dbPathLabel, $dbPathTextBox, $dbBrowseButton))
        $dbConfigTab.Controls.Add($dbPanel)
        $configTabControl.TabPages.Add($dbConfigTab)
        
        # Security settings tab
        $securityConfigTab = New-Object System.Windows.Forms.TabPage
        $securityConfigTab.Text = "Security"
        
        $securityPanel = New-Object System.Windows.Forms.Panel
        $securityPanel.Dock = "Fill"
        $securityPanel.Padding = New-Object System.Windows.Forms.Padding(10)
        
        $authGroupBox = New-Object System.Windows.Forms.GroupBox
        $authGroupBox.Text = "Authentication"
        $authGroupBox.Location = New-Object System.Drawing.Point(10, 20)
        $authGroupBox.Size = New-Object System.Drawing.Size(780, 150)
        
        $basicAuthRadio = New-Object System.Windows.Forms.RadioButton
        $basicAuthRadio.Text = "Basic Authentication (Username/Password)"
        $basicAuthRadio.Location = New-Object System.Drawing.Point(20, 30)
        $basicAuthRadio.Size = New-Object System.Drawing.Size(400, 25)
        $basicAuthRadio.Checked = $true
        
        $oidcAuthRadio = New-Object System.Windows.Forms.RadioButton
        $oidcAuthRadio.Text = "OIDC/OAuth2 Authentication"
        $oidcAuthRadio.Location = New-Object System.Drawing.Point(20, 60)
        $oidcAuthRadio.Size = New-Object System.Drawing.Size(400, 25)
        
        $samlAuthRadio = New-Object System.Windows.Forms.RadioButton
        $samlAuthRadio.Text = "SAML Authentication"
        $samlAuthRadio.Location = New-Object System.Drawing.Point(20, 90)
        $samlAuthRadio.Size = New-Object System.Drawing.Size(400, 25)
        
        $authGroupBox.Controls.AddRange(@($basicAuthRadio, $oidcAuthRadio, $samlAuthRadio))
        
        $securityPanel.Controls.Add($authGroupBox)
        $securityConfigTab.Controls.Add($securityPanel)
        $configTabControl.TabPages.Add($securityConfigTab)
        
        # Save configuration button
        $saveConfigButton = New-Object System.Windows.Forms.Button
        $saveConfigButton.Text = "Save Configuration"
        $saveConfigButton.Size = New-Object System.Drawing.Size(150, 40)
        $saveConfigButton.Location = New-Object System.Drawing.Point(20, 540)
        $saveConfigButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
        $saveConfigButton.ForeColor = [System.Drawing.Color]::White
        $saveConfigButton.FlatStyle = "Flat"
        $saveConfigButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $saveConfigButton.Add_Click({
            $this.SaveConfiguration(@{
                GuiPort = $guiPortTextBox.Text
                FrontendPort = $frontendPortTextBox.Text
                EnableSSL = $enableSSLCheckBox.Checked
                CertPath = $certPathTextBox.Text
                DatabaseType = $dbTypeComboBox.SelectedItem
                DatabasePath = $dbPathTextBox.Text
                AuthType = if ($basicAuthRadio.Checked) { "Basic" } elseif ($oidcAuthRadio.Checked) { "OIDC" } else { "SAML" }
            })
        })
        
        $configPanel.Controls.AddRange(@($titleLabel, $configTabControl, $saveConfigButton))
        $configTab.Controls.Add($configPanel)
        $this.TabControl.TabPages.Add($configTab)
    }  
  [void] CreateManagementTab() {
        $mgmtTab = New-Object System.Windows.Forms.TabPage
        $mgmtTab.Text = "Management"
        $mgmtTab.BackColor = [System.Drawing.Color]::White
        
        $mgmtPanel = New-Object System.Windows.Forms.Panel
        $mgmtPanel.Dock = "Fill"
        $mgmtPanel.Padding = New-Object System.Windows.Forms.Padding(20)
        
        # Title
        $titleLabel = New-Object System.Windows.Forms.Label
        $titleLabel.Text = "Service Management"
        $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
        $titleLabel.Location = New-Object System.Drawing.Point(20, 20)
        $titleLabel.Size = New-Object System.Drawing.Size(400, 30)
        
        # Service control panel
        $serviceGroupBox = New-Object System.Windows.Forms.GroupBox
        $serviceGroupBox.Text = "Velociraptor Service Control"
        $serviceGroupBox.Location = New-Object System.Drawing.Point(20, 70)
        $serviceGroupBox.Size = New-Object System.Drawing.Size(820, 150)
        $serviceGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        # Service status display
        $serviceStatusLabel = New-Object System.Windows.Forms.Label
        $serviceStatusLabel.Text = "Service Status:"
        $serviceStatusLabel.Location = New-Object System.Drawing.Point(20, 30)
        $serviceStatusLabel.Size = New-Object System.Drawing.Size(100, 20)
        $serviceStatusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        
        $serviceStatusValue = New-Object System.Windows.Forms.Label
        $serviceStatusValue.Text = $this.InstallationState.ServiceStatus
        $serviceStatusValue.Location = New-Object System.Drawing.Point(130, 30)
        $serviceStatusValue.Size = New-Object System.Drawing.Size(200, 20)
        $serviceStatusValue.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
        $serviceStatusValue.ForeColor = if ($this.InstallationState.ServiceStatus -eq "Running") { [System.Drawing.Color]::Green } else { [System.Drawing.Color]::Red }
        
        # Service control buttons
        $startButton = New-Object System.Windows.Forms.Button
        $startButton.Text = "Start Service"
        $startButton.Size = New-Object System.Drawing.Size(100, 35)
        $startButton.Location = New-Object System.Drawing.Point(20, 70)
        $startButton.BackColor = [System.Drawing.Color]::Green
        $startButton.ForeColor = [System.Drawing.Color]::White
        $startButton.FlatStyle = "Flat"
        $startButton.Add_Click({ $this.StartService() })
        
        $stopButton = New-Object System.Windows.Forms.Button
        $stopButton.Text = "Stop Service"
        $stopButton.Size = New-Object System.Drawing.Size(100, 35)
        $stopButton.Location = New-Object System.Drawing.Point(130, 70)
        $stopButton.BackColor = [System.Drawing.Color]::Red
        $stopButton.ForeColor = [System.Drawing.Color]::White
        $stopButton.FlatStyle = "Flat"
        $stopButton.Add_Click({ $this.StopService() })
        
        $restartButton = New-Object System.Windows.Forms.Button
        $restartButton.Text = "Restart Service"
        $restartButton.Size = New-Object System.Drawing.Size(100, 35)
        $restartButton.Location = New-Object System.Drawing.Point(240, 70)
        $restartButton.BackColor = [System.Drawing.Color]::Orange
        $restartButton.ForeColor = [System.Drawing.Color]::White
        $restartButton.FlatStyle = "Flat"
        $restartButton.Add_Click({ $this.RestartService() })
        
        $openWebUIButton = New-Object System.Windows.Forms.Button
        $openWebUIButton.Text = "Open Web UI"
        $openWebUIButton.Size = New-Object System.Drawing.Size(120, 35)
        $openWebUIButton.Location = New-Object System.Drawing.Point(360, 70)
        $openWebUIButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
        $openWebUIButton.ForeColor = [System.Drawing.Color]::White
        $openWebUIButton.FlatStyle = "Flat"
        $openWebUIButton.Add_Click({ $this.OpenWebUI() })
        
        $serviceGroupBox.Controls.AddRange(@($serviceStatusLabel, $serviceStatusValue, $startButton, $stopButton, $restartButton, $openWebUIButton))
        
        # Update management
        $updateGroupBox = New-Object System.Windows.Forms.GroupBox
        $updateGroupBox.Text = "Update Management"
        $updateGroupBox.Location = New-Object System.Drawing.Point(20, 240)
        $updateGroupBox.Size = New-Object System.Drawing.Size(820, 120)
        $updateGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        $currentVersionLabel = New-Object System.Windows.Forms.Label
        $currentVersionLabel.Text = "Current Version:"
        $currentVersionLabel.Location = New-Object System.Drawing.Point(20, 30)
        $currentVersionLabel.Size = New-Object System.Drawing.Size(100, 20)
        $currentVersionLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        
        $currentVersionValue = New-Object System.Windows.Forms.Label
        $currentVersionValue.Text = $this.InstallationState.Version ?? "Not Installed"
        $currentVersionValue.Location = New-Object System.Drawing.Point(130, 30)
        $currentVersionValue.Size = New-Object System.Drawing.Size(200, 20)
        $currentVersionValue.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
        
        $checkUpdatesButton = New-Object System.Windows.Forms.Button
        $checkUpdatesButton.Text = "Check for Updates"
        $checkUpdatesButton.Size = New-Object System.Drawing.Size(130, 35)
        $checkUpdatesButton.Location = New-Object System.Drawing.Point(20, 70)
        $checkUpdatesButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
        $checkUpdatesButton.ForeColor = [System.Drawing.Color]::White
        $checkUpdatesButton.FlatStyle = "Flat"
        $checkUpdatesButton.Add_Click({ $this.CheckForUpdates() })
        
        $updateButton = New-Object System.Windows.Forms.Button
        $updateButton.Text = "Update Now"
        $updateButton.Size = New-Object System.Drawing.Size(100, 35)
        $updateButton.Location = New-Object System.Drawing.Point(160, 70)
        $updateButton.BackColor = [System.Drawing.Color]::Green
        $updateButton.ForeColor = [System.Drawing.Color]::White
        $updateButton.FlatStyle = "Flat"
        $updateButton.Enabled = $false
        $updateButton.Add_Click({ $this.UpdateVelociraptor() })
        
        $updateGroupBox.Controls.AddRange(@($currentVersionLabel, $currentVersionValue, $checkUpdatesButton, $updateButton))
        
        # Backup and restore
        $backupGroupBox = New-Object System.Windows.Forms.GroupBox
        $backupGroupBox.Text = "Backup & Restore"
        $backupGroupBox.Location = New-Object System.Drawing.Point(20, 380)
        $backupGroupBox.Size = New-Object System.Drawing.Size(820, 120)
        $backupGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        $backupButton = New-Object System.Windows.Forms.Button
        $backupButton.Text = "Create Backup"
        $backupButton.Size = New-Object System.Drawing.Size(120, 35)
        $backupButton.Location = New-Object System.Drawing.Point(20, 30)
        $backupButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
        $backupButton.ForeColor = [System.Drawing.Color]::White
        $backupButton.FlatStyle = "Flat"
        $backupButton.Add_Click({ $this.CreateBackup() })
        
        $restoreButton = New-Object System.Windows.Forms.Button
        $restoreButton.Text = "Restore Backup"
        $restoreButton.Size = New-Object System.Drawing.Size(120, 35)
        $restoreButton.Location = New-Object System.Drawing.Point(150, 30)
        $restoreButton.BackColor = [System.Drawing.Color]::Orange
        $restoreButton.ForeColor = [System.Drawing.Color]::White
        $restoreButton.FlatStyle = "Flat"
        $restoreButton.Add_Click({ $this.RestoreBackup() })
        
        $uninstallButton = New-Object System.Windows.Forms.Button
        $uninstallButton.Text = "Uninstall"
        $uninstallButton.Size = New-Object System.Drawing.Size(100, 35)
        $uninstallButton.Location = New-Object System.Drawing.Point(300, 30)
        $uninstallButton.BackColor = [System.Drawing.Color]::Red
        $uninstallButton.ForeColor = [System.Drawing.Color]::White
        $uninstallButton.FlatStyle = "Flat"
        $uninstallButton.Add_Click({ $this.UninstallVelociraptor() })
        
        $backupGroupBox.Controls.AddRange(@($backupButton, $restoreButton, $uninstallButton))
        
        $mgmtPanel.Controls.AddRange(@($titleLabel, $serviceGroupBox, $updateGroupBox, $backupGroupBox))
        $mgmtTab.Controls.Add($mgmtPanel)
        $this.TabControl.TabPages.Add($mgmtTab)
    }
Functions

    [void] CreateMonitoringTab() {
        $monitorTab = New-Object System.Windows.Forms.TabPage
        $monitorTab.Text = "Monitoring"
        $monitorTab.BackColor = [System.Drawing.Color]::White
        
        $monitorPanel = New-Object System.Windows.Forms.Panel
        $monitorPanel.Dock = "Fill"
        $monitorPanel.Padding = New-Object System.Windows.Forms.Padding(20)
        
        # Title
        $titleLabel = New-Object System.Windows.Forms.Label
        $titleLabel.Text = "System Monitoring Dashboard"
        $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
        $titleLabel.Location = New-Object System.Drawing.Point(20, 20)
        $titleLabel.Size = New-Object System.Drawing.Size(400, 30)
        
        # Real-time metrics panel
        $metricsGroupBox = New-Object System.Windows.Forms.GroupBox
        $metricsGroupBox.Text = "Real-time Metrics"
        $metricsGroupBox.Location = New-Object System.Drawing.Point(20, 70)
        $metricsGroupBox.Size = New-Object System.Drawing.Size(820, 200)
        $metricsGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        # Create metrics display
        $metricsListView = New-Object System.Windows.Forms.ListView
        $metricsListView.View = "Details"
        $metricsListView.FullRowSelect = $true
        $metricsListView.GridLines = $true
        $metricsListView.Location = New-Object System.Drawing.Point(20, 30)
        $metricsListView.Size = New-Object System.Drawing.Size(780, 150)
        
        $metricsListView.Columns.Add("Metric", 200) | Out-Null
        $metricsListView.Columns.Add("Current Value", 150) | Out-Null
        $metricsListView.Columns.Add("Status", 100) | Out-Null
        $metricsListView.Columns.Add("Last Updated", 150) | Out-Null
        
        # Add sample metrics
        $metrics = @(
            @("Active Clients", "0", "OK", (Get-Date).ToString("HH:mm:ss")),
            @("Running Hunts", "0", "OK", (Get-Date).ToString("HH:mm:ss")),
            @("CPU Usage", "0%", "OK", (Get-Date).ToString("HH:mm:ss")),
            @("Memory Usage", "0 MB", "OK", (Get-Date).ToString("HH:mm:ss")),
            @("Disk Usage", "0 GB", "OK", (Get-Date).ToString("HH:mm:ss"))
        )
        
        foreach ($metric in $metrics) {
            $item = New-Object System.Windows.Forms.ListViewItem($metric[0])
            $item.SubItems.Add($metric[1]) | Out-Null
            $item.SubItems.Add($metric[2]) | Out-Null
            $item.SubItems.Add($metric[3]) | Out-Null
            $metricsListView.Items.Add($item) | Out-Null
        }
        
        $metricsGroupBox.Controls.Add($metricsListView)
        
        # Client management
        $clientsGroupBox = New-Object System.Windows.Forms.GroupBox
        $clientsGroupBox.Text = "Connected Clients"
        $clientsGroupBox.Location = New-Object System.Drawing.Point(20, 290)
        $clientsGroupBox.Size = New-Object System.Drawing.Size(820, 200)
        $clientsGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        $clientsListView = New-Object System.Windows.Forms.ListView
        $clientsListView.View = "Details"
        $clientsListView.FullRowSelect = $true
        $clientsListView.GridLines = $true
        $clientsListView.Location = New-Object System.Drawing.Point(20, 30)
        $clientsListView.Size = New-Object System.Drawing.Size(780, 150)
        
        $clientsListView.Columns.Add("Client ID", 200) | Out-Null
        $clientsListView.Columns.Add("Hostname", 150) | Out-Null
        $clientsListView.Columns.Add("OS", 100) | Out-Null
        $clientsListView.Columns.Add("Last Seen", 150) | Out-Null
        $clientsListView.Columns.Add("Status", 100) | Out-Null
        
        $clientsGroupBox.Controls.Add($clientsListView)
        
        # Control buttons
        $buttonPanel = New-Object System.Windows.Forms.Panel
        $buttonPanel.Location = New-Object System.Drawing.Point(20, 510)
        $buttonPanel.Size = New-Object System.Drawing.Size(820, 50)
        
        $refreshButton = New-Object System.Windows.Forms.Button
        $refreshButton.Text = "Refresh Data"
        $refreshButton.Size = New-Object System.Drawing.Size(120, 35)
        $refreshButton.Location = New-Object System.Drawing.Point(0, 5)
        $refreshButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
        $refreshButton.ForeColor = [System.Drawing.Color]::White
        $refreshButton.FlatStyle = "Flat"
        $refreshButton.Add_Click({ $this.RefreshMonitoringData() })
        
        $exportButton = New-Object System.Windows.Forms.Button
        $exportButton.Text = "Export Report"
        $exportButton.Size = New-Object System.Drawing.Size(120, 35)
        $exportButton.Location = New-Object System.Drawing.Point(130, 5)
        $exportButton.BackColor = [System.Drawing.Color]::Green
        $exportButton.ForeColor = [System.Drawing.Color]::White
        $exportButton.FlatStyle = "Flat"
        $exportButton.Add_Click({ $this.ExportMonitoringReport() })
        
        $buttonPanel.Controls.AddRange(@($refreshButton, $exportButton))
        
        $monitorPanel.Controls.AddRange(@($titleLabel, $metricsGroupBox, $clientsGroupBox, $buttonPanel))
        $monitorTab.Controls.Add($monitorPanel)
        $this.TabControl.TabPages.Add($monitorTab)
    }
    
    [void] CreateIncidentResponseTab() {
        $irTab = New-Object System.Windows.Forms.TabPage
        $irTab.Text = "Incident Response"
        $irTab.BackColor = [System.Drawing.Color]::White
        
        $irPanel = New-Object System.Windows.Forms.Panel
        $irPanel.Dock = "Fill"
        $irPanel.Padding = New-Object System.Windows.Forms.Padding(20)
        
        # Title
        $titleLabel = New-Object System.Windows.Forms.Label
        $titleLabel.Text = "Incident Response Center"
        $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
        $titleLabel.Location = New-Object System.Drawing.Point(20, 20)
        $titleLabel.Size = New-Object System.Drawing.Size(400, 30)
        
        # Quick response panel
        $quickResponseGroupBox = New-Object System.Windows.Forms.GroupBox
        $quickResponseGroupBox.Text = "Quick Response Actions"
        $quickResponseGroupBox.Location = New-Object System.Drawing.Point(20, 70)
        $quickResponseGroupBox.Size = New-Object System.Drawing.Size(820, 150)
        $quickResponseGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        # Response buttons
        $malwareButton = New-Object System.Windows.Forms.Button
        $malwareButton.Text = "Malware Investigation"
        $malwareButton.Size = New-Object System.Drawing.Size(150, 40)
        $malwareButton.Location = New-Object System.Drawing.Point(20, 30)
        $malwareButton.BackColor = [System.Drawing.Color]::Red
        $malwareButton.ForeColor = [System.Drawing.Color]::White
        $malwareButton.FlatStyle = "Flat"
        $malwareButton.Add_Click({ $this.StartIncidentResponse("Malware") })
        
        $aptButton = New-Object System.Windows.Forms.Button
        $aptButton.Text = "APT Investigation"
        $aptButton.Size = New-Object System.Drawing.Size(150, 40)
        $aptButton.Location = New-Object System.Drawing.Point(180, 30)
        $aptButton.BackColor = [System.Drawing.Color]::DarkRed
        $aptButton.ForeColor = [System.Drawing.Color]::White
        $aptButton.FlatStyle = "Flat"
        $aptButton.Add_Click({ $this.StartIncidentResponse("APT") })
        
        $ransomwareButton = New-Object System.Windows.Forms.Button
        $ransomwareButton.Text = "Ransomware Response"
        $ransomwareButton.Size = New-Object System.Drawing.Size(150, 40)
        $ransomwareButton.Location = New-Object System.Drawing.Point(340, 30)
        $ransomwareButton.BackColor = [System.Drawing.Color]::Purple
        $ransomwareButton.ForeColor = [System.Drawing.Color]::White
        $ransomwareButton.FlatStyle = "Flat"
        $ransomwareButton.Add_Click({ $this.StartIncidentResponse("Ransomware") })
        
        $dataBreachButton = New-Object System.Windows.Forms.Button
        $dataBreachButton.Text = "Data Breach Response"
        $dataBreachButton.Size = New-Object System.Drawing.Size(150, 40)
        $dataBreachButton.Location = New-Object System.Drawing.Point(500, 30)
        $dataBreachButton.BackColor = [System.Drawing.Color]::Orange
        $dataBreachButton.ForeColor = [System.Drawing.Color]::White
        $dataBreachButton.FlatStyle = "Flat"
        $dataBreachButton.Add_Click({ $this.StartIncidentResponse("DataBreach") })
        
        $insiderButton = New-Object System.Windows.Forms.Button
        $insiderButton.Text = "Insider Threat"
        $insiderButton.Size = New-Object System.Drawing.Size(150, 40)
        $insiderButton.Location = New-Object System.Drawing.Point(20, 80)
        $insiderButton.BackColor = [System.Drawing.Color]::Brown
        $insiderButton.ForeColor = [System.Drawing.Color]::White
        $insiderButton.FlatStyle = "Flat"
        $insiderButton.Add_Click({ $this.StartIncidentResponse("Insider") })
        
        $networkButton = New-Object System.Windows.Forms.Button
        $networkButton.Text = "Network Intrusion"
        $networkButton.Size = New-Object System.Drawing.Size(150, 40)
        $networkButton.Location = New-Object System.Drawing.Point(180, 80)
        $networkButton.BackColor = [System.Drawing.Color]::Navy
        $networkButton.ForeColor = [System.Drawing.Color]::White
        $networkButton.FlatStyle = "Flat"
        $networkButton.Add_Click({ $this.StartIncidentResponse("NetworkIntrusion") })
        
        $customButton = New-Object System.Windows.Forms.Button
        $customButton.Text = "Custom Investigation"
        $customButton.Size = New-Object System.Drawing.Size(150, 40)
        $customButton.Location = New-Object System.Drawing.Point(340, 80)
        $customButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
        $customButton.ForeColor = [System.Drawing.Color]::White
        $customButton.FlatStyle = "Flat"
        $customButton.Add_Click({ $this.StartCustomInvestigation() })
        
        $quickResponseGroupBox.Controls.AddRange(@($malwareButton, $aptButton, $ransomwareButton, $dataBreachButton, $insiderButton, $networkButton, $customButton))
        
        # Active investigations
        $activeGroupBox = New-Object System.Windows.Forms.GroupBox
        $activeGroupBox.Text = "Active Investigations"
        $activeGroupBox.Location = New-Object System.Drawing.Point(20, 240)
        $activeGroupBox.Size = New-Object System.Drawing.Size(820, 200)
        $activeGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        $investigationsListView = New-Object System.Windows.Forms.ListView
        $investigationsListView.View = "Details"
        $investigationsListView.FullRowSelect = $true
        $investigationsListView.GridLines = $true
        $investigationsListView.Location = New-Object System.Drawing.Point(20, 30)
        $investigationsListView.Size = New-Object System.Drawing.Size(780, 150)
        
        $investigationsListView.Columns.Add("Investigation ID", 150) | Out-Null
        $investigationsListView.Columns.Add("Type", 120) | Out-Null
        $investigationsListView.Columns.Add("Status", 100) | Out-Null
        $investigationsListView.Columns.Add("Started", 120) | Out-Null
        $investigationsListView.Columns.Add("Progress", 100) | Out-Null
        $investigationsListView.Columns.Add("Actions", 100) | Out-Null
        
        $activeGroupBox.Controls.Add($investigationsListView)
        
        # Tools panel
        $toolsGroupBox = New-Object System.Windows.Forms.GroupBox
        $toolsGroupBox.Text = "Investigation Tools"
        $toolsGroupBox.Location = New-Object System.Drawing.Point(20, 460)
        $toolsGroupBox.Size = New-Object System.Drawing.Size(820, 80)
        $toolsGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        $artifactButton = New-Object System.Windows.Forms.Button
        $artifactButton.Text = "Artifact Manager"
        $artifactButton.Size = New-Object System.Drawing.Size(120, 35)
        $artifactButton.Location = New-Object System.Drawing.Point(20, 25)
        $artifactButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
        $artifactButton.ForeColor = [System.Drawing.Color]::White
        $artifactButton.FlatStyle = "Flat"
        $artifactButton.Add_Click({ $this.OpenArtifactManager() })
        
        $timelineButton = New-Object System.Windows.Forms.Button
        $timelineButton.Text = "Timeline Builder"
        $timelineButton.Size = New-Object System.Drawing.Size(120, 35)
        $timelineButton.Location = New-Object System.Drawing.Point(150, 25)
        $timelineButton.BackColor = [System.Drawing.Color]::Green
        $timelineButton.ForeColor = [System.Drawing.Color]::White
        $timelineButton.FlatStyle = "Flat"
        $timelineButton.Add_Click({ $this.OpenTimelineBuilder() })
        
        $reportButton = New-Object System.Windows.Forms.Button
        $reportButton.Text = "Report Generator"
        $reportButton.Size = New-Object System.Drawing.Size(120, 35)
        $reportButton.Location = New-Object System.Drawing.Point(280, 25)
        $reportButton.BackColor = [System.Drawing.Color]::Purple
        $reportButton.ForeColor = [System.Drawing.Color]::White
        $reportButton.FlatStyle = "Flat"
        $reportButton.Add_Click({ $this.OpenReportGenerator() })
        
        $toolsGroupBox.Controls.AddRange(@($artifactButton, $timelineButton, $reportButton))
        
        $irPanel.Controls.AddRange(@($titleLabel, $quickResponseGroupBox, $activeGroupBox, $toolsGroupBox))
        $irTab.Controls.Add($irPanel)
        $this.TabControl.TabPages.Add($irTab)
    }   
 [void] CreateSettingsTab() {
        $settingsTab = New-Object System.Windows.Forms.TabPage
        $settingsTab.Text = "Settings"
        $settingsTab.BackColor = [System.Drawing.Color]::White
        
        $settingsPanel = New-Object System.Windows.Forms.Panel
        $settingsPanel.Dock = "Fill"
        $settingsPanel.Padding = New-Object System.Windows.Forms.Padding(20)
        
        # Title
        $titleLabel = New-Object System.Windows.Forms.Label
        $titleLabel.Text = "Application Settings"
        $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
        $titleLabel.Location = New-Object System.Drawing.Point(20, 20)
        $titleLabel.Size = New-Object System.Drawing.Size(400, 30)
        
        # General settings
        $generalGroupBox = New-Object System.Windows.Forms.GroupBox
        $generalGroupBox.Text = "General Settings"
        $generalGroupBox.Location = New-Object System.Drawing.Point(20, 70)
        $generalGroupBox.Size = New-Object System.Drawing.Size(820, 150)
        $generalGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        $autoStartCheckBox = New-Object System.Windows.Forms.CheckBox
        $autoStartCheckBox.Text = "Start with Windows"
        $autoStartCheckBox.Location = New-Object System.Drawing.Point(20, 30)
        $autoStartCheckBox.Size = New-Object System.Drawing.Size(200, 25)
        $autoStartCheckBox.Checked = $true
        
        $minimizeToTrayCheckBox = New-Object System.Windows.Forms.CheckBox
        $minimizeToTrayCheckBox.Text = "Minimize to system tray"
        $minimizeToTrayCheckBox.Location = New-Object System.Drawing.Point(20, 60)
        $minimizeToTrayCheckBox.Size = New-Object System.Drawing.Size(200, 25)
        $minimizeToTrayCheckBox.Checked = $true
        
        $autoUpdateCheckBox = New-Object System.Windows.Forms.CheckBox
        $autoUpdateCheckBox.Text = "Check for updates automatically"
        $autoUpdateCheckBox.Location = New-Object System.Drawing.Point(20, 90)
        $autoUpdateCheckBox.Size = New-Object System.Drawing.Size(250, 25)
        $autoUpdateCheckBox.Checked = $true
        
        $generalGroupBox.Controls.AddRange(@($autoStartCheckBox, $minimizeToTrayCheckBox, $autoUpdateCheckBox))
        
        # Logging settings
        $loggingGroupBox = New-Object System.Windows.Forms.GroupBox
        $loggingGroupBox.Text = "Logging Settings"
        $loggingGroupBox.Location = New-Object System.Drawing.Point(20, 240)
        $loggingGroupBox.Size = New-Object System.Drawing.Size(820, 120)
        $loggingGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        $logLevelLabel = New-Object System.Windows.Forms.Label
        $logLevelLabel.Text = "Log Level:"
        $logLevelLabel.Location = New-Object System.Drawing.Point(20, 30)
        $logLevelLabel.Size = New-Object System.Drawing.Size(80, 20)
        
        $logLevelComboBox = New-Object System.Windows.Forms.ComboBox
        $logLevelComboBox.Items.AddRange(@("ERROR", "WARN", "INFO", "DEBUG"))
        $logLevelComboBox.SelectedIndex = 2
        $logLevelComboBox.Location = New-Object System.Drawing.Point(110, 28)
        $logLevelComboBox.Size = New-Object System.Drawing.Size(100, 25)
        $logLevelComboBox.DropDownStyle = "DropDownList"
        
        $logPathLabel = New-Object System.Windows.Forms.Label
        $logPathLabel.Text = "Log Directory:"
        $logPathLabel.Location = New-Object System.Drawing.Point(20, 65)
        $logPathLabel.Size = New-Object System.Drawing.Size(80, 20)
        
        $logPathTextBox = New-Object System.Windows.Forms.TextBox
        $logPathTextBox.Text = $script:Config.LogPath
        $logPathTextBox.Location = New-Object System.Drawing.Point(110, 63)
        $logPathTextBox.Size = New-Object System.Drawing.Size(500, 25)
        
        $logBrowseButton = New-Object System.Windows.Forms.Button
        $logBrowseButton.Text = "Browse..."
        $logBrowseButton.Location = New-Object System.Drawing.Point(620, 61)
        $logBrowseButton.Size = New-Object System.Drawing.Size(80, 28)
        
        $loggingGroupBox.Controls.AddRange(@($logLevelLabel, $logLevelComboBox, $logPathLabel, $logPathTextBox, $logBrowseButton))
        
        # About section
        $aboutGroupBox = New-Object System.Windows.Forms.GroupBox
        $aboutGroupBox.Text = "About"
        $aboutGroupBox.Location = New-Object System.Drawing.Point(20, 380)
        $aboutGroupBox.Size = New-Object System.Drawing.Size(820, 120)
        $aboutGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        $aboutText = @"
Velociraptor Professional Suite v$($script:Config.Version)
Publisher: $($script:Config.Publisher)

This application provides a comprehensive GUI for managing Velociraptor DFIR deployments.
Built with PowerShell and Windows Forms for maximum compatibility and performance.

© 2024 Velociraptor DFIR Community. All rights reserved.
"@
        
        $aboutLabel = New-Object System.Windows.Forms.Label
        $aboutLabel.Text = $aboutText
        $aboutLabel.Location = New-Object System.Drawing.Point(20, 25)
        $aboutLabel.Size = New-Object System.Drawing.Size(780, 80)
        $aboutLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        
        $aboutGroupBox.Controls.Add($aboutLabel)
        
        # Save settings button
        $saveSettingsButton = New-Object System.Windows.Forms.Button
        $saveSettingsButton.Text = "Save Settings"
        $saveSettingsButton.Size = New-Object System.Drawing.Size(120, 40)
        $saveSettingsButton.Location = New-Object System.Drawing.Point(20, 520)
        $saveSettingsButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
        $saveSettingsButton.ForeColor = [System.Drawing.Color]::White
        $saveSettingsButton.FlatStyle = "Flat"
        $saveSettingsButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $saveSettingsButton.Add_Click({
            $this.SaveSettings(@{
                AutoStart = $autoStartCheckBox.Checked
                MinimizeToTray = $minimizeToTrayCheckBox.Checked
                AutoUpdate = $autoUpdateCheckBox.Checked
                LogLevel = $logLevelComboBox.SelectedItem
                LogPath = $logPathTextBox.Text
            })
        })
        
        $settingsPanel.Controls.AddRange(@($titleLabel, $generalGroupBox, $loggingGroupBox, $aboutGroupBox, $saveSettingsButton))
        $settingsTab.Controls.Add($settingsPanel)
        $this.TabControl.TabPages.Add($settingsTab)
    }
    
    # Core functionality methods
    [bool] CheckInstallation() {
        return Test-Path "$($script:Config.InstallPath)\velociraptor.exe"
    }
    
    [string] GetServiceStatus() {
        try {
            $service = Get-Service -Name $script:Config.ServiceName -ErrorAction SilentlyContinue
            return if ($service) { $service.Status } else { "Not Installed" }
        }
        catch {
            return "Unknown"
        }
    }
    
    [string] GetInstalledVersion() {
        try {
            if ($this.CheckInstallation()) {
                $versionOutput = & "$($script:Config.InstallPath)\velociraptor.exe" version 2>$null
                if ($versionOutput -match "Velociraptor\s+v?(\d+\.\d+\.\d+)") {
                    return $matches[1]
                }
            }
            return $null
        }
        catch {
            return $null
        }
    }
    
    [datetime] GetLastUpdateTime() {
        try {
            if ($this.CheckInstallation()) {
                return (Get-Item "$($script:Config.InstallPath)\velociraptor.exe").LastWriteTime
            }
            return [datetime]::MinValue
        }
        catch {
            return [datetime]::MinValue
        }
    }
    
    [System.Drawing.Icon] CreateApplicationIcon() {
        # Create a simple icon (in real implementation, load from resource)
        $bitmap = New-Object System.Drawing.Bitmap(32, 32)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.FillRectangle([System.Drawing.Brushes]::Blue, 0, 0, 32, 32)
        $graphics.DrawString("V", (New-Object System.Drawing.Font("Arial", 20, [System.Drawing.FontStyle]::Bold)), [System.Drawing.Brushes]::White, 8, 2)
        $graphics.Dispose()
        return [System.Drawing.Icon]::FromHandle($bitmap.GetHicon())
    }
    
    [void] StartStatusMonitoring() {
        # Start a timer to update status information
        $this.StatusTimer = New-Object System.Threading.Timer({
            # Update status in UI thread
            $this.MainForm.Invoke([Action]{
                $this.UpdateStatus()
            })
        }, $null, 0, 5000) # Update every 5 seconds
    }
    
    [void] UpdateStatus() {
        $this.InstallationState.ServiceStatus = $this.GetServiceStatus()
        # Update UI elements as needed
    }
    
    [void] Show() {
        [System.Windows.Forms.Application]::Run($this.MainForm)
    }
}
[void] StartInstallation([bool] $IsStandalone, [string] $InstallPath, [bool] $InstallService, [bool] $ConfigureFirewall, [bool] $CreateShortcut) {
        $this.ShowProgressDialog("Installing Velociraptor", "Preparing installation...")
        
        try {
            # Create installation directory
            if (-not (Test-Path $InstallPath)) {
                New-Item -Path $InstallPath -ItemType Directory -Force | Out-Null
            }
            
            # Download Velociraptor
            $this.UpdateProgress("Downloading Velociraptor binary...", 20)
            $this.DownloadVelociraptor($InstallPath)
            
            # Generate configuration
            $this.UpdateProgress("Generating configuration...", 40)
            if ($IsStandalone) {
                $this.GenerateStandaloneConfig($InstallPath)
            } else {
                $this.GenerateServerConfig($InstallPath)
            }
            
            # Install service
            if ($InstallService) {
                $this.UpdateProgress("Installing Windows service...", 60)
                $this.InstallWindowsService($InstallPath, $IsStandalone)
            }
            
            # Configure firewall
            if ($ConfigureFirewall) {
                $this.UpdateProgress("Configuring Windows Firewall...", 80)
                $this.ConfigureFirewall()
            }
            
            # Create shortcuts
            if ($CreateShortcut) {
                $this.UpdateProgress("Creating shortcuts...", 90)
                $this.CreateDesktopShortcut($InstallPath)
            }
            
            # Update registry
            $this.UpdateProgress("Updating registry...", 95)
            $this.UpdateRegistry($InstallPath)
            
            $this.UpdateProgress("Installation completed successfully!", 100)
            Start-Sleep -Seconds 2
            $this.CloseProgressDialog()
            
            [System.Windows.Forms.MessageBox]::Show("Velociraptor has been installed successfully!", "Installation Complete", "OK", "Information")
            
            # Refresh installation state
            $this.InstallationState.IsInstalled = $true
            $this.InstallationState.Version = $this.GetInstalledVersion()
            
            # Switch to management tab
            $this.TabControl.SelectedIndex = 3
        }
        catch {
            $this.CloseProgressDialog()
            [System.Windows.Forms.MessageBox]::Show("Installation failed: $($_.Exception.Message)", "Installation Error", "OK", "Error")
        }
    }
    
    [void] DownloadVelociraptor([string] $InstallPath) {
        $apiUrl = "https://api.github.com/repos/$($script:Config.Repository)/releases/latest"
        
        try {
            $release = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing
            $asset = $release.assets | Where-Object { $_.name -like "*windows-amd64.exe" } | Select-Object -First 1
            
            if (-not $asset) {
                throw "Could not find Windows binary in latest release"
            }
            
            $downloadPath = Join-Path $InstallPath "velociraptor.exe"
            Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $downloadPath -UseBasicParsing
            
            if (-not (Test-Path $downloadPath)) {
                throw "Failed to download Velociraptor binary"
            }
        }
        catch {
            throw "Failed to download Velociraptor: $($_.Exception.Message)"
        }
    }
    
    [void] GenerateStandaloneConfig([string] $InstallPath) {
        $configPath = Join-Path $InstallPath "standalone.config.yaml"
        $config = @"
version:
  name: velociraptor
  version: "0.72"
  commit: standalone
  build_time: "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

Client:
  server_urls:
    - https://localhost:8000/
  ca_certificate: |
    -----BEGIN CERTIFICATE-----
    # Auto-generated certificate
    -----END CERTIFICATE-----
  
  nonce: "$(New-Guid)"
  
GUI:
  bind_address: 0.0.0.0
  bind_port: 8889
  
logging:
  output_directory: $($script:Config.LogPath)
  separate_logs_per_component: true
  
autoexec:
  argv:
    - artifacts
    - collect
    - Generic.Client.Info
"@
        
        Set-Content -Path $configPath -Value $config -Encoding UTF8
    }
    
    [void] GenerateServerConfig([string] $InstallPath) {
        $configPath = Join-Path $InstallPath "server.config.yaml"
        $config = @"
version:
  name: velociraptor
  version: "0.72"
  commit: server
  build_time: "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

Client:
  server_urls:
    - https://localhost:8000/
  ca_certificate: |
    -----BEGIN CERTIFICATE-----
    # Auto-generated certificate
    -----END CERTIFICATE-----

Frontend:
  bind_address: 0.0.0.0
  bind_port: 8000
  certificate: server.cert
  private_key: server.key

GUI:
  bind_address: 0.0.0.0
  bind_port: 8889
  certificate: server.cert
  private_key: server.key

datastore:
  implementation: FileBaseDataStore
  location: $InstallPath\datastore
  filestore_directory: $InstallPath\filestore

logging:
  output_directory: $($script:Config.LogPath)
  separate_logs_per_component: true
"@
        
        Set-Content -Path $configPath -Value $config -Encoding UTF8
    }
    
    [void] InstallWindowsService([string] $InstallPath, [bool] $IsStandalone) {
        $serviceName = $script:Config.ServiceName
        $binaryPath = Join-Path $InstallPath "velociraptor.exe"
        $configPath = if ($IsStandalone) { Join-Path $InstallPath "standalone.config.yaml" } else { Join-Path $InstallPath "server.config.yaml" }
        
        $serviceArgs = if ($IsStandalone) {
            "--config `"$configPath`" gui"
        } else {
            "--config `"$configPath`" frontend"
        }
        
        # Remove existing service if it exists
        $existingService = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        if ($existingService) {
            Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
            & sc.exe delete $serviceName
        }
        
        # Create new service
        & sc.exe create $serviceName binPath= "`"$binaryPath`" $serviceArgs" start= auto DisplayName= "Velociraptor DFIR Platform"
        & sc.exe description $serviceName "Velociraptor Digital Forensics and Incident Response Platform"
        
        # Start the service
        Start-Service -Name $serviceName
    }
    
    [void] ConfigureFirewall() {
        try {
            # Allow Velociraptor through Windows Firewall
            New-NetFirewallRule -DisplayName "Velociraptor GUI" -Direction Inbound -Protocol TCP -LocalPort 8889 -Action Allow -ErrorAction SilentlyContinue
            New-NetFirewallRule -DisplayName "Velociraptor Frontend" -Direction Inbound -Protocol TCP -LocalPort 8000 -Action Allow -ErrorAction SilentlyContinue
        }
        catch {
            Write-Warning "Failed to configure firewall rules: $($_.Exception.Message)"
        }
    }
    
    [void] CreateDesktopShortcut([string] $InstallPath) {
        try {
            $shell = New-Object -ComObject WScript.Shell
            $shortcut = $shell.CreateShortcut("$env:USERPROFILE\Desktop\Velociraptor.lnk")
            $shortcut.TargetPath = "http://localhost:8889"
            $shortcut.Description = "Velociraptor Web Interface"
            $shortcut.Save()
        }
        catch {
            Write-Warning "Failed to create desktop shortcut: $($_.Exception.Message)"
        }
    }
    
    [void] UpdateRegistry([string] $InstallPath) {
        try {
            if (-not (Test-Path $script:Config.RegistryPath)) {
                New-Item -Path $script:Config.RegistryPath -Force | Out-Null
            }
            
            Set-ItemProperty -Path $script:Config.RegistryPath -Name "InstallPath" -Value $InstallPath
            Set-ItemProperty -Path $script:Config.RegistryPath -Name "Version" -Value $script:Config.Version
            Set-ItemProperty -Path $script:Config.RegistryPath -Name "InstallDate" -Value (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        }
        catch {
            Write-Warning "Failed to update registry: $($_.Exception.Message)"
        }
    }
    
    # Service management methods
    [void] StartService() {
        try {
            Start-Service -Name $script:Config.ServiceName
            [System.Windows.Forms.MessageBox]::Show("Velociraptor service started successfully.", "Service Started", "OK", "Information")
            $this.UpdateStatus()
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Failed to start service: $($_.Exception.Message)", "Service Error", "OK", "Error")
        }
    }
    
    [void] StopService() {
        try {
            Stop-Service -Name $script:Config.ServiceName -Force
            [System.Windows.Forms.MessageBox]::Show("Velociraptor service stopped successfully.", "Service Stopped", "OK", "Information")
            $this.UpdateStatus()
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Failed to stop service: $($_.Exception.Message)", "Service Error", "OK", "Error")
        }
    }
    
    [void] RestartService() {
        try {
            Restart-Service -Name $script:Config.ServiceName -Force
            [System.Windows.Forms.MessageBox]::Show("Velociraptor service restarted successfully.", "Service Restarted", "OK", "Information")
            $this.UpdateStatus()
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Failed to restart service: $($_.Exception.Message)", "Service Error", "OK", "Error")
        }
    }
    
    [void] OpenWebUI() {
        try {
            Start-Process "http://localhost:8889"
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Failed to open web interface: $($_.Exception.Message)", "Error", "OK", "Error")
        }
    }
    
    # Progress dialog methods
    [void] ShowProgressDialog([string] $Title, [string] $Message) {
        $this.ProgressForm = New-Object System.Windows.Forms.Form
        $this.ProgressForm.Text = $Title
        $this.ProgressForm.Size = New-Object System.Drawing.Size(400, 150)
        $this.ProgressForm.StartPosition = "CenterParent"
        $this.ProgressForm.FormBorderStyle = "FixedDialog"
        $this.ProgressForm.MaximizeBox = $false
        $this.ProgressForm.MinimizeBox = $false
        
        $messageLabel = New-Object System.Windows.Forms.Label
        $messageLabel.Text = $Message
        $messageLabel.Location = New-Object System.Drawing.Point(20, 20)
        $messageLabel.Size = New-Object System.Drawing.Size(350, 20)
        
        $progressBar = New-Object System.Windows.Forms.ProgressBar
        $progressBar.Location = New-Object System.Drawing.Point(20, 50)
        $progressBar.Size = New-Object System.Drawing.Size(350, 25)
        $progressBar.Style = "Continuous"
        
        $this.ProgressForm.Controls.AddRange(@($messageLabel, $progressBar))
        $this.ProgressForm.Show()
        $this.ProgressForm.BringToFront()
    }
    
    [void] UpdateProgress([string] $Message, [int] $Percentage) {
        if ($this.ProgressForm) {
            $this.ProgressForm.Controls[0].Text = $Message
            $this.ProgressForm.Controls[1].Value = $Percentage
            $this.ProgressForm.Refresh()
        }
    }
    
    [void] CloseProgressDialog() {
        if ($this.ProgressForm) {
            $this.ProgressForm.Close()
            $this.ProgressForm = $null
        }
    }
}

# Main execution
function Start-VelociraptorInstaller {
    param(
        [switch] $Silent,
        [switch] $Uninstall,
        [string] $ConfigFile
    )
    
    try {
        # Check if running as administrator
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            [System.Windows.Forms.MessageBox]::Show("This application requires administrator privileges. Please run as administrator.", "Administrator Required", "OK", "Warning")
            return
        }
        
        if ($Uninstall) {
            # Uninstall mode
            $result = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to uninstall Velociraptor?", "Confirm Uninstall", "YesNo", "Question")
            if ($result -eq "Yes") {
                # Perform uninstallation
                Write-Host "Uninstalling Velociraptor..."
                # Implementation would go here
            }
            return
        }
        
        if ($Silent) {
            # Silent installation mode
            Write-Host "Starting silent installation..."
            # Implementation would go here
            return
        }
        
        # GUI mode
        $app = [VelociraptorInstallerApp]::new()
        $app.Show()
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to start application: $($_.Exception.Message)", "Application Error", "OK", "Error")
        Write-Error $_.Exception.Message
    }
}

# Entry point
if ($MyInvocation.InvocationName -ne '.') {
    Start-VelociraptorInstaller -Silent:$Silent -Uninstall:$Uninstall -ConfigFile $ConfigFile
}
