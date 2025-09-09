# Add Velociraptor User Script
param(
    [string]$Username = "admin",
    [string]$Password = "admin123",
    [string]$VelociraptorPath = "C:\tools\velociraptor.exe"
)

Write-Host "Adding Velociraptor user: $Username" -ForegroundColor Green

try {
    # Add user using velociraptor user add command
    $addUserCmd = "& '$VelociraptorPath' --config '' user add '$Username' --password '$Password' --role administrator"
    
    Write-Host "Executing: $addUserCmd" -ForegroundColor Yellow
    
    # Execute the command
    Invoke-Expression $addUserCmd
    
    Write-Host "User '$Username' added successfully!" -ForegroundColor Green
    Write-Host "You can now login with:" -ForegroundColor Cyan
    Write-Host "  Username: $Username" -ForegroundColor White
    Write-Host "  Password: $Password" -ForegroundColor White
    Write-Host "  URL: https://127.0.0.1:8889" -ForegroundColor White
    
} catch {
    Write-Host "Error adding user: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "You may need to stop Velociraptor first, add the user, then restart it." -ForegroundColor Yellow
}