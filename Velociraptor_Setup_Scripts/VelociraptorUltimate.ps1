# Velociraptor Ultimate - Comprehensive DFIR Platform
# Version: 5.0.4-beta
# Combines all functionality into one powerful application

#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Velociraptor Ultimate - Complete DFIR automation platform
    
.DESCRIPTION
    Comprehensive application combining:
    - Investigation management and case tracking
    - Offline collection and artifact building
    - Server deployment and configuration
    - Artifact pack management with 3rd party tools
    - Performance monitoring and health checks
    - Cross-platform deployment capabilities
    
.EXAMPLE
    .\VelociraptorUltimate.ps1
    Launches the complete GUI application
#>

param(
    [switch] $NoGUI,
    
    [ValidateScript({Test-Path (Split-Path $_ -Parent) -PathType Container})]
    [string] $ConfigPath = ".\config\ultimate-config.json",
    
    [ValidateSet('Debug', 'Info', 'Warning', 'Error')]
    [string] $LogLevel = 'Info',
    
    [ValidateRange(800, 2560)]
    [int] $WindowWidth = 1400,
    
    [ValidateRange(600, 1440)]
    [int] $WindowHeight = 900
)

# Import required assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Web

# Import modules
$ModulePaths = @(
    "$PSScriptRoot\modules\VelociraptorDeployment\VelociraptorDeployment.psd1",
    "$PSScriptRoot\modules\VelociraptorCompliance\VelociraptorCompliance.psd1",
    "$PSScriptRoot\modules\VelociraptorML\VelociraptorML.psd1"
)

foreach ($ModulePath in $ModulePaths) {
    if (Test-Path $ModulePath) {
        try {
            Import-Module $ModulePath -Force -ErrorAction SilentlyContinue
            Write-Verbose "Successfully imported module: $ModulePath"
        } catch {
            Write-Warning "Could not import module: $ModulePath - $($_.Exception.Message)"
        }
    } else {
        Write-Verbose "Module not found: $ModulePath"
    }
}

# Main application class
class VelociraptorUltimateApp {
    [System.Windows.Forms.Form] $MainForm
    [System.Windows.Forms.TabControl] $MainTabControl
    [hashtable] $Config
    [System.Collections.ArrayList] $LogEntries
    
    VelociraptorUltimateApp() {
        $this.LogEntries = New-Object System.Collections.ArrayList
        $this.LoadConfiguration()
        $this.InitializeGUI()
    }
    
    [void] LoadConfiguration() {
        try {
            $defaultConfig = @{
                WindowTitle = "Velociraptor Ultimate v5.0.4-beta"
                WindowSize = @{ Width = $script:WindowWidth; Height = $script:WindowHeight }
                VelociraptorRepo = "Ununp3ntium115/velociraptor"
                DefaultPaths = @{
                    Artifacts = ".\artifacts"
                    Collections = ".\collections"
                    Configs = ".\configs"
                    Logs = ".\logs"
                }
                LogLevel = $script:LogLevel
            }
            
            if (Test-Path $script:ConfigPath) {
                try {
                    $configContent = Get-Content $script:ConfigPath -Raw -ErrorAction Stop
                    $loadedConfig = $configContent | ConvertFrom-Json -AsHashtable -ErrorAction Stop
                    $this.Config = $defaultConfig + $loadedConfig
                    Write-Verbose "Configuration loaded from: $script:ConfigPath"
                } catch {
                    Write-Warning "Failed to load configuration from $script:ConfigPath`: $($_.Exception.Message)"
                    $this.Config = $defaultConfig
                }
            } else {
                $this.Config = $defaultConfig
                Write-Verbose "Using default configuration"
            }
        } catch {
            Write-Error "Critical error in LoadConfiguration: $($_.Exception.Message)"
            throw
        }
    }
    
