# Considerations when using RHEL7

RHEL 7 has specific conditions for installing TFE that can be found here: https://developer.hashicorp.com/terraform/enterprise/requirements/os-specific/rhel-requirements

## Playbook requirements
- install.yaml - If the `install_dependencies` role is enabled, docker-ce will be installed. For RHEL7, you have the option to pass `docker_from_centos: true` which, when true, will add the CentOS `extras` repo and docker CentOS repos `edge` and `test` to the remote RHEL7 host. `docker_from_centos: false`, you must have a repo enabled with docker and all dependencies available OR have the packages installed already.

- firewalld - If the remote RHEL7 host is using firewalld then `use_firewalld_enabled: true` should be set. This will add the docker0 interface to the trusted zone. 

- SElinux - If SElinux is enforcing and you are using `mounted_disk` then `selinux_enforcing: true` will allow you to run `selinux.yaml`

- selinux.yaml - When `selinux_enforcing: true` and `mounted_disk: true` then after you run `install.yaml`, after a few minutes the `mounted_disk_path` will be created. Then you can run `selinux.yaml` to set the context for this path.

- `firewalld_ansible_python_interpreter` - Some Ansible modueles such as firewalld and selinux require python2. This parameter allows you to pass python 2 as the interpertor for these tasks and use python3 for all others if desired.

## Inputs variables
Relvent Ansible variables for RHEL7 operating systems are:

```yaml
### --- Start RHEL7 Specific --- ###
# If docker_from_centos is false, the task assumes repos with docker packages are enabled on the host
docker_from_centos: true
# If firewalld is on. This will add docker0 interface to the trusted zone
use_firewalld_enabled: true
# Ansible's firewalld module requires python-firewall, which may only be available in python2
firewalld_ansible_python_interpreter: /usr/bin/python2.7
# If selinux is enabled. When using mounted disk this sets the context for the mounted disk path
selinux_enforcing: true
### --- End RHEL7 Specific --- ###
```

|    Variable                           |    Description    |    Required   |
| --- | --- | --- |
| firewalld_ansible_python_interpreter | If using firewalld and selinux, python 2 interpertor must be used. Sometimes you may need to provide a different python interpertor for these tasks vs the rest of the playbooks.         | Only when using firewalld or selinux on RHEL 7   |
| docker_from_centos | true or false. Whether or not to install and use the CentOS repos to install docker. If false, the playbooks assume the packages are available from a repo enabled already.      | Only when you do not have a repo enabled that provides docker on RHEL7     |
| use_firewalld_enabled | true or false. Whether or not firewalld is enabled on the remote host.         | Only when using rhel7     |
| selinux_enforcing| true or false. Is SElinux enforcing on the remote host         | Only when using rhel7     |