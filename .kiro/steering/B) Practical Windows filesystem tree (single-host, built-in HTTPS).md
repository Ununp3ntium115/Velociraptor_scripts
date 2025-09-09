C:\Users\Brody\Velociraptor
├─ bin\
│  └─ velociraptor.exe
├─ config\
│  ├─ server.config.yaml                # Server + GUI config
│  ├─ clients.config.yaml               # Client MSI template
│  ├─ users.yaml                        # Local users (if used)
│  ├─ roles.yaml                        # Custom roles/ACLs (optional)
│  ├─ artifacts\
│  │  ├─ custom\                        # Your custom artifact YAMLs
│  │  └─ signed\                        # (optional) signed artifacts
│  └─ tls\
│     ├─ server.crt                     # HTTPS cert (PEM)
│     ├─ server.key                     # HTTPS key (PEM)
│     ├─ ca.crt                         # CA for client auth (optional)
│     └─ api.mtls\                      # (optional) API mutual-TLS materials
├─ data\
│  ├─ datastore\                        # Metadata (leveldb/filestore layout)
│  ├─ filestore\                        # Large blobs (results, uploads)
│  │  ├─ clients\
│  │  ├─ hunts\
│  │  └─ downloads\
│  ├─ downloads\                        # GUI-generated ZIPs/CSV exports
│  └─ quarantine\                       # (optional) collected binaries
├─ logs\
│  ├─ server.log                        # Structured server logs
│  ├─ audit.log                         # GUI/API audit entries
│  └─ http_access.log                   # (optional) access log
├─ gui\
│  ├─ static\                           # Served assets (bundled)
│  └─ templates\                        # (rarely customized)
├─ msi\
│  ├─ windows_x64\
│  │  ├─ velociraptor_client.msi        # Generated client installer
│  │  ├─ client.config.yaml             # Embedded into MSI
│  │  └─ client.crt / client.key        # Per-tenant client creds
│  └─ windows_x86\                      # (if needed)
├─ service\
│  ├─ install_service.ps1               # sc.exe create or NSSM wrapper
│  └─ velociraptor.service.args         # e.g., "server -c config\server.config.yaml"
└─ backups\
   ├─ config-YYYYMMDD-HHMMSS.zip        # Periodic config/artifacts/tls backup
   └─ keys-YYYYMMDD-HHMMSS.zip          # Protected backup of keys
# Practical Windows Filesystem Tree (Single-Host, Built-in HTTPS)

## Production-Ready Windows Velociraptor Deployment Structure

This document provides a practical filesystem layout for a Windows single-host Velociraptor server with built-in HTTPS, following [DEPLOY-SUCCESS] patterns and production best practices.

### Production Directory Structure

