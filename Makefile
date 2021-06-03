.PHONY: build32
build32: clean
	./build.sh 32

.PHONY: build64
build64: clean
	./build.sh 64

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
