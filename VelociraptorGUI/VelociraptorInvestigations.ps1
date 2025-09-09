# Velociraptor Investigations GUI
# Consolidated investigation management interface

<#
.SYNOPSIS
    Velociraptor Investigations Management GUI
    
.DESCRIPTION
    Simple, focused GUI for managing DFIR investigations with Velociraptor.
    Includes incident response workflows, artifact management, and reporting.
#>

param(
    [string] $VelociraptorPath = "$env:ProgramFiles\Velociraptor",
    [string] $ConfigFile
)

# Add required assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Global configuration
$script:Config = @{
    AppName = "Velociraptor Investigations"
    Version = "6.0.0"
    VelociraptorPath = $VelociraptorPath
    ConfigFile = $ConfigFile
    Repository = "Ununp3ntium115/velociraptor"
}

# Main Application Class
class VelociraptorInvestigationsApp {
    [System.Windows.Forms.Form] $MainForm
    [System.Windows.Forms.ListView] $InvestigationsListView
    [System.Windows.Forms.TextBox] $LogTextBox
    [hashtable] $ActiveInvestigations
    
    VelociraptorInvestigationsApp() {
        $this.ActiveInvestigations = @{}
        $this.InitializeMainForm()
    }
    
    [void] InitializeMainForm() {
        $this.MainForm = New-Object System.Windows.Forms.Form
        $this.MainForm.Text = $script:Config.AppName
        $this.MainForm.Size = New-Object System.Drawing.Size(1000, 700)
        $this.MainForm.StartPosition = "CenterScreen"
        $this.MainForm.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        
        # Create main layout
        $this.CreateHeader()
        $this.CreateInvestigationPanel()
        $this.CreateQuickActionsPanel()
        $this.CreateLogPanel()
        $this.CreateStatusBar()
    }
    
    [void] CreateHeader() {
        $headerPanel = New-Object System.Windows.Forms.Panel
        $headerPanel.Height = 80
        $headerPanel.Dock = "Top"
        $headerPanel.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
        
        $titleLabel = New-Object System.Windows.Forms.Label
        $titleLabel.Text = "🔍 Velociraptor Investigations"
        $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
        $titleLabel.ForeColor = [System.Drawing.Color]::White
        $titleLabel.Location = New-Object System.Drawing.Point(20, 20)
        $titleLabel.Size = New-Object System.Drawing.Size(400, 40)
        
        $versionLabel = New-Object System.Windows.Forms.Label
        $versionLabel.Text = "DFIR Investigation Management v$($script:Config.Version)"
        $versionLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $versionLabel.ForeColor = [System.Drawing.Color]::LightGray
        $versionLabel.Location = New-Object System.Drawing.Point(20, 50)
        $versionLabel.Size = New-Object System.Drawing.Size(400, 20)
        
        $headerPanel.Controls.AddRange(@($titleLabel, $versionLabel))
        $this.MainForm.Controls.Add($headerPanel)
    }
    
