# 📝 Shorthand Reference System

## 🎯 Usage in Code Comments

```powershell
# Follow [ARCH] structure conventions
function New-VelociraptorConfig {
    # Security per [SECU] guidelines
    # Testing per [TEST] standards
    # Deployment per [DEPL] procedures
}
```

## 📖 Usage in Documentation

```markdown
<!-- Cross-reference other documents -->
See [TECH] for technology details
Refer to [ROAD] for roadmap information
Check [QASY] for QA processes
Follow [SECU] security guidelines
```

## 🔍 Quick Lookup

| Code | Command | Description |
|------|---------|-------------|
| PROD | `Get-Content steering/product.md` | Product overview |
| TECH | `Get-Content steering/tech.md` | Technology stack |
| ARCH | `Get-Content steering/structure.md` | Architecture |
| ROAD | `Get-Content steering/roadmap.md` | Development roadmap |
| SECU | `Get-Content steering/security.md` | Security guidelines |
| TEST | `Get-Content steering/testing.md` | Testing standards |
| DEPL | `Get-Content steering/deployment.md` | Deployment guide |
| TROU | `Get-Content steering/troubleshooting.md` | Troubleshooting |
| GUIS | `Get-Content steering/gui-system.md` | GUI architecture |
| QASY | `Get-Content steering/qa-system.md` | QA processes |

## 🔄 Maintenance

When adding new steering documents:
1. Use 4-letter code format
2. Include code in document header
3. Update this reference
4. Add cross-references in related docs
