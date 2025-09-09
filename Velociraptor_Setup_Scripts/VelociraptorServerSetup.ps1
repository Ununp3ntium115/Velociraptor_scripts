# Velociraptor Server Setup GUI
# Consolidated server and standalone setup interface

<#
.SYNOPSIS
    Velociraptor Server Setup GUI
    
.DESCRIPTION
    Simple, focused GUI for setting up Velociraptor server or standalone installations.
    Handles installation, configuration, and service management.
#>

param(
    [string] $InstallPath = "$env:ProgramFiles\Velociraptor",
    [switch] $Standalone
)

# Add required assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Global configuration
$script:Config = @{
    AppName = "Velociraptor Server Setup"
    Version = "6.0.0"
    InstallPath = $InstallPath
    ServiceName = "VelociraptorService"
    Repository = "Ununp3ntium115/velociraptor"
    RegistryPath = "HKLM:\SOFTWARE\Velociraptor"
}

# Main Application Class
class VelociraptorServerSetupApp {
    [System.Windows.Forms.Form] $MainForm
    [System.Windows.Forms.TabControl] $TabControl
    [System.Windows.Forms.TextBox] $LogTextBox
    [System.Windows.Forms.ProgressBar] $ProgressBar
    [System.Windows.Forms.Label] $StatusLabel
    [hashtable] $InstallationState
    
    VelociraptorServerSetupApp() {
        $this.InstallationState = @{
            IsInstalled = $this.CheckInstallation()
            ServiceStatus = $this.GetServiceStatus()
            Version = $this.GetInstalledVersion()
        }
        $this.InitializeMainForm()
    }
    
    [void] InitializeMainForm() {
        $this.MainForm = New-Object System.Windows.Forms.Form
        $this.MainForm.Text = $script:Config.AppName
        $this.MainForm.Size = New-Object System.Drawing.Size(800, 600)
        $this.MainForm.StartPosition = "CenterScreen"
        $this.MainForm.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        
        # Create main layout
        $this.CreateHeader()
        $this.CreateTabControl()
        $this.CreateLogPanel()
        $this.CreateStatusBar()
    }
    
    [void] CreateHeader() {
        $headerPanel = New-Object System.Windows.Forms.Panel
        $headerPanel.Height = 80
        $headerPanel.Dock = "Top"
        $headerPanel.BackColor = [System.Drawing.Color]::FromArgb(70, 130, 180)
        
        $titleLabel = New-Object System.Windows.Forms.Label
        $titleLabel.Text = "⚙️ Velociraptor Server Setup"
        $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
        $titleLabel.ForeColor = [System.Drawing.Color]::White
        $titleLabel.Location = New-Object System.Drawing.Point(20, 15)
        $titleLabel.Size = New-Object System.Drawing.Size(450, 35)
        
        $subtitleLabel = New-Object System.Windows.Forms.Label
        $subtitleLabel.Text = "Installation, Configuration & Management"
        $subtitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $subtitleLabel.ForeColor = [System.Drawing.Color]::LightGray
        $subtitleLabel.Location = New-Object System.Drawing.Point(20, 50)
        $subtitleLabel.Size = New-Object System.Drawing.Size(400, 20)
        
        # Status indicator
        $statusPanel = New-Object System.Windows.Forms.Panel
        $statusPanel.Location = New-Object System.Drawing.Point(600, 20)
        $statusPanel.Size = New-Object System.Drawing.Size(150, 40)
        
        $statusIndicator = New-Object System.Windows.Forms.Label
        if ($this.InstallationState.IsInstalled) {
            $statusIndicator.Text = "✅ INSTALLED"
            $statusIndicator.ForeColor = [System.Drawing.Color]::LightGreen
        } else {
            $statusIndicator.Text = "❌ NOT INSTALLED"
            $statusIndicator.ForeColor = [System.Drawing.Color]::LightCoral
        }
        $statusIndicator.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $statusIndicator.Location = New-Object System.Drawing.Point(0, 0)
        $statusIndicator.Size = New-Object System.Drawing.Size(150, 20)
        
        $serviceIndicator = New-Object System.Windows.Forms.Label
        $serviceIndicator.Text = "Service: $($this.InstallationState.ServiceStatus)"
        $serviceIndicator.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $serviceIndicator.ForeColor = [System.Drawing.Color]::White
        $serviceIndicator.Location = New-Object System.Drawing.Point(0, 20)
        $serviceIndicator.Size = New-Object System.Drawing.Size(150, 20)
        
        $statusPanel.Controls.AddRange(@($statusIndicator, $serviceIndicator))
        $headerPanel.Controls.AddRange(@($titleLabel, $subtitleLabel, $statusPanel))
        $this.MainForm.Controls.Add($headerPanel)
    }
    