    [void] InitializeGUI() {
        try {
            # Main form
            $this.MainForm = New-Object System.Windows.Forms.Form
            $this.MainForm.Text = $this.Config.WindowTitle
            $this.MainForm.Size = New-Object System.Drawing.Size($this.Config.WindowSize.Width, $this.Config.WindowSize.Height)
            $this.MainForm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
            $this.MainForm.BackColor = [System.Drawing.Color]::White
            $this.MainForm.MinimumSize = New-Object System.Drawing.Size(800, 600)
            
            # Main tab control
            $this.MainTabControl = New-Object System.Windows.Forms.TabControl
            $this.MainTabControl.Dock = [System.Windows.Forms.DockStyle]::Fill
            $this.MainTabControl.Font = New-Object System.Drawing.Font("Segoe UI", 10)
            
            # Create all tabs with error handling
            try { $this.CreateDashboardTab() } catch { Write-Warning "Failed to create Dashboard tab: $($_.Exception.Message)" }
            try { $this.CreateInvestigationsTab() } catch { Write-Warning "Failed to create Investigations tab: $($_.Exception.Message)" }
            try { $this.CreateOfflineWorkerTab() } catch { Write-Warning "Failed to create Offline Worker tab: $($_.Exception.Message)" }
            try { $this.CreateServerSetupTab() } catch { Write-Warning "Failed to create Server Setup tab: $($_.Exception.Message)" }
            try { $this.CreateArtifactManagementTab() } catch { Write-Warning "Failed to create Artifact Management tab: $($_.Exception.Message)" }
            try { $this.CreateMonitoringTab() } catch { Write-Warning "Failed to create Monitoring tab: $($_.Exception.Message)" }
            
            $this.MainForm.Controls.Add($this.MainTabControl)
            
            # Add global error handler
            $this.MainForm.Add_FormClosing({
                param($sender, $e)
                try {
                    $this.AddLogEntry("Application closing...")
                } catch {
                    # Ignore errors during shutdown
                }
            })
            
        } catch {
            Write-Error "Critical error in InitializeGUI: $($_.Exception.Message)"
            throw
        }
    }
    
    [void] CreateDashboardTab() {
        $dashboardTab = New-Object System.Windows.Forms.TabPage
        $dashboardTab.Text = "Dashboard"
        $dashboardTab.BackColor = [System.Drawing.Color]::White
        
        # Quick stats panel
        $statsGroupBox = New-Object System.Windows.Forms.GroupBox
        $statsGroupBox.Text = "System Overview"
        $statsGroupBox.Location = New-Object System.Drawing.Point(20, 20)
        $statsGroupBox.Size = New-Object System.Drawing.Size(1340, 120)
        $statsGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        # System status labels
        $statusLabels = @(
            @{ Text = "Velociraptor Status: Checking..."; X = 20; Y = 30 },
            @{ Text = "Active Collections: 0"; X = 350; Y = 30 },
            @{ Text = "Artifact Packs: Loading..."; X = 650; Y = 30 },
            @{ Text = "System Health: Good"; X = 950; Y = 30 }
        )
        
        foreach ($labelInfo in $statusLabels) {
            $label = New-Object System.Windows.Forms.Label
            $label.Text = $labelInfo.Text
            $label.Location = New-Object System.Drawing.Point($labelInfo.X, $labelInfo.Y)
            $label.Size = New-Object System.Drawing.Size(300, 25)
            $label.Font = New-Object System.Drawing.Font("Segoe UI", 9)
            $statsGroupBox.Controls.Add($label)
        }
        
        # Quick action buttons
        $quickActions = @(
            @{ Text = "Start Investigation"; Action = { $this.MainTabControl.SelectedIndex = 1 }; X = 20; Color = [System.Drawing.Color]::FromArgb(0, 120, 215) },
            @{ Text = "Offline Collection"; Action = { $this.MainTabControl.SelectedIndex = 2 }; X = 200; Color = [System.Drawing.Color]::FromArgb(34, 139, 34) },
            @{ Text = "Server Setup"; Action = { $this.MainTabControl.SelectedIndex = 3 }; X = 380; Color = [System.Drawing.Color]::FromArgb(70, 130, 180) },
            @{ Text = "Manage Artifacts"; Action = { $this.MainTabControl.SelectedIndex = 4 }; X = 560; Color = [System.Drawing.Color]::FromArgb(128, 0, 128) },
            @{ Text = "View Monitoring"; Action = { $this.MainTabControl.SelectedIndex = 5 }; X = 740; Color = [System.Drawing.Color]::FromArgb(255, 140, 0) },
            @{ Text = "Open Web UI"; Action = { $this.OpenWebUI() }; X = 920; Color = [System.Drawing.Color]::FromArgb(220, 20, 60) }
        )
        
        foreach ($action in $quickActions) {
            $button = New-Object System.Windows.Forms.Button
            $button.Text = $action.Text
            $button.Location = New-Object System.Drawing.Point($action.X, 160)
            $button.Size = New-Object System.Drawing.Size(160, 50)
            $button.BackColor = $action.Color
            $button.ForeColor = [System.Drawing.Color]::White
            $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
            $button.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
            $button.Add_Click($action.Action)
            $dashboardTab.Controls.Add($button)
        }
        
        # Recent activity log
        $logGroupBox = New-Object System.Windows.Forms.GroupBox
        $logGroupBox.Text = "Recent Activity"
        $logGroupBox.Location = New-Object System.Drawing.Point(20, 230)
        $logGroupBox.Size = New-Object System.Drawing.Size(1340, 300)
        $logGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        $logListBox = New-Object System.Windows.Forms.ListBox
        $logListBox.Location = New-Object System.Drawing.Point(10, 25)
        $logListBox.Size = New-Object System.Drawing.Size(1320, 265)
        $logListBox.Font = New-Object System.Drawing.Font("Consolas", 9)
        $logGroupBox.Controls.Add($logListBox)
        
        $dashboardTab.Controls.Add($statsGroupBox)
        $dashboardTab.Controls.Add($logGroupBox)
        $this.MainTabControl.TabPages.Add($dashboardTab)
    }
    
