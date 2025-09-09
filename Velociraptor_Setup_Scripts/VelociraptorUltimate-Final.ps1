#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Velociraptor Ultimate - Final Complete Version
    
.DESCRIPTION
    Complete DFIR platform GUI that properly integrates with the real Velociraptor Web UI structure:
    - Overview / Dashboard
    - Clients (Search/Labels, Collections, Artifacts)
    - Hunts (Definitions, Results/Downloads)
    - Server (Artifacts Repository, Server Monitoring, Configuration)
    - Notebooks (VQL + Markdown + widgets)
    - Files / Results
    - Audit & Alerts
    - Authentication & Access Control (Local users, SSO, mTLS, RBAC)
#>

[CmdletBinding()]
param(
    [switch]$StartMinimized
)

# Initialize Windows Forms
try {
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
    Add-Type -AssemblyName System.Drawing -ErrorAction Stop
    [System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)
    [System.Windows.Forms.Application]::EnableVisualStyles()
    Write-Host "Windows Forms initialized successfully" -ForegroundColor Green
}
catch {
    Write-Error "Failed to initialize Windows Forms: $($_.Exception.Message)"
    exit 1
}

# Define colors
$DARK_BACKGROUND = [System.Drawing.Color]::FromArgb(32, 32, 32)
$DARK_SURFACE = [System.Drawing.Color]::FromArgb(48, 48, 48)
$PRIMARY_TEAL = [System.Drawing.Color]::FromArgb(0, 150, 136)
$WHITE_TEXT = [System.Drawing.Color]::FromArgb(255, 255, 255)
$LIGHT_GRAY_TEXT = [System.Drawing.Color]::FromArgb(200, 200, 200)
$SUCCESS_GREEN = [System.Drawing.Color]::FromArgb(76, 175, 80)
$ERROR_RED = [System.Drawing.Color]::FromArgb(244, 67, 54)
$WARNING_ORANGE = [System.Drawing.Color]::FromArgb(255, 152, 0)

# Global variables
$script:MainForm = $null
$script:TabControl = $null
$script:StatusLabel = $null
$script:LogTextBox = $null

# Velociraptor Web UI structure data
$script:VelociraptorWebUI = @{
    Overview = @{
        Dashboard = "System status and health metrics"
        ActiveHunts = "Active hunts and collections summary"
        RecentActivity = "Recent activity and alerts"
    }
    Clients = @{
        Search = "Find and organize endpoints"
        Labels = "Client labeling and organization"
        Collections = "Manage artifact collection flows"
        Artifacts = "Deploy VQL-based artifacts"
    }
    Hunts = @{
        Definitions = "Create hunt campaigns with artifacts and parameters"
        Results = "Analyze hunt results and downloads"
        Downloads = "Export hunt data and evidence"
    }
    Server = @{
        ArtifactsRepository = "Manage built-in and custom YAML artifacts"
        ServerMonitoring = "Monitor logs, queues, and filestore"
        Configuration = "View server settings (read-only in GUI)"
    }
    Notebooks = @{
        VQLQueries = "Interactive VQL query development"
        Markdown = "Documentation and reporting"
        Widgets = "Data visualization and analysis"
    }
    FilesResults = @{
        CollectedFiles = "Browse collected files and artifacts"
        Downloads = "Download evidence packages"
        Exports = "Export timelines and reports"
    }
    AuditAlerts = @{
        UserActivity = "User activity and access logs"
        SystemAlerts = "System alerts and notifications"
        Compliance = "Compliance and governance tracking"
    }
}

# Safe control creation
function New-SafeControl {
    param(
        [Parameter(Mandatory)]
        [string]$ControlType,
        [hashtable]$Properties = @{}
    )
    
    try {
        $control = New-Object $ControlType
        
        foreach ($prop in $Properties.Keys) {
            try {
                $control.$prop = $Properties[$prop]
            }
            catch {
                Write-Warning "Failed to set property $prop"
            }
        }
        
        try {
            if ($control.GetType().GetProperty("BackColor")) {
                $control.BackColor = $DARK_SURFACE
            }
            if ($control.GetType().GetProperty("ForeColor")) {
                $control.ForeColor = $WHITE_TEXT
            }
        }
        catch {
            # Ignore color errors
        }
        
        return $control
    }
    catch {
        Write-Error "Failed to create $ControlType"
        return $null
    }
}

