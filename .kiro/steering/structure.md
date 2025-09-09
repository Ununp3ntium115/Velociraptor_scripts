# Project Structure

## Root Directory Layout

```
Velociraptor_Setup_Scripts/
├── Deploy_Velociraptor_Standalone.ps1    # Main standalone deployment script
├── Deploy_Velociraptor_Server.ps1        # Main server deployment script
├── VelociraptorSetupScripts.psm1         # Root module file
├── VelociraptorSetupScripts.psd1         # Root module manifest
├── package.json                          # NPM-style metadata and scripts
├── VERSION                               # Current version number (5.0.4-beta)
├── README.md                             # Main documentation
├── LICENSE                               # MIT license
└── deploy-velociraptor-standalone.sh     # Cross-platform shell script
```

## Core Directories

### `/modules/` - PowerShell Modules
Organized by functional area with consistent structure:
```
modules/
├── VelociraptorDeployment/              # Core deployment functionality
│   ├── VelociraptorDeployment.psd1     # Module manifest
│   ├── VelociraptorDeployment.psm1     # Module script
│   └── functions/                       # Individual function files
├── VelociraptorCompliance/              # Compliance and governance
├── VelociraptorGovernance/              # Enterprise governance features
├── VelociraptorML/                      # AI/ML integration and analytics
└── ZeroTrustSecurity/                   # Security hardening and compliance
```

### `/scripts/` - Utility Scripts
Organized by category with comprehensive functionality:
```
scripts/
├── configuration-management/            # Config and environment management
├── cross-platform/                     # Linux/macOS deployment scripts
│   ├── Deploy-VelociraptorLinux.ps1   # Linux deployment
│   ├── Deploy-VelociraptorMacOS.ps1   # macOS deployment
│   ├── CrossPlatform-Utils.psm1       # Shared utilities
│   └── Manage-VelociraptorService.ps1  # Service management
├── monitoring/                          # Health monitoring and alerting
├── security/                           # Security baseline scripts
├── Build-*.ps1                        # Build and packaging scripts
├── Fork-VelociraptorEcosystem.ps1     # Repository forking automation
├── Organize-Documentation.ps1          # Documentation management
└── Test-CodeQuality.ps1               # Code quality validation
```

### `/gui/` - Graphical Interfaces
```
gui/
├── VelociraptorGUI.ps1                 # Main GUI application (Windows Forms)
├── IncidentResponseGUI.ps1             # Incident response interface
└── Enhanced-Package-GUI.ps1            # Package management GUI (archived)
```

### `/templates/` - Configuration Templates
```
templates/
├── configurations/                      # Velociraptor config templates
│   ├── server-config.yaml             # Server configuration template
│   ├── standalone-config.yaml         # Standalone configuration template
│   └── cluster-config.yaml            # Cluster configuration template
```

### `/containers/` - Container Deployments
```
containers/
├── docker/                             # Docker configurations
│   ├── Dockerfile                      # Container build file
│   └── docker-compose.yml             # Multi-container setup
└── kubernetes/                         # Kubernetes manifests and Helm charts
    └── helm/                           # Helm chart files
        └── velociraptor/               # Velociraptor Helm chart
```

### `/cloud/` - Cloud Provider Scripts
```
cloud/
├── aws/                                # AWS deployment scripts
│   ├── Deploy-VelociraptorAWS.ps1     # AWS-specific deployment
│   └── aws-lambda/                     # Serverless functions
└── azure/                              # Azure deployment scripts
    ├── Deploy-VelociraptorAzure.ps1   # Azure-specific deployment
    └── azure-functions/                # Azure Functions
```

### `/tests/` - Comprehensive Testing Suite
```
tests/
├── unit/                               # Unit tests (Pester 3.x compatible)
│   ├── Basic-Infrastructure.Tests.ps1  # Core infrastructure tests
│   ├── Deploy-Velociraptor-Server.Tests.ps1  # Server deployment tests
│   ├── Module-Functions.Tests.ps1      # Module function tests
│   └── VelociraptorDeployment.Module.Tests.ps1  # Core module tests
├── integration/                        # Integration tests
│   ├── Cross-Platform-Deployment.Tests.ps1  # Multi-platform tests
│   ├── GUI-Functionality.Tests.ps1     # GUI component tests
│   ├── Configuration-Management.Tests.ps1   # Config validation tests
│   ├── Monitoring-Health.Tests.ps1     # Health monitoring tests
│   └── Artifact-Collection.Tests.ps1   # Artifact management tests
├── security/                           # Security validation tests
│   ├── Security-Validation.Tests.ps1   # Comprehensive security tests
│   └── Security-Baseline.Tests.ps1     # Security baseline validation
└── Run-Tests.ps1                       # Test runner with multiple formats
```

