## When to Use
When there is a need to install Terraform Enterprise on long lived, static, virtual machines or bare-metal servers. If installing on a cloud service provider, such as AWS, Azure, or GCP, the preferred method is to use Terraform open source to automate this deployment in an autoscaling group by utilizing user_data scripts.

## How to Use
`playbook.yaml` is the main entry point for installing TFE with Ansible. It calls the specific roles you enable depending on what you are trying to accomplish. You can enable and disable roles at will by editing the variables in `group_vars/tfe.yaml`

Example playbook.yaml:

```YAML
- name : Create the automated installation of TFE and install
  hosts: tfe
  become: yes
  roles:
    - { role: install-tfe, when: install_tfe_enabled }

- name : Uninstall TFE
  hosts: tfe
  become: yes
  roles:
    - { role: uninstall-tfe, when: uninstall_tfe_enabled }
```

Example of enabling and disabling roles:
```YAML
# Enable or Disable Ansible Roles
install_dependencies_enabled: false
copy_files_enabled: true
install_tfe_enabled: true
uninstall_tfe_enabled: false
```
## Setup - Verify Host Connection

1. Add the ip address or FQDN of the server that TFE will be installed on to the `hosts` file
2. Put the ssh private key .pem in this directory, or somewhere ansible can reach it on the host
3. Add the path the to ssh private key and the ssh username to the `group_vars/tfe-.yaml` file
4. Run `ansible tfe -m ping -i hosts` to test the connection to the host (note: This may fail if ICMP pings are blocked)
5. Populate the rest of the variables in `group_vars/tfe.yaml` using the table ___ here ___ as a guide.


## Setup - Install Files and TLS Certificates
A variable named `files_on_system` determines if files will be copied from the control node (where you run Ansible from) to the TFE node or not. When set to `false` the playbook will look in `roles/copy-files/files/` for the install files such as the install.sh, license.rli, airgap, and replicated.tar.gz file. and copy them to the remote TFE node. It will also do the same for TLS certifiactes. If set to `true` then you must have the files already placed in the `tfe_installer_dir` and `tfe_license_path` you provided in `group_vars/tfe.yaml` and certificates placed in the `tfe_config_dir`.

## Setup - Populate Input Variables
Go through the availalbe input variables in `group_vars/tfe.yaml` and configure them to match your desired install. 

## Running the Playbook
Once you are ready to install TFE run the command `ansible-playbook -i hosts playbook.yaml`. Time to complete will vary based on type of install (airgap vs online), network connections, and compute resources. Airgap installs take the longest if you have to copy the .airgap bundle to the remote host. 

Once the playbook is complete, Ansible should return a debug message similiar to:

```json
            "To continue the installation, visit the following URL in your browser:",
            "",
            "  http://172.30.0.4:8800"
```

You should now be able to access the replicated admin console at port 8800, but TFE will take another 10 to 15 minutes to finish the automated install. You can watch this from the dashboard. 

### Variables

|    Variable                           |    Description    |    Required   |
| ---------                             | ---------         | ---------     |
| install_dependencies_enabled          | Enable the role to install dependencies on the TFE host             | yes          |
| copy_files_enabled                    | Enable the role to copy files to the RFe host             | test          |
| install_tfe_enabled                   | Enable the role to install TFE            | test          |
| uninstall_tfe_enabled                  | Enable the role to uninstall TFE              | test          |
| ansible_ssh_private_key_file            | The SSh key Ansible will use to connect to the remote host              | test          |
| ansible_user                    | The remote user Ansible will try to connect as              | test          |
| airgap_install                    | True or False. Whether or not you are using airgap install mode           | test          |
| pkg_repos_reachable_with_airgap           | True or False. If using airgap, whether or not packages can be download from the internet             | test          |
| install_docker_before                    | True or False. Whether or not docker was installed on the system before running install.sh              | test          |
| files_on_system                    | True or False. Are the install files and TLS certs already on the remote host?             | test          |
| tfe_installer_dir                    | The TFE install dir on the remote host              | test          |
| tfe_config_dir                   | The TFE configuration settings directory on the remote host             | test          |
| tfe_settings_path                    | The path to the tfe-settings.json file on the remote host             | test          |
| tfe_license_path                    | The path to the license file on the remote host              | test          |
| tfe_airgap_path                    | The path to the airgap bundle on the remote host              | test          |
| repl_bundle_path                    | The path to the replicated bundle on the remote host              | test          |
| repl_conf_path                    | The path to the replicated.conf file on the remote host             | test          |
| tfe_cert_name                    | The name of the tfe cert in the roles/copy-files/file directory              | test          |
| tfe_privkey_name                    | The name of the tfe cert private key in the roles/copy-files/file directory              | test          |
| ca_bundle_name                    | The name of the tfe CA custom bundle in the roles/copy-files/file directory              | test          |
| ca_cert_data                    | A one line string with no new lines that contains the custom CA bundle             | test          |
| license_name                    | The name of the license file in the roles/copy-files/file directory       | test          |