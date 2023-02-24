# Airgap Install with Mounted Disk Example

Below is an example `group_vars/tfe.yaml` when installing TFE as mounted disk using airgap mode. All values are examples only.

```YAML
# Enable or Disable Ansible Roles
install_dependencies_enabled: true
copy_files_enabled: true
install_tfe_enabled: true
uninstall_tfe_enabled: false 

# SSH Settings
ansible_ssh_private_key_file: ansublerser-ssh.pem
ansible_user: ansibleuser

# Airgap Settings
airgap_install: true
pkg_repos_reachable_with_airgap: true
install_docker_before: true

# Are the files, such as the license, airgap, etc, already on the remote host?
# If false, these will be sourced from roles/copy-files/files/ dir
files_on_system: false

# TFE Installation file locations
tfe_installer_dir: /opt/tfe/installer
tfe_config_dir: /etc
tfe_settings_path: /etc/tfe-settings.json
tfe_license_path: /etc
tfe_airgap_path: /opt/tfe/installer
repl_bundle_path: /opt/tfe/installer
repl_conf_path: /etc/replicated.conf

# TFE TLS Certificates file names. Certificates will go in the `tfe_config_dir` on the remote host
# Certificates should be places in the roles/copy-files/files dir on the ansible control node
tfe_cert_name: tfe-cert.pem  
tfe_privkey_name: tfe-cert-key.pem
ca_bundle_name: tfe-ca-bundle.pem

# Custom certificate authority (CA) bundle. 
# JSON does not allow raw newline characters, so replace any newlines in the data with \n.
# The command awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' tfe-ca-bundle.pem can assist.
ca_cert_data: -----BEGIN CERTIFICATE-----\nMIIFIDCCBAigAwIBAgISA0t9452nQ7vgwYP4F+v/...+Q=\n-----END CERTIFICATE-----\n-----BEGIN CERTIFICATE-----\nMIIFFjCCAv6gAwIBAgIRAJErCErPDBinU/bWLiWnX1owDQYJKoZIhvcNAQELBQAw\nTzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3Vy...+XWYp6rjd5JW1zbVWEkLNxE7GJThEUG3szgBVGP7pSWTUTsqX\nnLRbwHOoq7hHwg==\n-----END CERTIFICATE-----\n-----BEGIN CERTIFICATE-----\nMIIFYDCCBEigAwIBAgIQQAF3ITfU6UK47naqPGQKtzANBgkqhkiG9w0BAQsFADA/\nMSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT\nDkRTVCBSb290IENB...+qR9sdjoSYKEBpsr6GtPAQw4dy753ec5\n-----END CERTIFICATE-----\n

# TFE File Names
license_name: tfe-license.rli

# Not required unless airgap_install: true
airgap_bund_name: tfe.airgap
replicated_tar_name: replicated.tar.gz

# TFE Install Secrets
console_password: mytfeconsolepass
encryption_password: mytfeencpass

# TFE install settings - Replicated config file
tfe_hostname: tfe.company.com
tfe_release_sequence: 0
tls_bootstrap_type: server-path
remove_import_settings_from: "false"

# Should be eth0 or equivilent, not docker0
tfe_private_ip: 172.30.0.4

# Mounted disk or External Services
mounted_disk: true

# TFE App Settings - tfe-settings.json. True = 1 False = 0
production_type: disk
disk_path: /opt/terraform-enterprise
capacity_concurrency: 10
capacity_memory: 512
enable_active_active: 0
enable_metrics_collection: 0
metrics_endpoint_enabled: 0
metrics_endpoint_port_http: null
metrics_endpoint_port_https: null
extra_no_proxy: null
force_tls: 0
hairpin_addressing: 0
pg_dbname: null
pg_netloc: null
pg_password: null
pg_user: null
restrict_worker_metadata_access: 1
s3_app_endpoint_url: null
s3_app_bucket_name: null
s3_app_bucket_region: null
tbw_image: null
http_proxy: null


# TFE App Settings - active/active - True = 1 False = 0
redis_host: null
redis_pass: null
redis_port: null
redis_use_password_auth: null
redis_use_tls: null


# TFE App settints - Log Forwarding - True = 1 False = 0
log_forwarding_enabled: 0
log_forwarding_config: null
```