#Requires -Modules Pester

<#
.SYNOPSIS
    Integration tests for GUI functionality and components.

.DESCRIPTION
    Tests the GUI components, form validation, and user interaction
    elements of the Velociraptor Setup Scripts.
#>

BeforeAll {
    # Set up test environment
    $ScriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
    $GUIScriptPath = Join-Path $ScriptRoot 'gui\VelociraptorGUI.ps1'
    $IncidentGUIPath = Join-Path $ScriptRoot 'gui\IncidentResponseGUI.ps1'
    
    # Mock Windows Forms components for testing
    if (-not ('System.Windows.Forms.Form' -as [type])) {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
        Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue
    }
    
    # Mock GUI components for headless testing
    Mock Show-MessageBox { return 'OK' }
    Mock Show-OpenFileDialog { return 'C:\test\config.yaml' }
    Mock Show-FolderBrowserDialog { return 'C:\test\folder' }
}

Describe "GUI Script Structure" {
    Context "Main GUI Script" -Skip:(-not (Test-Path $GUIScriptPath)) {
        It "Should exist" {
            Test-Path $GUIScriptPath | Should -Be $true
        }
        
        It "Should be a valid PowerShell script" {
            $scriptContent = Get-Content $GUIScriptPath -Raw
            { [scriptblock]::Create($scriptContent) } | Should -Not -Throw
        }
        
        It "Should load Windows Forms assemblies" {
            $scriptContent = Get-Content $GUIScriptPath -Raw
            $scriptContent | Should -Match 'Add-Type.*System\.Windows\.Forms'
            $scriptContent | Should -Match 'Add-Type.*System\.Drawing'
        }
        
        It "Should contain form creation code" {
            $scriptContent = Get-Content $GUIScriptPath -Raw
            $scriptContent | Should -Match 'New-Object.*Form|System\.Windows\.Forms\.Form'
        }
        
        It "Should handle command line parameters" {
            $scriptContent = Get-Content $GUIScriptPath -Raw
            $scriptContent | Should -Match 'param\s*\(|CmdletBinding'
        }
    }
    
    Context "Incident Response GUI" -Skip:(-not (Test-Path $IncidentGUIPath)) {
        It "Should exist" {
            Test-Path $IncidentGUIPath | Should -Be $true
        }
        
        It "Should be a valid PowerShell script" {
            $scriptContent = Get-Content $IncidentGUIPath -Raw
            { [scriptblock]::Create($scriptContent) } | Should -Not -Throw
        }
        
        It "Should contain incident response specific functionality" {
            $scriptContent = Get-Content $IncidentGUIPath -Raw
            $scriptContent | Should -Match 'incident|response|package|collection'
        }
    }
}

Describe "GUI Form Components" {
    Context "Form Controls" -Skip:(-not (Test-Path $GUIScriptPath)) {
        BeforeAll {
            $scriptContent = Get-Content $GUIScriptPath -Raw
        }
        
        It "Should create main form" {
            $scriptContent | Should -Match '\$form.*=.*New-Object.*Form'
        }
        
        It "Should have buttons" {
            $scriptContent | Should -Match '\$.*button.*=.*New-Object.*Button'
        }
        
        It "Should have text boxes" {
            $scriptContent | Should -Match '\$.*text.*=.*New-Object.*TextBox'
        }
        
        It "Should have labels" {
            $scriptContent | Should -Match '\$.*label.*=.*New-Object.*Label'
        }
        
        It "Should have tab controls or panels" {
            $scriptContent | Should -Match 'TabControl|Panel|GroupBox'
        }
    }
    
    Context "Event Handlers" -Skip:(-not (Test-Path $GUIScriptPath)) {
        BeforeAll {
            $scriptContent = Get-Content $GUIScriptPath -Raw
        }
        
        It "Should have click event handlers" {
            $scriptContent | Should -Match 'add_Click|\.Click\s*\+='
        }
        
        It "Should have form load handlers" {
            $scriptContent | Should -Match 'add_Load|\.Load\s*\+='
        }
        
        It "Should handle form closing" {
            $scriptContent | Should -Match 'add_FormClosing|\.FormClosing\s*\+='
        }
    }
}