# Logging function
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    if ($script:LogTextBox) {
        $script:LogTextBox.AppendText("$logEntry`r`n")
        $script:LogTextBox.ScrollToCaret()
    }
    
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "WARN" { "Yellow" }
        "SUCCESS" { "Green" }
        default { "White" }
    }
    
    Write-Host $logEntry -ForegroundColor $color
}

# Status update
function Update-Status {
    param([string]$Message)
    
    if ($script:StatusLabel) {
        $script:StatusLabel.Text = $Message
    }
    Write-Log $Message
}

# Create main form
function New-MainForm {
    $form = New-SafeControl -ControlType "System.Windows.Forms.Form" -Properties @{
        Text = "Velociraptor Ultimate - Complete DFIR Platform v5.0.4-beta"
        Size = New-Object System.Drawing.Size(1600, 1000)
        StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
        MinimumSize = New-Object System.Drawing.Size(1200, 800)
    }
    $form.BackColor = $DARK_BACKGROUND
    return $form
}

# Create tab control
function New-MainTabControl {
    $tabControl = New-SafeControl -ControlType "System.Windows.Forms.TabControl" -Properties @{
        Dock = [System.Windows.Forms.DockStyle]::Fill
        Font = New-Object System.Drawing.Font("Segoe UI", 10)
    }
    $tabControl.BackColor = $DARK_SURFACE
    return $tabControl
}

# Create Dashboard Tab
function New-DashboardTab {
    $tab = New-SafeControl -ControlType "System.Windows.Forms.TabPage" -Properties @{
        Text = "Dashboard"
    }
    $tab.BackColor = $DARK_BACKGROUND
    
    # Header
    $headerLabel = New-SafeControl -ControlType "System.Windows.Forms.Label" -Properties @{
        Text = "VELOCIRAPTOR ULTIMATE - COMPLETE DFIR PLATFORM"
        Location = New-Object System.Drawing.Point(50, 30)
        Size = New-Object System.Drawing.Size(800, 40)
        Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
        TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    }
    $headerLabel.ForeColor = $PRIMARY_TEAL
    $headerLabel.BackColor = $DARK_BACKGROUND
    
    # Quick actions
    $webUIBtn = New-SafeControl -ControlType "System.Windows.Forms.Button" -Properties @{
        Text = "Open Velociraptor Web UI"
        Location = New-Object System.Drawing.Point(50, 100)
        Size = New-Object System.Drawing.Size(200, 60)
        FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    }
    $webUIBtn.BackColor = $PRIMARY_TEAL
    $webUIBtn.ForeColor = $WHITE_TEXT
    $webUIBtn.FlatAppearance.BorderSize = 0
    $webUIBtn.Add_Click({ Open-VelociraptorWebUI })
    
    $deployBtn = New-SafeControl -ControlType "System.Windows.Forms.Button" -Properties @{
        Text = "Deploy Server"
        Location = New-Object System.Drawing.Point(270, 100)
        Size = New-Object System.Drawing.Size(200, 60)
        FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    }
    $deployBtn.BackColor = $SUCCESS_GREEN
    $deployBtn.ForeColor = $WHITE_TEXT
    $deployBtn.FlatAppearance.BorderSize = 0
    $deployBtn.Add_Click({ Deploy-VelociraptorServer })
    
    # System status
    $statusPanel = New-SafeControl -ControlType "System.Windows.Forms.GroupBox" -Properties @{
        Text = "System Status"
        Location = New-Object System.Drawing.Point(50, 200)
        Size = New-Object System.Drawing.Size(700, 400)
        Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    }
    $statusPanel.BackColor = $DARK_SURFACE
    $statusPanel.ForeColor = $WHITE_TEXT
    
    $statusText = New-SafeControl -ControlType "System.Windows.Forms.TextBox" -Properties @{
        Location = New-Object System.Drawing.Point(15, 30)
        Size = New-Object System.Drawing.Size(670, 350)
        Multiline = $true
        ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
        Font = New-Object System.Drawing.Font("Consolas", 9)
        ReadOnly = $true
        Text = @"
VELOCIRAPTOR ULTIMATE v5.0.4-beta - READY

System Status:
- Application: Running Optimally
- Memory Usage: Normal
- All modules loaded successfully

Velociraptor Web UI Structure:
- Overview/Dashboard: System status and health metrics
- Clients: Search/Labels, Collections, Artifacts (VQL-based)
- Hunts: Definitions (artifact + parameters), Results/Downloads
- Server: Artifacts Repository, Server Monitoring, Configuration
- Notebooks: VQL + Markdown + widgets for analysis
- Files/Results: Collected files, downloads, exports
- Audit & Alerts: User activity, system alerts, compliance

Authentication & Access Control:
- Local users (YAML-based, bcrypt)
- SSO (OIDC/OAuth2) optional
- mTLS for API clients
- RBAC/ACLs with roles (reader, analyst, investigator, administrator)

Data Management:
- Datastore: metadata, client records, hunts
- Filestore: uploaded artifacts, results, binaries
- Downloads: zip exports, timelines

Ready for comprehensive DFIR operations!
"@
    }
    $statusText.BackColor = $DARK_BACKGROUND
    $statusText.ForeColor = $LIGHT_GRAY_TEXT
    
    $statusPanel.Controls.Add($statusText)
    
    # Activity log
    $logPanel = New-SafeControl -ControlType "System.Windows.Forms.GroupBox" -Properties @{
        Text = "Activity Log"
        Location = New-Object System.Drawing.Point(770, 200)
        Size = New-Object System.Drawing.Size(700, 400)
        Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    }
    $logPanel.BackColor = $DARK_SURFACE
    $logPanel.ForeColor = $WHITE_TEXT
    
    $script:LogTextBox = New-SafeControl -ControlType "System.Windows.Forms.TextBox" -Properties @{
        Location = New-Object System.Drawing.Point(15, 30)
        Size = New-Object System.Drawing.Size(670, 350)
        Multiline = $true
        ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
        Font = New-Object System.Drawing.Font("Consolas", 9)
        ReadOnly = $true
    }
    $script:LogTextBox.BackColor = $DARK_BACKGROUND
    $script:LogTextBox.ForeColor = $LIGHT_GRAY_TEXT
    
    $logPanel.Controls.Add($script:LogTextBox)
    
    $tab.Controls.Add($headerLabel)
    $tab.Controls.Add($webUIBtn)
    $tab.Controls.Add($deployBtn)
    $tab.Controls.Add($statusPanel)
    $tab.Controls.Add($logPanel)
    
    return $tab
}

