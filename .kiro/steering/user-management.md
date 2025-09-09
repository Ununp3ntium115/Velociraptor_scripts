# Velociraptor User Management Guide

## User Management Best Practices

This document provides proven methods for managing Velociraptor users based on successful deployment experience.

### Quick User Setup

#### Default Admin Account
After successful deployment using [DEPLOY-SUCCESS], create the default admin account:

```powershell
# Default credentials for initial setup
Username: admin
Password: admin123
Role: administrator
```

### User Management Scripts

#### Add-VelociraptorUser.ps1
Simple script for adding users to an existing Velociraptor instance:

```powershell
.\Add-VelociraptorUser.ps1 -Username "admin" -Password "admin123"
```

**Features:**
- Adds user with administrator role
- Works with running Velociraptor instance
- Provides clear feedback and login instructions

#### Restart-VelociraptorWithUser.ps1
Comprehensive script that restarts Velociraptor with proper user management:

```powershell
.\Restart-VelociraptorWithUser.ps1 -Username "admin" -Password "admin123"
```

**Features:**
- Stops existing Velociraptor processes
- Generates proper configuration file
- Adds user to configuration
- Restarts with user authentication enabled

### User Management Workflow

#### Initial Setup (No Authentication)
1. Deploy using [DEPLOY-SUCCESS] method
2. Access web interface (no authentication required initially)
3. Add users through scripts or web interface
4. Restart with authentication enabled

#### Production Setup (With Authentication)
1. Use `Restart-VelociraptorWithUser.ps1` for proper user management
2. Configure multiple users with appropriate roles
3. Enable proper SSL certificates
4. Set up user access controls

### User Roles and Permissions

#### Administrator Role
- Full system access
- User management capabilities
- Configuration management
- All artifact and hunt permissions

#### Standard User Role
- Limited system access
- Cannot manage users
- Cannot modify server configuration
- Can run hunts and collect artifacts

### Security Considerations

#### Password Management
- Change default passwords immediately in production
- Use strong passwords (minimum 12 characters)
- Consider implementing password policies
- Regular password rotation for shared accounts

#### Access Control
- Limit administrator accounts to essential personnel
- Use principle of least privilege
- Monitor user access and activities
- Regular user access reviews

### Troubleshooting User Issues

#### Common User Problems
- **Cannot login**: Check username/password, verify user exists
- **Access denied**: Check user role and permissions
- **Session expired**: Re-authenticate, check session timeout settings
- **User not found**: Verify user was added correctly to configuration

#### User Management Commands
```powershell
# List existing users (requires config file)
velociraptor.exe --config config.yaml user list

# Add user with specific role
velociraptor.exe --config config.yaml user add username --password password --role role

# Delete user
velociraptor.exe --config config.yaml user del username
```

### Integration with GUI Applications

#### GUI User Management Features
Update GUI applications to include:
- User creation forms
- Password management
- Role assignment
- User status monitoring

#### Example GUI Integration
```powershell
# Add user management to existing GUIs
function Add-UserToGUI {
    param($Username, $Password, $Role = "administrator")
    
    # Use proven user management scripts
    & ".\Add-VelociraptorUser.ps1" -Username $Username -Password $Password
}
```

### Best Practices

#### Development Environment
- Use default admin/admin123 for testing
- Reset users between test runs
- Document test user accounts

#### Production Environment
- Change all default passwords
- Use strong authentication
- Implement user access logging
- Regular security audits

#### User Onboarding
1. Create user account with appropriate role
2. Provide login instructions and URL
3. Initial training on Velociraptor interface
4. Document user responsibilities and access levels

### Automation and Scripting

#### Bulk User Creation
```powershell
# Example bulk user creation
$users = @(
    @{Username="analyst1"; Password="SecurePass123"; Role="analyst"},
    @{Username="admin2"; Password="AdminPass456"; Role="administrator"}
)

foreach ($user in $users) {
    .\Add-VelociraptorUser.ps1 -Username $user.Username -Password $user.Password
}
```

#### User Monitoring
```powershell
# Monitor user sessions and activity
function Get-VelociraptorUserStatus {
    # Check active sessions
    # Monitor user activity logs
    # Report user access patterns
}
```

### Reference Codes

- **[USER-MGMT]**: General user management guidance
- **[USER-SCRIPTS]**: User management script references
- **[USER-SECURITY]**: User security best practices
- **[USER-TROUBLESHOOT]**: User troubleshooting guidance

This user management approach has been tested and provides reliable user administration for Velociraptor deployments.