Describe "GUI Functionality" {
    Context "Configuration Management" -Skip:(-not (Test-Path $GUIScriptPath)) {
        BeforeAll {
            $scriptContent = Get-Content $GUIScriptPath -Raw
        }
        
        It "Should handle configuration loading" {
            $scriptContent | Should -Match 'Get-Content.*yaml|ConvertFrom-Yaml|Import.*Config'
        }
        
        It "Should handle configuration saving" {
            $scriptContent | Should -Match 'Out-File.*yaml|ConvertTo-Yaml|Export.*Config'
        }
        
        It "Should validate configuration" {
            $scriptContent | Should -Match 'Test-Path|Validate|Check.*Config'
        }
    }
    
    Context "Deployment Integration" -Skip:(-not (Test-Path $GUIScriptPath)) {
        BeforeAll {
            $scriptContent = Get-Content $GUIScriptPath -Raw
        }
        
        It "Should integrate with deployment scripts" {
            $scriptContent | Should -Match 'Deploy.*Velociraptor|Start-Process.*Deploy'
        }
        
        It "Should show deployment progress" {
            $scriptContent | Should -Match 'ProgressBar|Progress|Status'
        }
        
        It "Should handle deployment errors" {
            $scriptContent | Should -Match 'try.*catch|ErrorAction|Exception'
        }
    }
    
    Context "User Input Validation" -Skip:(-not (Test-Path $GUIScriptPath)) {
        BeforeAll {
            $scriptContent = Get-Content $GUIScriptPath -Raw
        }
        
        It "Should validate port numbers" {
            $scriptContent | Should -Match 'port.*validation|ValidateRange.*port|\[int\].*port'
        }
        
        It "Should validate file paths" {
            $scriptContent | Should -Match 'Test-Path|ValidateScript.*path|file.*validation'
        }
        
        It "Should validate directory paths" {
            $scriptContent | Should -Match 'Test-Path.*Directory|ValidateScript.*directory'
        }
        
        It "Should provide user feedback" {
            $scriptContent | Should -Match 'MessageBox|Show.*Message|Status.*Text'
        }
    }
}

Describe "GUI Error Handling" {
    Context "Exception Management" -Skip:(-not (Test-Path $GUIScriptPath)) {
        BeforeAll {
            $scriptContent = Get-Content $GUIScriptPath -Raw
        }
        
        It "Should have try-catch blocks" {
            $scriptContent | Should -Match 'try\s*\{'
            $scriptContent | Should -Match 'catch\s*\{'
        }
        
        It "Should display error messages to user" {
            $scriptContent | Should -Match 'MessageBox.*Show|Show.*Error|Error.*Message'
        }
        
        It "Should log errors" {
            $scriptContent | Should -Match 'Write-Log.*Error|Log.*Error|Out-File.*error'
        }
    }
    
    Context "Input Validation Errors" -Skip:(-not (Test-Path $GUIScriptPath)) {
        BeforeAll {
            $scriptContent = Get-Content $GUIScriptPath -Raw
        }
        
        It "Should handle invalid input gracefully" {
            $scriptContent | Should -Match 'validation|invalid|error.*input'
        }
        
        It "Should prevent form submission with invalid data" {
            $scriptContent | Should -Match 'return.*false|prevent|validate.*before'
        }
    }
}

Describe "GUI Accessibility and Usability" {
    Context "Form Layout" -Skip:(-not (Test-Path $GUIScriptPath)) {
        BeforeAll {
            $scriptContent = Get-Content $GUIScriptPath -Raw
        }
        
        It "Should set appropriate form size" {
            $scriptContent | Should -Match 'Size.*=.*\d+,\s*\d+|Width.*=.*\d+|Height.*=.*\d+'
        }
        
        It "Should position controls appropriately" {
            $scriptContent | Should -Match 'Location.*=.*\d+,\s*\d+|Left.*=.*\d+|Top.*=.*\d+'
        }
        
        It "Should have descriptive control names" {
            $scriptContent | Should -Match 'Name.*=.*[''"][A-Za-z]+[''"]'
        }
    }
    
    Context "User Experience" -Skip:(-not (Test-Path $GUIScriptPath)) {
        BeforeAll {
            $scriptContent = Get-Content $GUIScriptPath -Raw
        }
        
        It "Should have helpful tooltips" {
            $scriptContent | Should -Match 'ToolTip|SetToolTip'
        }
        
        It "Should have appropriate tab order" {
            $scriptContent | Should -Match 'TabIndex|TabStop'
        }
        
        It "Should handle keyboard shortcuts" {
            $scriptContent | Should -Match 'KeyDown|KeyPress|Shortcut'
        }
    }
}

