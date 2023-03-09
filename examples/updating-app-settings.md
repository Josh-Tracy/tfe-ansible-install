# Updating TFE Application Settings

## Standlone TFE

### Option 1 - Manual
1. SSH into the node(s) and run `tfe-admin node-drain` to ensure no new workloads get scheduled and in progress ones finish
2. Run `tfe-admin app-config -k <KEY> -v <VALUE>`

>Note: Step 2 only needs to be run on 1 node in an active/active cluster.

This command allows you to use the CLI to make real-time application changes, such as capacity_concurrency. You must provide both an allowable `<KEY>` (setting name) and `<VALUE>` (new setting value). Run replicatedctl app-config export for a complete list of the current app-config settings.

For the configuration changes to take effect, you must restart the Terraform Enterprise application on each node instance. To restart Terraform Enterprise:

>Note: You must restart the app on EACH node if you are running active/active.

3. Run `replicatedctl app stop` to stop the application.
4. Run `replicatedctl app status` to confirm the application is stopped.
5. Run `replicatedctl app start` to start the application.
6. You can run `replicatedctl app-config export` to verify your changes have been enacted.
7. UPDATE YOUR AUTOMATION CONFIGS/TEMPLATES TO MATCH THESE NEW SETTINGS!!!!!!!

### Option 2 - Ansible
1. Run `ansible-playbook -i hosts.yaml drain-nodes.yaml` to drain the nodes in the `tfe` host group of active workloads and prevent new ones.
2. Update `group_vars/tfe.yaml` variables `update_key` and `update_value` to the app setting you are trying to update. As an exmaple, if you are trying to update capacity_concurreny of the TFE app, set `update_key: capacity_concurreny` and `update_value: "12"`.
3. Run `ansible-playbook -i hosts.yaml app-config-update.yaml`. This playbook will run the app config update on the first node in the TFE host group. This will be propgated to the rest of the nodes in the cluster