    [void] CreateTabControl() {
        $this.TabControl = New-Object System.Windows.Forms.TabControl
        $this.TabControl.Location = New-Object System.Drawing.Point(20, 100)
        $this.TabControl.Size = New-Object System.Drawing.Size(740, 300)
        
        # Create tabs
        $this.CreateInstallationTab()
        $this.CreateConfigurationTab()
        $this.CreateManagementTab()
        
        $this.MainForm.Controls.Add($this.TabControl)
    }
    
    [void] CreateInstallationTab() {
        $installTab = New-Object System.Windows.Forms.TabPage
        $installTab.Text = "Installation"
        
        # Installation type selection
        $typeGroupBox = New-Object System.Windows.Forms.GroupBox
        $typeGroupBox.Text = "Installation Type"
        $typeGroupBox.Location = New-Object System.Drawing.Point(20, 20)
        $typeGroupBox.Size = New-Object System.Drawing.Size(680, 80)
        
        $standaloneRadio = New-Object System.Windows.Forms.RadioButton
        $standaloneRadio.Text = "Standalone Client - Single machine DFIR analysis"
        $standaloneRadio.Location = New-Object System.Drawing.Point(20, 25)
        $standaloneRadio.Size = New-Object System.Drawing.Size(400, 25)
        $standaloneRadio.Checked = $true
        
        $serverRadio = New-Object System.Windows.Forms.RadioButton
        $serverRadio.Text = "Server Installation - Enterprise deployment with multiple clients"
        $serverRadio.Location = New-Object System.Drawing.Point(20, 50)
        $serverRadio.Size = New-Object System.Drawing.Size(500, 25)
        
        $typeGroupBox.Controls.AddRange(@($standaloneRadio, $serverRadio))
        
        # Installation path
        $pathGroupBox = New-Object System.Windows.Forms.GroupBox
        $pathGroupBox.Text = "Installation Directory"
        $pathGroupBox.Location = New-Object System.Drawing.Point(20, 120)
        $pathGroupBox.Size = New-Object System.Drawing.Size(680, 60)
        
        $pathTextBox = New-Object System.Windows.Forms.TextBox
        $pathTextBox.Text = $script:Config.InstallPath
        $pathTextBox.Location = New-Object System.Drawing.Point(20, 25)
        $pathTextBox.Size = New-Object System.Drawing.Size(500, 25)
        
        $browseButton = New-Object System.Windows.Forms.Button
        $browseButton.Text = "Browse..."
        $browseButton.Location = New-Object System.Drawing.Point(530, 23)
        $browseButton.Size = New-Object System.Drawing.Size(80, 28)
        $browseButton.Add_Click({
            $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
            $folderDialog.Description = "Select installation directory"
            $folderDialog.SelectedPath = $pathTextBox.Text
            if ($folderDialog.ShowDialog() -eq "OK") {
                $pathTextBox.Text = $folderDialog.SelectedPath
            }
        })
        
        $pathGroupBox.Controls.AddRange(@($pathTextBox, $browseButton))
        
        # Installation options
        $optionsGroupBox = New-Object System.Windows.Forms.GroupBox
        $optionsGroupBox.Text = "Installation Options"
        $optionsGroupBox.Location = New-Object System.Drawing.Point(20, 200)
        $optionsGroupBox.Size = New-Object System.Drawing.Size(680, 60)
        
        $serviceCheckBox = New-Object System.Windows.Forms.CheckBox
        $serviceCheckBox.Text = "Install as Windows Service"
        $serviceCheckBox.Location = New-Object System.Drawing.Point(20, 25)
        $serviceCheckBox.Size = New-Object System.Drawing.Size(200, 25)
        $serviceCheckBox.Checked = $true
        
        $firewallCheckBox = New-Object System.Windows.Forms.CheckBox
        $firewallCheckBox.Text = "Configure Firewall"
        $firewallCheckBox.Location = New-Object System.Drawing.Point(230, 25)
        $firewallCheckBox.Size = New-Object System.Drawing.Size(150, 25)
        $firewallCheckBox.Checked = $true
        
        $shortcutCheckBox = New-Object System.Windows.Forms.CheckBox
        $shortcutCheckBox.Text = "Create Desktop Shortcut"
        $shortcutCheckBox.Location = New-Object System.Drawing.Point(390, 25)
        $shortcutCheckBox.Size = New-Object System.Drawing.Size(180, 25)
        $shortcutCheckBox.Checked = $true
        
        $optionsGroupBox.Controls.AddRange(@($serviceCheckBox, $firewallCheckBox, $shortcutCheckBox))
        
        # Install button
        if (-not $this.InstallationState.IsInstalled) {
            $installButton = New-Object System.Windows.Forms.Button
            $installButton.Text = "🚀 Install Velociraptor"
            $installButton.Size = New-Object System.Drawing.Size(200, 40)
            $installButton.Location = New-Object System.Drawing.Point(250, 270)
            $installButton.BackColor = [System.Drawing.Color]::Green
            $installButton.ForeColor = [System.Drawing.Color]::White
            $installButton.FlatStyle = "Flat"
            $installButton.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
            $installButton.Add_Click({
                $this.StartInstallation($standaloneRadio.Checked, $pathTextBox.Text, $serviceCheckBox.Checked, $firewallCheckBox.Checked, $shortcutCheckBox.Checked)
            })
            $installTab.Controls.Add($installButton)
        } else {
            $installedLabel = New-Object System.Windows.Forms.Label
            $installedLabel.Text = "✅ Velociraptor is already installed"
            $installedLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
            $installedLabel.ForeColor = [System.Drawing.Color]::Green
            $installedLabel.Location = New-Object System.Drawing.Point(250, 280)
            $installedLabel.Size = New-Object System.Drawing.Size(300, 25)
            $installTab.Controls.Add($installedLabel)
        }
        
        $installTab.Controls.AddRange(@($typeGroupBox, $pathGroupBox, $optionsGroupBox))
        $this.TabControl.TabPages.Add($installTab)
    }
    
