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

.PHONY: clean
clean:
	rm --force *.zip
	rm --force *.zip.*
	rm --force *.img
	rm --force *.tar.bz2
	rm --force *.tar.bz2.*
