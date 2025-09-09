# Velociraptor Source Repository

## Custom Velociraptor Repository

**CRITICAL**: This project uses a custom fork of Velociraptor instead of the official upstream repository. All deployment scripts, modules, and automation tools are configured to use the custom repository.

### Repository Configuration

- **Custom Repository**: `https://github.com/Ununp3ntium115/velociraptor.git`
- **Official Upstream**: `https://github.com/Velocidex/velociraptor.git` (NOT used)
- **API Endpoint**: `https://api.github.com/repos/Ununp3ntium115/velociraptor/releases/latest`

### Download Sources

All deployment scripts in this project download Velociraptor binaries from the custom repository:
```
https://api.github.com/repos/Ununp3ntium115/velociraptor/releases/latest
```

### Affected Components

The following scripts and modules have been configured to use the custom repository:

#### Main Deployment Scripts
- `Deploy_Velociraptor_Standalone.ps1`
- `Deploy_Velociraptor_Server.ps1`
- `Deploy_Velociraptor_Server_Improved.ps1`
- `Deploy_Velociraptor_Standalone_Improved.ps1`
- `Deploy_Velociraptor_WithCompliance.ps1`

#### Cross-Platform Scripts
- `deploy-velociraptor-standalone.sh` (macOS/Linux shell script)
- `scripts/cross-platform/Deploy-VelociraptorLinux.ps1`
- `scripts/cross-platform/Deploy-VelociraptorMacOS.ps1`
- `community_repository_template/Deploy_Velociraptor_Standalone.ps1`

#### Utility and Management Scripts
- `Investigate-ArtifactPack.ps1`
- `Start-PerformanceMeasurement.ps1`
- `Start-PerformanceMeasurement-Simple.ps1`
- `Manage-VelociraptorConfig.ps1`

#### Fork Management Scripts
- `scripts/Fork-VelociraptorEcosystem.ps1`
- All incident package fork scripts in `incident-packages/*/scripts/`

#### PowerShell Modules
- `modules/VelociraptorDeployment/` - Core deployment module
- `modules/VelociraptorML/` - AI/ML integration module
- `modules/VelociraptorCompliance/` - Compliance module
- `modules/ZeroTrustSecurity/` - Security hardening module

#### Container and Cloud Deployments
- `containers/docker/` - Docker deployment configurations
- `containers/kubernetes/helm/` - Kubernetes Helm charts
- `cloud/aws/` - AWS deployment scripts
- `cloud/azure/` - Azure deployment scripts

### Development Guidelines

When adding new scripts, modules, or modifying existing ones:

1. **Always use the custom repository**: `Ununp3ntium115/velociraptor`
2. **Never reference the upstream**: Avoid `Velocidx/velociraptor` or `Velocidex/velociraptor`
3. **API URL format**: Use `https://api.github.com/repos/Ununp3ntium115/velociraptor/releases/latest`
4. **Download URLs**: Ensure all binary downloads come from the custom repository releases
5. **Version checking**: Use custom repository for version validation and updates
6. **Documentation**: Reference custom repository in all documentation and examples

### Code Implementation Pattern

When implementing Velociraptor downloads in scripts:

```powershell
# Correct implementation
$VelociraptorRepo = "Ununp3ntium115/velociraptor"
$ApiUrl = "https://api.github.com/repos/$VelociraptorRepo/releases/latest"

# Get latest release information
$LatestRelease = Invoke-RestMethod -Uri $ApiUrl -Headers $Headers

# Download binary from custom repository
$DownloadUrl = $LatestRelease.assets | Where-Object { $_.name -like "*windows-amd64.exe" } | Select-Object -ExpandProperty browser_download_url
```

### Rationale for Custom Repository

Using the custom repository provides several advantages:

#### Technical Benefits
- **Custom modifications and enhancements**: Ability to implement project-specific features
- **Independent release cycles**: Not dependent on upstream release schedules
- **Specialized builds**: Custom builds optimized for this deployment platform
- **Full control**: Complete control over the Velociraptor distribution and features

#### Operational Benefits
- **Stability**: Consistent binary availability and version control
- **Security**: Controlled source for all Velociraptor binaries
- **Customization**: Ability to include custom artifacts and configurations
- **Integration**: Seamless integration with deployment automation

#### Development Benefits
- **Fork management**: Automated forking and synchronization capabilities
- **Testing**: Controlled environment for testing new features
- **Documentation**: Custom documentation and examples
- **Community**: Independent community development and contributions

### Repository Synchronization

The project includes automated tools for managing the custom repository:

#### Fork Management
- `scripts/Fork-VelociraptorEcosystem.ps1` - Automated forking of Velociraptor ecosystem
- Automated synchronization with upstream when needed
- Custom branch management and release processes

#### Version Management
- Independent versioning scheme aligned with project releases
- Custom release notes and changelog management
- Automated binary building and distribution

#### Quality Assurance
- Custom testing and validation processes
- Security scanning and vulnerability assessment
- Performance testing and optimization

### Migration and Compatibility

#### Upstream Compatibility
- Maintains compatibility with upstream Velociraptor features
- Regular synchronization of critical security updates
- Selective integration of upstream improvements

#### Migration Path
- Clear migration path for users wanting to switch to upstream
- Documentation for converting configurations
- Tools for repository URL updates

### Security Considerations

#### Source Verification
- All binaries are built from verified source code
- Digital signatures and checksums for all releases
- Transparent build process and audit trail

#### Supply Chain Security
- Controlled build environment and processes
- Regular security audits and vulnerability assessments
- Secure distribution and download mechanisms

### Support and Maintenance

#### Community Support
- Dedicated support for custom repository users
- Community forums and documentation
- Regular updates and maintenance schedules

#### Documentation
- Comprehensive documentation for custom features
- Migration guides and troubleshooting resources
- API documentation and integration examples

### Future Roadmap

#### Planned Enhancements
- Enhanced AI/ML integration capabilities
- Advanced compliance and governance features
- Improved cross-platform support and optimization
- Extended cloud-native and container support

#### Long-term Strategy
- Continued alignment with upstream security updates
- Independent feature development and innovation
- Community-driven enhancement and contribution process
- Enterprise-grade support and professional services