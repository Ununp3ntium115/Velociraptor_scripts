@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'VelociraptorML.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')

    # ID used to uniquely identify this module
    GUID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'

    # Author of this module
    Author = 'Velociraptor Setup Scripts Team'

    # Company or vendor of this module
    CompanyName = 'Velociraptor Community'

    # Copyright statement for this module
    Copyright = '(c) 2025 Velociraptor Community. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'AI/ML-powered configuration generation, predictive analytics, and automated troubleshooting for Velociraptor DFIR deployments.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module
    FunctionsToExport = @(
        'New-IntelligentConfiguration',
        'Start-PredictiveAnalytics',
        'Start-AutomatedTroubleshooting'
    )

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @(
        'New-AIConfig',
        'Start-MLAnalytics',
        'Start-AutoTroubleshoot'
    )

    # Private data to pass to the module
    PrivateData = @{
        PSData = @{
            # Tags applied to this module
            Tags = @(
                'Velociraptor', 'AI', 'MachineLearning', 'Configuration',
                'PredictiveAnalytics', 'Troubleshooting', 'DFIR', 'Automation'
            )

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/Ununp3ntium115/Velociraptor_Setup_Scripts/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/Ununp3ntium115/Velociraptor_Setup_Scripts'

            # ReleaseNotes of this module
            ReleaseNotes = @'
# VelociraptorML v1.0.0 - AI-Powered DFIR Configuration

## Features
- **Intelligent Configuration Generation**: AI-driven configuration optimization
- **Predictive Analytics**: ML-based deployment success prediction
- **Automated Troubleshooting**: Self-healing deployment capabilities
- **Multi-Environment Support**: Development, Testing, Production optimizations
- **Use Case Optimization**: ThreatHunting, IncidentResponse, Compliance, Forensics
- **Resource-Aware Configuration**: Automatic resource optimization
- **Security Hardening**: Multi-level security configuration

## Functions
- New-IntelligentConfiguration: Generate optimized configurations
- Start-PredictiveAnalytics: Predict deployment success
- Start-AutomatedTroubleshooting: Diagnose and fix issues

## Requirements
- PowerShell 5.1+ or PowerShell Core 7.0+
- Velociraptor Setup Scripts platform
'@
        }
    }
}