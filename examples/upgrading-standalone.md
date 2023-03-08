# Upgrading TFE Versions - Standalone TFE

## Before Upgrading
Read up on the documentation https://developer.hashicorp.com/terraform/enterprise/admin/infrastructure/upgrades#before-upgrade

The most important part is:
- Create a backup copy of the storage prior to upgrading your instance. Backup and restore responsibility varies depending on your Terraform Enterprise operation mode.

## Online Installs
1. Safely drain connections from the node by running `tfe-admin node-drain` on each TFE node or `ansible-playbook -i hosts.yaml drain-nodes.yaml`.
This command will quiesce the current node and remove it from service. It will allow current work to complete and safely stop the node from picking up any new jobs from the Redis queue, allowing the application to be safely stopped.

2. Update `tfe_release_sequence` in `group_vars/tfe.yaml` to the desired version following the required release path which can be found here https://developer.hashicorp.com/terraform/enterprise/releases

>Note: * Denotes a required release. All online upgrades will automatically install this version, but airgap customers must upgrade to this version before proceeding to later releases.

3. Run `ansible-playbook -i hosts.yaml install.yaml`. TFE will restart on the new verison.

## Airgap Installs

1. Safely drain connections from the node by running `tfe-admin node-drain` on the TFE node or `ansible-playbook -i hosts.yaml drain-nodes.yaml`. 
This command will quiesce the current node and remove it from service. It will allow current work to complete and safely stop the node from picking up any new jobs from the Redis queue, allowing the application to be safely stopped.

2. Update the following variables in `group_vars/tfe.yaml` to the desired version following the required release path which can be found here https://developer.hashicorp.com/terraform/enterprise/releases
- `airgap_bund_name` 
- `replicated_tar_name`
- `upgrade_target_version`

>Note: * Denotes a required release. All online upgrades will automatically install this version, but airgap customers must upgrade to this version before proceeding to later releases.

3. Run `ansible-playbook -i hosts.yaml upgrade-airgap.yaml`. TFE will restart on the new verison.