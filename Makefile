SHELL = /bin/bash
.SHELLFLAGS = -e -o pipefail -c

.PHONY: build-32bit
build-32bit:
	test -n "$(ANSIBLE_HOSTNAME)" # check env variable $$ANSIBLE_HOSTNAME
	test -n "$(ANSIBLE_REPOSITORY_URL)" # check env variable $$ANSIBLE_REPOSITORY_URL
	test -n "$(ANSIBLE_VAULT_PASSWORD)" # check env variable $$ANSIBLE_VAULT_PASSWORD
	./build.sh 32

.PHONY: build-64bit
build-64bit:
	test -n "$(ANSIBLE_HOSTNAME)" # check env variable $$ANSIBLE_HOSTNAME
	test -n "$(ANSIBLE_REPOSITORY_URL)" # check env variable $$ANSIBLE_REPOSITORY_URL
	test -n "$(ANSIBLE_VAULT_PASSWORD)" # check env variable $$ANSIBLE_VAULT_PASSWORD
	./build.sh 64

.PHONY: clean
clean:
	rm --recursive --force CustoPiZer/
	sudo rm --recursive --force workspace/