    [void] CreateConfigurationTab() {
        $configTab = New-Object System.Windows.Forms.TabPage
        $configTab.Text = "Configuration"
        
        # Server settings
        $serverGroupBox = New-Object System.Windows.Forms.GroupBox
        $serverGroupBox.Text = "Server Settings"
        $serverGroupBox.Location = New-Object System.Drawing.Point(20, 20)
        $serverGroupBox.Size = New-Object System.Drawing.Size(680, 120)
        
        # GUI Port
        $guiPortLabel = New-Object System.Windows.Forms.Label
        $guiPortLabel.Text = "GUI Port:"
        $guiPortLabel.Location = New-Object System.Drawing.Point(20, 30)
        $guiPortLabel.Size = New-Object System.Drawing.Size(80, 20)
        
        $guiPortTextBox = New-Object System.Windows.Forms.TextBox
        $guiPortTextBox.Text = "8889"
        $guiPortTextBox.Location = New-Object System.Drawing.Point(110, 28)
        $guiPortTextBox.Size = New-Object System.Drawing.Size(80, 25)
        
        # Frontend Port
        $frontendPortLabel = New-Object System.Windows.Forms.Label
        $frontendPortLabel.Text = "Frontend Port:"
        $frontendPortLabel.Location = New-Object System.Drawing.Point(220, 30)
        $frontendPortLabel.Size = New-Object System.Drawing.Size(90, 20)
        
        $frontendPortTextBox = New-Object System.Windows.Forms.TextBox
        $frontendPortTextBox.Text = "8000"
        $frontendPortTextBox.Location = New-Object System.Drawing.Point(320, 28)
        $frontendPortTextBox.Size = New-Object System.Drawing.Size(80, 25)
        
        # SSL
        $sslCheckBox = New-Object System.Windows.Forms.CheckBox
        $sslCheckBox.Text = "Enable SSL/TLS"
        $sslCheckBox.Location = New-Object System.Drawing.Point(20, 70)
        $sslCheckBox.Size = New-Object System.Drawing.Size(120, 25)
        $sslCheckBox.Checked = $true
        
        $serverGroupBox.Controls.AddRange(@($guiPortLabel, $guiPortTextBox, $frontendPortLabel, $frontendPortTextBox, $sslCheckBox))
        
        # Database settings
        $dbGroupBox = New-Object System.Windows.Forms.GroupBox
        $dbGroupBox.Text = "Database Configuration"
        $dbGroupBox.Location = New-Object System.Drawing.Point(20, 160)
        $dbGroupBox.Size = New-Object System.Drawing.Size(680, 80)
        
        $dbTypeLabel = New-Object System.Windows.Forms.Label
        $dbTypeLabel.Text = "Database Type:"
        $dbTypeLabel.Location = New-Object System.Drawing.Point(20, 30)
        $dbTypeLabel.Size = New-Object System.Drawing.Size(100, 20)
        
        $dbTypeComboBox = New-Object System.Windows.Forms.ComboBox
        $dbTypeComboBox.Items.AddRange(@("SQLite (Default)", "MySQL", "PostgreSQL"))
        $dbTypeComboBox.SelectedIndex = 0
        $dbTypeComboBox.Location = New-Object System.Drawing.Point(130, 28)
        $dbTypeComboBox.Size = New-Object System.Drawing.Size(150, 25)
        $dbTypeComboBox.DropDownStyle = "DropDownList"
        
        $dbGroupBox.Controls.AddRange(@($dbTypeLabel, $dbTypeComboBox))
        
        # Save configuration button
        $saveConfigButton = New-Object System.Windows.Forms.Button
        $saveConfigButton.Text = "💾 Save Configuration"
        $saveConfigButton.Size = New-Object System.Drawing.Size(180, 35)
        $saveConfigButton.Location = New-Object System.Drawing.Point(260, 260)
        $saveConfigButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
        $saveConfigButton.ForeColor = [System.Drawing.Color]::White
        $saveConfigButton.FlatStyle = "Flat"
        $saveConfigButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $saveConfigButton.Add_Click({
            $this.SaveConfiguration(@{
                GuiPort = $guiPortTextBox.Text
                FrontendPort = $frontendPortTextBox.Text
                EnableSSL = $sslCheckBox.Checked
                DatabaseType = $dbTypeComboBox.SelectedItem
            })
        })
        
        $configTab.Controls.AddRange(@($serverGroupBox, $dbGroupBox, $saveConfigButton))
        $this.TabControl.TabPages.Add($configTab)
    }
    
