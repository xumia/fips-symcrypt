.ONESHELL:
SHELL = /bin/bash
.SHELLFLAGS += -e

ARCH ?= amd64

ROOT := $(shell pwd)
SYMCRYPT_OPENSSL := target/symcrypt-openssl_0.1_amd64.deb
OPENSSH := target/ssh_8.4p1-5+fips_all.deb
GOLANG := target/golang-1.15-go_1.15.15-1~deb11u1+fips_amd64.deb
PYTHON := target/python3.9_3.9.2-1+fips_amd64.deb

DEPNEDS := $(SYMCRYPT_OPENSSL) $(OPENSSH) $(GOLANG) $(PYTHON)

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

$(GOLANG):
	cd src/golang
	rm -rf debian
	cp -rf ../golang-debian/debian debian
	export QUILT_PATCHES=../golang.patch
	export QUILT_REFRESH_ARGS="-p ab --no-timestamps --no-index"
	quilt push -a
	dpkg-buildpackage -b -rfakeroot -us -uc
	cp ../*.deb $(ROOT)/target
	rm ../*.deb

$(PYTHON):
	cd src/cpython
	rm -rf debian
	cp -rf ../python3/debian debian
	export QUILT_PATCHES=debian/patches
	export QUILT_REFRESH_ARGS="-p ab --no-timestamps --no-index"
	quilt push -a
	rm -rf .pc
	export QUILT_PATCHES=../cpython.patch
	quilt push -a

	# Fix Misc/NEWS not found issue
	touch Misc/NEWS
	dpkg-buildpackage -b -d -rfakeroot -us -uc
	cp ../*.deb $(ROOT)/target
	rm ../*.deb
