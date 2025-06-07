#!/bin/bash
set -e -E -u -C -o pipefail

if [[ -f "/boot/firmware/gitops-bootstrap.done" ]]; then
  echo "GitOps bootstrap already completed - Exiting"
  exit 0
fi

# shellcheck source=/dev/null
source "/boot/firmware/gitops.env"

# shellcheck source=/dev/null
source "/usr/local/bin/gitops-utils.sh"

checkout_repository
install_roles
install_collections
deploy_ansible_playbook "bootstrap.yml"

echo "Create force rollout marker file"
touch "/boot/firmware/gitops-force-rollout.now"

echo "Create bootstrap marker file"
touch "/boot/firmware/gitops-bootstrap.done"

echo "Reboot system"
reboot
