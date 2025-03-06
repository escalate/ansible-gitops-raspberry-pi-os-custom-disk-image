[![Test](https://github.com/escalate/ansible-gitops-raspberry-pi-os-custom-disk-image/actions/workflows/test.yml/badge.svg?branch=master&event=push)](https://github.com/escalate/ansible-gitops-raspberry-pi-os-custom-disk-image/actions/workflows/test.yml)

# Ansible GitOps - Raspberry Pi OS custom disk image

A build tool to create a customized Raspberry Pi OS disk image which initiates the Ansible GitOps workflow on first boot.

## How does it work?

The build tool downloads the latest [Raspberry Pi OS Lite (32-bit / 64-bit)](https://www.raspberrypi.org/software/operating-systems/) disk image and creates a systemd service inside it to bootstrap the Ansible GitOps workflow on first boot.

After the Raspberry Pi boots successfully with the customized disk image, the systemd service prepares all needed dependencies and runs [ansible-pull](https://docs.ansible.com/ansible/latest/cli/ansible-pull.html) with the user pre-configured environment variables.

Ansible-pull checks out the pre-configured Git repository and runs the playbook `bootstrap.yml`.
All steps for the further process must be stored in the `bootstrap.yml` playbook e.g. the preparation of an external USB drive as well as a cronjob for the periodical execution of ansible-pull.

After the successful run of the playbook, a marker is set to prevent the systemd service from starting again at the next boot. Finally, the system is rebooted to complete all changes.

Any configuration change of the Raspberry Pi should now be possible via the configured Git repository.

## How to create a customized disk image?

1. Define necessary environment variables needed for the later ansible-pull run.

```
export ANSIBLE_HOSTNAME=testserver.fritz.box
export ANSIBLE_REPOSITORY_URL=https://github.com/escalate/ansible-gitops-example-repository.git
export ANSIBLE_VAULT_PASSWORD=s3cret
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

3. Flash the customized disk image with [Etcher](https://www.balena.io/etcher/) to the SD card.

4. Insert the SD card into the Raspberry Pi and power it up. Done.

## How does the customization work?

With the choosen approach it is only possible to add / change / delete static files inside the disk image.
To run native OS commands like apt, the QEMU user emulation would have to be used.
For the moment it is good enough to work with.

## License

MIT