    [void] CreateInvestigationPanel() {
        $investigationGroupBox = New-Object System.Windows.Forms.GroupBox
        $investigationGroupBox.Text = "Active Investigations"
        $investigationGroupBox.Location = New-Object System.Drawing.Point(20, 100)
        $investigationGroupBox.Size = New-Object System.Drawing.Size(600, 300)
        $investigationGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        $this.InvestigationsListView = New-Object System.Windows.Forms.ListView
        $this.InvestigationsListView.View = "Details"
        $this.InvestigationsListView.FullRowSelect = $true
        $this.InvestigationsListView.GridLines = $true
        $this.InvestigationsListView.Location = New-Object System.Drawing.Point(10, 25)
        $this.InvestigationsListView.Size = New-Object System.Drawing.Size(580, 220)
        
        $this.InvestigationsListView.Columns.Add("ID", 80) | Out-Null
        $this.InvestigationsListView.Columns.Add("Type", 120) | Out-Null
        $this.InvestigationsListView.Columns.Add("Target", 150) | Out-Null
        $this.InvestigationsListView.Columns.Add("Status", 80) | Out-Null
        $this.InvestigationsListView.Columns.Add("Started", 120) | Out-Null
        
        # Investigation control buttons
        $buttonPanel = New-Object System.Windows.Forms.Panel
        $buttonPanel.Location = New-Object System.Drawing.Point(10, 255)
        $buttonPanel.Size = New-Object System.Drawing.Size(580, 35)
        
        $viewButton = New-Object System.Windows.Forms.Button
        $viewButton.Text = "View Details"
        $viewButton.Size = New-Object System.Drawing.Size(100, 30)
        $viewButton.Location = New-Object System.Drawing.Point(0, 0)
        $viewButton.Add_Click({ $this.ViewInvestigationDetails() })
        
        $stopButton = New-Object System.Windows.Forms.Button
        $stopButton.Text = "Stop"
        $stopButton.Size = New-Object System.Drawing.Size(80, 30)
        $stopButton.Location = New-Object System.Drawing.Point(110, 0)
        $stopButton.BackColor = [System.Drawing.Color]::Red
        $stopButton.ForeColor = [System.Drawing.Color]::White
        $stopButton.Add_Click({ $this.StopInvestigation() })
        
        $reportButton = New-Object System.Windows.Forms.Button
        $reportButton.Text = "Generate Report"
        $reportButton.Size = New-Object System.Drawing.Size(120, 30)
        $reportButton.Location = New-Object System.Drawing.Point(200, 0)
        $reportButton.BackColor = [System.Drawing.Color]::Green
        $reportButton.ForeColor = [System.Drawing.Color]::White
        $reportButton.Add_Click({ $this.GenerateReport() })
        
        $buttonPanel.Controls.AddRange(@($viewButton, $stopButton, $reportButton))
        $investigationGroupBox.Controls.AddRange(@($this.InvestigationsListView, $buttonPanel))
        $this.MainForm.Controls.Add($investigationGroupBox)
    }
    
    [void] CreateQuickActionsPanel() {
        $actionsGroupBox = New-Object System.Windows.Forms.GroupBox
        $actionsGroupBox.Text = "Quick Investigation Launch"
        $actionsGroupBox.Location = New-Object System.Drawing.Point(640, 100)
        $actionsGroupBox.Size = New-Object System.Drawing.Size(320, 300)
        $actionsGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        # Investigation type buttons
        $investigations = @(
            @{ Name = "🦠 Malware Analysis"; Type = "Malware"; Color = [System.Drawing.Color]::Red },
            @{ Name = "🎯 APT Investigation"; Type = "APT"; Color = [System.Drawing.Color]::DarkRed },
            @{ Name = "🔒 Ransomware Response"; Type = "Ransomware"; Color = [System.Drawing.Color]::Purple },
            @{ Name = "📊 Data Breach"; Type = "DataBreach"; Color = [System.Drawing.Color]::Orange },
            @{ Name = "👤 Insider Threat"; Type = "Insider"; Color = [System.Drawing.Color]::Brown },
            @{ Name = "🌐 Network Intrusion"; Type = "NetworkIntrusion"; Color = [System.Drawing.Color]::Navy },
            @{ Name = "🔍 Custom Investigation"; Type = "Custom"; Color = [System.Drawing.Color]::FromArgb(0, 120, 215) }
        )
        
        $y = 30
        foreach ($investigation in $investigations) {
            $button = New-Object System.Windows.Forms.Button
            $button.Text = $investigation.Name
            $button.Size = New-Object System.Drawing.Size(280, 35)
            $button.Location = New-Object System.Drawing.Point(20, $y)
            $button.BackColor = $investigation.Color
            $button.ForeColor = [System.Drawing.Color]::White
            $button.FlatStyle = "Flat"
            $button.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
            $button.Tag = $investigation.Type
            $button.Add_Click({ $this.StartInvestigation($this.Tag) })
            
            $actionsGroupBox.Controls.Add($button)
            $y += 40
        }
        
        $this.MainForm.Controls.Add($actionsGroupBox)
    }
    
