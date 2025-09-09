# CONT - Contributing Guidelines

**Code**: `CONT` | **Category**: DEV | **Status**: ✅ Active

## 🚀 **Quick Start**

### **Setup**
```bash
git clone https://github.com/Ununp3ntium115/Velociraptor_Setup_Scripts.git
cd Velociraptor_Setup_Scripts
```

### **Development Environment**
- **PowerShell**: 5.1+ or PowerShell Core 7.0+
- **Testing**: Pester framework
- **Code Quality**: PSScriptAnalyzer

## 📋 **Contribution Process**

### **1. Issue Creation**
- Use templates for bug reports/feature requests
- Check existing issues first
- Provide detailed descriptions

### **2. Development Workflow**
```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Make changes following [ARCH] conventions
# Add tests following [TEST] guidelines
# Update documentation

# Submit PR with detailed description
```

### **3. Code Standards**

**PowerShell Best Practices**:
- Use approved verbs (`Get-`, `Set-`, `New-`, `Test-`)
- Implement parameter validation
- Include comment-based help
- Follow [ARCH] naming conventions

**Example Function**:
```powershell
function Get-VelociraptorStatus {
    <#
    .SYNOPSIS
        Gets Velociraptor service status
    .PARAMETER ConfigPath
        Path to configuration file
    .EXAMPLE
        Get-VelociraptorStatus -ConfigPath "server.yaml"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [string]$ConfigPath
    )
    
    # Implementation here
}
```

## 🧪 **Testing Requirements**

### **Test Coverage**
- Unit tests for all functions
- Integration tests for workflows
- Security validation tests
- Cross-platform compatibility tests

### **Running Tests**
```powershell
# Run all tests
.\tests\Run-Tests.ps1

# Run specific category
.\tests\Run-Tests.ps1 -TestType Unit
```

## 🔒 **Security Guidelines**

- No hardcoded credentials
- Use SecureString for sensitive data
- HTTPS for external requests
- Input validation and sanitization
- Follow [SECU] security standards

## 📚 **Documentation**

- Update relevant [steering docs] for changes
- Include working code examples
- Add troubleshooting information
- Use shorthand references ([TECH], [ARCH], etc.)

## 🎯 **Contribution Areas**

### **High Impact**
- Cross-platform deployment improvements
- AI/ML feature enhancements
- Security hardening
- Performance optimization

### **Good First Issues**
- Documentation improvements
- Test coverage expansion
- Bug fixes
- Example scripts

## 🔗 **Related Documents**
- [ARCH] - Project structure and conventions
- [TEST] - Testing guidelines and standards
- [SECU] - Security requirements
- [ROAD] - Development roadmap and priorities