```
C:\Velociraptor\
├── bin\
│   ├── velociraptor.exe                    # Main executable (from [CUSTOM-REPO])
│   ├── velociraptor-backup.exe             # Backup binary for rollback
│   └── version.txt                         # Current version tracking
├── config\
│   ├── server.config.yaml                 # Main server configuration
│   ├── server.config.yaml.template        # Configuration template
│   ├── client.config.yaml                 # Client configuration
│   └── backup\
│       ├── server.config.yaml.$(date)     # Timestamped backups
│       └── client.config.yaml.$(date)
├── certs\
│   ├── server\
│   │   ├── server.pem                     # Server certificate
│   │   ├── server.key                     # Server private key
│   │   └── server.csr                     # Certificate signing request
│   ├── ca\
│   │   ├── ca.pem                         # Certificate Authority
│   │   ├── ca.key                         # CA private key
│   │   └── ca.crl                         # Certificate revocation list
│   ├── gui\
│   │   ├── gui.pem                        # GUI-specific certificate
│   │   └── gui.key                        # GUI private key
│   └── clients\
│       ├── client-template.pem            # Client certificate template
│       └── client-template.key            # Client key template
├── data\
│   ├── datastore\                         # Main datastore
│   │   ├── clients\                       # Client information
│   │   ├── hunts\                         # Hunt data
│   │   ├── flows\                         # Flow executions
│   │   └── artifacts\                     # Artifact results
│   ├── filestore\                         # File storage
│   │   ├── uploads\                       # Uploaded files
│   │   ├── downloads\                     # Downloaded files
│   │   └── monitoring\                    # Monitoring data
│   ├── notebooks\                         # Jupyter notebooks
│   │   ├── users\                         # User notebooks
│   │   └── shared\                        # Shared notebooks
│   └── temp\                              # Temporary files
├── logs\
│   ├── server\
│   │   ├── server.log                     # Main server log
│   │   ├── server-$(date).log             # Rotated logs
│   │   └── error.log                      # Error-specific log
│   ├── gui\
│   │   ├── access.log                     # GUI access log
│   │   ├── auth.log                       # Authentication log
│   │   └── gui-error.log                  # GUI error log
│   ├── audit\
│   │   ├── audit.log                      # Security audit log
│   │   └── compliance.log                 # Compliance logging
│   └── performance\
│       ├── performance.log                # Performance metrics
│       └── health.log                     # Health check logs
├── backup\
│   ├── daily\
│   │   ├── config-$(date).zip             # Daily config backup
│   │   └── datastore-$(date).zip          # Daily data backup
│   ├── weekly\
│   │   └── full-backup-$(date).zip        # Weekly full backup
│   └── scripts\
│       ├── backup.ps1                     # Backup script
│       └── restore.ps1                    # Restore script
├── tools\
│   ├── collectors\
│   │   ├── windows-collector.exe          # Windows offline collector
│   │   ├── linux-collector               # Linux offline collector
│   │   └── macos-collector               # macOS offline collector
│   ├── artifacts\
│   │   ├── custom\                        # Custom artifacts
│   │   ├── third-party\                   # Third-party tools
│   │   └── templates\                     # Artifact templates
│   └── scripts\
│       ├── maintenance.ps1               # Maintenance scripts
│       ├── health-check.ps1              # Health monitoring
│       └── user-management.ps1           # User management
├── monitoring\
│   ├── health\
│   │   ├── status.json                    # Current status
│   │   └── metrics.json                   # Performance metrics
│   ├── alerts\
│   │   ├── alert-config.yaml              # Alert configuration
│   │   └── alert-history.log              # Alert history
│   └── reports\
│       ├── daily-report.html              # Daily status report
│       └── weekly-summary.pdf             # Weekly summary
└── service\
    ├── install-service.ps1                # Service installation script
    ├── uninstall-service.ps1              # Service removal script
    ├── service.log                        # Service-specific log
    └── service-config.xml                 # Service configuration
```

### HTTPS Certificate Structure

#### Self-Signed Certificate Setup
```
C:\Velociraptor\certs\
├── generate-certs.ps1                     # Certificate generation script
├── ca\
│   ├── ca.pem                             # Root CA certificate
│   ├── ca.key                             # Root CA private key
│   └── ca.conf                            # CA configuration
├── server\
│   ├── server.pem                         # Server certificate (includes SAN)
│   ├── server.key                         # Server private key
│   ├── server.conf                        # Server cert configuration
│   └── server.csr                         # Certificate signing request
└── gui\
    ├── gui.pem                            # GUI-specific certificate
    ├── gui.key                            # GUI private key
    └── gui.conf                           # GUI cert configuration
```

#### Certificate Configuration Files

**ca.conf**
```ini
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_ca

[req_distinguished_name]
CN = Velociraptor CA

[v3_ca]
basicConstraints = CA:TRUE
keyUsage = keyCertSign, cRLSign
```

**server.conf**
```ini
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req

[req_distinguished_name]
CN = Velociraptor Server

[v3_req]
basicConstraints = CA:FALSE
keyUsage = keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = velociraptor.local
IP.1 = 127.0.0.1
IP.2 = ::1
```

### Service Installation Structure

#### Windows Service Files
```
C:\Program Files\Velociraptor\
├── velociraptor.exe                       # Service executable
├── server.config.yaml                    # Service configuration
└── service-wrapper.exe                   # Service wrapper (if needed)

C:\ProgramData\Velociraptor\
├── datastore\                            # Service datastore
├── logs\                                 # Service logs
├── temp\                                 # Temporary files
└── cache\                                # Service cache
```

### Security and Permissions

#### Directory Permissions
```powershell
# Set secure permissions
icacls "C:\Velociraptor" /grant "Administrators:F" /inheritance:r
icacls "C:\Velociraptor\config" /grant "Administrators:F" /inheritance:r
icacls "C:\Velociraptor\certs" /grant "Administrators:F" /inheritance:r
icacls "C:\Velociraptor\data" /grant "NT SERVICE\Velociraptor:F" /inheritance:r
icacls "C:\Velociraptor\logs" /grant "NT SERVICE\Velociraptor:M" /inheritance:r
```

