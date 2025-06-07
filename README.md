[![Test](https://github.com/escalate/ansible-gitops-raspberry-pi-os-custom-disk-image/actions/workflows/test.yml/badge.svg?branch=master&event=push)](https://github.com/escalate/ansible-gitops-raspberry-pi-os-custom-disk-image/actions/workflows/test.yml)

# Ansible GitOps - Raspberry Pi OS custom disk image

A build tool based on [CustoPiZe](https://github.com/OctoPrint/CustoPiZer) to create a custom Raspberry Pi OS disk image that starts the Ansible GitOps workflow on first boot.

## How does it work?

The build tool downloads the latest [Raspberry Pi OS Lite (32-bit / 64-bit)](https://www.raspberrypi.com/software/operating-systems/) disk image and creates a systemd service in it that starts the Ansible GitOps workflow on first boot.

After the Raspberry Pi has successfully booted with the customized disk image, the systemd service prepares all required [dependencies](https://github.com/escalate/ansible-gitops-raspberry-pi-os-custom-disk-image/blob/master/scripts/files/gitops-preparation.sh) and executes a [bootstrap script](https://github.com/escalate/ansible-gitops-raspberry-pi-os-custom-disk-image/blob/master/scripts/files/gitops-bootstrap.sh) with the settings preconfigured by the user.

The [bootstrap script](https://github.com/escalate/ansible-gitops-raspberry-pi-os-custom-disk-image/blob/master/scripts/files/gitops-bootstrap.sh) checks out the preconfigured [Git repository](https://github.com/escalate/ansible-gitops-example-repository/), installs required roles and collections and runs the `bootstrap.yml` playbook.
The `bootstrap.yml` playbook must contain all steps for the further process, e.g. the preparation of an external USB drive and a cronjob for the regular execution of the [rollout script](https://github.com/escalate/ansible-gitops-raspberry-pi-os-custom-disk-image/blob/master/scripts/files/gitops-rollout.sh).

After the successful run of the `bootstrap.yml` playbook, markers are set to prevent the scripts from being restarted at the next system start. Finally, the system is rebooted to complete all changes.

All configuration changes on the Raspberry Pi should now be possible via the `site.yml` of the configured [Git repository](https://github.com/escalate/ansible-gitops-example-repository/).

## How to create a customized disk image?

1. Define necessary environment variables needed for the later ansible-playbook run.

```
# The Fully Qualified Domain Name (FQDN) of your server
export ANSIBLE_HOSTNAME="testserver.fritz.box"

# The Ansible inventory group name where your server belongs to. For more information see https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
export ANSIBLE_HOSTGROUP="testing"

# The URL of your Ansible control repository
export ANSIBLE_REPOSITORY_URL="https://github.com/escalate/ansible-gitops-example-repository.git"

# The secret password to decrypt your Ansible Vault file. For more information see https://docs.ansible.com/ansible/latest/user_guide/vault.html
export ANSIBLE_VAULT_PASSWORD="s3cret"
```

2. Start the build process with one of the following commands.

32-bit OS version:

```
make build-32bit
```

64-bit OS version:

```
make build-64bit
```

3. Flash the customized disk image with [balena Etcher](https://etcher.balena.io/) to the SD card.

4. Insert the SD card into the Raspberry Pi and power it up. Done.

## License

MIT
