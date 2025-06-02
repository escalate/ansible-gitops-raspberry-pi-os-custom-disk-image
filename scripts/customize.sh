#!/bin/bash
set -x
set -e

export LC_ALL=C

# shellcheck source=/dev/null
source /common.sh
install_cleanup_trap

echo "Activate SSHD on boot"
touch "${BOOT_PATH}/ssh.txt"

echo "Add default user pi with password raspberry"
# shellcheck disable=SC2016
echo 'pi:$6$MVEGdHTqed7c7za0$ESdhSXBIjSTVWKY7YWBII3UjQM6LhFur1alIXWJ9/Hf4mxgZqIuyX1yEsVf/qct4/sT0NStmvIPZs5de3SNNy0' >"${BOOT_PATH}/userconf.txt"

echo "Copy original disk image archive"
cp "/files/${DOWNLOAD_IMAGE_ARCHIVE}" "/var/tmp/${DOWNLOAD_IMAGE_ARCHIVE}"
cp "/files/${DOWNLOAD_IMAGE_ARCHIVE}.sha256" "/var/tmp/${DOWNLOAD_IMAGE_ARCHIVE}.sha256"

echo "Set hostname"
echo "${ANSIBLE_HOSTNAME}" >"/etc/hostname"
sed --in-place "s/raspberrypi/${ANSIBLE_HOSTNAME}/g" "/etc/hosts"

echo "Create GitOps scripts"
cp "/files/gitops-bootstrap.sh" "/usr/local/bin/gitops-bootstrap.sh"
cp "/files/gitops-deployment.sh" "/usr/local/bin/gitops-deployment.sh"
cp "/files/gitops-preparation.sh" "/usr/local/bin/gitops-preparation.sh"
cp "/files/gitops-utils.sh" "/usr/local/bin/gitops-utils.sh"

echo "Define GitOps environment variables"
tee "${BOOT_PATH}/gitops.env" <<EOT
ANSIBLE_HOSTNAME="${ANSIBLE_HOSTNAME}"
ANSIBLE_HOSTGROUP="${ANSIBLE_HOSTGROUP}"
ANSIBLE_REPOSITORY_URL="${ANSIBLE_REPOSITORY_URL}"
ANSIBLE_VAULT_PASSWORD="${ANSIBLE_VAULT_PASSWORD}"
EOT

echo "Create GitOps bootstrap systemd service"
cp "/files/gitops-bootstrap.service" "/etc/systemd/system/gitops-bootstrap.service"

echo "Enable GitOps bootstrap systemd service on startup"
ln --symbolic "/etc/systemd/system/gitops-bootstrap.service" "/etc/systemd/system/multi-user.target.wants/gitops-bootstrap.service"
