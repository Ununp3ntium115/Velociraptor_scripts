# 🧭 Steering Documentation System

**Master Index for Velociraptor Setup Scripts Documentation**

## 📋 **Quick Reference Index**

| Code | Topic | File | Status | Description |
|------|-------|------|--------|-------------|
| **CORE** | | | | **Core Platform Documentation** |
| `PROD` | Product | [product.md](product.md) | ✅ | Product overview, features, users |
| `TECH` | Technology | [tech.md](tech.md) | ✅ | Tech stack, commands, dependencies |
| `ARCH` | Architecture | [structure.md](structure.md) | ✅ | Project structure, conventions |
| `REPO` | Repository | [velociraptor-source.md](velociraptor-source.md) | ✅ | Custom repo configuration |
| `TEST` | Testing | [testing.md](testing.md) | ✅ | Testing guidelines, coverage |
| **DEV** | | | | **Development & Operations** |
| `ROAD` | Roadmap | [roadmap.md](roadmap.md) | ✅ | Development roadmap, priorities |
| `CONT` | Contributing | [contributing.md](contributing.md) | ✅ | Contribution guidelines |
| `DEPL` | Deployment | [deployment.md](deployment.md) | ✅ | Deployment strategies, analysis |
| `TROU` | Troubleshooting | [troubleshooting.md](troubleshooting.md) | ✅ | Common issues, solutions |
| `SECU` | Security | [security.md](security.md) | ✅ | Security hardening, compliance |
| **GUI** | | | | **User Interface** |
| `GUIS` | GUI System | [gui-system.md](gui-system.md) | ✅ | GUI architecture, components |
| `GUIG` | GUI Guide | [gui-guide.md](gui-guide.md) | 📝 | User guide, training |
| `GUIF` | GUI Fixes | [gui-fixes.md](gui-fixes.md) | 📝 | Known issues, fixes |
| **REL** | | | | **Release Management** |
| `RELS` | Release System | [release-system.md](release-system.md) | 📝 | Release process, instructions |
| `RELN` | Release Notes | [release-notes.md](release-notes.md) | 📝 | Current release notes |
| `BETA` | Beta Process | [beta-process.md](beta-process.md) | 📝 | Beta testing, feedback |
| **QA** | | | | **Quality Assurance** |
| `QASY` | QA System | [qa-system.md](qa-system.md) | ✅ | QA processes, standards |
| `QARE` | QA Reports | [qa-reports.md](qa-reports.md) | 📝 | Latest QA reports |
| `PERF` | Performance | [performance.md](performance.md) | 📝 | Performance metrics, optimization |

## 🚀 **Usage Examples**

### Quick Access
```powershell
# View product overview
Get-Content steering/product.md

# Check tech stack
Get-Content steering/tech.md

# Review testing guidelines  
Get-Content steering/testing.md
```

### Shorthand References
```markdown
<!-- In documentation, reference other docs -->
See [TECH] for technology details
Refer to [ROAD] for roadmap information
Check [QASY] for QA processes
```

### Code Comments
```powershell
# Follow [ARCH] structure conventions
# Security per [SECU] guidelines
# Testing per [TEST] standards
```

## 📁 **Organization Principles**

### **1. Hierarchical Structure**
- **Core**: Essential platform documentation
- **Dev**: Development and operations
- **GUI**: User interface documentation  
- **Rel**: Release management
- **QA**: Quality assurance

### **2. Shorthand System**
- **4-letter codes** for easy reference
- **Consistent naming** across all docs
- **Cross-references** using codes
- **Quick lookup** via index table

### **3. Content Standards**
- **Concise**: Focus on actionable information
- **Current**: Keep documentation up-to-date
- **Linked**: Cross-reference related topics
- **Searchable**: Use consistent terminology

## 🔄 **Maintenance**

### **Adding New Documents**
1. Choose appropriate category (CORE/DEV/GUI/REL/QA)
2. Assign 4-letter code (check index for conflicts)
3. Update this README index table
4. Add cross-references in related documents

### **Document Lifecycle**
- **Active**: Current, maintained documents
- **Archive**: Historical documents moved to `/archive/`
- **Deprecated**: Outdated documents marked for removal

### **Review Schedule**
- **Monthly**: Review and update active documents
- **Quarterly**: Archive outdated documents
- **Annually**: Comprehensive documentation audit

## 📊 **Document Status**

| Status | Count | Description |
|--------|-------|-------------|
| ✅ Active | 12 | Current, maintained documents |
| 📝 Draft | 9 | In development |
| 🗄️ Archive | 60+ | Historical documents |
| ❌ Deprecated | 0 | Marked for removal |

---

**Last Updated**: $(Get-Date -Format 'yyyy-MM-dd')  
**Maintainer**: Velociraptor Setup Scripts Team  
**Version**: 1.0.0