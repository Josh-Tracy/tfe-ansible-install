# Ansible Playbooks for Installing Terraform Enterprise

## Notice

Hashicorp does not create or maintain this repository. This is a personal repository.

## When to Use

When there is a need to install Terraform Enterprise on long lived, static, virtual machines or bare-metal servers. If installing on a cloud service provider, such as AWS, Azure, or GCP, the preferred method is to use Terraform open source to automate this deployment in an autoscaling group utilizing user_data scripts.

## Supported Operating Systems

Only the following operating systems are supported. If you wish to use one not listed here, update `role/install-dependencies/tasks/main.yml` to download packages for the desired OS.

- Ubuntu [focal]
- RHEL [7]
- RHEL [8]

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

A variable named `files_on_system` determines if files will be copied from the control node (where you run Ansible from) to the TFE node or not. When set to `false` the playbook will look in `roles/copy-files/files/` for the install files such as the install.sh, license.rli, airgap, and replicated.tar.gz file. and copy them to the remote TFE node. It will also do the same for TLS certificates. If set to `true` then you must have the files already placed in the `tfe_installer_dir` and `tfe_license_path` you provided in `group_vars/tfe.yaml` and certificates placed in the `tfe_config_dir`.

## Setup - Populate Input Variables

Go through the available input variables in `group_vars/tfe.yaml` and configure them to match your desired install. 

## Running the Playbook - Standalone TFE server

Once you are ready to install TFE run the command `ansible-playbook -i hosts.yaml install.yaml`. Time to complete will vary based on type of install (airgap vs online), network connections, and compute resources. Airgap installs take the longest if you have to copy the .airgap bundle to the remote host. 

Once the playbook is complete, Ansible should return a debug message similar to:

```json
            "To continue the installation, visit the following URL in your browser:",
            "",
            "  http://172.30.0.4:8800"
```

You should now be able to access the replicated admin console at port 8800, but TFE will take another 10 to 15 minutes to finish the automated install. You can watch this from the dashboard. 

## Active/Active

For active/active installs, follow the directions in `examples/active-active.md`

### Variables

Input variables for group_vars and their descriptions. Divided into sections. Some variables are repeated in multiple sections. This is on purpose.

#### Ansible Connection Variables

These variables control how Ansible connects to the remote hosts.

|    Variable                           |    Description    |    Required   |
| --- | --- | --- |
| ansible_python_interpreter      | The python interpreter to use on the remote host.         | no     |
| ansible_ssh_private_key_file  | The SSH key Ansible will use to connect to the remote host as the ansible_user.              | yes          |
| ansible_user  | The remote ssh user Ansible will try to connect as.              | yes          |

#### Ansible Enabled/Disabled Roles Variables

These variables control which Ansible roles are enabled in `install.yaml`. Helps speed up troubleshooting.

|    Variable                           |    Description    |    Required   |
| --- | --- | --- |
| install_dependencies_enabled | true or false. Enable the role to install dependencies on the TFE host | yes |
| copy_files_enabled | true or false. Enable the role to copy files to the TFE host | yes  |
| install_tfe_enabled  | true or false. Enable the role to install TFE  | yes    |

#### RHEL Variables

These variables are relevant when using RHEL OS. Can be omitted if you're not using RHEL. Ansible will detect what OS you are using.

|    Variable                           |    Description    |    Required   |
| --- | --- | --- |
| firewalld_ansible_python_interpreter | If using firewalld and selinux, python 2 interpreter must be used. Sometimes you may need to provide a different python interpreter for these tasks vs the rest of the playbooks.         | Only when using firewalld or selinux on RHEL 7   |
| install_python_2_7 | If Python 2.7 needs to be installed | no
| docker_from_centos | true or false. Whether or not to install and use the CentOS repos to install docker. If false, the playbooks assume the packages are available from a repo enabled already.      | Only when you do not have a repo enabled that provides docker on RHEL     |
| use_firewalld_enabled | true or false. Whether or not firewalld is enabled on the remote host.         | Only when using rhel     |
| selinux_enforcing| true or false. Is SElinux enforcing on the remote host?         | Only when using rhel     |

#### Active / Active Variables

These variables are relevant for using active/active. `run_install.sh` and `tfe-settings.json` are templated based on these values.