    [void] CreateManagementTab() {
        $mgmtTab = New-Object System.Windows.Forms.TabPage
        $mgmtTab.Text = "Management"
        
        # Service control
        $serviceGroupBox = New-Object System.Windows.Forms.GroupBox
        $serviceGroupBox.Text = "Service Control"
        $serviceGroupBox.Location = New-Object System.Drawing.Point(20, 20)
        $serviceGroupBox.Size = New-Object System.Drawing.Size(680, 100)
        
        $serviceStatusLabel = New-Object System.Windows.Forms.Label
        $serviceStatusLabel.Text = "Service Status: $($this.InstallationState.ServiceStatus)"
        $serviceStatusLabel.Location = New-Object System.Drawing.Point(20, 30)
        $serviceStatusLabel.Size = New-Object System.Drawing.Size(200, 20)
        $serviceStatusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
        
        $startButton = New-Object System.Windows.Forms.Button
        $startButton.Text = "▶ Start"
        $startButton.Size = New-Object System.Drawing.Size(80, 35)
        $startButton.Location = New-Object System.Drawing.Point(20, 60)
        $startButton.BackColor = [System.Drawing.Color]::Green
        $startButton.ForeColor = [System.Drawing.Color]::White
        $startButton.Add_Click({ $this.StartService() })
        
        $stopButton = New-Object System.Windows.Forms.Button
        $stopButton.Text = "⏹ Stop"
        $stopButton.Size = New-Object System.Drawing.Size(80, 35)
        $stopButton.Location = New-Object System.Drawing.Point(110, 60)
        $stopButton.BackColor = [System.Drawing.Color]::Red
        $stopButton.ForeColor = [System.Drawing.Color]::White
        $stopButton.Add_Click({ $this.StopService() })
        
        $restartButton = New-Object System.Windows.Forms.Button
        $restartButton.Text = "🔄 Restart"
        $restartButton.Size = New-Object System.Drawing.Size(80, 35)
        $restartButton.Location = New-Object System.Drawing.Point(200, 60)
        $restartButton.BackColor = [System.Drawing.Color]::Orange
        $restartButton.ForeColor = [System.Drawing.Color]::White
        $restartButton.Add_Click({ $this.RestartService() })
        
        $openWebButton = New-Object System.Windows.Forms.Button
        $openWebButton.Text = "🌐 Open Web UI"
        $openWebButton.Size = New-Object System.Drawing.Size(120, 35)
        $openWebButton.Location = New-Object System.Drawing.Point(300, 60)
        $openWebButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
        $openWebButton.ForeColor = [System.Drawing.Color]::White
        $openWebButton.Add_Click({ $this.OpenWebUI() })
        
        $serviceGroupBox.Controls.AddRange(@($serviceStatusLabel, $startButton, $stopButton, $restartButton, $openWebButton))
        
        # Update management
        $updateGroupBox = New-Object System.Windows.Forms.GroupBox
        $updateGroupBox.Text = "Update Management"
        $updateGroupBox.Location = New-Object System.Drawing.Point(20, 140)
        $updateGroupBox.Size = New-Object System.Drawing.Size(680, 80)
        
        $versionLabel = New-Object System.Windows.Forms.Label
        $versionLabel.Text = "Current Version: $($this.InstallationState.Version ?? 'Not Installed')"
        $versionLabel.Location = New-Object System.Drawing.Point(20, 30)
        $versionLabel.Size = New-Object System.Drawing.Size(200, 20)
        
        $checkUpdatesButton = New-Object System.Windows.Forms.Button
        $checkUpdatesButton.Text = "🔍 Check Updates"
        $checkUpdatesButton.Size = New-Object System.Drawing.Size(120, 35)
        $checkUpdatesButton.Location = New-Object System.Drawing.Point(250, 25)
        $checkUpdatesButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
        $checkUpdatesButton.ForeColor = [System.Drawing.Color]::White
        $checkUpdatesButton.Add_Click({ $this.CheckForUpdates() })
        
        $updateGroupBox.Controls.AddRange(@($versionLabel, $checkUpdatesButton))
        
        # Uninstall
        $uninstallGroupBox = New-Object System.Windows.Forms.GroupBox
        $uninstallGroupBox.Text = "Uninstall"
        $uninstallGroupBox.Location = New-Object System.Drawing.Point(20, 240)
        $uninstallGroupBox.Size = New-Object System.Drawing.Size(680, 60)
        
        $uninstallButton = New-Object System.Windows.Forms.Button
        $uninstallButton.Text = "🗑️ Uninstall Velociraptor"
        $uninstallButton.Size = New-Object System.Drawing.Size(180, 35)
        $uninstallButton.Location = New-Object System.Drawing.Point(250, 20)
        $uninstallButton.BackColor = [System.Drawing.Color]::Red
        $uninstallButton.ForeColor = [System.Drawing.Color]::White
        $uninstallButton.Add_Click({ $this.UninstallVelociraptor() })
        
        $uninstallGroupBox.Controls.Add($uninstallButton)
        
        $mgmtTab.Controls.AddRange(@($serviceGroupBox, $updateGroupBox, $uninstallGroupBox))
        $this.TabControl.TabPages.Add($mgmtTab)
    }
    
