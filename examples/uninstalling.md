# Uninstalling TFE

The `uninstall.yaml` playbook will run the official uninstall script from Hashicorp's documentation here: https://developer.hashicorp.com/terraform/enterprise/install/uninstall

>Note: The Ansible task is programmed to remove all snapshots and all docker containers/images related to TFE and replicated. Edit the task if you do not like it. 

## Requirements
- python module pexpect must be installed, or Ansible must be allowed to install it. The palybook will attempt to install it if it is not installed.

## What It Removes
- It will remove all snapshots, docker containers, and executables installed by the `install.sh` script.

- It will also remove the `disk` path you provided if you performed a mounted disk install by specifying `mounted_disk: true` in `group_vars/tfe.yaml`.

## What It Does Not Remove
- It does NOT remove your data from the external services object storage or postgresql databse. It simply cleans up the compute layer. 

## Requirements
In order to run the `uninstall.yaml` playbook, you must have the pexpect python package installed on the remote host, or the ability to install it when the playbook runs.

Run `pip-3 install pexpect` on the remote host, or let the `uninstall.yaml` playbook do it for you.

## Running
Run the command `ansible-playbook -i hosts uninstall.yaml`