### `/incident-packages/` - Pre-built Response Scenarios
```
incident-packages/
├── APT-Package/                        # Advanced Persistent Threat
├── Ransomware-Package/                 # Ransomware investigation
├── DataBreach-Package/                 # Data breach response
├── Malware-Package/                    # Malware analysis
├── NetworkIntrusion-Package/           # Network intrusion
├── Insider-Package/                    # Insider threat
├── Complete-Package/                   # Comprehensive package
└── *.zip                              # Packaged versions
```

### `/docs/` - Documentation System
```
docs/
└── archive/                            # Organized documentation archive
    ├── beta/                           # Beta testing documentation
    ├── release/                        # Release notes and changelogs
    ├── qa/                             # Quality assurance documents
    ├── planning/                       # Planning and roadmap documents
    ├── gui/                            # GUI-related documentation
    ├── support/                        # Troubleshooting and support
    ├── security/                       # Security documentation
    ├── development/                    # Development processes
    ├── general/                        # General purpose documents
    └── planning/                       # Strategic planning documents
```

### `/steering/` - Active Guidance System
```
steering/
├── README.md                           # Steering system overview
├── INDEX.md                            # Quick reference index
├── SHORTHAND.md                        # Code-based reference system
├── deployment.md                       # Deployment guidance
├── gui-guide.md                        # GUI user guide
├── gui-system.md                       # GUI system architecture
├── product.md                          # Product overview
└── security.md                         # Security guidelines
```

## Naming Conventions

### PowerShell Scripts
- **Deployment Scripts**: `Deploy_Velociraptor_*.ps1` (underscore format for main scripts)
- **Cross-Platform Scripts**: `Deploy-Velociraptor*.ps1` (hyphen format for utilities)
- **Test Scripts**: `*.Tests.ps1` (Pester convention)
- **GUI Scripts**: `*GUI*.ps1`
- **Utility Scripts**: `Verb-Noun.ps1` (PowerShell approved verbs)

### PowerShell Functions
- **Approved Verbs**: `Get-`, `Set-`, `New-`, `Test-`, `Start-`, `Stop-`, `Install-`, `Remove-`
- **Verb-Noun Pattern**: `Get-VelociraptorStatus`, `New-VelociraptorConfig`
- **PascalCase**: All function names use PascalCase
- **Module Prefix**: Consider using module-specific prefixes for exported functions

### Module Organization
- **Module Directory**: Each module has its own directory under `/modules/`
- **Manifest File**: `ModuleName.psd1` with metadata and dependencies
- **Script Module**: `ModuleName.psm1` with function definitions
- **Function Organization**: 
  - `/functions/Public/` for exported functions
  - `/functions/Private/` for internal functions
- **Templates**: `/templates/` subdirectory when applicable

### Configuration Files
- **Velociraptor Configs**: `*.yaml` (YAML format preferred)
- **Metadata**: `*.json` (JSON for structured data)
- **PowerShell Data**: `*.psd1` (PowerShell data files for module configuration)
- **Version Control**: `VERSION` file for centralized version management

## File Organization Patterns

### Module Structure Pattern
```
ModuleName/
├── ModuleName.psd1                     # Module manifest with metadata
├── ModuleName.psm1                     # Main module file with exports
├── functions/                          # Function organization (optional)
│   ├── Public/                         # Exported functions
│   │   ├── Get-ModuleFunction.ps1     # Individual function files
│   │   └── Set-ModuleConfiguration.ps1
│   └── Private/                        # Internal helper functions
│       ├── Test-InternalLogic.ps1     # Private helper functions
│       └── Format-InternalData.ps1
├── templates/                          # Configuration templates (optional)
│   ├── default-config.yaml           # Default configuration
│   └── advanced-config.yaml          # Advanced configuration
└── README.md                          # Module-specific documentation
```

### Script Categories and Organization
- **Root Level**: Main deployment and setup scripts for immediate use
- **`/scripts/`**: Utility and specialized scripts organized by functional category
- **`/tests/`**: Comprehensive test files with matching script names and categories
- **`/examples/`**: Example configurations, demos, and usage scenarios
- **`/gui/`**: Graphical user interface applications
- **`/templates/`**: Reusable configuration templates

### Documentation Structure
- **Root README.md**: Main project documentation and quick start
- **Module READMEs**: Specific module documentation and usage
- **Steering System**: Active guidance documents in `/steering/`
- **Archive System**: Historical documentation in `/docs/archive/`
- **Inline Help**: Comment-based help in all PowerShell functions
- **Cross-References**: Use shorthand codes for document references

### Quality Assurance Structure
- **Test Organization**: Unit, integration, and security test categories
- **Code Quality**: PSScriptAnalyzer integration with custom rules
- **Documentation**: Comprehensive documentation with organized archive
- **Version Control**: Centralized version management and release processes

## Custom Repository Integration

All scripts and modules are configured to use the custom Velociraptor repository:
- **Repository URL**: `https://github.com/Ununp3ntium115/velociraptor.git`
- **API Endpoint**: `https://api.github.com/repos/Ununp3ntium115/velociraptor/releases/latest`
- **Binary Sources**: All downloads from custom repository releases
- **Fork Management**: Automated forking scripts for ecosystem management