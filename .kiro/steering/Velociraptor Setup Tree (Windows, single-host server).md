Setup Velociraptor
├─ 1. Binary Acquisition
│  └─ Download velociraptor.exe (release build)
├─ 2. Initial Configuration
│  ├─ Run: velociraptor.exe config generate
│  │  ├─ server.config.yaml      # Main server + GUI config
│  │  └─ client.config.yaml      # Template for MSI clients
│  └─ Place configs under: config\
├─ 3. TLS / Certificates
│  ├─ server.crt / server.key    # HTTPS for GUI/API
│  ├─ ca.crt                     # CA for client MSI validation
│  └─ config\tls\                # Store certs/keys
├─ 4. User & Auth Setup
│  ├─ users.yaml                 # Local accounts (if basic auth)
│  ├─ roles.yaml                 # (optional) custom RBAC roles
│  └─ Reference in server.config.yaml
├─ 5. Data & Storage Layout
│  ├─ data\datastore\            # Metadata
│  ├─ data\filestore\            # Hunt & flow results
│  └─ data\downloads\            # GUI exports
├─ 6. Service/Daemon Setup
│  ├─ service\install_service.ps1   # Register Windows service
│  └─ velociraptor.service.args     # "server -c config\server.config.yaml"
├─ 7. GUI Access
│  ├─ Default port: 8889
│  ├─ URL: https://<server>:8889
│  └─ Login: user from users.yaml / configured provider
└─ 8. Client Installer Generation
   ├─ Run: velociraptor.exe config repack --msi
   │  ├─ embeds client.config.yaml
   │  ├─ includes CA cert
   │  └─ outputs velociraptor_client.msi under msi\
   └─ Deploy MSI to endpoints
# Velociraptor Setup Tree (Windows, Single-Host Server)

## Directory Structure for Windows Single-Host Deployment

This document outlines the recommended directory structure for a Windows single-host Velociraptor server deployment following [DEPLOY-SUCCESS] patterns.

### Recommended Installation Structure

```
C:\Velociraptor\
├── bin\
│   ├── velociraptor.exe                    # Main Velociraptor binary
│   └── version.txt                         # Version tracking
├── config\
│   ├── server.config.yaml                 # Server configuration
│   ├── client.config.yaml                 # Client configuration template
│   └── backup\                            # Configuration backups
│       ├── server.config.yaml.bak
│       └── client.config.yaml.bak
├── data\
│   ├── clients\                           # Client data storage
│   ├── hunts\                             # Hunt results
│   ├── artifacts\                         # Custom artifacts
│   ├── notebooks\                         # Jupyter notebooks
│   └── uploads\                           # File uploads
├── logs\
│   ├── server.log                         # Server logs
│   ├── access.log                         # Access logs
│   └── audit.log                          # Audit logs
├── certs\
│   ├── server.pem                         # Server certificate
│   ├── server.key                         # Server private key
│   ├── ca.pem                             # Certificate Authority
│   └── client.pem                         # Client certificate template
├── tools\
│   ├── collectors\                        # Offline collectors
│   ├── artifacts\                         # Third-party tools
│   └── scripts\                           # Helper scripts
└── backup\
    ├── daily\                             # Daily backups
    ├── weekly\                            # Weekly backups
    └── config\                            # Configuration snapshots
```

### Alternative Simple Structure (Recommended for [SIMPLE-GUI])

```
C:\tools\
├── velociraptor.exe                       # Single binary deployment
└── temp\                                  # Temporary files (auto-generated)
    ├── server.config.yaml                # Auto-generated config
    ├── server.pem                        # Auto-generated cert
    ├── server.key                        # Auto-generated key
    └── datastore\                        # Auto-generated datastore
```

### Service Installation Structure

```
C:\Program Files\Velociraptor\
├── velociraptor.exe                       # Service binary
├── server.config.yaml                    # Service configuration
└── service.log                           # Service logs

C:\ProgramData\Velociraptor\
├── datastore\                            # Service datastore
├── logs\                                 # Service logs
└── temp\                                 # Temporary files
```

### User Data Locations

