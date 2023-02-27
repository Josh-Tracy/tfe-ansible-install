# Ansible Playbooks for Install Terraform Enterprise

## Notice
Hashicorp does not create or maintain this repository. This is a personal repository.

## When to Use
When there is a need to install Terraform Enterprise on long lived, static, virtual machines or bare-metal servers. If installing on a cloud service provider, such as AWS, Azure, or GCP, the preferred method is to use Terraform open source to automate this deployment in an autoscaling group utilizing user_data scripts.

## Supported Operating Systems
Only the following operating systems are supported. If you wish to use one not listed here, update `role/install-dependencies/tasks/main.yml` to download packages for the desired OS.

- Ubuntu

## How to Use
`install.yaml` is the main entry point for installing TFE with Ansible. It calls the specific roles you enable depending on what you are trying to accomplish. You can enable and disable roles at will by editing the variables at the top of `group_vars/tfe.yaml`. This saves time when troubleshooting and running the playbook over and over.

Example roles in install.yaml:

```YAML
- name : Install dependencies
  hosts: tfe
  become: yes
  roles:
    - { role: install-dependencies, when: install_dependencies_enabled }

- name : Create the automated installation of TFE and install
  hosts: tfe
  become: yes
  roles:
    - { role: install-tfe, when: install_tfe_enabled }
```

Example of enabling and disabling roles:
```YAML
# Enable or Disable Ansible Roles
install_dependencies_enabled: false
copy_files_enabled: true
install_tfe_enabled: true
```
## Setup - Verify Host Connection

1. Add the ip address or FQDN of the server that TFE will be installed on to the `hosts.yaml` file under the `tfe` host group.
2. Put the ssh private key .pem in this directory, or somewhere ansible can reach it on the ansible control node.
3. Add the path the to ssh private key and the ssh username to the `group_vars/tfe.yaml` file.
4. Run `ansible tfe -m ping -i hosts.yaml` to test the connection to the host (note: This may fail if ICMP pings are blocked)
5. Populate the rest of the variables in `group_vars/tfe.yaml` using the table in this README as a guide and the examples directory.


## Setup - Install Files and TLS Certificates
A variable named `files_on_system` determines if files will be copied from the control node (where you run Ansible from) to the TFE node or not. When set to `false` the playbook will look in `roles/copy-files/files/` for the install files such as the install.sh, license.rli, airgap, and replicated.tar.gz file. and copy them to the remote TFE node. It will also do the same for TLS certifiactes. If set to `true` then you must have the files already placed in the `tfe_installer_dir` and `tfe_license_path` you provided in `group_vars/tfe.yaml` and certificates placed in the `tfe_config_dir`.

## Setup - Populate Input Variables
Go through the availalbe input variables in `group_vars/tfe.yaml` and configure them to match your desired install. 

## Running the Playbook - Standalone TFE server
Once you are ready to install TFE run the command `ansible-playbook -i hosts.yaml install.yaml`. Time to complete will vary based on type of install (airgap vs online), network connections, and compute resources. Airgap installs take the longest if you have to copy the .airgap bundle to the remote host. 

Once the playbook is complete, Ansible should return a debug message similiar to:

```json
            "To continue the installation, visit the following URL in your browser:",
            "",
            "  http://172.30.0.4:8800"
```

You should now be able to access the replicated admin console at port 8800, but TFE will take another 10 to 15 minutes to finish the automated install. You can watch this from the dashboard. 

## Active/Active
For active/active installs, follow the directions in `examples/active-active.md`

### Variables

