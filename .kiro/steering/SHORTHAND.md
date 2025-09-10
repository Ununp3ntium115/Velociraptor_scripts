# Steering System Shorthand Reference

## Quick Reference Codes

This document provides shorthand codes for quick reference to steering guidance across all documentation and code.

### Core Project References

#### Product and Architecture
- **[PRODUCT]** - Product overview and features (`product.md`)
- **[TECH]** - Technology stack and development environment (`tech.md`)
- **[STRUCT]** - Project structure and organization (`structure.md`)
- **[TEST]** - Testing guidelines and quality assurance (`testing.md`)

#### Source and Repository
- **[VELOCI-SOURCE]** - Custom Velociraptor repository configuration (`velociraptor-source.md`)
- **[CUSTOM-REPO]** - Reference to `Ununp3ntium115/velociraptor` repository
- **[API-ENDPOINT]** - `https://api.github.com/repos/Ununp3ntium115/velociraptor/releases/latest`

### Deployment and Operations

#### Deployment Success
- **[DEPLOY-SUCCESS]** - Proven deployment methods (`deployment-success.md`)
- **[SIMPLE-GUI]** - Simple GUI deployment approach
- **[WORKING-CMD]** - `C:\tools\velociraptor.exe gui` command
- **[ADMIN-LAUNCH]** - Administrator privilege launch method
- **[PROJECT-STATUS]** - Comprehensive project capabilities overview (`project-status.md`)
- **[GUI-SUITE]** - 25+ VelociraptorUltimate application variants
- **[QA-FRAMEWORK]** - Quality Assurance and User Acceptance testing

#### User Management
- **[USER-MGMT]** - User management best practices (`user-management.md`)
- **[USER-SCRIPTS]** - User management script references
- **[USER-SECURITY]** - User security guidelines
- **[DEFAULT-CREDS]** - admin/admin123 default credentials

#### Troubleshooting
- **[TROUBLESHOOT]** - General troubleshooting guidance
- **[USER-TROUBLESHOOT]** - User-specific troubleshooting
- **[DEPLOY-TROUBLESHOOT]** - Deployment troubleshooting
- **[PORT-CHECK]** - `netstat -an | findstr :8889` verification

### Technical Implementation

#### PowerShell and Modules
- **[PS-MODULES]** - PowerShell module structure and organization
- **[PS-FUNCTIONS]** - PowerShell function naming and conventions
- **[PS-TESTING]** - Pester testing framework usage
- **[PS-QUALITY]** - PSScriptAnalyzer and code quality

#### Cross-Platform Support
- **[CROSS-PLATFORM]** - Windows, Linux, macOS support
- **[PLATFORM-DETECT]** - Platform detection and auto-configuration
- **[LINUX-DEPLOY]** - Linux-specific deployment guidance
- **[MACOS-DEPLOY]** - macOS-specific deployment guidance

#### Container and Cloud
- **[CONTAINER]** - Docker and Kubernetes deployment
- **[CLOUD]** - Multi-cloud deployment (AWS, Azure, GCP)
- **[HELM]** - Kubernetes Helm chart deployment
- **[SERVERLESS]** - Serverless deployment options

### Security and Compliance

#### Security Framework
- **[SECU]** - Security guidelines and best practices
- **[ZERO-TRUST]** - Zero Trust security implementation
- **[COMPLIANCE]** - SOX, HIPAA, PCI-DSS, GDPR compliance
- **[CERTS]** - Certificate management and SSL configuration

#### Access Control
- **[ACCESS-CONTROL]** - User access and permission management
- **[ROLE-MGMT]** - Role-based access control
- **[AUTH]** - Authentication and authorization
- **[AUDIT]** - Security auditing and logging

### Quality Assurance

#### Testing Categories
- **[UNIT-TEST]** - Unit testing guidelines and structure
- **[INTEGRATION-TEST]** - Integration testing approach
- **[SECURITY-TEST]** - Security testing and validation
- **[CROSS-PLATFORM-TEST]** - Multi-platform testing

#### Code Quality
- **[CODE-QUALITY]** - Code quality standards and tools
- **[COVERAGE]** - Test coverage requirements (>90% critical, >80% overall)
- **[PERFORMANCE]** - Performance testing and optimization
- **[RELIABILITY]** - Reliability and stability requirements

### Development Workflow

#### Module Development
- **[MODULE-DEV]** - Module development guidelines
- **[FUNCTION-DEV]** - Function development standards
- **[CONFIG-DEV]** - Configuration management development
- **[GUI-DEV]** - GUI application development

#### Documentation
- **[DOC-STANDARDS]** - Documentation standards and organization
- **[INLINE-HELP]** - Comment-based help requirements
- **[ARCHIVE-SYSTEM]** - Documentation archive organization
- **[STEERING-SYSTEM]** - Steering system usage and maintenance

### Incident Response

#### Pre-built Packages
- **[INCIDENT-PACKAGES]** - Pre-built incident response packages
- **[APT-PACKAGE]** - Advanced Persistent Threat package
- **[RANSOMWARE-PACKAGE]** - Ransomware investigation package
- **[MALWARE-PACKAGE]** - Malware analysis package
- **[BREACH-PACKAGE]** - Data breach response package

#### Artifact Management
- **[ARTIFACT-MGMT]** - Artifact management and collection
- **[TOOL-DEPS]** - Tool dependency management
- **[OFFLINE-COLLECTOR]** - Offline collector building
- **[CUSTOM-ARTIFACTS]** - Custom artifact development
- **[ARTIFACT-REPO]** - 100+ forensic artifacts repository

#### GUI Applications
- **[GUI-FINAL]** - VelociraptorUltimate-Final.ps1 production version
- **[GUI-SIMPLE]** - VelociraptorUltimate-Simple-Working.ps1 proven version
- **[GUI-COMPLETE]** - VelociraptorUltimate-Complete.ps1 comprehensive version
- **[GUI-SECURE]** - VelociraptorUltimate-Secure.ps1 security-hardened version
- **[GUI-TEST]** - Testing and development GUI versions

### Usage Examples

#### In Code Comments
```powershell
# Follow [DEPLOY-SUCCESS] method for reliable deployment
# Use [USER-MGMT] scripts for user administration
# Reference [CUSTOM-REPO] for all Velociraptor downloads
```

#### In Documentation
```markdown
For deployment guidance, see [DEPLOY-SUCCESS].
User management follows [USER-MGMT] best practices.
All testing should meet [TEST] coverage requirements.
```

#### In Issue Tracking
```
- Implement [SIMPLE-GUI] deployment method
- Update scripts to use [CUSTOM-REPO] endpoint
- Ensure [COVERAGE] targets are met
```

### Maintenance Guidelines

#### When to Update Shorthand Codes
- New steering documents added
- Major feature additions or changes
- Process or workflow modifications
- Technology stack updates

#### Code Consistency
- Use consistent shorthand codes across all documentation
- Update references when steering documents change
- Maintain cross-references between related concepts
- Regular review and cleanup of unused codes

This shorthand system enables quick reference and consistent documentation across the entire Velociraptor Setup Scripts project.