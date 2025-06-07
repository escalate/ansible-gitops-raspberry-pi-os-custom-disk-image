#!/bin/bash
set -e -E -u -C -o pipefail

export LC_ALL="C.UTF-8"

checkout_repository() {
  if [[ ! -d "/etc/gitops" ]]; then
    echo "Checkout GitOps repository"
    git clone "${ANSIBLE_REPOSITORY_URL}" "/etc/gitops"
  fi
}

install_roles() {
  if [[ -f "/etc/gitops/requirements.yml" ]]; then
    echo "Install Ansible roles with dependencies"
    cd "/etc/gitops/"
    ansible-galaxy role install \
      --roles-path="/etc/ansible/roles" \
      --role-file="requirements.yml" \
      --force-with-deps
  else
    echo "No requirements.yml file in GitOps repository found - Skipping Ansible roles installation"
  fi
}

install_collections() {
  if [[ -f "/etc/gitops/requirements.yml" ]]; then
    echo "Install Ansible collections with dependencies"
    cd "/etc/gitops/"
    ansible-galaxy collection install \
      --collections-path="/etc/ansible/collections" \
      --requirements-file="requirements.yml" \
      --force-with-deps
  else
    echo "No requirements.yml file in GitOps repository found - Skipping Ansible collections installation"
  fi
}

deploy_ansible_playbook() {
  ANSIBLE_PLAYBOOK_FILE="$1"
  # shellcheck disable=SC2034
  ANSIBLE_CONFIG="/etc/gitops/ansible.cfg"

  echo "Deploy Ansible ${ANSIBLE_PLAYBOOK_FILE} playbook"
  cd "/etc/gitops/"
  ansible-playbook \
    --inventory="/etc/ansible/hosts.yml" \
    "${ANSIBLE_PLAYBOOK_FILE}"
}

rollout() {
  echo "Check for updates in the GitOps repository"
  cd "/etc/gitops/"
  git fetch

  LOCAL_COMMIT="$(git rev-parse "@")"
  REMOTE_COMMIT="$(git rev-parse "@{u}")"
  MERGE_BASE="$(git merge-base "@" "@{u}")"

  if [[ "${LOCAL_COMMIT}" = "${REMOTE_COMMIT}" ]]; then
    echo "No updates found in the GitOps repository"
  elif [[ "${LOCAL_COMMIT}" = "${MERGE_BASE}" ]]; then
    echo "Local GitOps repository is behind the remote GitOps repository - Pulling changes"
    git pull --rebase
    if [[ ! -f "/boot/firmware/gitops-force-rollout.now" ]]; then
      install_roles
      install_collections
      echo "Rollout changes from the GitOps repository"
      deploy_ansible_playbook "site.yml"
    fi
  elif [[ "${REMOTE_COMMIT}" = "${MERGE_BASE}" ]]; then
    echo "Local GitOps repository is ahead of the remote GitOps repository"
  else
    echo "Local GitOps repository and remote GitOps repository have diverged"
  fi

  if [[ -f "/boot/firmware/gitops-force-rollout.now" ]]; then
    install_roles
    install_collections
    echo "Force rollout of changes from the GitOps repository"
    deploy_ansible_playbook "site.yml"
    rm "/boot/firmware/gitops-force-rollout.now"
  fi
}
