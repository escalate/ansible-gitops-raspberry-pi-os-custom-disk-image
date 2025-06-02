#!/bin/bash
set -e -E -u -C -o pipefail

if [[ -f "/boot/firmware/gitops-preparation.done" ]]; then
  echo "GitOps preparation already completed. Exiting."
  exit 0
fi

echo "Update package information"
apt-get update

echo "Install Python pip"
apt-get --yes install python3-pip

echo "Install Git"
apt-get --yes install git

echo "Install Ansible"
pip3 install \
  --disable-pip-version-check \
  --break-system-packages \
  --root-user-action=ignore \
  ansible

echo "Create Ansible configuration directory"
mkdir --parent --verbose /etc/ansible

echo "Create Ansible configuration file"
tee "/etc/ansible/ansible.cfg" <<EOT
[defaults]
collections_path = /etc/ansible/collections
interpreter_python = auto_silent
nocows = true
roles_path = /etc/ansible/roles
vault_password_file = /etc/ansible/.vault_pass.txt
verbosity = 1

[diff]
always = true
EOT

echo "Create Ansible inventory file"
tee "/etc/ansible/hosts.yml" <<EOT
${ANSIBLE_HOSTGROUP}:
  hosts:
    ${ANSIBLE_HOSTNAME}:
      ansible_connection: local
      ansible_host: 127.0.0.1
EOT

echo "Create Ansible Vault password file"
echo "${ANSIBLE_VAULT_PASSWORD}" >/etc/ansible/.vault_pass.txt

echo "Create marker file"
touch "/boot/firmware/gitops-preparation.done"
