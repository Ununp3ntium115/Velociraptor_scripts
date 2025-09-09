Server:
  bind_address: 0.0.0.0
  port: 8889                        # GUI + API
GUI:
  bind: 0.0.0.0
  port: 8889
  base_path: /                      # change if behind a proxy subpath
  tls_certificate: config/tls/server.crt
  tls_private_key: config/tls/server.key
  authentication: basic             # or oidc / externally terminated
  users_db: config/users.yaml       # if using local accounts
Datastore:
  implementation: filestore         # default filesystem-backed
  location: data/datastore
Filestore:
  location: data/filestore
Logging:
  file: logs/server.log
  audit_log: logs/audit.log
Artifacts:
  repository:
    - builtin
    - config/artifacts/custom
Downloads:
  location: data/downloads
# Minimal server.config.yaml Keys for GUI Operation

## Essential Configuration Keys for Velociraptor GUI

This document outlines the minimal configuration keys required for Velociraptor GUI operation, supporting both [SIMPLE-GUI] and advanced deployments.

### Core Server Configuration

#### Basic Server Settings
```yaml
version:
  name: velociraptor
  version: "0.7.0"
  commit: "unknown"
  build_time: "unknown"

# Server identity and binding
server_type: server
bind_address: 127.0.0.1
bind_port: 8889

# GUI-specific settings
gui:
  bind_address: 127.0.0.1
  bind_port: 8889
  gw_certificate: |
    -----BEGIN CERTIFICATE-----
    [Auto-generated certificate content]
    -----END CERTIFICATE-----
  gw_private_key: |
    -----BEGIN RSA PRIVATE KEY-----
    [Auto-generated private key content]
    -----END RSA PRIVATE KEY-----
```

#### Certificate Configuration
```yaml
# Client certificate authority
ca_certificate: |
  -----BEGIN CERTIFICATE-----
  [Certificate Authority content]
  -----END CERTIFICATE-----

ca_private_key: |
  -----BEGIN RSA PRIVATE KEY-----
  [CA Private Key content]
  -----END RSA PRIVATE KEY-----

# Server certificates
server_certificate: |
  -----BEGIN CERTIFICATE-----
  [Server certificate content]
  -----END CERTIFICATE-----

server_private_key: |
  -----BEGIN RSA PRIVATE KEY-----
  [Server private key content]
  -----END RSA PRIVATE KEY-----
```

### GUI-Specific Configuration

#### GUI Access Control
```yaml
gui:
  # Basic GUI settings
  bind_address: 127.0.0.1
  bind_port: 8889
  
  # Authentication settings
  authenticator:
    type: Basic
    
  # User database (when using file-based auth)
  users:
    - name: admin
      password_hash: "$2a$10$[bcrypt_hash]"
      roles:
        - administrator
        
  # Session management
  session_timeout: 3600  # 1 hour
  
  # HTTPS settings
  use_plain_http: false
  certificate: |
    -----BEGIN CERTIFICATE-----
    [GUI certificate content]
    -----END CERTIFICATE-----
  private_key: |
    -----BEGIN RSA PRIVATE KEY-----
    [GUI private key content]
    -----END RSA PRIVATE KEY-----
```

#### Datastore Configuration
```yaml
# Datastore settings (required for GUI operation)
datastore:
  implementation: FileBaseDataStore
  location: ./datastore
  filestore_directory: ./datastore
```

### Auto-Generated Configuration (Simple GUI Mode)

When using [WORKING-CMD] (`velociraptor.exe gui`), Velociraptor auto-generates a minimal configuration:

```yaml
# Auto-generated minimal config
version:
  name: velociraptor
  version: "0.7.0"

server_type: server
bind_address: 127.0.0.1
bind_port: 8889

gui:
  bind_address: 127.0.0.1
  bind_port: 8889
  use_plain_http: false
  # Certificates auto-generated

datastore:
  implementation: FileBaseDataStore
  location: ./temp/datastore

# No user authentication required initially
```

### Advanced GUI Configuration

