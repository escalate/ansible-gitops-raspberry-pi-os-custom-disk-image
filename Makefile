.PHONY: build
build: lint
	./build.sh

.PHONY: lint
lint:
	ec
	find . -name "*.sh" -exec shellcheck {} \;

.PHONY: version
version:
	ec --version
	shellcheck --version