|    Variable                           |    Description    |    Required   |
| --- | --- | --- |
| enable_active_active | 0 or 1. Whether or not to enable active/active architecture. Setting to 1 disabled the replicated UI in the run_install.sh script and sets the enable_active_active in tfe-settings.json to 1. | Must be set to 0 or 1. |
| redis_host | The redis hostname.     | Only if using active/active. |
| redis_pass | The redis password if using password authentication.      | Only if using active/active with redis_use_password_auth = 1.  |
| redis_port | The redis port to connect on.       | Only if using active/active.  |
| redis_use_password_auth | 0 or 1. Whether or not to use password authentication to redis.      | Only if using active/active.  |
| redis_use_tls | 0 or 1. Whether or not to use TLS with redis.       | Only if using active/active.  |

#### Install.sh Variables

variables used to create the `run_install.sh` script. These values determine the flags that will be passed to `install.sh`.

|    Variable                           |    Description    |    Required   |
| --- | --- | --- |
| airgap_install  | true or false. Whether or not you are using airgap install mode. | yes        |
| extra_no_proxy  | When configured to use a proxy, a `,` (comma) separated list of hosts to exclude from proxying. Please note that this list does not support whitespace characters. For example: `127.0.0.1,tfe.myapp.com,myco.github.com`.        | no          |
| http_proxy   | true or false. Whether or not a proxy  is being used in the environment . | yes         |
| http_proxy_name  | If a proxy is being used, the FQDN or IP of the proxy to be passed to the install.sh script.  | Only if http_proxy is true         |
| install_docker_before  | true or false. Whether or not docker was installed on the system before running install.sh. | yes |
| tfe_installer_dir | The TFE install dir on the remote host. | yes          |
| tfe_private_ip | The private IP of the host that install.sh will use when installing TFE. Can be provided as a host var in hosts.yaml as well. | yes |

#### Misc. Variables Used for Conditionals in The Playbooks

These variables determine what actions Ansible takes during the installation.

|    Variable                           |    Description    |    Required   |
| --- | --- | --- |
| files_on_system | true or false. Are the install files (install.sh, .airgap, etc.) and TLS certs already on the remote host? If true, ansible will NOT attempt to copy these files from roles/copy-files/files/ because it assumes you have already placed them in their  tfe_installer_dir, tfe_settings_path, tfe_airgap_path, tfe_license_path, and tfe_config_dir respectively.           | yes          |
| pkg_repos_reachable_with_airgap | true or false. If airgap_install = true, whether or not packages can be download from the internet. | Only with airgap_install: true|

#### Replicated.conf Variables

These variables are used to build replicated.conf

|    Variable                           |    Description    |    Required   |
| --- | --- | --- |
| console_password  | The replicated admin console password at port 8800. | yes          |
| remove_import_settings_from | true or false. Whether or not to remove the tfe-settings.json file after install is complete. | yes  |
| tfe_installer_dir | The TFE install dir on the remote host where install.sh is placed. | yes          |
| tfe_config_dir  | The TFE configuration settings directory on the remote host. TLS certificates will go here.  | yes          |
| tfe_settings_path | The path to the tfe-settings.json file on the remote host.  | yes         |
| tfe_license_path | The path to the license file on the remote host.  | yes        |
| license_name   | The name of the license file in the roles/copy-files/file directory  | yes   |
| tfe_airgap_path  | The path to the airgap bundle on the remote host.  | yes         |
| airgap_bund_name | NO SPACES! The name of the .airgap file in the roles/copy-files/file directory   | Only if airgap_install: true    |
| repl_bundle_path  | The path to the replicated bundle on the remote host. | yes         |
| repl_conf_path  | The path to the replicated.conf file on the remote host. | yes         |
| tfe_cert_name  | The name of the tfe cert in the roles/copy-files/file directory. | yes          |
| tfe_privkey_name  | The name of the tfe cert private key in the roles/copy-files/file directory  | yes          |
| tfe_hostname | FQDN of the TFE server that is ALSO a valid name on your TLS/SSL certificate | yes          |
| tfe_release_sequence | The TFE release sequence to use if online install when airgap_install: false | yes |
| tls_bootstrap_type | Whether ot not TFE should generate its own certificates. Set to "server-path" when providing TLS certificates. | yes         |

#### settings.json Variables

These settings determine the configuration for tfe-settings.json and ultimatley the TFE application.