    [void] CreateInvestigationsTab() {
        $investigationsTab = New-Object System.Windows.Forms.TabPage
        $investigationsTab.Text = "Investigations"
        $investigationsTab.BackColor = [System.Drawing.Color]::White
        
        # Case management panel
        $casePanel = New-Object System.Windows.Forms.Panel
        $casePanel.Location = New-Object System.Drawing.Point(20, 20)
        $casePanel.Size = New-Object System.Drawing.Size(400, 800)
        $casePanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
        
        $caseLabel = New-Object System.Windows.Forms.Label
        $caseLabel.Text = "Case Management"
        $caseLabel.Location = New-Object System.Drawing.Point(10, 10)
        $caseLabel.Size = New-Object System.Drawing.Size(200, 25)
        $caseLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
        $casePanel.Controls.Add($caseLabel)
        
        # New case button
        $newCaseBtn = New-Object System.Windows.Forms.Button
        $newCaseBtn.Text = "New Case"
        $newCaseBtn.Location = New-Object System.Drawing.Point(10, 45)
        $newCaseBtn.Size = New-Object System.Drawing.Size(120, 35)
        $newCaseBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
        $newCaseBtn.ForeColor = [System.Drawing.Color]::White
        $newCaseBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $newCaseBtn.Add_Click({ $this.CreateNewCase() })
        $casePanel.Controls.Add($newCaseBtn)
        
        # Case list
        $caseListBox = New-Object System.Windows.Forms.ListBox
        $caseListBox.Location = New-Object System.Drawing.Point(10, 90)
        $caseListBox.Size = New-Object System.Drawing.Size(375, 300)
        $caseListBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $casePanel.Controls.Add($caseListBox)
        
        # Investigation details panel
        $detailsPanel = New-Object System.Windows.Forms.Panel
        $detailsPanel.Location = New-Object System.Drawing.Point(440, 20)
        $detailsPanel.Size = New-Object System.Drawing.Size(920, 800)
        $detailsPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
        
        $detailsLabel = New-Object System.Windows.Forms.Label
        $detailsLabel.Text = "Investigation Details"
        $detailsLabel.Location = New-Object System.Drawing.Point(10, 10)
        $detailsLabel.Size = New-Object System.Drawing.Size(200, 25)
        $detailsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
        $detailsPanel.Controls.Add($detailsLabel)
        
        $investigationsTab.Controls.Add($casePanel)
        $investigationsTab.Controls.Add($detailsPanel)
        $this.MainTabControl.TabPages.Add($investigationsTab)
    }
    