|    Variable                           |    Description    |    Required   |
| ---------                             | ---------         | ---------     |
| tfe_private_ip | The private IP of the host that install.sh will use when installing TFE | yes |
| install_dependencies_enabled | true or false. Enable the role to install dependencies on the TFE host | yes |
| copy_files_enabled | true or false. Enable the role to copy files to the TFE host | yes  |
| install_tfe_enabled  | true or false. Enable the role to install TFE  | yes    |
| ansible_ssh_private_key_file  | The SSH key Ansible will use to connect to the remote host              | yes          |
| ansible_user  | The remote user Ansible will try to connect as              | yes          |
| airgap_install  | true or false. Whether or not you are using airgap install mode | yes        |
| pkg_repos_reachable_with_airgap | true or false. If using airgap, whether or not packages can be download from the internet  | Only with airgap_install: true|
| install_docker_before  | true or false. Whether or not docker was installed on the system before running install.sh | yes |
| files_on_system | true or false. Are the install files and TLS certs already on the remote host?             | yes          |
| tfe_installer_dir | The TFE install dir on the remote host | yes          |
| tfe_config_dir  | The TFE configuration settings directory on the remote host  | yes          |
| tfe_settings_path | The path to the tfe-settings.json file on the remote host  | yes         |
| tfe_license_path | The path to the license file on the remote host  | yes        |
| tfe_airgap_path  | The path to the airgap bundle on the remote host  | yes         |
| repl_bundle_path  | The path to the replicated bundle on the remote host | yes         |
| repl_conf_path  | The path to the replicated.conf file on the remote host | yes         |
| tfe_cert_name  | The name of the tfe cert in the roles/copy-files/file directory | yes          |
| tfe_privkey_name  | The name of the tfe cert private key in the roles/copy-files/file directory  | yes          |
| ca_bundle_name  | The name of the tfe CA custom bundle in the roles/copy-files/file directory  | Only if using a CA bundle.          |
| ca_cert_data  | A one line string with no new lines that contains the custom CA bundle  | Only if using a CA bundle.  |
| license_name   | The name of the license file in the roles/copy-files/file directory  | yes   |
| airgap_bund_name | The name of the .airgap file in the roles/copy-files/file directory   | Only if airgap_install: true    |
| replicated_tar_name  | The name of the replicated.tar.gz file in the roles/copy-files/file directory       | Only if airgap_install: true           |
| console_password  | The replicated admin console password at port 8800 | yes          |
| encryption_password | The encyption password for the internal vault. Must be the same on all TFE nodes when using active/active | yes          |
| tfe_release_sequence | The TFE release sequence to use if online install when airgap_install: false | yes |
| tls_bootstrap_type | The name of the license file in the roles/copy-files/file directory | yes         |
| remove_import_settings_from | true or false. Whether or not to remove the tfe-settings.json file after install is complete. | yes  |
| mounted_disk  | true or false. Whether or not to use mounted disk or external services. | yes          |
| aws_access_key_id | AWS Access key ID to connect to object storage | Only when using external services that require this such as S3, MinIO, HitachiS3, etc.          |
| aws_secret_access_key | AWS Access key to connect to object storage       | Only when using external services that require this such as S3, MinIO, HitachiS3, etc.          |
| production_type | "disk" or "external"       | yes          |
| disk_path | The path to store app data is using production_type: disk       | Only if using mounted disk       |
| capacity_concurrency | The amount of terraform runs allowed to be performed in parallel       | yes          |
| capacity_memory | Amount of memory allocated to each terraform run       | yes          |
| enable_metrics_collection | 0 or 1. Whether or not to enable metrics collection       | yes         |
| metrics_endpoint_enabled  | 0 or 1. Whether or not to enable metrics collection endpoint       | yes          |
| metrics_endpoint_port_http | 0 or 1. Metrics collection http port     | no          |
| metrics_endpoint_port_https |  0 or 1. Metrics collection https port       |no         |
| extra_no_proxy  | When configured to use a proxy, a , (comma) separated list of hosts to exclude from proxying. Please note that this list does not support whitespace characters. For example: 127.0.0.1,tfe.myapp.com,myco.github.com        | no          |
| force_tls  | 0 or 1. When set, TFE will require all application traffic to use HTTPS by sending a 'Strict-Transport-Security' header value in responses, and marking cookies as secure. A valid, trusted TLS certificate must be installed when this option is set, as browsers will refuse to serve webpages that have an HSTS header set that also serve self-signed or untrusted certificates.       | yes          |
| hairpin_addressing   | 0 or 1. When set, TFE services will direct traffic destined for the installation's FQDN toward the instance's internal IP address. This is useful for cloud environments where HTTP clients running on instances behind a load balancer cannot send requests to the public hostname of that load balancer       | yes          |
| pg_dbname   | The name of the pg database when using external services | Only when using external services        |
| pg_netloc   | The FQDN:port or IP:port  of the pg database when using external services      | Only when using external services          |
| pg_password   | The password for the pg database when using external services       | Only when using external services     |
| pg_user   | The user to authenticate as when using external services       | Only when using external services          |
| restrict_worker_metadata_access  | 0 or 1. Prevents the environment where Terraform operations are executed from accessing the cloud instance metadata service. This should not be set when Terraform operations rely on using instance metadata (i.e., the instance IAM profile) as part of the Terraform provider configuration. Note: a bug in Docker version 19.03.3 prevents this setting from working correctly. Operators should avoid using this Docker version when enabling this setting.       | yes          |
| custom_s3_endpoint  | true or false. Whether or not you will be providing an s3 endpoint or using the defaults. If you set this to false, TFE will use the defaults automagically. If true, you must provide an endpoint       | yes         |
| s3_app_endpoint_url  | The endpoint URL for s3 object storage. Only needed if `custom_s3_endpoint: true`        | no          |
| s3_app_bucket_name  | The name of the s3 bucket.       | Only when using external services          |
| s3_app_bucket_region  | The region of the s3 bucket. Set to us-east-1 for self hosts s3 storage.       | Only when using external services          |
| s3_use_kms  | true or false. If the s3 bucket is encrypted with kms or not.     | Only when using external services          |
| s3_sse_kms_key_id   | The kms key id if `s3_use_kms: true `  | Only when using external services and KMS      |
| tbw_image | Set this to custom_image if you want to use an alternative Terraform build worker image (the default is default_image).   | no     |
| http_proxy   | true or false. Whether or not a proxy  is being used in the environment  | yes         |
| http_proxy_name  | If a proxy is being used, the FQDN or IP of the proxy to be passed to the install.sh script  | Only if http_proxy is true         |
| redis_host | The redis hostname      | Only if using active/active  |
| redis_pass | The redis password if using password authentication       | Only if using active/active  |
| redis_port | The redis port to connect on       | Only if using active/active  |
| redis_use_password_auth | 0 or 1. Whether or not to use password authentication to redis      | Only if using active/active  |
| redis_use_tls | 0 or 1. Whether or not to use TLS with redis       | Only if using active/active  |
| log_forwarding_enabled | 0 or 1. Whether or not to enable log forwarding       | yes  |
| log_forwarding_config | 0 or 1. Whether or not to enable active active architecture.       | yes  |