# Steering System Index

## Quick Navigation

This index provides fast access to all steering guidance and reference materials for the Velociraptor Setup Scripts project.

### 🚀 Getting Started

#### Essential First Steps
1. **[DEPLOY-SUCCESS]** - Start here for reliable deployment (proven 100% success rate)
2. **[USER-MGMT]** - Set up user accounts and authentication
3. **[WORKING-CMD]** - Use `C:\tools\velociraptor.exe gui` for simple deployment
4. **[DEFAULT-CREDS]** - admin/admin123 for initial testing
5. **GUI Applications** - Choose from 25+ VelociraptorUltimate variants

#### Available GUI Applications
- **VelociraptorUltimate-Simple-Working.ps1** - Proven working version
- **VelociraptorUltimate-Final.ps1** - Production-ready complete version
- **VelociraptorUltimate-Complete.ps1** - Comprehensive feature set
- **VelociraptorUltimate-Secure.ps1** - Security-hardened version
- **Plus 20+ additional specialized variants**

#### Quick Deployment
```powershell
# The proven working method
Start-Process PowerShell -ArgumentList "-NoExit", "-Command", "C:\tools\velociraptor.exe gui" -Verb RunAs
```

### 📚 Core Documentation

#### Project Foundation
- **[PRODUCT]** (`product.md`) - What this project does and who it's for
- **[TECH]** (`tech.md`) - Technology stack and development tools
- **[STRUCT]** (`structure.md`) - How the project is organized
- **[TEST]** (`testing.md`) - Quality assurance and testing approach

#### Specialized Guidance
- **[VELOCI-SOURCE]** (`velociraptor-source.md`) - Custom repository configuration
- **[DEPLOY-SUCCESS]** (`deployment-success.md`) - Proven deployment methods
- **[USER-MGMT]** (`user-management.md`) - User administration best practices

### 🔧 Development Reference

#### PowerShell Development
- **[PS-MODULES]** - Module structure and organization
- **[PS-FUNCTIONS]** - Function naming and conventions
- **[PS-TESTING]** - Pester testing framework
- **[PS-QUALITY]** - Code quality with PSScriptAnalyzer

#### Cross-Platform Support
- **[CROSS-PLATFORM]** - Windows, Linux, macOS deployment
- **[PLATFORM-DETECT]** - Automatic platform detection
- **[LINUX-DEPLOY]** - Linux-specific deployment
- **[MACOS-DEPLOY]** - macOS-specific deployment

### 🛡️ Security and Compliance

#### Security Framework
- **[SECU]** - Security guidelines and hardening
- **[ZERO-TRUST]** - Zero Trust security implementation
- **[COMPLIANCE]** - SOX, HIPAA, PCI-DSS, GDPR compliance
- **[CERTS]** - Certificate management and SSL

#### Access Control
- **[ACCESS-CONTROL]** - User permissions and access management
- **[ROLE-MGMT]** - Role-based access control
- **[AUTH]** - Authentication and authorization
- **[AUDIT]** - Security auditing and logging

### 🧪 Quality Assurance

#### Testing Strategy
- **[UNIT-TEST]** - Unit testing guidelines
- **[INTEGRATION-TEST]** - Integration testing approach
- **[SECURITY-TEST]** - Security validation testing
- **[COVERAGE]** - >90% critical, >80% overall coverage targets
- **QA Framework** - Complete Quality Assurance testing suite
- **UA Testing** - User Acceptance testing with real-world scenarios

#### Code Quality
- **[CODE-QUALITY]** - Standards and automated checks
- **[PERFORMANCE]** - Performance testing and optimization
- **[RELIABILITY]** - Stability and reliability requirements
- **Test Applications** - Dedicated testing versions of all GUI applications
- **QA Reports** - Comprehensive test reports and validation results

### 🚨 Incident Response

#### Pre-built Packages
- **[INCIDENT-PACKAGES]** - Ready-to-use response scenarios
- **[APT-PACKAGE]** - Advanced Persistent Threat investigations
- **[RANSOMWARE-PACKAGE]** - Ransomware incident response
- **[MALWARE-PACKAGE]** - Malware analysis and containment
- **[BREACH-PACKAGE]** - Data breach investigation