    [void] CreateOfflineWorkerTab() {
        $offlineTab = New-Object System.Windows.Forms.TabPage
        $offlineTab.Text = "Offline Worker"
        $offlineTab.BackColor = [System.Drawing.Color]::White
        
        # Collection builder panel
        $builderPanel = New-Object System.Windows.Forms.GroupBox
        $builderPanel.Text = "Collection Builder"
        $builderPanel.Location = New-Object System.Drawing.Point(20, 20)
        $builderPanel.Size = New-Object System.Drawing.Size(650, 400)
        $builderPanel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        # Artifact selection
        $artifactLabel = New-Object System.Windows.Forms.Label
        $artifactLabel.Text = "Select Artifacts:"
        $artifactLabel.Location = New-Object System.Drawing.Point(15, 30)
        $artifactLabel.Size = New-Object System.Drawing.Size(120, 20)
        $builderPanel.Controls.Add($artifactLabel)
        
        $artifactCheckedListBox = New-Object System.Windows.Forms.CheckedListBox
        $artifactCheckedListBox.Location = New-Object System.Drawing.Point(15, 55)
        $artifactCheckedListBox.Size = New-Object System.Drawing.Size(300, 200)
        $artifactCheckedListBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $builderPanel.Controls.Add($artifactCheckedListBox)
        
        # Build collection button
        $buildBtn = New-Object System.Windows.Forms.Button
        $buildBtn.Text = "Build Collection"
        $buildBtn.Location = New-Object System.Drawing.Point(15, 270)
        $buildBtn.Size = New-Object System.Drawing.Size(150, 40)
        $buildBtn.BackColor = [System.Drawing.Color]::FromArgb(34, 139, 34)
        $buildBtn.ForeColor = [System.Drawing.Color]::White
        $buildBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $buildBtn.Add_Click({ $this.BuildOfflineCollection() })
        $builderPanel.Controls.Add($buildBtn)
        
        # Progress panel
        $progressPanel = New-Object System.Windows.Forms.GroupBox
        $progressPanel.Text = "Build Progress"
        $progressPanel.Location = New-Object System.Drawing.Point(690, 20)
        $progressPanel.Size = New-Object System.Drawing.Size(670, 400)
        $progressPanel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        $progressBar = New-Object System.Windows.Forms.ProgressBar
        $progressBar.Location = New-Object System.Drawing.Point(15, 30)
        $progressBar.Size = New-Object System.Drawing.Size(640, 25)
        $progressPanel.Controls.Add($progressBar)
        
        $progressTextBox = New-Object System.Windows.Forms.TextBox
        $progressTextBox.Location = New-Object System.Drawing.Point(15, 65)
        $progressTextBox.Size = New-Object System.Drawing.Size(640, 320)
        $progressTextBox.Multiline = $true
        $progressTextBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
        $progressTextBox.Font = New-Object System.Drawing.Font("Consolas", 9)
        $progressTextBox.ReadOnly = $true
        $progressPanel.Controls.Add($progressTextBox)
        
        $offlineTab.Controls.Add($builderPanel)
        $offlineTab.Controls.Add($progressPanel)
        $this.MainTabControl.TabPages.Add($offlineTab)
    }
    