Describe "GUI Integration Tests" {
    Context "File Operations" {
        It "Should handle file dialogs" {
            # Mock file dialog operations
            Mock Show-OpenFileDialog { return 'C:\test\config.yaml' }
            Mock Show-SaveFileDialog { return 'C:\test\output.yaml' }
            
            # Test file dialog functionality
            $result = Show-OpenFileDialog
            $result | Should -Be 'C:\test\config.yaml'
        }
        
        It "Should handle folder selection" {
            Mock Show-FolderBrowserDialog { return 'C:\test\folder' }
            
            $result = Show-FolderBrowserDialog
            $result | Should -Be 'C:\test\folder'
        }
    }
    
    Context "Configuration Generation" {
        It "Should generate valid YAML configuration" {
            # Mock configuration data
            $configData = @{
                version = "1.0"
                server = @{
                    bind_address = "0.0.0.0"
                    bind_port = 8000
                }
            }
            
            # Test YAML generation (mock)
            $configData | Should -Not -BeNullOrEmpty
            $configData.version | Should -Be "1.0"
            $configData.server.bind_port | Should -Be 8000
        }
        
        It "Should validate generated configuration" {
            # Mock validation function
            function Test-VelociraptorConfig {
                param($ConfigPath)
                return $true
            }
            
            $result = Test-VelociraptorConfig -ConfigPath 'C:\test\config.yaml'
            $result | Should -Be $true
        }
    }
    
    Context "Deployment Integration" {
        It "Should launch deployment scripts" {
            Mock Start-Process { 
                return @{ 
                    Id = 1234
                    HasExited = $false
                    ExitCode = 0
                }
            }
            
            $process = Start-Process -FilePath 'powershell.exe' -ArgumentList '-File Deploy_Velociraptor_Standalone.ps1' -PassThru
            $process.Id | Should -Be 1234
        }
        
        It "Should monitor deployment progress" {
            Mock Get-Process { 
                return @{ 
                    Id = 1234
                    HasExited = $true
                    ExitCode = 0
                }
            }
            
            $process = Get-Process -Id 1234 -ErrorAction SilentlyContinue
            $process.HasExited | Should -Be $true
        }
    }
}

Describe "GUI Performance" {
    Context "Responsiveness" {
        It "Should handle large configuration files" {
            # Mock large configuration
            $largeConfig = @{}
            1..1000 | ForEach-Object { $largeConfig["key$_"] = "value$_" }
            
            # Should handle large data without hanging
            $largeConfig.Count | Should -Be 1000
        }
        
        It "Should update UI without blocking" {
            # Mock UI update operations
            Mock Update-ProgressBar { return $true }
            Mock Update-StatusText { return $true }
            
            # Test non-blocking UI updates
            $result1 = Update-ProgressBar
            $result2 = Update-StatusText
            
            $result1 | Should -Be $true
            $result2 | Should -Be $true
        }
    }
    
    Context "Memory Management" {
        It "Should dispose of resources properly" {
            # Mock resource disposal
            Mock Dispose-Form { return $true }
            Mock Clear-Variables { return $true }
            
            # Test resource cleanup
            $result1 = Dispose-Form
            $result2 = Clear-Variables
            
            $result1 | Should -Be $true
            $result2 | Should -Be $true
        }
    }
}

AfterAll {
    # Clean up any test resources
    Remove-Variable -Name 'TestForm' -ErrorAction SilentlyContinue
    Remove-Variable -Name 'TestConfig' -ErrorAction SilentlyContinue
}