#### File Security
- **Certificates**: Read-only for service account, Full control for Administrators
- **Configuration**: Read-only for service account, Full control for Administrators
- **Data**: Full control for service account
- **Logs**: Modify for service account

### Automated Setup Scripts

#### Directory Creation Script
```powershell
# Create-VelociraptorStructure.ps1
$BaseDir = "C:\Velociraptor"
$Directories = @(
    "bin", "config", "config\backup", "certs\server", "certs\ca", "certs\gui", "certs\clients",
    "data\datastore", "data\filestore", "data\notebooks", "data\temp",
    "logs\server", "logs\gui", "logs\audit", "logs\performance",
    "backup\daily", "backup\weekly", "backup\scripts",
    "tools\collectors", "tools\artifacts", "tools\scripts",
    "monitoring\health", "monitoring\alerts", "monitoring\reports",
    "service"
)

foreach ($Dir in $Directories) {
    $FullPath = Join-Path $BaseDir $Dir
    New-Item -ItemType Directory -Path $FullPath -Force
    Write-Host "Created: $FullPath"
}
```

#### Certificate Generation Script
```powershell
# Generate-Certificates.ps1
$CertDir = "C:\Velociraptor\certs"

# Generate CA
openssl genrsa -out "$CertDir\ca\ca.key" 4096
openssl req -new -x509 -days 3650 -key "$CertDir\ca\ca.key" -out "$CertDir\ca\ca.pem" -config "$CertDir\ca\ca.conf"

# Generate Server Certificate
openssl genrsa -out "$CertDir\server\server.key" 2048
openssl req -new -key "$CertDir\server\server.key" -out "$CertDir\server\server.csr" -config "$CertDir\server\server.conf"
openssl x509 -req -in "$CertDir\server\server.csr" -CA "$CertDir\ca\ca.pem" -CAkey "$CertDir\ca\ca.key" -CAcreateserial -out "$CertDir\server\server.pem" -days 365 -extensions v3_req -extfile "$CertDir\server\server.conf"
```

### Backup and Maintenance

#### Automated Backup Script
```powershell
# backup.ps1
$BackupDir = "C:\Velociraptor\backup\daily"
$Date = Get-Date -Format "yyyyMMdd-HHmmss"

# Stop service
Stop-Service "Velociraptor" -Force

# Backup configuration
Compress-Archive -Path "C:\Velociraptor\config\*" -DestinationPath "$BackupDir\config-$Date.zip"

# Backup datastore
Compress-Archive -Path "C:\Velociraptor\data\datastore" -DestinationPath "$BackupDir\datastore-$Date.zip"

# Start service
Start-Service "Velociraptor"
```

#### Health Check Script
```powershell
# health-check.ps1
$HealthStatus = @{
    Service = (Get-Service "Velociraptor").Status
    Port = (Test-NetConnection -ComputerName localhost -Port 8889).TcpTestSucceeded
    DiskSpace = (Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace
    LastBackup = (Get-ChildItem "C:\Velociraptor\backup\daily" | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime
}

$HealthStatus | ConvertTo-Json | Out-File "C:\Velociraptor\monitoring\health\status.json"
```

### Integration with [DEPLOY-SUCCESS]

#### Simple to Production Migration
1. **Start Simple**: Use [WORKING-CMD] for initial deployment
2. **Create Structure**: Run directory creation script
3. **Generate Certificates**: Create proper HTTPS certificates
4. **Migrate Configuration**: Move from temp to production config
5. **Install Service**: Set up Windows service
6. **Configure Monitoring**: Enable health checks and backups

#### Production Deployment Commands
```powershell
# 1. Create directory structure
.\Create-VelociraptorStructure.ps1

# 2. Generate certificates
.\Generate-Certificates.ps1

# 3. Install service
.\install-service.ps1

# 4. Start monitoring
.\health-check.ps1
```

This structure provides a robust, production-ready Velociraptor deployment with built-in HTTPS, comprehensive logging, automated backups, and proper security controls while maintaining compatibility with [SIMPLE-GUI] deployment patterns.