    [void] CreateServerSetupTab() {
        $serverTab = New-Object System.Windows.Forms.TabPage
        $serverTab.Text = "Server Setup"
        $serverTab.BackColor = [System.Drawing.Color]::White
        
        # Configuration panel
        $configPanel = New-Object System.Windows.Forms.GroupBox
        $configPanel.Text = "Server Configuration"
        $configPanel.Location = New-Object System.Drawing.Point(20, 20)
        $configPanel.Size = New-Object System.Drawing.Size(650, 500)
        $configPanel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        # Server type selection
        $serverTypeLabel = New-Object System.Windows.Forms.Label
        $serverTypeLabel.Text = "Deployment Type:"
        $serverTypeLabel.Location = New-Object System.Drawing.Point(15, 30)
        $serverTypeLabel.Size = New-Object System.Drawing.Size(120, 20)
        $configPanel.Controls.Add($serverTypeLabel)
        
        $serverTypeCombo = New-Object System.Windows.Forms.ComboBox
        $serverTypeCombo.Location = New-Object System.Drawing.Point(140, 28)
        $serverTypeCombo.Size = New-Object System.Drawing.Size(200, 25)
        $serverTypeCombo.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
        $serverTypeCombo.Items.AddRange(@("Standalone", "Server", "Cluster", "Cloud"))
        $serverTypeCombo.SelectedIndex = 0
        $configPanel.Controls.Add($serverTypeCombo)
        
        # Deploy button
        $deployBtn = New-Object System.Windows.Forms.Button
        $deployBtn.Text = "Deploy Server"
        $deployBtn.Location = New-Object System.Drawing.Point(15, 450)
        $deployBtn.Size = New-Object System.Drawing.Size(150, 40)
        $deployBtn.BackColor = [System.Drawing.Color]::FromArgb(70, 130, 180)
        $deployBtn.ForeColor = [System.Drawing.Color]::White
        $deployBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $deployBtn.Add_Click({ $this.DeployServer() })
        $configPanel.Controls.Add($deployBtn)
        
        # Status panel
        $statusPanel = New-Object System.Windows.Forms.GroupBox
        $statusPanel.Text = "Deployment Status"
        $statusPanel.Location = New-Object System.Drawing.Point(690, 20)
        $statusPanel.Size = New-Object System.Drawing.Size(670, 500)
        $statusPanel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        $statusTextBox = New-Object System.Windows.Forms.TextBox
        $statusTextBox.Location = New-Object System.Drawing.Point(15, 30)
        $statusTextBox.Size = New-Object System.Drawing.Size(640, 450)
        $statusTextBox.Multiline = $true
        $statusTextBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
        $statusTextBox.Font = New-Object System.Drawing.Font("Consolas", 9)
        $statusTextBox.ReadOnly = $true
        $statusPanel.Controls.Add($statusTextBox)
        
        $serverTab.Controls.Add($configPanel)
        $serverTab.Controls.Add($statusPanel)
        $this.MainTabControl.TabPages.Add($serverTab)
    }
    
    [void] CreateArtifactManagementTab() {
        $artifactTab = New-Object System.Windows.Forms.TabPage
        $artifactTab.Text = "Artifacts"
        $artifactTab.BackColor = [System.Drawing.Color]::White
        
        # Artifact packs panel
        $packsPanel = New-Object System.Windows.Forms.GroupBox
        $packsPanel.Text = "Artifact Packs"
        $packsPanel.Location = New-Object System.Drawing.Point(20, 20)
        $packsPanel.Size = New-Object System.Drawing.Size(400, 800)
        $packsPanel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        # Pack list
        $packListBox = New-Object System.Windows.Forms.ListBox
        $packListBox.Location = New-Object System.Drawing.Point(15, 30)
        $packListBox.Size = New-Object System.Drawing.Size(370, 300)
        $packListBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        
        # Load artifact packs
        $artifactPacks = @(
            "APT-Package",
            "Ransomware-Package", 
            "DataBreach-Package",
            "Malware-Package",
            "NetworkIntrusion-Package",
            "Insider-Package",
            "Complete-Package"
        )
        
        foreach ($pack in $artifactPacks) {
            $packListBox.Items.Add($pack)
        }
        
        $packsPanel.Controls.Add($packListBox)
        
        # Pack management buttons
        $loadPackBtn = New-Object System.Windows.Forms.Button
        $loadPackBtn.Text = "Load Pack"
        $loadPackBtn.Location = New-Object System.Drawing.Point(15, 350)
        $loadPackBtn.Size = New-Object System.Drawing.Size(100, 35)
        $loadPackBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
        $loadPackBtn.ForeColor = [System.Drawing.Color]::White
        $loadPackBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $loadPackBtn.Add_Click({ $this.LoadArtifactPack() })
        $packsPanel.Controls.Add($loadPackBtn)
        
        # Tools management panel
        $toolsPanel = New-Object System.Windows.Forms.GroupBox
        $toolsPanel.Text = "3rd Party Tools"
        $toolsPanel.Location = New-Object System.Drawing.Point(440, 20)
        $toolsPanel.Size = New-Object System.Drawing.Size(920, 800)
        $toolsPanel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        # Tools list
        $toolsListView = New-Object System.Windows.Forms.ListView
        $toolsListView.Location = New-Object System.Drawing.Point(15, 30)
        $toolsListView.Size = New-Object System.Drawing.Size(890, 400)
        $toolsListView.View = [System.Windows.Forms.View]::Details
        $toolsListView.FullRowSelect = $true
        $toolsListView.GridLines = $true
        
        # Add columns
        $toolsListView.Columns.Add("Tool Name", 200)
        $toolsListView.Columns.Add("Version", 100)
        $toolsListView.Columns.Add("Status", 100)
        $toolsListView.Columns.Add("Path", 400)
        
        $toolsPanel.Controls.Add($toolsListView)
        
        # Tool management buttons
        $downloadToolsBtn = New-Object System.Windows.Forms.Button
        $downloadToolsBtn.Text = "Download Tools"
        $downloadToolsBtn.Location = New-Object System.Drawing.Point(15, 450)
        $downloadToolsBtn.Size = New-Object System.Drawing.Size(150, 35)
        $downloadToolsBtn.BackColor = [System.Drawing.Color]::FromArgb(34, 139, 34)
        $downloadToolsBtn.ForeColor = [System.Drawing.Color]::White
        $downloadToolsBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $downloadToolsBtn.Add_Click({ $this.DownloadTools() })
        $toolsPanel.Controls.Add($downloadToolsBtn)
        
        $artifactTab.Controls.Add($packsPanel)
        $artifactTab.Controls.Add($toolsPanel)
        $this.MainTabControl.TabPages.Add($artifactTab)
    }
    
