# Final parts of VelociraptorInstaller.ps1 - Monitoring, Incident Response, and Core Functions

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