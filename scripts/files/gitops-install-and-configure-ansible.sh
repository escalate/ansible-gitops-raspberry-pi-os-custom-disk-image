#!/bin/bash
set -eo pipefail

echo "Update package information"
apt-get update

echo "Install Python pip"
apt-get --yes install python3-pip

echo "Install Git"
apt-get --yes install git

echo "Install Ansible"
pip3 install --disable-pip-version-check --break-system-packages --root-user-action=ignore ansible

echo "Create configuration directories"
mkdir --parent /etc/ansible
mkdir --parent /etc/gitops

echo "Create Ansible configuration file"
echo -e "[defaults]\ninterpreter_python = auto_silent" >/etc/ansible/ansible.cfg

echo "Create Ansible inventory file"
echo -e "gitops:\n  hosts:\n    ${ANSIBLE_HOSTNAME}:\n      ansible_host: 127.0.0.1" >/etc/ansible/hosts.yml

echo "Create Ansible Vault password file"
echo "${ANSIBLE_VAULT_PASSWORD}" >/etc/ansible/.vault_pass.txt
