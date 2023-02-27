# Installing TFE in an Active/Active architecture

When installing TFE in active/active mode on multiple nodes, follow these steps. Not properly following them will result in data loss or unexpected operations.

## Configuring the Inventory File
In the `hosts.yaml` file, only add 1 VM's hostname or IP address under the `tfe` group to begin with. Add your additional hosts only after you have enabled active/active and verified a successful terraform run.

An example of an inventory file with 2 nodes in active/active. You must include each hosts unique private IP address.

```yaml
tfe:
  hosts:
    172.176.250.204:
      # Should be eth0 or equivilent, not docker0
      tfe_private_ip: 172.30.0.4
    20.97.233.217:
      tfe_private_ip: 172.30.0.5
```

## Steps to Active/Active
1. Run the `install.yaml` playbook against a single host in the `tfe` host group to perform 1 standalone installation with active/active disabled.
2. Login, create the admin user and Organization, and verify you can perform a terraform apply.
3. Run the `uninstall.yaml` playbook to uninstall TFE from the host.
4. Modify the `group_vars/tfe.yaml` variables to configure active/active.
5. Run the `install.yaml` playbook against the host in the `tfe` host group again to reconnect it to external services and redis.
>Note: This will disable port 8800 replicated admin console UI.
6. Login and perform a terraform apply to ensure Redis is working properly.
7. Add the other tfe hosts under the `tfe` group in the `hosts.yaml` file.
9. Run the `install.yaml` playbook to install TFE on all the nodes you desire at once (up to 5 supported per cluster).
10. SSH into those nodes are run `replicatedctl app status` to verify a healthy application launch.
11. Run a few terraform plans and applys to verify the application functionality.

## Example Inputs for Active/Active

```yaml
# TFE App Settings - active/active - True = 1 False = 0
enable_active_active: 1
redis_host: tferedis.redis.cache.windows.net
redis_pass: redispassword
redis_port: 6380
redis_use_password_auth: 1
redis_use_tls: 1
```

## Active/Active Documentation

- active/active docs - https://developer.hashicorp.com/terraform/enterprise/install/automated/active-active
- `hairpin_addressing` on active/active - https://support.hashicorp.com/hc/en-us/articles/1500001609382-Enable-Hairpinning-on-Active-Active-Terraform-Enterprise