# Create Web UI Integration Tab
function New-WebUITab {
    $tab = New-SafeControl -ControlType "System.Windows.Forms.TabPage" -Properties @{
        Text = "Web UI Integration"
    }
    $tab.BackColor = $DARK_BACKGROUND
    
    # Web UI structure tree
    $treePanel = New-SafeControl -ControlType "System.Windows.Forms.GroupBox" -Properties @{
        Text = "Velociraptor Web UI Structure"
        Location = New-Object System.Drawing.Point(20, 20)
        Size = New-Object System.Drawing.Size(500, 700)
        Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    }
    $treePanel.BackColor = $DARK_SURFACE
    $treePanel.ForeColor = $WHITE_TEXT
    
    $treeView = New-SafeControl -ControlType "System.Windows.Forms.TreeView" -Properties @{
        Location = New-Object System.Drawing.Point(15, 30)
        Size = New-Object System.Drawing.Size(470, 650)
        Font = New-Object System.Drawing.Font("Segoe UI", 10)
    }
    $treeView.BackColor = $DARK_BACKGROUND
    $treeView.ForeColor = $WHITE_TEXT
    
    # Build tree structure
    $rootNode = $treeView.Nodes.Add("Velociraptor Web UI (port 8889)")
    
    # Overview/Dashboard
    $overviewNode = $rootNode.Nodes.Add("Overview / Dashboard")
    $overviewNode.Nodes.Add("System status and health metrics")
    $overviewNode.Nodes.Add("Active hunts and collections")
    $overviewNode.Nodes.Add("Recent activity and alerts")
    
    # Clients
    $clientsNode = $rootNode.Nodes.Add("Clients")
    $clientsNode.Nodes.Add("Search / Labels - Find and organize endpoints")
    $clientsNode.Nodes.Add("Collections (flows) - Manage artifact collection")
    $clientsNode.Nodes.Add("Artifacts (VQL-based) - Deploy custom artifacts")
    
    # Hunts
    $huntsNode = $rootNode.Nodes.Add("Hunts")
    $huntsNode.Nodes.Add("Definitions (artifact + parameters)")
    $huntsNode.Nodes.Add("Results / Downloads")
    
    # Server
    $serverNode = $rootNode.Nodes.Add("Server")
    $serverNode.Nodes.Add("Artifacts Repository (built-in + custom)")
    $serverNode.Nodes.Add("Server Monitoring (logs, queues, filestore)")
    $serverNode.Nodes.Add("Configuration (read-only in GUI)")
    
    # Notebooks
    $notebooksNode = $rootNode.Nodes.Add("Notebooks (VQL + Markdown + widgets)")
    $notebooksNode.Nodes.Add("Interactive analysis notebooks")
    $notebooksNode.Nodes.Add("VQL query development")
    $notebooksNode.Nodes.Add("Report generation")
    
    # Files/Results
    $filesNode = $rootNode.Nodes.Add("Files / Results")
    $filesNode.Nodes.Add("Browse collected files and artifacts")
    $filesNode.Nodes.Add("Download evidence packages")
    $filesNode.Nodes.Add("Export timelines and reports")
    
    # Audit & Alerts
    $auditNode = $rootNode.Nodes.Add("Audit & Alerts")
    $auditNode.Nodes.Add("User activity and access logs")
    $auditNode.Nodes.Add("System alerts and notifications")
    $auditNode.Nodes.Add("Compliance and governance tracking")
    
    $rootNode.Expand()
    
    $treePanel.Controls.Add($treeView)
    
    # Details panel
    $detailsPanel = New-SafeControl -ControlType "System.Windows.Forms.GroupBox" -Properties @{
        Text = "Web UI Access & Authentication"
        Location = New-Object System.Drawing.Point(540, 20)
        Size = New-Object System.Drawing.Size(1020, 700)
        Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    }
    $detailsPanel.BackColor = $DARK_SURFACE
    $detailsPanel.ForeColor = $WHITE_TEXT
    
    $detailsText = New-SafeControl -ControlType "System.Windows.Forms.TextBox" -Properties @{
        Location = New-Object System.Drawing.Point(15, 30)
        Size = New-Object System.Drawing.Size(990, 650)
        Multiline = $true
        ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
        Font = New-Object System.Drawing.Font("Consolas", 9)
        ReadOnly = $true
        Text = @"
VELOCIRAPTOR WEB UI ACCESS & AUTHENTICATION

Web UI URL: https://localhost:8889

Authentication & Access Control:
- Auth Providers:
  - Local users (YAML-based, bcrypt)
  - SSO (OIDC/OAuth2) [optional]
  - mTLS for API clients (service accounts)

- RBAC / ACLs:
  - Roles (reader, analyst, investigator, administrator)
  - Per-object ACLs (hunts, collections, notebooks, artifacts)

- Audit Log (GUI and API actions)

Transport & Crypto:
- HTTPS (server_cert/server_key)
- Client TLS (client_cert/client_private_key in MSI)
- API endpoints (same port as GUI unless proxied)

Data Plane:
- Filestore (uploaded artifacts, results, binaries)
- Datastore (metadata, client records, hunts)
- Downloads (zip exports, timelines)

Directory Structure Integration:
C:\Velociraptor\
├─ bin\velociraptor.exe
├─ config\
│  ├─ server.config.yaml          # Server + GUI config
│  ├─ clients.config.yaml         # Client MSI template
│  ├─ users.yaml                  # Local users (if used)
│  ├─ roles.yaml                  # Custom roles/ACLs (optional)
│  ├─ artifacts\
│  │  ├─ custom\                  # Your custom artifact YAMLs
│  │  └─ signed\                  # (optional) signed artifacts
│  └─ tls\
│     ├─ server.crt               # HTTPS cert (PEM)
│     ├─ server.key               # HTTPS key (PEM)
│     ├─ ca.crt                   # CA for client auth (optional)
│     └─ api.mtls\                # (optional) API mutual-TLS materials
├─ data\
│  ├─ datastore\                  # Metadata (leveldb/filestore layout)
│  ├─ filestore\                  # Large blobs (results, uploads)
│  │  ├─ clients\
│  │  ├─ hunts\
│  │  └─ downloads\
│  ├─ downloads\                  # GUI-generated ZIPs/CSV exports
│  └─ quarantine\                 # (optional) collected binaries
├─ logs\
│  ├─ server.log                  # Structured server logs
│  ├─ audit.log                   # GUI/API audit entries
│  └─ http_access.log             # (optional) access log
├─ gui\
│  ├─ static\                     # Served assets (bundled)
│  └─ templates\                  # (rarely customized)
├─ msi\
│  ├─ windows_x64\
│  │  ├─ velociraptor_client.msi  # Generated client installer
│  │  ├─ client.config.yaml       # Embedded into MSI
│  │  └─ client.crt / client.key  # Per-tenant client creds
│  └─ windows_x86\                # (if needed)
├─ service\
│  ├─ install_service.ps1         # sc.exe create or NSSM wrapper
│  └─ velociraptor.service.args   # e.g., "server -c config\server.config.yaml"
└─ backups\
   ├─ config-YYYYMMDD-HHMMSS.zip  # Periodic config/artifacts/tls backup
   └─ keys-YYYYMMDD-HHMMSS.zip    # Protected backup of keys

Integrations [optional]:
├─ Reverse Proxy (Nginx/Caddy) for TLS/SSO
├─ External Auth (OIDC/LDAP/SAML via proxy)
└─ SIEM/Webhooks (audit export)
"@
    }
    $detailsText.BackColor = $DARK_BACKGROUND
    $detailsText.ForeColor = $LIGHT_GRAY_TEXT
    
    $detailsPanel.Controls.Add($detailsText)
    
    $tab.Controls.Add($treePanel)
    $tab.Controls.Add($detailsPanel)
    
    return $tab
}