```
%USERPROFILE%\.velociraptor\
├── client.config.yaml                    # User client config
├── cache\                                # Client cache
└── logs\                                 # Client logs

%APPDATA%\Velociraptor\
├── gui-settings.json                     # GUI preferences
├── bookmarks.json                        # Saved bookmarks
└── recent.json                           # Recent activities
```

### Deployment-Specific Structures

#### Development/Testing Structure
```
D:\VelociraptorDev\
├── velociraptor.exe                       # Development binary
├── test-config.yaml                      # Test configuration
├── test-data\                            # Test data
└── logs\                                 # Development logs
```

#### Production Structure
```
C:\Velociraptor\Production\
├── bin\velociraptor.exe                  # Production binary
├── config\server.config.yaml            # Production config
├── data\                                 # Production datastore
├── logs\                                 # Production logs
├── backup\                               # Automated backups
└── monitoring\                           # Health monitoring
```

### Permissions and Security

#### Directory Permissions
- **C:\Velociraptor\**: Full control for Administrators, Read for Users
- **C:\Velociraptor\config\**: Full control for Administrators only
- **C:\Velociraptor\certs\**: Full control for Administrators only
- **C:\Velociraptor\data\**: Full control for Velociraptor service account
- **C:\Velociraptor\logs\**: Modify for Velociraptor service account

#### File Permissions
- **velociraptor.exe**: Execute for Users, Full control for Administrators
- **server.config.yaml**: Read for service account, Full control for Administrators
- **Certificate files**: Read for service account, Full control for Administrators

### Setup Commands

#### Create Directory Structure
```powershell
# Create main directories
New-Item -ItemType Directory -Path "C:\Velociraptor" -Force
New-Item -ItemType Directory -Path "C:\Velociraptor\bin" -Force
New-Item -ItemType Directory -Path "C:\Velociraptor\config" -Force
New-Item -ItemType Directory -Path "C:\Velociraptor\data" -Force
New-Item -ItemType Directory -Path "C:\Velociraptor\logs" -Force
New-Item -ItemType Directory -Path "C:\Velociraptor\certs" -Force
New-Item -ItemType Directory -Path "C:\Velociraptor\backup" -Force

# Set permissions
icacls "C:\Velociraptor\config" /grant "Administrators:F" /inheritance:r
icacls "C:\Velociraptor\certs" /grant "Administrators:F" /inheritance:r
```

#### Simple Setup (Following [WORKING-CMD])
```powershell
# Simple setup - just ensure binary location
New-Item -ItemType Directory -Path "C:\tools" -Force
# Copy velociraptor.exe to C:\tools\
# Run: C:\tools\velociraptor.exe gui
```

### Backup Strategy

#### Configuration Backup
```powershell
# Backup configuration files
Copy-Item "C:\Velociraptor\config\*.yaml" "C:\Velociraptor\backup\config\" -Force
```

#### Data Backup
```powershell
# Backup datastore (stop service first)
Stop-Service "Velociraptor"
Copy-Item "C:\Velociraptor\data" "C:\Velociraptor\backup\data-$(Get-Date -Format 'yyyyMMdd')" -Recurse -Force
Start-Service "Velociraptor"
```

### Monitoring and Maintenance

#### Log Rotation
- Configure log rotation for server.log, access.log, audit.log
- Implement automated cleanup of old log files
- Monitor disk space usage

#### Health Checks
```powershell
# Check service status
Get-Service "Velociraptor"

# Check port binding
netstat -an | findstr :8889

# Check log files for errors
Get-Content "C:\Velociraptor\logs\server.log" -Tail 50 | Where-Object {$_ -like "*ERROR*"}
```

### Integration with [DEPLOY-SUCCESS]

#### Simple Deployment Path
1. Create `C:\tools\` directory
2. Place `velociraptor.exe` in `C:\tools\`
3. Run `C:\tools\velociraptor.exe gui` as Administrator
4. Velociraptor auto-generates structure in temp directory

#### Production Deployment Path
1. Create full directory structure
2. Generate proper configuration files
3. Install as Windows service
4. Configure monitoring and backups

This structure supports both [SIMPLE-GUI] deployments and full production installations while maintaining security and operational best practices.