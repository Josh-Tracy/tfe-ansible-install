# Installing TFE in an Active/Active architecture

When installing TFE in active/active mode on multiple nodes, follow these steps. Not properly following them will result in data loss or unexpected operations.

## Configuring the Inventory File
In the `hosts` file, only add 1 VM's hostname or IP address under the `[tfe]` group to begin with. Add your additional hosts only after you have enabled active/active and verified a successful terraform run.

## Steps to Active/Active
1. Run the `install.yaml` playbook against a single host in the `[tfe]` host group to perform 1 standalone installation with active/active disabled.
2. Login, create the admin user and Organization, and verify you can perform a terraform apply.
3. Run the `uninstall.yaml` playbook to uninstall TFE from the host.
4. Modify the `group_vars/tfe.yaml` variables to configure active/active.
5. Run the `install.yaml` playbook against the host in the `[tfe]` host group again to reconnect it to external services and redis.
>Note: This will disable port 8800 replicated admin console UI.
6. Login and perform a terraform apply to ensure Redis is working properly.
7. Add the other tfe hosts under the `[tfe]` group in the `hosts` file.
9. Run the `install.yaml` playbook to install TFE on all the nodes you desire at once (up to 5 supported per cluster).