    [void] CreateMonitoringTab() {
        $monitoringTab = New-Object System.Windows.Forms.TabPage
        $monitoringTab.Text = "Monitoring"
        $monitoringTab.BackColor = [System.Drawing.Color]::White
        
        # Health status panel
        $healthPanel = New-Object System.Windows.Forms.GroupBox
        $healthPanel.Text = "System Health"
        $healthPanel.Location = New-Object System.Drawing.Point(20, 20)
        $healthPanel.Size = New-Object System.Drawing.Size(1340, 200)
        $healthPanel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        # Performance metrics panel
        $metricsPanel = New-Object System.Windows.Forms.GroupBox
        $metricsPanel.Text = "Performance Metrics"
        $metricsPanel.Location = New-Object System.Drawing.Point(20, 240)
        $metricsPanel.Size = New-Object System.Drawing.Size(1340, 300)
        $metricsPanel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        # Logs panel
        $logsPanel = New-Object System.Windows.Forms.GroupBox
        $logsPanel.Text = "System Logs"
        $logsPanel.Location = New-Object System.Drawing.Point(20, 560)
        $logsPanel.Size = New-Object System.Drawing.Size(1340, 260)
        $logsPanel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        $logsTextBox = New-Object System.Windows.Forms.TextBox
        $logsTextBox.Location = New-Object System.Drawing.Point(15, 30)
        $logsTextBox.Size = New-Object System.Drawing.Size(1310, 220)
        $logsTextBox.Multiline = $true
        $logsTextBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
        $logsTextBox.Font = New-Object System.Drawing.Font("Consolas", 9)
        $logsTextBox.ReadOnly = $true
        $logsPanel.Controls.Add($logsTextBox)
        
        $monitoringTab.Controls.Add($healthPanel)
        $monitoringTab.Controls.Add($metricsPanel)
        $monitoringTab.Controls.Add($logsPanel)
        $this.MainTabControl.TabPages.Add($monitoringTab)
    }
    
