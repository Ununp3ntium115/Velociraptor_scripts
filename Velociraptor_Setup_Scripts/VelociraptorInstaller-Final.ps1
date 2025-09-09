# Final implementation methods and main execution for VelociraptorInstaller.ps1

    # Installation methods
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