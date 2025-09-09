# Restart Velociraptor with User Management
param(
    [string]$Username = "admin",
    [string]$Password = "admin123",
    [string]$VelociraptorPath = "C:\tools\velociraptor.exe",
    [int]$Port = 8889
)

Write-Host "Restarting Velociraptor with user management..." -ForegroundColor Green

try {
    # Stop existing Velociraptor process
    Write-Host "Stopping existing Velociraptor processes..." -ForegroundColor Yellow
    Get-Process | Where-Object {$_.ProcessName -like "*velociraptor*"} | Stop-Process -Force
    Start-Sleep 3
    
    # Generate a basic config file
    $configPath = "$env:TEMP\velociraptor-config.yaml"
    Write-Host "Generating config at: $configPath" -ForegroundColor Yellow
    
    & $VelociraptorPath config generate --config $configPath
    
    if (Test-Path $configPath) {
        Write-Host "Config generated successfully" -ForegroundColor Green
        
        # Add user to the config
        Write-Host "Adding user: $Username" -ForegroundColor Yellow
        & $VelociraptorPath --config $configPath user add $Username --password $Password --role administrator
        
        # Start Velociraptor with the config
        Write-Host "Starting Velociraptor GUI with config..." -ForegroundColor Green
        Start-Process PowerShell -ArgumentList "-NoExit", "-Command", "& '$VelociraptorPath' --config '$configPath' gui --bind 127.0.0.1 --port $Port" -Verb RunAs
        
        Start-Sleep 5
        Write-Host "Velociraptor should be starting..." -ForegroundColor Green
        Write-Host "Login details:" -ForegroundColor Cyan
        Write-Host "  URL: https://127.0.0.1:$Port" -ForegroundColor White
        Write-Host "  Username: $Username" -ForegroundColor White
        Write-Host "  Password: $Password" -ForegroundColor White
        
    } else {
        Write-Host "Failed to generate config file" -ForegroundColor Red
    }
    
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}