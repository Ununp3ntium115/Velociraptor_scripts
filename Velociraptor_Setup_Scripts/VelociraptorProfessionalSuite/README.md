# Velociraptor Professional Suite v6.0.0

## 🚀 Quick Start

**For the easiest installation experience:**

1. **Right-click** on `LAUNCH_INSTALLER.bat` 
2. Select **"Run as administrator"**
3. Follow the GUI wizard

**Alternative methods:**
- Double-click `LAUNCH_INSTALLER.ps1` (if PowerShell is your default)
- Open PowerShell as Administrator and run: `.\LAUNCH_INSTALLER.ps1`

## 📋 What's Included

This package contains everything you need for a complete Velociraptor DFIR deployment:

### 🖥️ **Professional GUI Installer**
- MSI-style installation wizard
- Standalone or Server deployment options
- Automatic service configuration
- Firewall rule management
- Desktop shortcut creation

### 🛠️ **Management Interface**
- **Service Control**: Start, stop, restart Velociraptor
- **Configuration Management**: GUI-based config editing
- **Real-time Monitoring**: System metrics and client status
- **Update Management**: Automatic update checking
- **Backup & Restore**: Data protection tools

### 🚨 **Incident Response Tools**
- **Quick Response Actions**: Pre-configured investigation types
  - Malware Investigation
  - APT Investigation  
  - Ransomware Response
  - Data Breach Response
  - Insider Threat Investigation
  - Network Intrusion Analysis
- **Investigation Management**: Track active cases
- **Artifact Manager**: Manage collection artifacts
- **Report Generator**: Professional investigation reports

### 📊 **Monitoring Dashboard**
- Real-time system metrics
- Connected client overview
- Service health monitoring
- Performance tracking

## 💻 System Requirements

- **Operating System**: Windows 10 or Windows Server 2016+
- **PowerShell**: Version 5.1 or later
- **Privileges**: Administrator rights required
- **.NET Framework**: 4.7.2 or later
- **Memory**: 4GB RAM minimum (8GB recommended)
- **Disk Space**: 2GB free space minimum

## 🔧 Installation Options

### **Standalone Client**
Perfect for single-machine analysis:
- Local DFIR capabilities
- Offline evidence collection
- Portable investigation tools
- No network requirements

### **Server Installation**
For enterprise deployments:
- Centralized management
- Multiple client support
- Web-based interface
- Network-based collections
- Centralized reporting

## 📁 File Structure

```
VelociraptorProfessionalSuite/
├── LAUNCH_INSTALLER.bat          # Windows batch launcher
├── LAUNCH_INSTALLER.ps1           # PowerShell launcher  
├── VelociraptorInstaller.ps1      # Main GUI installer
├── modules/                       # PowerShell modules
│   ├── VelociraptorDeployment/   # Core deployment module
│   ├── VelociraptorML/           # AI/ML integration
│   ├── VelociraptorCompliance/   # Compliance features
│   └── ZeroTrustSecurity/        # Security hardening
└── README.md                      # This file
```

## 🎯 Features Overview

### **Installation Wizard**
- Welcome screen with system status
- Installation type selection
- Path and configuration options
- Progress tracking with detailed status
- Completion confirmation

### **Configuration Management**
- **Server Settings**: Ports, SSL, certificates
- **Database Configuration**: SQLite, MySQL, PostgreSQL
- **Security Settings**: Authentication methods
- **Advanced Options**: Custom parameters

### **Service Management**
- Service status monitoring
- Start/Stop/Restart controls
- Automatic startup configuration
- Web UI quick access
- Service health checks

### **Monitoring & Analytics**
- Real-time performance metrics
- Client connection status
- System resource usage
- Investigation progress tracking
- Alert and notification system

### **Incident Response**
- Pre-built investigation templates
- Custom investigation workflows
- Evidence collection automation
- Timeline reconstruction
- Professional report generation

## 🔐 Security Features

- **Secure Installation**: Administrator privilege validation
- **Certificate Management**: SSL/TLS configuration
- **Access Control**: Role-based permissions
- **Audit Logging**: Complete activity tracking
- **Compliance Support**: SOX, HIPAA, PCI-DSS, GDPR

## 🆘 Troubleshooting

### **Common Issues**

**"Access Denied" Error**
- Ensure you're running as Administrator
- Right-click and select "Run as administrator"

**"Execution Policy" Error**
- The launcher automatically handles this
- Or manually run: `Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process`

**"PowerShell Not Found"**
- Install PowerShell 5.1 or later
- Windows 10+ includes PowerShell by default

**GUI Doesn't Appear**
- Check Windows Forms is available
- Verify .NET Framework 4.7.2+
- Try running from PowerShell console

### **Getting Help**

1. **Check the logs**: `%ProgramData%\Velociraptor\Logs\`
2. **Review documentation**: Built-in help system
3. **Community support**: GitHub issues and discussions
4. **Professional support**: Available for enterprise deployments

## 📞 Support & Resources

- **GitHub Repository**: https://github.com/Ununp3ntium115/Velociraptor_Setup_Scripts
- **Documentation**: Comprehensive guides included
- **Community Forum**: GitHub Discussions
- **Issue Reporting**: GitHub Issues

## 📄 License

MIT License - See LICENSE file for complete terms.

## 🙏 Acknowledgments

Built on the excellent Velociraptor DFIR platform by Rapid7.
Custom repository maintained by the Velociraptor Setup Scripts community.

---

**Ready to get started?** Just double-click `LAUNCH_INSTALLER.bat` and follow the wizard!