|    Variable                           |    Description    |    Required   |
| --- | --- | --- |
| aws_access_key_id | AWS Access key ID to connect to object storage. | Only when using external services that require this such as S3, MinIO, HitachiS3, etc.          |
| aws_secret_access_key | AWS Access key to connect to object storage.       | Only when using external services that require this such as S3, MinIO, HitachiS3, etc.          |
| ca_bundle_name  | The name of the tfe CA custom bundle in the roles/copy-files/file directory  | Only if using a CA bundle.          |
| ca_cert_data  | A one line string with no new lines that contains the custom CA bundle. Use the command `awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' roles/copy-files/files/fullchain1.pem` to get the correct output.  | Only if using a CA bundle.  |
| encryption_password | The encryption password for the internal vault. Must be the same on all TFE nodes when using active/active. | yes          |
| mounted_disk  | true or false. Whether or not to use mounted disk or external services. | yes          |
| production_type | "disk" or "external".       | yes          |
| disk_path | The path to store app data is using production_type: disk.       | Only if using mounted disk       |
| capacity_concurrency | The amount of terraform runs allowed to be performed in parallel .      | yes          |
| capacity_memory | Amount of memory allocated to each terraform run .      | yes          |
| enable_metrics_collection | 0 or 1. Whether or not to enable metrics collection.       | yes         |
| metrics_endpoint_enabled  | 0 or 1. Whether or not to enable metrics collection endpoint.       | yes          |
| metrics_endpoint_port_http | Metrics collection http port.     | no          |
| metrics_endpoint_port_https |  Metrics collection https port.       |no         |
| force_tls  | 0 or 1. When set, TFE will require all application traffic to use HTTPS by sending a 'Strict-Transport-Security' header value in responses, and marking cookies as secure. A valid, trusted TLS certificate must be installed when this option is set, as browsers will refuse to serve webpages that have an HSTS header set that also serve self-signed or untrusted certificates.       | yes          |
| hairpin_addressing   | 0 or 1. When set, TFE services will direct traffic destined for the installation's FQDN toward the instance's internal IP address. This is useful for cloud environments where HTTP clients running on instances behind a load balancer cannot send requests to the public hostname of that load balancer.       | yes          |
| pg_dbname   | The name of the pg database when using external services | Only when using external services.        |
| pg_netloc   | The FQDN:port or IP:port  of the pg database when using external services.      | Only when using external services.         |
| pg_password   | The password for the pg database when using external services.       | Only when using external services.     |
| pg_user   | The user to authenticate as when using external services.       | Only when using external services.          |
| restrict_worker_metadata_access  | 0 or 1. Prevents the environment where Terraform operations are executed from accessing the cloud instance metadata service. This should not be set when Terraform operations rely on using instance metadata (i.e., the instance IAM profile) as part of the Terraform provider configuration. Note: a bug in Docker version 19.03.3 prevents this setting from working correctly. Operators should avoid using this Docker version when enabling this setting.       | yes          |
| custom_s3_endpoint  | true or false. Whether or not you will be providing an s3 endpoint or using the defaults. If you set this to false, TFE will use the defaults automagically. If true, you must provide an endpoint.       | yes         |
| s3_app_endpoint_url  | The endpoint URL for s3 object storage. Only needed if `custom_s3_endpoint: true`.        | no          |
| s3_app_bucket_name  | The name of the s3 bucket.       | Only when using external services.          |
| s3_app_bucket_region  | The region of the s3 bucket. Set to us-east-1 for self hosts s3 storage.       | Only when using external services.          |
| s3_use_kms  | true or false. If the s3 bucket is encrypted with kms or not.     | Only when using external services          |
| s3_sse_kms_key_id   | The kms key id if `s3_use_kms: true `  | Only when using external services and KMS      |
| tbw_image | Set this to custom_image if you want to use an alternative Terraform build worker image (the default is default_image).   | no     |
| tfe_hostname | FQDN of the TFE server that is ALSO a valid name on your TLS/SSL certificate | yes          |
| log_forwarding_enabled | 0 or 1. Not supported at this time with this playbook.       | yes  |
| log_forwarding_config | Not supported at this time with this playbook.       | yes  |

#### Airgap Related Variables

|    Variable                           |    Description    |    Required   |
| --- | --- | --- |
| replicated_tar_name  | NO SPACES! The name of the replicated.tar.gz file in the roles/copy-files/file directory       | Only if airgap_install: true           |


#### upgrade-airgap.yaml Variables

|    Variable                           |    Description    |    Required   |
| --- | --- | --- |
| upgrade_target_version | The version of TFE you want to upgrade to | Only when using airgap install mode. |

# app-config-update.yaml Variables

|    Variable                           |    Description    |   yes  |
| --- | --- | --- |
| update_key | The key in settings.json you want to update. | yes |
| update_value | The new value of the setting. | yes |
