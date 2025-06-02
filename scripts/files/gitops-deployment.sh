#!/bin/bash
set -e -E -u -C -o pipefail

exec 1> >(logger --tag "$(basename "$0")") 2>&1

# shellcheck source=/dev/null
source "/boot/firmware/gitops.env"

# shellcheck source=/dev/null
source "/usr/local/bin/gitops-utils.sh"

checkout_repository
install_roles
install_collections
run_ansible_playbook "site.yml"
