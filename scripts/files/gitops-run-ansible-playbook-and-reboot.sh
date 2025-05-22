#!/bin/bash
set -eo pipefail

echo "Run Ansible playbook"
ansible-pull \
  --url="${ANSIBLE_REPOSITORY_URL}" \
  --directory="/etc/gitops" \
  --inventory="/etc/ansible/hosts.yml" \
  --vault-password-file="/etc/ansible/.vault_pass.txt" \
  --diff \
  --verbose \
  bootstrap.yml

echo "Create marker file"
touch /boot/firmware/gitops-bootstrap.done

echo "Reboot system"
reboot
