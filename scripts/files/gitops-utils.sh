#!/bin/bash
set -e -E -u -C -o pipefail

export LC_ALL="C.UTF-8"

checkout_repository() {
  if [[ ! -d "/etc/gitops" ]]; then
    echo "Clone GitOps repository"
    git clone "${ANSIBLE_REPOSITORY_URL}" /etc/gitops
  fi

  cd /etc/gitops

  echo "Check for updates in the GitOps repository"
  git fetch

  LOCAL_COMMIT="$(git rev-parse "@")"
  REMOTE_COMMIT="$(git rev-parse "@{u}")"
  MERGE_BASE="$(git merge-base "@" "@{u}")"

  if [[ "${LOCAL_COMMIT}" = "${REMOTE_COMMIT}" ]]; then
    echo "No updates found in the GitOps repository. Nothing to do."
  elif [[ "${LOCAL_COMMIT}" = "${MERGE_BASE}" ]]; then
    echo "Local GitOps repository is behind the remote GitOps repository. Pulling changes."
    git pull --rebase
  elif [[ "${REMOTE_COMMIT}" = "${MERGE_BASE}" ]]; then
    echo "Local GitOps repository is ahead of the remote GitOps repository. No action performed."
  else
    echo "Local GitOps repository and remote GitOps repository have diverged. No action performed."
  fi
}

install_roles() {
  echo "Install Ansible roles"
  if [[ -f "/etc/gitops/requirements.yml" ]]; then
    ansible-galaxy role install \
      --roles-path="/etc/ansible/roles" \
      --role-file="/etc/gitops/requirements.yml" \
      --force-with-deps
  else
    echo "No requirements.yml file in GitOps repository found. Skipping Ansible roles installation."
  fi
}

install_collections() {
  echo "Install Ansible collections"
  if [[ -f "/etc/gitops/requirements.yml" ]]; then
    ansible-galaxy collection install \
      --collections-path="/etc/ansible/collections" \
      --requirements-file="/etc/gitops/requirements.yml" \
      --force-with-deps
  else
    echo "No requirements.yml file in GitOps repository found. Skipping Ansible collections installation."
  fi
}

run_ansible_playbook() {
  ANSIBLE_PLAYBOOK_FILE="$1"
  # shellcheck disable=SC2034
  ANSIBLE_CONFIG="/etc/gitops/ansible.cfg"

  echo "Run Ansible ${ANSIBLE_PLAYBOOK_FILE} playbook"
  ansible-playbook \
    --inventory="/etc/ansible/hosts.yml" \
    "${ANSIBLE_PLAYBOOK_FILE}"
}
