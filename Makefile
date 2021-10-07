.ONESHELL:
SHELL = /bin/bash
.SHELLFLAGS += -e

ARCH ?= amd64

ROOT := $(shell pwd)
SYMCRYPT_OPENSSL := target/symcrypt-openssl_0.1_amd64.deb
OPENSSH := target/ssh_8.4p1-5+fips_all.deb

DEPNEDS := $(SYMCRYPT_OPENSSL) $(OPENSSH)

all: $(DEPNEDS)

$(SYMCRYPT_OPENSSL):
	cd src/SymCrypt-OpenSSL-Debian
	ARCH=$(ARCH) make all

$(OPENSSH): $(SYMCRYPT_OPENSSL)
	sudo dpkg -i target/symcrypt-openssl_0.1_amd64.deb
	cd src/openssh
	export QUILT_PATCHES=../openssh.patch
	export QUILT_REFRESH_ARGS="-p ab --no-timestamps --no-index"
	quilt push -a
	LIBS="-lsymcryptengine -lsymcrypt -lcrypto -lssl -ledit" DEB_BUILD_PROFILES="noudeb" DEB_BUILD_OPTIONS="nocheck nostrip"  DEB_CFLAGS_APPEND="-DUSE_SYMCRYPT_ENGINE"  dpkg-buildpackage -b -rfakeroot -us -uc
	quilt pop -a
	cp ../*.deb $(ROOT)/target
	rm ../*.deb
