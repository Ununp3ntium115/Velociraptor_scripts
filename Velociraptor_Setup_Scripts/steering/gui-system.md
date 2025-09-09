# GUIS - GUI System Architecture

**Code**: `GUIS` | **Category**: GUI | **Status**: ✅ Active

## 🖥️ **GUI Architecture**

### **Core Components**
- **VelociraptorGUI.ps1**: Main configuration wizard
- **IncidentResponseGUI.ps1**: Incident response interface
- **Enhanced-Package-GUI.ps1**: Package management interface

### **Technology Stack**
- **Framework**: Windows Forms (.NET)
- **Language**: PowerShell 5.1+ / PowerShell Core 7.0+
- **UI Library**: System.Windows.Forms, System.Drawing
- **Cross-Platform**: PowerShell Core for Linux/macOS support

## 🎨 **Design Patterns**

### **Wizard-Style Interface**
9-step configuration process:
1. Welcome & Overview
2. Deployment Type Selection
3. Storage Configuration
4. Certificate Settings
5. Security Configuration
6. Network Settings
7. Authentication Setup
8. Review & Generate
9. Deployment Complete

### **Component Architecture**
```powershell
# Form creation pattern
$form = New-Object System.Windows.Forms.Form
$form.Text = "Velociraptor Configuration Wizard"
$form.Size = New-Object System.Drawing.Size(800, 600)
$form.StartPosition = "CenterScreen"

# Control validation pattern
$textBox.Add_TextChanged({
    if (Test-ValidInput $textBox.Text) {
        $textBox.BackColor = [System.Drawing.Color]::White
    } else {
        $textBox.BackColor = [System.Drawing.Color]::LightPink
    }
})
```

## 🔧 **GUI Components**

### **Input Controls**
- **TextBox**: Configuration paths, server names
- **ComboBox**: Dropdown selections (deployment type, security level)
- **CheckBox**: Feature toggles (SSL, auto-start)
- **NumericUpDown**: Port numbers, timeouts
- **FolderBrowserDialog**: Directory selection
- **OpenFileDialog**: File selection

### **Display Controls**
- **Label**: Field descriptions and instructions
- **ProgressBar**: Deployment progress indication
- **RichTextBox**: Configuration preview and logs
- **TabControl**: Multi-section interfaces
- **GroupBox**: Logical control grouping

### **Action Controls**
- **Button**: Navigation (Next, Back, Deploy)
- **MenuStrip**: Application menu
- **ToolStrip**: Quick action toolbar
- **StatusStrip**: Status information

## 🎯 **User Experience Patterns**

### **Validation Strategy**
- **Real-time validation**: Immediate feedback on input
- **Visual indicators**: Color coding for valid/invalid states
- **Error messages**: Clear, actionable error descriptions
- **Progress tracking**: Visual progress through wizard steps

### **Accessibility Features**
- **Keyboard navigation**: Tab order and shortcuts
- **Screen reader support**: Proper control labeling
- **High contrast**: Color scheme considerations
- **Tooltips**: Helpful context information

## 🔄 **State Management**

### **Configuration State**
```powershell
# Global configuration object
$Global:VelociraptorConfig = @{
    DeploymentType = 'Standalone'
    InstallPath = 'C:\tools'
    DataPath = 'C:\VelociraptorData'
    SecurityLevel = 'Standard'
    NetworkConfig = @{
        GuiPort = 8889
        ServerPort = 8000
    }
}
```

### **Form State Transitions**
- **Step validation**: Ensure required fields before proceeding
- **Back navigation**: Preserve previous selections
- **Configuration persistence**: Save/load configuration files
- **Error recovery**: Handle and recover from errors gracefully

## 🧪 **Testing Approach**

### **GUI Testing Strategy**
- **Unit tests**: Individual control behavior
- **Integration tests**: Form workflow validation
- **User acceptance tests**: End-to-end scenarios
- **Cross-platform tests**: PowerShell Core compatibility

### **Test Automation**
```powershell
# GUI component testing
Describe "VelociraptorGUI Form" {
    It "Should create main form" {
        $form = New-VelociraptorForm
        $form.Text | Should -Be "Velociraptor Configuration Wizard"
    }
    
    It "Should validate port numbers" {
        $result = Test-PortValidation -Port 8889
        $result | Should -Be $true
    }
}
```

## 🔗 **Integration Points**

### **Backend Integration**
- **Configuration generation**: YAML file creation
- **Deployment scripts**: PowerShell script execution
- **Service management**: Windows/Linux service control
- **Health monitoring**: Real-time status updates

### **AI Integration**
- **Intelligent defaults**: AI-suggested configurations
- **Validation assistance**: Smart error detection
- **Performance optimization**: Resource-aware settings

## 🔗 **Related Documents**
- [GUIG] - GUI user guide and training
- [GUIF] - GUI fixes and known issues
- [ARCH] - Overall architecture patterns
- [TEST] - Testing guidelines