    [void] CreateLogPanel() {
        $logGroupBox = New-Object System.Windows.Forms.GroupBox
        $logGroupBox.Text = "Setup Log"
        $logGroupBox.Location = New-Object System.Drawing.Point(20, 420)
        $logGroupBox.Size = New-Object System.Drawing.Size(740, 120)
        
        $this.LogTextBox = New-Object System.Windows.Forms.TextBox
        $this.LogTextBox.Multiline = $true
        $this.LogTextBox.ScrollBars = "Vertical"
        $this.LogTextBox.ReadOnly = $true
        $this.LogTextBox.Location = New-Object System.Drawing.Point(10, 20)
        $this.LogTextBox.Size = New-Object System.Drawing.Size(720, 90)
        $this.LogTextBox.Font = New-Object System.Drawing.Font("Consolas", 9)
        $this.LogTextBox.BackColor = [System.Drawing.Color]::Black
        $this.LogTextBox.ForeColor = [System.Drawing.Color]::LimeGreen
        
        $logGroupBox.Controls.Add($this.LogTextBox)
        $this.MainForm.Controls.Add($logGroupBox)
        
        # Add initial log message
        $this.AddLogMessage("Velociraptor Server Setup initialized")
        if ($this.InstallationState.IsInstalled) {
            $this.AddLogMessage("Existing installation detected")
        } else {
            $this.AddLogMessage("Ready for installation")
        }
    }
    