#### Artifact Management
- **[ARTIFACT-MGMT]** - Artifact collection and management
- **[TOOL-DEPS]** - Tool dependency management
- **[OFFLINE-COLLECTOR]** - Offline collector building
- **[CUSTOM-ARTIFACTS]** - Custom artifact development
- **Artifact Repository** - 100+ forensic artifacts (Generic, Linux, Windows)
- **Tool Integration** - Third-party tool management and integration
- **Artifact Import** - Automated artifact import and validation

### ☁️ Cloud and Containers

#### Container Deployment
- **[CONTAINER]** - Docker and Kubernetes deployment
- **[HELM]** - Kubernetes Helm chart deployment
- **[CLOUD]** - Multi-cloud support (AWS, Azure, GCP)
- **[SERVERLESS]** - Serverless deployment options

### 🔍 Troubleshooting

#### Common Issues
- **[TROUBLESHOOT]** - General troubleshooting guidance
- **[USER-TROUBLESHOOT]** - User-specific issues
- **[DEPLOY-TROUBLESHOOT]** - Deployment problems
- **[PORT-CHECK]** - `netstat -an | findstr :8889` verification

#### Quick Fixes
```powershell
# Check if Velociraptor is running
Get-Process | Where-Object {$_.ProcessName -like "*velociraptor*"}

# Verify port is listening
netstat -an | findstr :8889

# Test web interface
Invoke-WebRequest -Uri "https://127.0.0.1:8889" -SkipCertificateCheck -UseBasicParsing
```

### 📖 Documentation System

#### Documentation Standards
- **[DOC-STANDARDS]** - Documentation organization and standards
- **[INLINE-HELP]** - Comment-based help requirements
- **[ARCHIVE-SYSTEM]** - Historical documentation archive
- **[STEERING-SYSTEM]** - This guidance system

#### Reference System
- **SHORTHAND.md** - Quick reference codes for all guidance
- **INDEX.md** - This comprehensive navigation document
- **README.md** - Steering system overview and introduction
- **project-status.md** - Comprehensive project capabilities and status overview

### 🔄 Development Workflow

#### Module Development
- **[MODULE-DEV]** - PowerShell module development guidelines
- **[FUNCTION-DEV]** - Function development standards
- **[CONFIG-DEV]** - Configuration management development
- **[GUI-DEV]** - GUI application development

#### Version Control
- **[CUSTOM-REPO]** - Use `Ununp3ntium115/velociraptor` repository
- **[API-ENDPOINT]** - `https://api.github.com/repos/Ununp3ntium115/velociraptor/releases/latest`

### 🎯 Success Metrics

#### Deployment Success Indicators
1. **Process Running**: Velociraptor process active
2. **Port Listening**: Port 8889 accepting connections
3. **Web Response**: HTTP response (even "Not authorized" is success)
4. **GUI Accessible**: Web interface loads at https://127.0.0.1:8889

#### Quality Targets
- **Test Pass Rate**: >95% across all environments
- **Code Coverage**: >80% overall, >90% for critical functions
- **Performance**: Full test suite completes in <5 minutes
- **Reliability**: <1% flaky test rate

### 🚀 Quick Actions

#### Immediate Deployment
```powershell
# 1. Simple deployment (proven working method)
C:\tools\velociraptor.exe gui

# 2. Add admin user
.\Add-VelociraptorUser.ps1 -Username "admin" -Password "admin123"

# 3. Verify deployment
netstat -an | findstr :8889
```

#### Development Setup
```powershell
# 1. Run tests
.\tests\Run-Tests.ps1 -TestType All

# 2. Code quality check
Invoke-ScriptAnalyzer -Path "." -Recurse

# 3. Import modules
Import-Module "./modules/VelociraptorDeployment/VelociraptorDeployment.psd1" -Force
```

### 📋 Checklists

#### Pre-Deployment Checklist
- [ ] Administrator privileges available
- [ ] Port 8889 available
- [ ] Velociraptor binary at `C:\tools\velociraptor.exe`
- [ ] Network connectivity for downloads

#### Post-Deployment Checklist
- [ ] Process running and stable
- [ ] Web interface accessible
- [ ] User accounts created
- [ ] Basic functionality tested

#### Production Readiness Checklist
- [ ] Default passwords changed
- [ ] SSL certificates configured
- [ ] User access controls implemented
- [ ] Security hardening applied
- [ ] Monitoring and alerting configured

This index provides comprehensive navigation to all steering guidance and ensures consistent, high-quality development and deployment of Velociraptor infrastructure.