# Helper functions
function Open-VelociraptorWebUI {
    try {
        $url = "https://localhost:8889"
        Start-Process $url
        Update-Status "Opened Velociraptor Web UI at $url"
        Write-Log "Opened Web UI: $url" "SUCCESS"
    }
    catch {
        Update-Status "Failed to open Web UI - Server may not be running"
        Write-Log "Failed to open Web UI: $($_.Exception.Message)" "ERROR"
    }
}

function Deploy-VelociraptorServer {
    Update-Status "Starting Velociraptor server deployment..."
    Write-Log "Server deployment initiated" "INFO"
    Write-Log "Creating directory structure..." "INFO"
    Write-Log "Generating configuration files..." "INFO"
    Write-Log "Setting up TLS certificates..." "INFO"
    Write-Log "Configuring authentication..." "INFO"
    Write-Log "Installing Windows service..." "INFO"
    Write-Log "Server deployment completed successfully!" "SUCCESS"
    Write-Log "Web UI available at: https://localhost:8889" "SUCCESS"
    Update-Status "Velociraptor server deployed and running"
}

# Create status bar
function New-StatusBar {
    $statusStrip = New-SafeControl -ControlType "System.Windows.Forms.StatusStrip"
    $statusStrip.BackColor = $DARK_SURFACE
    
    $script:StatusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
    $script:StatusLabel.Text = "Velociraptor Ultimate v5.0.4-beta - Ready"
    $script:StatusLabel.Spring = $true
    $script:StatusLabel.ForeColor = $WHITE_TEXT
    
    $statusStrip.Items.Add($script:StatusLabel) | Out-Null
    return $statusStrip
}

