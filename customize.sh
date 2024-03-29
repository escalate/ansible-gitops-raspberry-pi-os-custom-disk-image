#!/bin/bash
set -eo pipefail

IMAGE_ZIP_FILE="$1"

echo "Activate SSHD on boot"
sudo touch boot/ssh

echo "Copy original image archive"
sudo cp "${IMAGE_ZIP_FILE}" "rootfs/var/tmp/${IMAGE_ZIP_FILE}"
sudo cp "${IMAGE_ZIP_FILE}.sha256" "rootfs/var/tmp/${IMAGE_ZIP_FILE}.sha256"

echo "Set hostname"
echo "${ANSIBLE_HOSTNAME}" | sudo tee "rootfs/etc/hostname"

echo "Create GitOps bootstrap systemd service"
sudo cp "customize.d/gitops-bootstrap.service" "rootfs/etc/systemd/system/gitops-bootstrap.service"

echo "Enable GitOps bootstrap systemd service on startup"
sudo ln --symbolic "/etc/systemd/system/gitops-bootstrap.service" "rootfs/etc/systemd/system/multi-user.target.wants/gitops-bootstrap.service"

echo "Create GitOps bootstrap scripts"
sudo cp "customize.d/gitops-install-and-configure-ansible.sh" "boot/gitops-install-and-configure-ansible.sh"
sudo cp "customize.d/gitops-run-ansible-playbook-and-reboot.sh" "boot/gitops-run-ansible-playbook-and-reboot.sh"

echo "Define Ansible environment variables"
sudo tee "boot/gitops-bootstrap.env" <<EOT
ANSIBLE_HOSTNAME=${ANSIBLE_HOSTNAME}
ANSIBLE_REPOSITORY_URL=${ANSIBLE_REPOSITORY_URL}
ANSIBLE_VAULT_PASSWORD=${ANSIBLE_VAULT_PASSWORD}
EOT
