.ONESHELL:
SHELL = /bin/bash
.SHELLFLAGS += -e

ARCH ?= amd64

all:
	cd src/SymCrypt-OpenSSL-Debian
	ARCH=$(ARCH) make all
