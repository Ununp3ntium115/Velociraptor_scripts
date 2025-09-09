# Continuation of VelociraptorInstaller.ps1 - Configuration and Management Tabs

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