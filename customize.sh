#!/bin/bash
set -eo pipefail

echo "Activate SSHD on boot"
sudo touch boot/ssh
