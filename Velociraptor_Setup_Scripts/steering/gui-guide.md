# GUIG - GUI User Guide

**Code**: `GUIG` | **Category**: GUI | **Status**: 📝 Draft

## 🚀 **Quick Start**

### **Launching the GUI**
```powershell
# Standard launch
.\gui\VelociraptorGUI.ps1

# Start minimized
.\gui\VelociraptorGUI.ps1 -StartMinimized

# Emergency clean install
.\VelociraptorGUI-InstallClean.ps1 -EmergencyMode
```

## 🧭 **Configuration Wizard**

### **Step-by-Step Process**

**Step 1: Welcome**
- Overview of features and capabilities
- System requirements check
- Getting started information

**Step 2: Deployment Type**
- **Server**: Multi-client enterprise deployment
- **Standalone**: Single-user forensic workstation
- **Client**: Agent-only deployment

**Step 3: Storage Configuration**
- **Datastore Directory**: Where Velociraptor stores data
- **Logs Directory**: Location for log files
- **Disk Space Validation**: Automatic space checking

**Step 4: Certificate Settings**
- **1 Year**: Standard certificate duration
- **2 Years**: Extended certificate duration
- **10 Years**: Long-term certificate duration

**Step 5: Security Settings**
- **VQL Restrictions**: Query language limitations
- **Registry Usage**: Windows registry access
- **Security Policies**: Access control settings

**Step 6: Network Configuration**
- **Frontend Address**: Server binding address
- **GUI Address**: Web interface binding
- **Port Configuration**: Network port settings
- **Organization Name**: Certificate organization

**Step 7: Authentication**
- **Admin Username**: Administrator account name
- **Admin Password**: Secure password (auto-generated available)
- **Password Complexity**: Strength requirements

**Step 8: Review & Generate**
- **Configuration Preview**: Complete settings overview
- **YAML Generation**: Configuration file creation
- **Validation**: Settings verification

**Step 9: Complete**
- **Success Confirmation**: Deployment ready status
- **Next Steps**: Post-configuration actions
- **Deployment Options**: Launch deployment scripts

## 🎨 **Interface Features**

### **Navigation**
- **Next/Back Buttons**: Step navigation
- **Progress Indicator**: Visual progress tracking
- **Step Validation**: Required field checking
- **Error Highlighting**: Invalid input indication

### **Input Validation**
- **Real-time Validation**: Immediate feedback
- **Color Coding**: Green (valid), Red (invalid)
- **Tooltips**: Helpful context information
- **Error Messages**: Clear, actionable descriptions

### **Advanced Features**
- **Secure Password Generator**: Cryptographically secure passwords
- **Directory Browser**: Visual folder selection
- **Configuration Templates**: Pre-built configurations
- **One-Click Deployment**: Integrated deployment execution

## 🔧 **Troubleshooting**

### **Common Issues**

**GUI Won't Start**:
```powershell
# Check PowerShell version
$PSVersionTable.PSVersion

# Test Windows Forms
Add-Type -AssemblyName System.Windows.Forms
```

**Configuration Errors**:
- Check required fields (highlighted in red)
- Verify directory paths exist
- Ensure ports are not in use
- Validate network addresses

**Deployment Failures**:
- Run as Administrator
- Check network connectivity
- Verify disk space
- Review error logs

### **Error Recovery**
- **Reset Configuration**: Clear all fields and start over
- **Load Previous**: Restore saved configuration
- **Skip Validation**: Bypass validation for testing
- **Emergency Mode**: Minimal configuration for quick deployment

## 🎯 **Best Practices**

### **Configuration Guidelines**
- **Use Absolute Paths**: Avoid relative paths for directories
- **Secure Passwords**: Use generated passwords for production
- **Network Security**: Bind GUI to localhost for security
- **Certificate Duration**: Use appropriate certificate lifetime
- **Backup Configurations**: Save configurations before deployment

### **Performance Tips**
- **SSD Storage**: Use SSD for datastore location
- **Adequate Memory**: Ensure sufficient RAM (8GB+ recommended)
- **Network Bandwidth**: Consider network capacity for multi-client
- **Port Selection**: Use non-conflicting ports

## 🔗 **Integration**

### **Deployment Integration**
The GUI integrates with deployment scripts:
- **Standalone**: `Deploy_Velociraptor_Standalone.ps1`
- **Server**: `Deploy_Velociraptor_Server.ps1`
- **Cross-Platform**: Platform-specific deployment scripts

### **AI Integration**
- **Intelligent Defaults**: AI-suggested configurations
- **Validation Assistance**: Smart error detection
- **Performance Optimization**: Resource-aware settings

## 📚 **Advanced Usage**

### **Command Line Options**
```powershell
# GUI with specific configuration
.\gui\VelociraptorGUI.ps1 -ConfigPath "saved-config.yaml"

# Automated mode (no user interaction)
.\gui\VelociraptorGUI.ps1 -AutoMode -ConfigPath "template.yaml"

# Debug mode (verbose logging)
.\gui\VelociraptorGUI.ps1 -Debug
```

### **Configuration Management**
- **Save Configurations**: Export settings to YAML
- **Load Configurations**: Import previous settings
- **Template Management**: Create and use templates
- **Batch Processing**: Automated configuration generation

## 🔗 **Related Documents**
- [GUIS] - GUI system architecture
- [GUIF] - GUI fixes and known issues
- [DEPL] - Deployment procedures
- [TROU] - Troubleshooting guide