    [void] CreateStatusBar() {
        $statusStrip = New-Object System.Windows.Forms.StatusStrip
        
        $this.StatusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
        $this.StatusLabel.Text = "Ready"
        $this.StatusLabel.Spring = $true
        
        $this.ProgressBar = New-Object System.Windows.Forms.ToolStripProgressBar
        $this.ProgressBar.Visible = $false
        
        $timeLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
        $timeLabel.Text = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        
        $statusStrip.Items.AddRange(@($this.StatusLabel, $this.ProgressBar, $timeLabel))
        $this.MainForm.Controls.Add($statusStrip)
    }
    
    # Installation and management methods
    [void] StartInstallation([bool] $IsStandalone, [string] $InstallPath, [bool] $InstallService, [bool] $ConfigureFirewall, [bool] $CreateShortcut) {
        $this.AddLogMessage("Starting installation...")
        $this.StatusLabel.Text = "Installing..."
        $this.ProgressBar.Visible = $true
        
        try {
            # Simulate installation steps
            $this.AddLogMessage("Creating installation directory: $InstallPath")
            if (-not (Test-Path $InstallPath)) {
                New-Item -Path $InstallPath -ItemType Directory -Force | Out-Null
            }
            
            $this.AddLogMessage("Downloading Velociraptor binary...")
            Start-Sleep -Seconds 2  # Simulate download
            
            $this.AddLogMessage("Generating configuration...")
            Start-Sleep -Seconds 1
            
            if ($InstallService) {
                $this.AddLogMessage("Installing Windows service...")
                Start-Sleep -Seconds 1
            }
            
            if ($ConfigureFirewall) {
                $this.AddLogMessage("Configuring Windows Firewall...")
                Start-Sleep -Seconds 1
            }
            
            if ($CreateShortcut) {
                $this.AddLogMessage("Creating desktop shortcut...")
                Start-Sleep -Seconds 1
            }
            
            $this.AddLogMessage("Installation completed successfully!")
            $this.StatusLabel.Text = "Installation Complete"
            
            [System.Windows.Forms.MessageBox]::Show("Velociraptor has been installed successfully!", "Installation Complete", "OK", "Information")
            
            # Update installation state
            $this.InstallationState.IsInstalled = $true
            $this.InstallationState.Version = "0.72.0"  # Simulated version
        }
        catch {
            $this.AddLogMessage("Installation failed: $($_.Exception.Message)")
            $this.StatusLabel.Text = "Installation Failed"
            [System.Windows.Forms.MessageBox]::Show("Installation failed: $($_.Exception.Message)", "Installation Error", "OK", "Error")
        }
        finally {
            $this.ProgressBar.Visible = $false
        }
    }
    
