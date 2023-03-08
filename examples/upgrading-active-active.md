# Upgrading TFE Versions - Active / Active

## Before Upgrading
Read up on the documentation https://developer.hashicorp.com/terraform/enterprise/admin/infrastructure/upgrades#before-upgrade

The most important part is:
- Create a backup copy of the storage prior to upgrading your instance. Backup and restore responsibility varies depending on your Terraform Enterprise operation mode.

## Online Installs
1. Safely drain connections from the node by running `tfe-admin node-drain` on each TFE node or `ansible-playbook -i hosts.yaml drain-nodes.yaml`.
This command will quiesce the current node and remove it from service. It will allow current work to complete and safely stop the node from picking up any new jobs from the Redis queue, allowing the application to be safely stopped.

2. Run `ansible-playbook -i hosts.yaml uninstall.yaml` against all BUT 1 nodes in the active/active cluster. We do this to avoid some TFE nodes being on the old version when the new one is running on the new version.

3. Update `tfe_release_sequence` in `group_vars/tfe.yaml` to the desired version following the required release path which can be found here https://developer.hashicorp.com/terraform/enterprise/releases

>Note: * Denotes a required release. All online upgrades will automatically install this version, but airgap customers must upgrade to this version before proceeding to later releases.

4. Run `ansible-playbook -i hosts.yaml install.yaml`. AGAINST THE 1 REMAINING NODE. TFE will restart on the new verison.

5. Wait for the upgrade to finish before moving onto step 6.

`replicatedctl app inspect` can be run on the nodes to verify the application is running on the new version. It can take a couple of minutes for the upgrade to finish. If you suspect the upgrade is failing, run `docker logs replicated` to try and identify why the upgrade is failing. The most common cause of failure is insufficient disk space. You can also run `docker logs replicated -f` to watch the upgrade in real time.

6. Run `ansible-playbook -i hosts.yaml install.yaml` against the nodes that your previously uninstalled TFE from to reinstall TFE.

## Airgap Installs

1. Safely drain connections from the node by running `tfe-admin node-drain` on the TFE node or `ansible-playbook -i hosts.yaml drain-nodes.yaml`. 
This command will quiesce the current node and remove it from service. It will allow current work to complete and safely stop the node from picking up any new jobs from the Redis queue, allowing the application to be safely stopped.

2. Run `ansible-playbook -i hosts.yaml uninstall.yaml` against all BUT 1 nodes in the active/active cluster. We do this to avoid some TFE nodes being on the old version when the new one is running on the new version.

3. Update the following variables in `group_vars/tfe.yaml` to the desired version following the required release path which can be found here https://developer.hashicorp.com/terraform/enterprise/releases
- `airgap_bund_name` 
- `replicated_tar_name`
- `upgrade_target_version`

>Note: * Denotes a required release. All online upgrades will automatically install this version, but airgap customers must upgrade to this version before proceeding to later releases.

4. Run `ansible-playbook -i hosts.yaml upgrade-airgap.yaml` AGAINST THE 1 REMAINING NODE. TFE will restart on the new verison.

5. Wait for the upgrade to finish before moving onto step 6.

`replicatedctl app inspect` can be run on the nodes to verify the application is running on the new version. It can take a couple of minutes for the upgrade to finish. If you suspect the upgrade is failing, run `docker logs replicated` to try and identify why the upgrade is failing. The most common cause of failure is insufficient disk space. You can also run `docker logs replicated -f` to watch the upgrade in real time.

6. Run `ansible-playbook -i hosts.yaml install.yaml` against the nodes that your previously uninstalled TFE from to reinstall TFE.