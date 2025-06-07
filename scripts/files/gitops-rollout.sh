#!/bin/bash
set -e -E -u -C -o pipefail

exec 1> >(logger --tag "$(basename "$0")") 2>&1

if [[ ! -f "/boot/firmware/gitops-preparation.done" ]]; then
  echo "GitOps bootstrap not completed - Exiting"
  exit 1
fi

# shellcheck source=/dev/null
source "/boot/firmware/gitops.env"

# shellcheck source=/dev/null
source "/usr/local/bin/gitops-utils.sh"

checkout_repository
rollout
