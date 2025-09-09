# Technology Stack

## Core Technologies

- **Primary Language**: PowerShell 5.1+ and PowerShell Core 7.0+
- **Module System**: PowerShell modules with manifest files (.psd1) and script modules (.psm1)
- **Configuration**: YAML and JSON configuration files
- **Testing Framework**: Pester 3.x/4.x/5.x with comprehensive test coverage
- **Package Management**: NPM-style package.json for metadata and dependencies

## Development Environment

- **Cross-Platform Support**: Windows (primary), Linux, macOS with auto-detection
- **Version Control**: Git with GitHub and comprehensive branching strategy
- **CI/CD**: Automated testing and release pipelines with quality gates
- **Code Quality**: PSScriptAnalyzer for PowerShell best practices and automated fixes

## Key Dependencies

### Container & Cloud Support
- **Container Support**: Docker and Kubernetes with Helm charts
- **Cloud Providers**: AWS CLI, Azure CLI, Google Cloud SDK (optional)
- **Serverless**: AWS Lambda, Azure Functions support

### Security & Compliance
- **Security Tools**: Built-in Windows security, UFW/firewalld for Linux
- **Compliance Frameworks**: SOX, HIPAA, PCI-DSS, GDPR validation
- **Zero Trust**: Advanced security hardening modules

### GUI & Interface
- **GUI Framework**: Windows Forms for desktop interfaces
- **Cross-Platform GUI**: PowerShell-based cross-platform support
- **Web Interface**: Velociraptor web GUI integration

## Architecture Components

### PowerShell Modules
```
modules/
├── VelociraptorDeployment/     # Core deployment functionality
├── VelociraptorCompliance/     # Compliance and governance
├── VelociraptorML/            # AI/ML integration
├── VelociraptorGovernance/    # Enterprise governance
└── ZeroTrustSecurity/         # Security hardening
```

### Cross-Platform Scripts
```
scripts/cross-platform/
├── Deploy-VelociraptorLinux.ps1    # Linux deployment
├── Deploy-VelociraptorMacOS.ps1    # macOS deployment
├── CrossPlatform-Utils.psm1        # Shared utilities
└── Manage-VelociraptorService.ps1   # Service management
```

### Testing Infrastructure
```
tests/
├── unit/           # Unit tests (Pester 3.x compatible)
├── integration/    # Integration tests
├── security/       # Security validation tests
└── Run-Tests.ps1   # Test runner with multiple formats
```

## Common Commands

### Development and Testing
```powershell
# Run all tests with coverage
.\tests\Run-Tests.ps1 -TestType All -OutputFormat NUnitXml

# Run specific test categories
.\tests\Run-Tests.ps1 -TestType Unit
.\tests\Run-Tests.ps1 -TestType Integration
.\tests\Run-Tests.ps1 -TestType Security

# Code quality analysis with fixes
Invoke-ScriptAnalyzer -Path "." -Recurse -Fix

# Import development modules
Import-Module "./modules/VelociraptorDeployment/VelociraptorDeployment.psd1" -Force
Import-Module "./modules/VelociraptorML/VelociraptorML.psd1" -Force
```

### Deployment Commands
```powershell
# Basic standalone deployment
.\Deploy_Velociraptor_Standalone.ps1

# Server deployment with custom settings
.\Deploy_Velociraptor_Server.ps1 -GuiPort 8889 -EnableSSL

# Cross-platform deployments
sudo pwsh ./scripts/cross-platform/Deploy-VelociraptorLinux.ps1 -AutoDetect
pwsh ./scripts/cross-platform/Deploy-VelociraptorMacOS.ps1 -Interactive

# Launch GUI configuration wizard
.\gui\VelociraptorGUI.ps1

# Container deployments
docker-compose -f containers/docker/docker-compose.yml up
helm install velociraptor containers/kubernetes/helm/velociraptor/
```

### Utility Commands
```powershell
# Performance measurement
.\Start-PerformanceMeasurement.ps1 -Detailed

# Health monitoring
.\scripts\monitoring\Monitor-VelociraptorHealth.ps1

# Artifact management
.\Investigate-ArtifactPack.ps1 -PackageName "APT-Package"

# Documentation organization
.\scripts\Organize-Documentation.ps1 -Action All
```

### Module Management
```powershell
# Test module loading
Test-ModuleManifest "./modules/VelociraptorDeployment/VelociraptorDeployment.psd1"

# Install development dependencies
Install-Module Pester -Force -AllowClobber
Install-Module PSScriptAnalyzer -Force
Install-Module PowerShellGet -Force
```

## Build System

The project uses a sophisticated PowerShell-based build system:

### Module Architecture
- **Module manifests (.psd1)**: Metadata, dependencies, and version management
- **Script modules (.psm1)**: Function exports and module logic
- **Nested modules**: Complex functionality with clean separation
- **Function organization**: Public/Private function separation

### Package Management
- **package.json**: NPM-style metadata and scripting
- **VERSION file**: Centralized version management
- **Release pipeline**: Automated packaging and distribution

### Quality Assurance
- **Multi-version Pester support**: 3.x, 4.x, and 5.x compatibility
- **Code coverage**: JaCoCo XML format with >90% target
- **Static analysis**: PSScriptAnalyzer with custom rules
- **Cross-platform testing**: Windows, Linux, macOS validation

## Custom Repository Integration

All deployments use the custom Velociraptor repository:
- **API Endpoint**: `https://api.github.com/repos/Ununp3ntium115/velociraptor/releases/latest`
- **Binary Downloads**: From custom repository releases
- **Version Management**: Independent of upstream Velociraptor releases