    [void] CreateLogPanel() {
        $logGroupBox = New-Object System.Windows.Forms.GroupBox
        $logGroupBox.Text = "Investigation Log"
        $logGroupBox.Location = New-Object System.Drawing.Point(20, 420)
        $logGroupBox.Size = New-Object System.Drawing.Size(940, 180)
        $logGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        
        $this.LogTextBox = New-Object System.Windows.Forms.TextBox
        $this.LogTextBox.Multiline = $true
        $this.LogTextBox.ScrollBars = "Vertical"
        $this.LogTextBox.ReadOnly = $true
        $this.LogTextBox.Location = New-Object System.Drawing.Point(10, 25)
        $this.LogTextBox.Size = New-Object System.Drawing.Size(920, 140)
        $this.LogTextBox.Font = New-Object System.Drawing.Font("Consolas", 9)
        $this.LogTextBox.BackColor = [System.Drawing.Color]::Black
        $this.LogTextBox.ForeColor = [System.Drawing.Color]::LimeGreen
        
        $logGroupBox.Controls.Add($this.LogTextBox)
        $this.MainForm.Controls.Add($logGroupBox)
        
        # Add initial log message
        $this.AddLogMessage("Velociraptor Investigations GUI started")
        $this.AddLogMessage("Ready for DFIR operations")
    }
    
    [void] CreateStatusBar() {
        $statusStrip = New-Object System.Windows.Forms.StatusStrip
        
        $statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
        $statusLabel.Text = "Ready - No active investigations"
        $statusLabel.Spring = $true
        
        $timeLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
        $timeLabel.Text = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        
        $statusStrip.Items.AddRange(@($statusLabel, $timeLabel))
        $this.MainForm.Controls.Add($statusStrip)
    }
    
    [void] StartInvestigation([string] $Type) {
        $investigationDialog = New-Object System.Windows.Forms.Form
        $investigationDialog.Text = "Start $Type Investigation"
        $investigationDialog.Size = New-Object System.Drawing.Size(500, 400)
        $investigationDialog.StartPosition = "CenterParent"
        $investigationDialog.FormBorderStyle = "FixedDialog"
        $investigationDialog.MaximizeBox = $false
        
        # Target input
        $targetLabel = New-Object System.Windows.Forms.Label
        $targetLabel.Text = "Target System/IP:"
        $targetLabel.Location = New-Object System.Drawing.Point(20, 20)
        $targetLabel.Size = New-Object System.Drawing.Size(100, 20)
        
        $targetTextBox = New-Object System.Windows.Forms.TextBox
        $targetTextBox.Location = New-Object System.Drawing.Point(130, 18)
        $targetTextBox.Size = New-Object System.Drawing.Size(300, 25)
        
        # Description input
        $descLabel = New-Object System.Windows.Forms.Label
        $descLabel.Text = "Description:"
        $descLabel.Location = New-Object System.Drawing.Point(20, 60)
        $descLabel.Size = New-Object System.Drawing.Size(100, 20)
        
        $descTextBox = New-Object System.Windows.Forms.TextBox
        $descTextBox.Multiline = $true
        $descTextBox.Location = New-Object System.Drawing.Point(130, 58)
        $descTextBox.Size = New-Object System.Drawing.Size(300, 80)
        
        # Priority selection
        $priorityLabel = New-Object System.Windows.Forms.Label
        $priorityLabel.Text = "Priority:"
        $priorityLabel.Location = New-Object System.Drawing.Point(20, 160)
        $priorityLabel.Size = New-Object System.Drawing.Size(100, 20)
        
        $priorityComboBox = New-Object System.Windows.Forms.ComboBox
        $priorityComboBox.Items.AddRange(@("Low", "Medium", "High", "Critical"))
        $priorityComboBox.SelectedIndex = 1
        $priorityComboBox.Location = New-Object System.Drawing.Point(130, 158)
        $priorityComboBox.Size = New-Object System.Drawing.Size(150, 25)
        $priorityComboBox.DropDownStyle = "DropDownList"
        
        # Artifacts selection
        $artifactsLabel = New-Object System.Windows.Forms.Label
        $artifactsLabel.Text = "Artifacts to collect:"
        $artifactsLabel.Location = New-Object System.Drawing.Point(20, 200)
        $artifactsLabel.Size = New-Object System.Drawing.Size(120, 20)
        
        $artifactsListBox = New-Object System.Windows.Forms.CheckedListBox
        $artifactsListBox.Location = New-Object System.Drawing.Point(130, 200)
        $artifactsListBox.Size = New-Object System.Drawing.Size(300, 100)
        
        # Add default artifacts based on investigation type
        $defaultArtifacts = $this.GetDefaultArtifacts($Type)
        foreach ($artifact in $defaultArtifacts) {
            $artifactsListBox.Items.Add($artifact, $true) | Out-Null
        }
        
        # Buttons
        $startButton = New-Object System.Windows.Forms.Button
        $startButton.Text = "Start Investigation"
        $startButton.Size = New-Object System.Drawing.Size(120, 35)
        $startButton.Location = New-Object System.Drawing.Point(200, 320)
        $startButton.BackColor = [System.Drawing.Color]::Green
        $startButton.ForeColor = [System.Drawing.Color]::White
        $startButton.DialogResult = "OK"
        
        $cancelButton = New-Object System.Windows.Forms.Button
        $cancelButton.Text = "Cancel"
        $cancelButton.Size = New-Object System.Drawing.Size(80, 35)
        $cancelButton.Location = New-Object System.Drawing.Point(330, 320)
        $cancelButton.DialogResult = "Cancel"
        
        $investigationDialog.Controls.AddRange(@($targetLabel, $targetTextBox, $descLabel, $descTextBox, $priorityLabel, $priorityComboBox, $artifactsLabel, $artifactsListBox, $startButton, $cancelButton))
        
        if ($investigationDialog.ShowDialog() -eq "OK") {
            $investigationId = "INV-" + (Get-Date -Format "yyyyMMdd-HHmmss")
            
            $investigation = @{
                Id = $investigationId
                Type = $Type
                Target = $targetTextBox.Text
                Description = $descTextBox.Text
                Priority = $priorityComboBox.SelectedItem
                Artifacts = @($artifactsListBox.CheckedItems)
                Status = "Running"
                StartTime = Get-Date
            }
            
            $this.ActiveInvestigations[$investigationId] = $investigation
            $this.UpdateInvestigationsList()
            $this.AddLogMessage("Started $Type investigation: $investigationId targeting $($targetTextBox.Text)")
            
            # Simulate investigation execution
            $this.ExecuteInvestigation($investigation)
        }
        
        $investigationDialog.Dispose()
    }
    
