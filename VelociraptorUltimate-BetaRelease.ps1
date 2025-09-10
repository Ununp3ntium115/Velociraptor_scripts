# Velociraptor Ultimate GUI - Beta Release
# Version: 5.0.4-beta
# Following [DEPLOY-SUCCESS] patterns for reliable deployment

#Requires -Version 5.1
#Requires -RunAsAdministrator

param(
    [string]$VelociraptorPath = "C:\tools\velociraptor.exe",
    [int]$DefaultPort = 8889,
    [string]$DefaultUsername = "admin",
    [string]$DefaultPassword = "admin123"
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Global variables for status tracking
$Global:VelociraptorProcess = $null
$Global:DeploymentStatus = "Not Started"
$Global:LastStatusCheck = Get-Date

# Main Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Velociraptor Ultimate - Beta Release v5.0.4"
$form.Size = New-Object System.Drawing.Size(900, 700)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)

# Create TabControl
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Location = New-Object System.Drawing.Point(10, 10)
$tabControl.Size = New-Object System.Drawing.Size(860, 640)
$tabControl.Font = New-Object System.Drawing.Font("Segoe UI", 9)

# Tab 1: Quick Deploy (Following [DEPLOY-SUCCESS])
$tabQuickDeploy = New-Object System.Windows.Forms.TabPage
$tabQuickDeploy.Text = "Quick Deploy"
$tabQuickDeploy.BackColor = [System.Drawing.Color]::White

# Quick Deploy - Title
$lblQuickTitle = New-Object System.Windows.Forms.Label
$lblQuickTitle.Text = "Quick Velociraptor Deployment"
$lblQuickTitle.Location = New-Object System.Drawing.Point(20, 20)
$lblQuickTitle.Size = New-Object System.Drawing.Size(400, 30)
$lblQuickTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$lblQuickTitle.ForeColor = [System.Drawing.Color]::FromArgb(0, 120, 215)

# Quick Deploy - Description
$lblQuickDesc = New-Object System.Windows.Forms.Label
$lblQuickDesc.Text = "Using proven [WORKING-CMD] method: C:\tools\velociraptor.exe gui"
$lblQuickDesc.Location = New-Object System.Drawing.Point(20, 55)
$lblQuickDesc.Size = New-Object System.Drawing.Size(600, 20)
$lblQuickDesc.Font = New-Object System.Drawing.Font("Segoe UI", 9)

# Status Panel
$panelStatus = New-Object System.Windows.Forms.Panel
$panelStatus.Location = New-Object System.Drawing.Point(20, 90)
$panelStatus.Size = New-Object System.Drawing.Size(800, 100)
$panelStatus.BorderStyle = "FixedSingle"
$panelStatus.BackColor = [System.Drawing.Color]::FromArgb(248, 248, 248)

$lblStatusTitle = New-Object System.Windows.Forms.Label
$lblStatusTitle.Text = "Deployment Status"
$lblStatusTitle.Location = New-Object System.Drawing.Point(10, 10)
$lblStatusTitle.Size = New-Object System.Drawing.Size(200, 20)
$lblStatusTitle.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "Ready to deploy"
$lblStatus.Location = New-Object System.Drawing.Point(10, 35)
$lblStatus.Size = New-Object System.Drawing.Size(780, 20)
$lblStatus.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(0, 120, 0)

$lblPortStatus = New-Object System.Windows.Forms.Label
$lblPortStatus.Text = "Port Status: Not checked"
$lblPortStatus.Location = New-Object System.Drawing.Point(10, 60)
$lblPortStatus.Size = New-Object System.Drawing.Size(380, 20)
$lblPortStatus.Font = New-Object System.Drawing.Font("Segoe UI", 9)

$lblProcessStatus = New-Object System.Windows.Forms.Label
$lblProcessStatus.Text = "Process Status: Not running"
$lblProcessStatus.Location = New-Object System.Drawing.Point(400, 60)
$lblProcessStatus.Size = New-Object System.Drawing.Size(380, 20)
$lblProcessStatus.Font = New-Object System.Drawing.Font("Segoe UI", 9)

# Add controls to status panel
$panelStatus.Controls.AddRange(@($lblStatusTitle, $lblStatus, $lblPortStatus, $lblProcessStatus))

# Quick Deploy Button
$btnQuickDeploy = New-Object System.Windows.Forms.Button
$btnQuickDeploy.Text = "🚀 Quick Deploy (Proven Method)"
$btnQuickDeploy.Location = New-Object System.Drawing.Point(20, 210)
$btnQuickDeploy.Size = New-Object System.Drawing.Size(200, 40)
$btnQuickDeploy.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btnQuickDeploy.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$btnQuickDeploy.ForeColor = [System.Drawing.Color]::White
$btnQuickDeploy.FlatStyle = "Flat"

# Status Check Button
$btnStatusCheck = New-Object System.Windows.Forms.Button
$btnStatusCheck.Text = "🔍 Check Status"
$btnStatusCheck.Location = New-Object System.Drawing.Point(240, 210)
$btnStatusCheck.Size = New-Object System.Drawing.Size(120, 40)
$btnStatusCheck.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$btnStatusCheck.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
$btnStatusCheck.ForeColor = [System.Drawing.Color]::White
$btnStatusCheck.FlatStyle = "Flat"

# Stop Service Button
$btnStop = New-Object System.Windows.Forms.Button
$btnStop.Text = "⏹️ Stop Service"
$btnStop.Location = New-Object System.Drawing.Point(380, 210)
$btnStop.Size = New-Object System.Drawing.Size(120, 40)
$btnStop.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$btnStop.BackColor = [System.Drawing.Color]::FromArgb(196, 43, 28)
$btnStop.ForeColor = [System.Drawing.Color]::White
$btnStop.FlatStyle = "Flat"

# Open Web Interface Button
$btnOpenWeb = New-Object System.Windows.Forms.Button
$btnOpenWeb.Text = "🌐 Open Web Interface"
$btnOpenWeb.Location = New-Object System.Drawing.Point(520, 210)
$btnOpenWeb.Size = New-Object System.Drawing.Size(150, 40)
$btnOpenWeb.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$btnOpenWeb.BackColor = [System.Drawing.Color]::FromArgb(16, 124, 16)
$btnOpenWeb.ForeColor = [System.Drawing.Color]::White
$btnOpenWeb.FlatStyle = "Flat"

# Configuration Panel
$panelConfig = New-Object System.Windows.Forms.Panel
$panelConfig.Location = New-Object System.Drawing.Point(20, 270)
$panelConfig.Size = New-Object System.Drawing.Size(800, 120)
$panelConfig.BorderStyle = "FixedSingle"
$panelConfig.BackColor = [System.Drawing.Color]::FromArgb(248, 248, 248)

$lblConfigTitle = New-Object System.Windows.Forms.Label
$lblConfigTitle.Text = "Configuration"
$lblConfigTitle.Location = New-Object System.Drawing.Point(10, 10)
$lblConfigTitle.Size = New-Object System.Drawing.Size(200, 20)
$lblConfigTitle.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)

$lblVelociraptorPath = New-Object System.Windows.Forms.Label
$lblVelociraptorPath.Text = "Velociraptor Path:"
$lblVelociraptorPath.Location = New-Object System.Drawing.Point(10, 40)
$lblVelociraptorPath.Size = New-Object System.Drawing.Size(120, 20)

$tx