#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Velociraptor Ultimate - Simple Working Version
    
.DESCRIPTION
    Simple GUI that calls the proven working deployment scripts directly
    instead of trying to replicate their complex logic.
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

# Simple deployment functions that call the working scripts
function Deploy-ServerUsingScript {
    try {
        $serverScript = Join-Path $PSScriptRoot "Deploy_Velociraptor_Server.ps1"
        if (Test-Path $serverScript) {
            Write-Log "Launching proven server deployment script..." "INFO"
            Update-Status "Starting server deployment using proven script..."
            
            # Check if running as administrator
            $currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
            $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
            
            if ($isAdmin) {
                # Launch the working script in a new window
                Start-Process PowerShell -ArgumentList "-NoExit", "-File", "`"$serverScript`""
                
                Write-Log "Server deployment script launched successfully" "SUCCESS"
                Update-Status "Server deployment script running - check the new window"
                
                [System.Windows.Forms.MessageBox]::Show(
                    "Server deployment script launched!`n`nThe proven Deploy_Velociraptor_Server.ps1 script is now running in a separate window.`n`nFollow the prompts in that window to complete the deployment.",
                    "Script Launched",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Information
                )
            } else {
                # Launch as administrator
                Write-Log "Launching server deployment script as Administrator..." "INFO"
                Start-Process PowerShell -ArgumentList "-NoExit", "-File", "`"$serverScript`"" -Verb RunAs
                
                Write-Log "Server deployment script launched as Administrator" "SUCCESS"
                Update-Status "Server deployment script running as Administrator - check the new window"
                
                [System.Windows.Forms.MessageBox]::Show(
                    "Server deployment script launched as Administrator!`n`nThe proven Deploy_Velociraptor_Server.ps1 script is now running in a separate elevated window.`n`nThis is required for service installation and firewall configuration.`n`nFollow the prompts in that window to complete the deployment.",
                    "Script Launched as Administrator",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Information
                )
            }
        } else {
            Write-Log "Server deployment script not found: $serverScript" "ERROR"
            [System.Windows.Forms.MessageBox]::Show(
                "Server deployment script not found!`n`nExpected location: $serverScript`n`nPlease ensure the Deploy_Velociraptor_Server.ps1 script exists.",
                "Script Not Found",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
        }
    }
    catch {
        Write-Log "Failed to launch server deployment script: $($_.Exception.Message)" "ERROR"
        [System.Windows.Forms.MessageBox]::Show(
            "Failed to launch server deployment script: $($_.Exception.Message)",
            "Launch Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
}

function Deploy-StandaloneUsingScript {
    try {
        $standaloneScript = Join-Path $PSScriptRoot "Deploy_Velociraptor_Standalone.ps1"
        if (Test-Path $standaloneScript) {
            Write-Log "Launching proven standalone deployment script..." "INFO"
            Update-Status "Starting standalone deployment using proven script..."
            
            # Launch the working script in a new window
            Start-Process PowerShell -ArgumentList "-NoExit", "-File", "`"$standaloneScript`""
            
            Write-Log "Standalone deployment script launched successfully" "SUCCESS"
            Update-Status "Standalone deployment script running - check the new window"
            
            [System.Windows.Forms.MessageBox]::Show(
                "Standalone deployment script launched!`n`nThe proven Deploy_Velociraptor_Standalone.ps1 script is now running in a separate window.`n`nThis will set up Velociraptor for single-machine investigations.",
                "Script Launched",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            )
        } else {
            Write-Log "Standalone deployment script not found: $standaloneScript" "ERROR"
            [System.Windows.Forms.MessageBox]::Show(
                "Standalone deployment script not found!`n`nExpected location: $standaloneScript`n`nPlease ensure the Deploy_Velociraptor_Standalone.ps1 script exists.",
                "Script Not Found",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
        }
    }
    catch {
        Write-Log "Failed to launch standalone deployment script: $($_.Exception.Message)" "ERROR"
        [System.Windows.Forms.MessageBox]::Show(
            "Failed to launch standalone deployment script: $($_.Exception.Message)",
            "Launch Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
}

function Launch-IncidentPackageGUI {
    try {
        $packageScript = Join-Path $PSScriptRoot "Enhanced-Package-GUI.ps1"
        if (Test-Path $packageScript) {
            Write-Log "Launching incident package GUI..." "INFO"
            Update-Status "Starting incident package management GUI..."
            
            # Launch the package GUI
            Start-Process PowerShell -ArgumentList "-NoExit", "-File", "`"$packageScript`""
            
            Write-Log "Incident package GUI launched successfully" "SUCCESS"
            Update-Status "Incident package GUI running"
            
            [System.Windows.Forms.MessageBox]::Show(
                "Incident Package GUI launched!`n`nThe Enhanced-Package-GUI.ps1 is now running in a separate window.`n`nUse it to select and deploy specialized incident response packages.",
                "GUI Launched",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            )
        } else {
            Write-Log "Incident package GUI not found: $packageScript" "ERROR"
            [System.Windows.Forms.MessageBox]::Show(
                "Incident Package GUI not found!`n`nExpected location: $packageScript`n`nPlease ensure the Enhanced-Package-GUI.ps1 script exists.",
                "Script Not Found",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
        }
    }
    catch {
        Write-Log "Failed to launch incident package GUI: $($_.Exception.Message)" "ERROR"
        [System.Windows.Forms.MessageBox]::Show(
            "Failed to launch incident package GUI: $($_.Exception.Message)",
            "Launch Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
}

function Check-VelociraptorStatus {
    try {
        Write-Log "Checking Velociraptor status..." "INFO"
        Update-Status "Checking Velociraptor status..."
        
        $statusInfo = @()
        
        # Check service status
        try {
            $service = Get-Service -Name "Velociraptor" -ErrorAction SilentlyContinue
            if ($service) {
                $statusInfo += "Service Status: $($service.Status)"
                if ($service.Status -eq "Running") {
                    Write-Log "Velociraptor service is running" "SUCCESS"
                } else {
                    Write-Log "Velociraptor service is $($service.Status)" "WARN"
                }
            } else {
                $statusInfo += "Service Status: Not Installed"
                Write-Log "Velociraptor service is not installed" "WARN"
            }
        }
        catch {
            $statusInfo += "Service Status: Cannot check (may need admin privileges)"
            Write-Log "Cannot check service status: $($_.Exception.Message)" "WARN"
        }
        
        # Check port 8889
        try {
            $tcpConnection = Get-NetTCPConnection -LocalPort 8889 -State Listen -ErrorAction SilentlyContinue
            if ($tcpConnection) {
                $statusInfo += "Port 8889: Listening"
                Write-Log "Port 8889 is listening" "SUCCESS"
            } else {
                $statusInfo += "Port 8889: Not Listening"
                Write-Log "Port 8889 is not listening" "WARN"
            }
        }
        catch {
            $statusInfo += "Port 8889: Cannot check"
            Write-Log "Cannot check port status: $($_.Exception.Message)" "WARN"
        }
        
        # Check processes
        $veloProcesses = Get-Process | Where-Object {$_.ProcessName -like "*velociraptor*"}
        if ($veloProcesses) {
            $statusInfo += "Processes: $($veloProcesses.Count) Velociraptor process(es) running"
            Write-Log "Found $($veloProcesses.Count) Velociraptor process(es)" "SUCCESS"
        } else {
            $statusInfo += "Processes: No Velociraptor processes found"
            Write-Log "No Velociraptor processes found" "WARN"
        }
        
        # Check web interface
        try {
            $webTest = Invoke-WebRequest -Uri "https://127.0.0.1:8889" -SkipCertificateCheck -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
            $statusInfo += "Web Interface: Accessible (HTTP $($webTest.StatusCode))"
            Write-Log "Web interface is accessible" "SUCCESS"
        }
        catch {
            $statusInfo += "Web Interface: Not Accessible"
            Write-Log "Web interface is not accessible" "WARN"
        }
        
        # Show status dialog
        $statusMessage = "VELOCIRAPTOR STATUS CHECK`n`n" + ($statusInfo -join "`n")
        
        [System.Windows.Forms.MessageBox]::Show(
            $statusMessage,
            "Velociraptor Status",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
        
        Update-Status "Status check completed"
        
    }
    catch {
        Write-Log "Status check failed: $($_.Exception.Message)" "ERROR"
        [System.Windows.Forms.MessageBox]::Show(
            "Status check failed: $($_.Exception.Message)",
            "Status Check Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
}

function Open-WebUI {
    try {
        # Check if Velociraptor service is running first
        $serviceRunning = $false
        try {
            $service = Get-Service -Name "Velociraptor" -ErrorAction SilentlyContinue
            if ($service -and $service.Status -eq "Running") {
                $serviceRunning = $true
                Write-Log "Velociraptor service is running" "SUCCESS"
            }
        }
        catch {
            # Service doesn't exist or can't be queried
        }
        
        # Check if port 8889 is listening
        $portListening = $false
        try {
            $tcpConnection = Get-NetTCPConnection -LocalPort 8889 -State Listen -ErrorAction SilentlyContinue
            if ($tcpConnection) {
                $portListening = $true
                Write-Log "Port 8889 is listening" "SUCCESS"
            }
        }
        catch {
            # Port not listening
        }
        
        if ($serviceRunning -or $portListening) {
            # Try common Velociraptor web UI URLs
            $urls = @(
                "https://localhost:8889",
                "https://127.0.0.1:8889",
                "http://localhost:8889",
                "http://127.0.0.1:8889"
            )
            
            $opened = $false
            foreach ($url in $urls) {
                try {
                    Start-Process $url
                    Write-Log "Opened Web UI: $url" "SUCCESS"
                    Update-Status "Web UI opened: $url"
                    $opened = $true
                    break
                }
                catch {
                    continue
                }
            }
            
            if (-not $opened) {
                Write-Log "Could not open browser, but service appears to be running" "WARN"
                [System.Windows.Forms.MessageBox]::Show(
                    "Velociraptor appears to be running, but could not open browser automatically.`n`nTry manually opening:`n- https://localhost:8889`n- http://localhost:8889",
                    "Web UI Access",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Information
                )
            }
        } else {
            Write-Log "Velociraptor service is not running" "WARN"
            [System.Windows.Forms.MessageBox]::Show(
                "Velociraptor is not currently running.`n`nPlease deploy a server or standalone setup first using the buttons above.`n`nService Status: Not Running`nPort 8889: Not Listening",
                "Velociraptor Not Running",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )
        }
    }
    catch {
        Write-Log "Failed to check Velociraptor status: $($_.Exception.Message)" "ERROR"
    }
}

# Create main form
function New-MainForm {
    $form = New-SafeControl -ControlType "System.Windows.Forms.Form" -Properties @{
        Text = "Velociraptor Ultimate - Simple Working Version v5.0.4-beta"
        Size = New-Object System.Drawing.Size(1400, 900)
        StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
        MinimumSize = New-Object System.Drawing.Size(1000, 700)
    }
    $form.BackColor = $DARK_BACKGROUND
    return $form
}

# Create main interface
function New-MainInterface {
    # Header
    $headerLabel = New-SafeControl -ControlType "System.Windows.Forms.Label" -Properties @{
        Text = "VELOCIRAPTOR ULTIMATE - SIMPLE WORKING VERSION"
        Location = New-Object System.Drawing.Point(50, 30)
        Size = New-Object System.Drawing.Size(1200, 40)
        Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
        TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    }
    $headerLabel.ForeColor = $PRIMARY_TEAL
    $headerLabel.BackColor = $DARK_BACKGROUND
    
    # Subtitle
    $subtitleLabel = New-SafeControl -ControlType "System.Windows.Forms.Label" -Properties @{
        Text = "Uses proven working deployment scripts for reliable DFIR platform setup"
        Location = New-Object System.Drawing.Point(50, 80)
        Size = New-Object System.Drawing.Size(1200, 30)
        Font = New-Object System.Drawing.Font("Segoe UI", 12)
        TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    }
    $subtitleLabel.ForeColor = $LIGHT_GRAY_TEXT
    $subtitleLabel.BackColor = $DARK_BACKGROUND
    
    # Main action buttons panel
    $buttonPanel = New-SafeControl -ControlType "System.Windows.Forms.Panel" -Properties @{
        Location = New-Object System.Drawing.Point(50, 140)
        Size = New-Object System.Drawing.Size(1300, 200)
    }
    $buttonPanel.BackColor = $DARK_BACKGROUND
    
    # Server deployment button
    $serverBtn = New-SafeControl -ControlType "System.Windows.Forms.Button" -Properties @{
        Text = "Deploy Velociraptor Server`n(Full Server with Web UI)"
        Location = New-Object System.Drawing.Point(50, 20)
        Size = New-Object System.Drawing.Size(280, 80)
        FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
        Cursor = [System.Windows.Forms.Cursors]::Hand
    }
    $serverBtn.BackColor = $PRIMARY_TEAL
    $serverBtn.ForeColor = $WHITE_TEXT
    $serverBtn.FlatAppearance.BorderSize = 0
    $serverBtn.Add_Click({ Deploy-ServerUsingScript })
    
    # Standalone deployment button
    $standaloneBtn = New-SafeControl -ControlType "System.Windows.Forms.Button" -Properties @{
        Text = "Deploy Standalone Setup`n(Single Machine Investigation)"
        Location = New-Object System.Drawing.Point(350, 20)
        Size = New-Object System.Drawing.Size(280, 80)
        FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
        Cursor = [System.Windows.Forms.Cursors]::Hand
    }
    $standaloneBtn.BackColor = $SUCCESS_GREEN
    $standaloneBtn.ForeColor = $WHITE_TEXT
    $standaloneBtn.FlatAppearance.BorderSize = 0
    $standaloneBtn.Add_Click({ Deploy-StandaloneUsingScript })
    
    # Incident packages button
    $packagesBtn = New-SafeControl -ControlType "System.Windows.Forms.Button" -Properties @{
        Text = "Incident Response Packages`n(Specialized Investigation Tools)"
        Location = New-Object System.Drawing.Point(650, 20)
        Size = New-Object System.Drawing.Size(280, 80)
        FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
        Cursor = [System.Windows.Forms.Cursors]::Hand
    }
    $packagesBtn.BackColor = $WARNING_ORANGE
    $packagesBtn.ForeColor = $WHITE_TEXT
    $packagesBtn.FlatAppearance.BorderSize = 0
    $packagesBtn.Add_Click({ Launch-IncidentPackageGUI })
    
    # Web UI button
    $webUIBtn = New-SafeControl -ControlType "System.Windows.Forms.Button" -Properties @{
        Text = "Open Web UI`n(Access Velociraptor Interface)"
        Location = New-Object System.Drawing.Point(950, 20)
        Size = New-Object System.Drawing.Size(280, 80)
        FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
        Cursor = [System.Windows.Forms.Cursors]::Hand
    }
    $webUIBtn.BackColor = $ERROR_RED
    $webUIBtn.ForeColor = $WHITE_TEXT
    $webUIBtn.FlatAppearance.BorderSize = 0
    $webUIBtn.Add_Click({ Open-WebUI })
    
    # Status check button
    $statusBtn = New-SafeControl -ControlType "System.Windows.Forms.Button" -Properties @{
        Text = "Check Status`n(Monitor Velociraptor)"
        Location = New-Object System.Drawing.Point(50, 120)
        Size = New-Object System.Drawing.Size(280, 50)
        FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        Cursor = [System.Windows.Forms.Cursors]::Hand
    }
    $statusBtn.BackColor = [System.Drawing.Color]::FromArgb(63, 81, 181)
    $statusBtn.ForeColor = $WHITE_TEXT
    $statusBtn.FlatAppearance.BorderSize = 0
    $statusBtn.Add_Click({ Check-VelociraptorStatus })
    
    $buttonPanel.Controls.AddRange(@($serverBtn, $standaloneBtn, $packagesBtn, $webUIBtn, $statusBtn))
    
    # Information panel
    $infoPanel = New-SafeControl -ControlType "System.Windows.Forms.GroupBox" -Properties @{
        Text = "Information & Status"
        Location = New-Object System.Drawing.Point(50, 360)
        Size = New-Object System.Drawing.Size(650, 450)
        Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    }
    $infoPanel.BackColor = $DARK_SURFACE
    $infoPanel.ForeColor = $WHITE_TEXT
    
    $infoText = New-SafeControl -ControlType "System.Windows.Forms.TextBox" -Properties @{
        Location = New-Object System.Drawing.Point(15, 30)
        Size = New-Object System.Drawing.Size(620, 400)
        Multiline = $true
        ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
        Font = New-Object System.Drawing.Font("Consolas", 9)
        ReadOnly = $true
        Text = @"
VELOCIRAPTOR ULTIMATE - SIMPLE WORKING VERSION

This version uses the proven working deployment scripts directly instead of 
trying to replicate their complex logic. This ensures maximum reliability.

AVAILABLE DEPLOYMENTS:

1. VELOCIRAPTOR SERVER (Deploy_Velociraptor_Server.ps1)
   - Full server deployment with web UI
   - Automatic binary download and installation
   - Service installation and configuration
   - Client MSI generation
   - Firewall configuration
   - Web interface at https://localhost:8889
   - REQUIRES ADMINISTRATOR PRIVILEGES (will prompt automatically)

2. STANDALONE SETUP (Deploy_Velociraptor_Standalone.ps1)
   - Single-machine investigation setup
   - Perfect for forensic workstations
   - No server infrastructure required
   - Self-contained evidence collection
   - Quick deployment for immediate use

3. INCIDENT RESPONSE PACKAGES (Enhanced-Package-GUI.ps1)
   - 7 specialized investigation packages
   - APT, Ransomware, Malware, Data Breach, etc.
   - Pre-configured artifact collections
   - Tool dependency management
   - One-click deployment

4. WEB UI ACCESS
   - Direct access to Velociraptor web interface
   - Tries multiple common URLs
   - Works after server deployment

ADVANTAGES OF THIS APPROACH:
✓ Uses proven, tested deployment scripts
✓ Maximum reliability and compatibility
✓ All original functionality preserved
✓ Easy troubleshooting and support
✓ No complex GUI logic to debug
✓ Leverages existing documentation

USAGE:
1. Click the deployment type you want
2. Follow the prompts in the new window
3. Use "Open Web UI" after deployment
4. Access full Velociraptor functionality

This approach ensures you get working deployments every time!
"@
    }
    $infoText.BackColor = $DARK_BACKGROUND
    $infoText.ForeColor = $LIGHT_GRAY_TEXT
    
    $infoPanel.Controls.Add($infoText)
    
    # Activity log panel
    $logPanel = New-SafeControl -ControlType "System.Windows.Forms.GroupBox" -Properties @{
        Text = "Activity Log"
        Location = New-Object System.Drawing.Point(720, 360)
        Size = New-Object System.Drawing.Size(630, 450)
        Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    }
    $logPanel.BackColor = $DARK_SURFACE
    $logPanel.ForeColor = $WHITE_TEXT
    
    $script:LogTextBox = New-SafeControl -ControlType "System.Windows.Forms.TextBox" -Properties @{
        Location = New-Object System.Drawing.Point(15, 30)
        Size = New-Object System.Drawing.Size(600, 400)
        Multiline = $true
        ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
        Font = New-Object System.Drawing.Font("Consolas", 9)
        ReadOnly = $true
    }
    $script:LogTextBox.BackColor = $DARK_BACKGROUND
    $script:LogTextBox.ForeColor = $LIGHT_GRAY_TEXT
    
    $logPanel.Controls.Add($script:LogTextBox)
    
    return @($headerLabel, $subtitleLabel, $buttonPanel, $infoPanel, $logPanel)
}

# Create status bar
function New-StatusBar {
    $statusStrip = New-SafeControl -ControlType "System.Windows.Forms.StatusStrip"
    $statusStrip.BackColor = $DARK_SURFACE
    
    $script:StatusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
    $script:StatusLabel.Text = "Velociraptor Ultimate - Simple Working Version - Ready"
    $script:StatusLabel.Spring = $true
    $script:StatusLabel.ForeColor = $WHITE_TEXT
    
    $statusStrip.Items.Add($script:StatusLabel) | Out-Null
    return $statusStrip
}

# Main initialization
function Initialize-Application {
    Write-Host "Initializing Velociraptor Ultimate - Simple Working Version..." -ForegroundColor Green
    
    $script:MainForm = New-MainForm
    if (-not $script:MainForm) {
        return $false
    }
    
    # Create interface elements
    $controls = New-MainInterface
    foreach ($control in $controls) {
        $script:MainForm.Controls.Add($control)
    }
    
    # Create status bar
    $statusBar = New-StatusBar
    $script:MainForm.Controls.Add($statusBar)
    
    # Event handlers
    $script:MainForm.Add_Load({
        Update-Status "Velociraptor Ultimate - Simple Working Version loaded"
        Write-Log "Application started - using proven deployment scripts" "SUCCESS"
        Write-Log "Ready to launch working deployment scripts" "SUCCESS"
    })
    
    if ($StartMinimized) {
        $script:MainForm.WindowState = [System.Windows.Forms.FormWindowState]::Minimized
    }
    
    return $true
}

# Main execution
try {
    if (Initialize-Application) {
        Write-Host "Launching Velociraptor Ultimate - Simple Working Version..." -ForegroundColor Green
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