# Velociraptor Deployment Success Guide

## Working Deployment Method

Based on successful testing and deployment experience, this document provides the proven approach for getting Velociraptor running quickly and reliably.

### The Simple Working Approach

**CRITICAL SUCCESS FACTOR**: Use Velociraptor's built-in GUI mode without custom configuration files. This allows Velociraptor to generate its own proper configuration automatically.

#### Proven Working Command
```powershell
# This is the command that works reliably
C:\tools\velociraptor.exe gui
```

#### Why This Works
- Velociraptor generates its own temporary configuration with proper certificates
- No complex certificate generation or configuration file management required
- Automatic port binding (default 8889)
- Self-contained and reliable

### Deployment Process

#### Step 1: Basic Setup
1. Ensure Velociraptor binary is available at `C:\tools\velociraptor.exe`
2. Run as Administrator for proper permissions
3. Use the simple GUI command without configuration files

#### Step 2: Launch Command
```powershell
# Launch in elevated PowerShell window
Start-Process PowerShell -ArgumentList "-NoExit", "-Command", "C:\tools\velociraptor.exe gui" -Verb RunAs
```

#### Step 3: Verification
```powershell
# Check if service is running
netstat -an | findstr :8889

# Test web interface accessibility
Invoke-WebRequest -Uri "https://127.0.0.1:8889" -SkipCertificateCheck -UseBasicParsing
```

Expected result: "Not authorized" response (this is correct - means service is running)

### User Management

#### Adding Users After Deployment
Use the provided user management scripts:

1. **Add-VelociraptorUser.ps1** - Simple user addition
2. **Restart-VelociraptorWithUser.ps1** - Full restart with user management

#### Default Credentials
- Username: `admin`
- Password: `admin123`
- URL: `https://127.0.0.1:8889`

### What NOT to Do

#### Avoid Complex Configuration Files
- Don't try to generate custom YAML configurations initially
- Don't manually create certificates
- Don't use complex deployment scripts for basic testing

#### Avoid These Common Pitfalls
- Running without Administrator privileges
- Using custom configuration files before understanding the basics
- Trying to modify certificates or security settings initially
- Using server deployment mode for simple testing

### Troubleshooting

#### If Deployment Fails
1. **Check Administrator Rights**: Must run as Administrator
2. **Check Port Availability**: Ensure port 8889 is not in use
3. **Check Binary Location**: Verify `C:\tools\velociraptor.exe` exists
4. **Use Simple Command**: Fall back to basic `velociraptor.exe gui`

#### Common Error Solutions
- **"Not authorized"**: This is expected - means service is running correctly
- **"Connection refused"**: Service not running - check process and restart
- **"Access denied"**: Run as Administrator
- **"Port in use"**: Kill existing processes or use different port

### Advanced Configuration

#### Only After Basic Success
Once the simple GUI mode is working:
1. Generate proper configuration files
2. Add multiple users
3. Configure SSL certificates
4. Set up service installation
5. Configure advanced security settings

#### Configuration Generation
```powershell
# Generate config only after basic deployment works
velociraptor.exe config generate --config velociraptor-config.yaml
```

### Integration with Existing Scripts

#### Update Deployment Scripts
Modify existing deployment scripts to use this proven approach:

```powershell
# Instead of complex configuration generation, use:
function Start-VelociraptorSimple {
    param([string]$VelociraptorPath = "C:\tools\velociraptor.exe")
    
    Start-Process PowerShell -ArgumentList "-NoExit", "-Command", "& '$VelociraptorPath' gui" -Verb RunAs
}
```

#### GUI Integration
Update GUI applications to use the working deployment method:
- Remove complex configuration generation
- Use simple GUI mode launch
- Add proper status checking
- Include user management tools

### Success Metrics

#### Deployment Success Indicators
1. **Process Running**: `Get-Process | Where-Object {$_.ProcessName -like "*velociraptor*"}`
2. **Port Listening**: `netstat -an | findstr :8889`
3. **Web Response**: HTTP response (even "Not authorized" is success)
4. **GUI Accessible**: Can access web interface at https://127.0.0.1:8889

#### Performance Expectations
- **Startup Time**: Should start within 10-15 seconds
- **Memory Usage**: Typically 70-100MB for basic GUI mode
- **CPU Usage**: Low CPU usage when idle
- **Response Time**: Web interface should respond quickly

### Documentation Updates

#### Update Required Files
Based on this success, update these files:
1. **Main README.md**: Include simple deployment instructions
2. **Deployment Scripts**: Simplify to use working method
3. **GUI Applications**: Update to use proven approach
4. **Test Scripts**: Update to test working deployment method

#### Steering System Integration
- **[DEPLOY-SUCCESS]**: Reference this successful deployment method
- **[SIMPLE-GUI]**: Use for simple GUI deployment references
- **[USER-MGMT]**: Reference user management scripts
- **[TROUBLESHOOT]**: Reference troubleshooting section

This approach has been tested and proven to work reliably, providing a solid foundation for more advanced configurations.