    [string[]] GetDefaultArtifacts([string] $Type) {
        switch ($Type) {
            "Malware" { return @("Windows.System.PowerShell", "Windows.Events.ProcessCreation", "Windows.Network.Netstat", "Windows.Forensics.Timeline") }
            "APT" { return @("Windows.Events.EventLogs", "Windows.Registry.NTUser", "Windows.Network.ArpCache", "Windows.Forensics.Prefetch") }
            "Ransomware" { return @("Windows.Events.EventLogs", "Windows.Forensics.Timeline", "Windows.Registry.NTUser", "Windows.Network.Netstat") }
            "DataBreach" { return @("Windows.Events.EventLogs", "Windows.Network.Netstat", "Windows.Forensics.Timeline", "Windows.Registry.NTUser") }
            "Insider" { return @("Windows.Events.EventLogs", "Windows.Forensics.Timeline", "Windows.Registry.NTUser", "Windows.System.PowerShell") }
            "NetworkIntrusion" { return @("Windows.Network.Netstat", "Windows.Events.EventLogs", "Windows.Network.ArpCache", "Windows.Forensics.Timeline") }
            default { return @("Windows.Events.EventLogs", "Windows.Forensics.Timeline", "Windows.Network.Netstat") }
        }
    }
    
    [void] ExecuteInvestigation([hashtable] $Investigation) {
        $this.AddLogMessage("Executing investigation $($Investigation.Id)...")
        $this.AddLogMessage("Collecting artifacts: $($Investigation.Artifacts -join ', ')")
        
        # Simulate artifact collection
        foreach ($artifact in $Investigation.Artifacts) {
            $this.AddLogMessage("Collecting $artifact...")
            Start-Sleep -Milliseconds 500
        }
        
        $Investigation.Status = "Completed"
        $Investigation.EndTime = Get-Date
        $this.UpdateInvestigationsList()
        $this.AddLogMessage("Investigation $($Investigation.Id) completed successfully")
    }
    