#### Multi-User Setup
```yaml
gui:
  authenticator:
    type: Basic
    
  users:
    - name: admin
      password_hash: "$2a$10$[admin_hash]"
      roles:
        - administrator
    - name: analyst
      password_hash: "$2a$10$[analyst_hash]"
      roles:
        - reader
        - investigator
    - name: viewer
      password_hash: "$2a$10$[viewer_hash]"
      roles:
        - reader
```

#### SAML/OAuth Integration
```yaml
gui:
  authenticator:
    type: SAML
    saml_certificate: |
      -----BEGIN CERTIFICATE-----
      [SAML certificate]
      -----END CERTIFICATE-----
    saml_private_key: |
      -----BEGIN RSA PRIVATE KEY-----
      [SAML private key]
      -----END RSA PRIVATE KEY-----
    saml_idp_metadata_url: "https://idp.example.com/metadata"
```

### Security Configuration

#### SSL/TLS Settings
```yaml
gui:
  # Force HTTPS
  use_plain_http: false
  
  # Certificate settings
  certificate: |
    -----BEGIN CERTIFICATE-----
    [SSL certificate]
    -----END CERTIFICATE-----
  private_key: |
    -----BEGIN RSA PRIVATE KEY-----
    [SSL private key]
    -----END RSA PRIVATE KEY-----
    
  # Security headers
  security_headers:
    X-Frame-Options: "DENY"
    X-Content-Type-Options: "nosniff"
    X-XSS-Protection: "1; mode=block"
```

#### Access Control
```yaml
gui:
  # IP restrictions
  allowed_ips:
    - 127.0.0.1
    - 192.168.1.0/24
    
  # Rate limiting
  rate_limit:
    requests_per_minute: 60
    
  # Session security
  session_timeout: 1800  # 30 minutes
  secure_cookies: true
```

### Logging Configuration

#### GUI Access Logging
```yaml
logging:
  # Log GUI access
  access_log: "./logs/access.log"
  
  # Audit logging
  audit_log: "./logs/audit.log"
  
  # Debug logging for GUI issues
  debug:
    gui: true
    auth: true
```

### Performance Configuration

#### GUI Performance Settings
```yaml
gui:
  # Connection limits
  max_connections: 100
  
  # Timeout settings
  read_timeout: 30
  write_timeout: 30
  
  # Buffer sizes
  max_upload_size: 104857600  # 100MB
  
  # Caching
  static_cache_timeout: 3600  # 1 hour
```

### Configuration Validation

#### Required Keys for GUI Operation
1. **version** - Version information
2. **server_type** - Must be "server"
3. **gui.bind_address** - GUI binding address
4. **gui.bind_port** - GUI port (default 8889)
5. **datastore** - Datastore configuration
6. **Certificates** - SSL certificates for HTTPS

#### Optional Keys for Enhanced GUI
1. **gui.users** - User authentication
2. **gui.authenticator** - Authentication method
3. **logging** - Access and audit logging
4. **gui.security_headers** - Security enhancements

### Configuration Generation Commands

#### Generate Basic Configuration
```powershell
# Generate minimal config
velociraptor.exe config generate --config server.config.yaml

# Generate with GUI settings
velociraptor.exe config generate --config server.config.yaml --gui
```

#### Validate Configuration
```powershell
# Validate configuration file
velociraptor.exe --config server.config.yaml config validate

# Test GUI configuration
velociraptor.exe --config server.config.yaml gui --dry-run
```

### Integration with [USER-MGMT]

#### Add Users to Configuration
```powershell
# Add user with password
velociraptor.exe --config server.config.yaml user add admin --password admin123 --role administrator

# List users
velociraptor.exe --config server.config.yaml user list
```

### Troubleshooting Configuration Issues

#### Common GUI Configuration Problems
1. **Certificate Issues**: Ensure certificates are properly formatted
2. **Port Binding**: Check bind_address and bind_port settings
3. **Authentication**: Verify user configuration and password hashes
4. **Datastore**: Ensure datastore location is accessible

#### Configuration Testing
```powershell
# Test configuration syntax
velociraptor.exe --config server.config.yaml config validate

# Test GUI startup
velociraptor.exe --config server.config.yaml gui --dry-run

# Check port binding
netstat -an | findstr :8889
```

This minimal configuration approach supports both [SIMPLE-GUI] auto-generated configs and full production configurations with proper user management and security settings.