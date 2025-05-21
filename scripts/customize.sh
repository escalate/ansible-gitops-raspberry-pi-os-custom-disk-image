#!/bin/bash
set -x
set -e

export LC_ALL=C

# shellcheck disable=SC1091
source /common.sh
install_cleanup_trap

echo "Activate SSHD on boot"
touch "${BOOT_PATH}/ssh.txt"

echo "Add default user pi with password raspberry"
# shellcheck disable=SC2016
echo 'pi:$6$MVEGdHTqed7c7za0$ESdhSXBIjSTVWKY7YWBII3UjQM6LhFur1alIXWJ9/Hf4mxgZqIuyX1yEsVf/qct4/sT0NStmvIPZs5de3SNNy0' >"${BOOT_PATH}/userconf.txt"

echo "Copy original image archive"
cp "/files/${DOWNLOAD_IMAGE_ARCHIVE}" "/var/tmp/${DOWNLOAD_IMAGE_ARCHIVE}"
cp "/files/${DOWNLOAD_IMAGE_ARCHIVE}.sha256" "/var/tmp/${DOWNLOAD_IMAGE_ARCHIVE}.sha256"

echo "Set hostname"
echo "${ANSIBLE_HOSTNAME}" >"/etc/hostname"
sed --in-place "s/raspberrypi/${ANSIBLE_HOSTNAME}/g" "/etc/hosts"

echo "Create GitOps bootstrap systemd service"
cp "/files/gitops-bootstrap.service" "/etc/systemd/system/gitops-bootstrap.service"

echo "Enable GitOps bootstrap systemd service on startup"
ln --symbolic "/etc/systemd/system/gitops-bootstrap.service" "/etc/systemd/system/multi-user.target.wants/gitops-bootstrap.service"

echo "Create GitOps bootstrap scripts"
cp "/files/gitops-install-and-configure-ansible.sh" "${BOOT_PATH}/gitops-install-and-configure-ansible.sh"
cp "/files/gitops-run-ansible-playbook-and-reboot.sh" "${BOOT_PATH}/gitops-run-ansible-playbook-and-reboot.sh"

echo "Define Ansible environment variables"
tee "${BOOT_PATH}/gitops-bootstrap.env" <<EOT
ANSIBLE_HOSTNAME=${ANSIBLE_HOSTNAME}
ANSIBLE_REPOSITORY_URL=${ANSIBLE_REPOSITORY_URL}
ANSIBLE_VAULT_PASSWORD=${ANSIBLE_VAULT_PASSWORD}
EOT
