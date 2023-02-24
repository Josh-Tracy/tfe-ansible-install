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