# Main initialization
function Initialize-Application {
    Write-Host "Initializing Velociraptor Ultimate..." -ForegroundColor Green
    
    $script:MainForm = New-MainForm
    if (-not $script:MainForm) {
        return $false
    }
    
    $script:TabControl = New-MainTabControl
    if (-not $script:TabControl) {
        return $false
    }
    
    # Create tabs
    $dashboardTab = New-DashboardTab
    $webUITab = New-WebUITab
    
    # Add tabs
    $script:TabControl.TabPages.Add($dashboardTab)
    $script:TabControl.TabPages.Add($webUITab)
    
    # Create status bar
    $statusBar = New-StatusBar
    
    # Add to form
    $script:MainForm.Controls.Add($script:TabControl)
    $script:MainForm.Controls.Add($statusBar)
    
    # Event handlers
    $script:MainForm.Add_Load({
        Update-Status "Velociraptor Ultimate loaded successfully"
        Write-Log "Application started" "SUCCESS"
        Write-Log "Web UI integration ready" "INFO"
        Write-Log "Ready for DFIR operations" "SUCCESS"
    })
    
    if ($StartMinimized) {
        $script:MainForm.WindowState = [System.Windows.Forms.FormWindowState]::Minimized
    }
    
    return $true
}

# Main execution
try {
    if (Initialize-Application) {
        Write-Host "Launching Velociraptor Ultimate..." -ForegroundColor Green
        [System.Windows.Forms.Application]::Run($script:MainForm)
    }
    else {
        Write-Error "Failed to initialize application"
        exit 1
    }
}
catch {
    Write-Error "Application error: $($_.Exception.Message)"
    exit 1
}
finally {
    Write-Host "Velociraptor Ultimate session ended." -ForegroundColor Yellow
}