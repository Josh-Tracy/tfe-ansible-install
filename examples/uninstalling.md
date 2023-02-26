# Uninstalling TFE

The `uninstall.yaml` playbook will run the official uninstall script from Hashicorp's documentation here: https://developer.hashicorp.com/terraform/enterprise/install/uninstall

>Note: The Ansible task is programmed to remove all snapshots and all docker containers/images related to TFE and replicated. Edit the task if you do not like it. 

## What It Removes
- It will remove all snapshots, docker containers, and executables installed by the `install.sh` script.

- It will also remove the `disk` path you provided if you performed a mounted disk install by specifying `mounted_disk: true` in `group_vars/tfe.yaml`.

## What It Does Not Remove
- It does NOT remove your data from the external services object storage or postgresql databse. It simply cleans up the compute layer. 

## Running
Run the command `ansible-playbook -i hosts uninstall.yaml`