    # Action methods
    [void] CreateNewCase() {
        try {
            $caseForm = New-Object System.Windows.Forms.Form
            $caseForm.Text = "New Investigation Case"
            $caseForm.Size = New-Object System.Drawing.Size(500, 400)
            $caseForm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent
            
            # Case name
            $nameLabel = New-Object System.Windows.Forms.Label
            $nameLabel.Text = "Case Name:"
            $nameLabel.Location = New-Object System.Drawing.Point(20, 20)
            $nameLabel.Size = New-Object System.Drawing.Size(100, 20)
            $caseForm.Controls.Add($nameLabel)
            
            $nameTextBox = New-Object System.Windows.Forms.TextBox
            $nameTextBox.Location = New-Object System.Drawing.Point(130, 18)
            $nameTextBox.Size = New-Object System.Drawing.Size(300, 25)
            $caseForm.Controls.Add($nameTextBox)
            
            # Create button
            $createBtn = New-Object System.Windows.Forms.Button
            $createBtn.Text = "Create Case"
            $createBtn.Location = New-Object System.Drawing.Point(200, 320)
            $createBtn.Size = New-Object System.Drawing.Size(100, 35)
            $createBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
            $createBtn.ForeColor = [System.Drawing.Color]::White
            $createBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
            $createBtn.Add_Click({ 
                try {
                    if ([string]::IsNullOrWhiteSpace($nameTextBox.Text)) {
                        [System.Windows.Forms.MessageBox]::Show("Please enter a case name.", "Validation Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
                        return
                    }
                    $this.AddLogEntry("Created new case: $($nameTextBox.Text)")
                    $caseForm.Close() 
                } catch {
                    [System.Windows.Forms.MessageBox]::Show("Error creating case: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                }
            })
            $caseForm.Controls.Add($createBtn)
            
            $caseForm.ShowDialog()
        } catch {
            Write-Error "Failed to create new case dialog: $($_.Exception.Message)"
        }
    }
    
    [void] BuildOfflineCollection() {
        try {
            $this.AddLogEntry("Starting offline collection build...")
            # Implementation would call existing artifact building functionality
            # Add validation and error handling for build process
        } catch {
            $this.AddLogEntry("Error building offline collection: $($_.Exception.Message)")
            Write-Error "BuildOfflineCollection failed: $($_.Exception.Message)"
        }
    }
    
    [void] DeployServer() {
        try {
            $this.AddLogEntry("Starting server deployment...")
            # Implementation would call existing deployment scripts
            # Add validation and error handling for deployment process
        } catch {
            $this.AddLogEntry("Error deploying server: $($_.Exception.Message)")
            Write-Error "DeployServer failed: $($_.Exception.Message)"
        }
    }
    
    [void] LoadArtifactPack() {
        try {
            $this.AddLogEntry("Loading artifact pack...")
            # Implementation would call Investigate-ArtifactPack.ps1 functionality
            # Add validation and error handling for pack loading
        } catch {
            $this.AddLogEntry("Error loading artifact pack: $($_.Exception.Message)")
            Write-Error "LoadArtifactPack failed: $($_.Exception.Message)"
        }
    }
    
    [void] DownloadTools() {
        try {
            $this.AddLogEntry("Downloading 3rd party tools...")
            # Implementation would call New-ArtifactToolManager.ps1 functionality
            # Add validation and error handling for tool downloads
        } catch {
            $this.AddLogEntry("Error downloading tools: $($_.Exception.Message)")
            Write-Error "DownloadTools failed: $($_.Exception.Message)"
        }
    }
    
    [void] OpenWebUI() {
        try {
            Start-Process "http://localhost:8889"
            $this.AddLogEntry("Opened Velociraptor Web UI")
        } catch {
            $this.AddLogEntry("Failed to open Web UI: $($_.Exception.Message)")
        }
    }
    
    [void] AddLogEntry([string] $message) {
        try {
            if ([string]::IsNullOrWhiteSpace($message)) {
                return
            }
            
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logEntry = "[$timestamp] $message"
            $this.LogEntries.Add($logEntry)
            
            # Write to appropriate stream based on log level
            switch ($this.Config.LogLevel) {
                'Debug' { Write-Debug $logEntry }
                'Info' { Write-Information $logEntry -InformationAction Continue }
                'Warning' { Write-Warning $logEntry }
                'Error' { Write-Error $logEntry }
                default { Write-Host $logEntry }
            }
        } catch {
            Write-Warning "Failed to add log entry: $($_.Exception.Message)"
        }
    }
    
    [void] Show() {
        [System.Windows.Forms.Application]::EnableVisualStyles()
        [System.Windows.Forms.Application]::Run($this.MainForm)
    }
}

# Main execution
if (-not $NoGUI) {
    try {
        $app = [VelociraptorUltimateApp]::new()
        $app.Show()
    } catch {
        Write-Error "Failed to start Velociraptor Ultimate: $($_.Exception.Message)"
        exit 1
    }
} else {
    Write-Host "Velociraptor Ultimate - CLI mode not yet implemented"
    Write-Host "Use without -NoGUI parameter to launch the GUI application"
}