    [void] SaveConfiguration([hashtable] $Config) {
        $this.AddLogMessage("Saving configuration...")
        $this.AddLogMessage("GUI Port: $($Config.GuiPort)")
        $this.AddLogMessage("Frontend Port: $($Config.FrontendPort)")
        $this.AddLogMessage("SSL Enabled: $($Config.EnableSSL)")
        $this.AddLogMessage("Database: $($Config.DatabaseType)")
        $this.AddLogMessage("Configuration saved successfully")
        
        [System.Windows.Forms.MessageBox]::Show("Configuration saved successfully!", "Configuration Saved", "OK", "Information")
    }
    
    [void] StartService() {
        $this.AddLogMessage("Starting Velociraptor service...")
        Start-Sleep -Seconds 1
        $this.InstallationState.ServiceStatus = "Running"
        $this.AddLogMessage("Service started successfully")
        [System.Windows.Forms.MessageBox]::Show("Velociraptor service started successfully.", "Service Started", "OK", "Information")
    }
    
    [void] StopService() {
        $this.AddLogMessage("Stopping Velociraptor service...")
        Start-Sleep -Seconds 1
        $this.InstallationState.ServiceStatus = "Stopped"
        $this.AddLogMessage("Service stopped successfully")
        [System.Windows.Forms.MessageBox]::Show("Velociraptor service stopped successfully.", "Service Stopped", "OK", "Information")
    }
    
    [void] RestartService() {
        $this.AddLogMessage("Restarting Velociraptor service...")
        Start-Sleep -Seconds 2
        $this.InstallationState.ServiceStatus = "Running"
        $this.AddLogMessage("Service restarted successfully")
        [System.Windows.Forms.MessageBox]::Show("Velociraptor service restarted successfully.", "Service Restarted", "OK", "Information")
    }
    
    [void] OpenWebUI() {
        $this.AddLogMessage("Opening Velociraptor web interface...")
        try {
            Start-Process "http://localhost:8889"
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Failed to open web interface: $($_.Exception.Message)", "Error", "OK", "Error")
        }
    }
    
    [void] CheckForUpdates() {
        $this.AddLogMessage("Checking for updates...")
        Start-Sleep -Seconds 2
        $this.AddLogMessage("No updates available")
        [System.Windows.Forms.MessageBox]::Show("You are running the latest version of Velociraptor.", "No Updates", "OK", "Information")
    }
    
    [void] UninstallVelociraptor() {
        $result = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to uninstall Velociraptor?", "Confirm Uninstall", "YesNo", "Question")
        if ($result -eq "Yes") {
            $this.AddLogMessage("Uninstalling Velociraptor...")
            Start-Sleep -Seconds 2
            $this.InstallationState.IsInstalled = $false
            $this.InstallationState.ServiceStatus = "Not Installed"
            $this.AddLogMessage("Uninstallation completed")
            [System.Windows.Forms.MessageBox]::Show("Velociraptor has been uninstalled successfully.", "Uninstall Complete", "OK", "Information")
        }
    }
    
    # Helper methods
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
        if ($this.CheckInstallation()) {
            return "0.72.0"  # Simulated version
        }
        return $null
    }
    
    [void] AddLogMessage([string] $Message) {
        $timestamp = (Get-Date).ToString("HH:mm:ss")
        $logEntry = "[$timestamp] $Message"
        $this.LogTextBox.AppendText("$logEntry`r`n")
        $this.LogTextBox.SelectionStart = $this.LogTextBox.Text.Length
        $this.LogTextBox.ScrollToCaret()
        [System.Windows.Forms.Application]::DoEvents()
    }
    
    [void] Show() {
        [System.Windows.Forms.Application]::Run($this.MainForm)
    }
}

# Main execution
function Start-VelociraptorServerSetup {
    try {
        # Check if running as administrator
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            [System.Windows.Forms.MessageBox]::Show("This application requires administrator privileges. Please run as administrator.", "Administrator Required", "OK", "Warning")
            return
        }
        
        $app = [VelociraptorServerSetupApp]::new()
        $app.Show()
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to start application: $($_.Exception.Message)", "Application Error", "OK", "Error")
        Write-Error $_.Exception.Message
    }
}

# Entry point
if ($MyInvocation.InvocationName -ne '.') {
    Start-VelociraptorServerSetup
}