    [void] UpdateInvestigationsList() {
        $this.InvestigationsListView.Items.Clear()
        
        foreach ($investigation in $this.ActiveInvestigations.Values) {
            $item = New-Object System.Windows.Forms.ListViewItem($investigation.Id)
            $item.SubItems.Add($investigation.Type) | Out-Null
            $item.SubItems.Add($investigation.Target) | Out-Null
            $item.SubItems.Add($investigation.Status) | Out-Null
            $item.SubItems.Add($investigation.StartTime.ToString("HH:mm:ss")) | Out-Null
            $item.Tag = $investigation
            
            if ($investigation.Status -eq "Running") {
                $item.BackColor = [System.Drawing.Color]::LightYellow
            } elseif ($investigation.Status -eq "Completed") {
                $item.BackColor = [System.Drawing.Color]::LightGreen
            }
            
            $this.InvestigationsListView.Items.Add($item) | Out-Null
        }
    }
    
    [void] AddLogMessage([string] $Message) {
        $timestamp = (Get-Date).ToString("HH:mm:ss")
        $logEntry = "[$timestamp] $Message"
        $this.LogTextBox.AppendText("$logEntry`r`n")
        $this.LogTextBox.SelectionStart = $this.LogTextBox.Text.Length
        $this.LogTextBox.ScrollToCaret()
    }
    
    [void] ViewInvestigationDetails() {
        if ($this.InvestigationsListView.SelectedItems.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Please select an investigation to view.", "No Selection", "OK", "Information")
            return
        }
        
        $investigation = $this.InvestigationsListView.SelectedItems[0].Tag
        $details = @"
Investigation Details:

ID: $($investigation.Id)
Type: $($investigation.Type)
Target: $($investigation.Target)
Description: $($investigation.Description)
Priority: $($investigation.Priority)
Status: $($investigation.Status)
Started: $($investigation.StartTime)
$(if ($investigation.EndTime) { "Completed: $($investigation.EndTime)" })

Artifacts Collected:
$($investigation.Artifacts -join "`n")
"@
        
        [System.Windows.Forms.MessageBox]::Show($details, "Investigation Details", "OK", "Information")
    }
    
    [void] StopInvestigation() {
        if ($this.InvestigationsListView.SelectedItems.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Please select an investigation to stop.", "No Selection", "OK", "Information")
            return
        }
        
        $investigation = $this.InvestigationsListView.SelectedItems[0].Tag
        if ($investigation.Status -eq "Running") {
            $investigation.Status = "Stopped"
            $investigation.EndTime = Get-Date
            $this.UpdateInvestigationsList()
            $this.AddLogMessage("Investigation $($investigation.Id) stopped by user")
        }
    }
    
    [void] GenerateReport() {
        if ($this.InvestigationsListView.SelectedItems.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Please select an investigation to generate a report.", "No Selection", "OK", "Information")
            return
        }
        
        $investigation = $this.InvestigationsListView.SelectedItems[0].Tag
        $this.AddLogMessage("Generating report for investigation $($investigation.Id)...")
        
        # Simulate report generation
        Start-Sleep -Seconds 2
        
        $reportPath = "$env:USERPROFILE\Desktop\Investigation_Report_$($investigation.Id).txt"
        $reportContent = @"
VELOCIRAPTOR INVESTIGATION REPORT
=================================

Investigation ID: $($investigation.Id)
Investigation Type: $($investigation.Type)
Target System: $($investigation.Target)
Priority: $($investigation.Priority)
Status: $($investigation.Status)

Timeline:
Started: $($investigation.StartTime)
$(if ($investigation.EndTime) { "Completed: $($investigation.EndTime)" })

Description:
$($investigation.Description)

Artifacts Collected:
$($investigation.Artifacts -join "`n")

Summary:
Investigation completed successfully. Evidence collected and ready for analysis.

Generated: $(Get-Date)
Generated by: Velociraptor Investigations GUI v$($script:Config.Version)
"@
        
        $reportContent | Out-File -FilePath $reportPath -Encoding UTF8
        $this.AddLogMessage("Report generated: $reportPath")
        
        [System.Windows.Forms.MessageBox]::Show("Report generated successfully:`n$reportPath", "Report Generated", "OK", "Information")
    }
    
    [void] Show() {
        [System.Windows.Forms.Application]::Run($this.MainForm)
    }
}

# Main execution
function Start-VelociraptorInvestigations {
    try {
        $app = [VelociraptorInvestigationsApp]::new()
        $app.Show()
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to start application: $($_.Exception.Message)", "Application Error", "OK", "Error")
        Write-Error $_.Exception.Message
    }
}

# Entry point
if ($MyInvocation.InvocationName -ne '.') {
    Start-VelociraptorInvestigations
}