.ONESHELL:
SHELL = /bin/bash
.SHELLFLAGS += -e

ARCH ?= amd64
BUILD_NAME = symcrypt-openssl
BUILD_VERSION = 0.1
SYMCRYPT_PACKAGE = $(BUILD_NAME)_$(BUILD_VERSION)_$(ARCH).deb
BUILD_ROOT_DIR = tmp/$(BUILD_NAME)

# TODO: Support arm64 and armhf
INSTALL_PATH = $(BUILD_ROOT_DIR)/usr/lib/x86_64-linux-gnu
DEBIAN_DIR = $(BUILD_ROOT_DIR)/DEBIAN

ROOT_PATH = $(shell realpath $(shell pwd)/../..)
TARGET_PATH = $(ROOT_PATH)/target
LIBSYMCRYPT = $(TARGET_PATH)/libsymcrypt.so
LIBSYMCRYPTENGINE = $(TARGET_PATH)/libsymcryptengine.so
TARGET = $(TARGET_PATH)/$(SYMCRYPT_PACKAGE)

DEPENDS := $(LIBSYMCRYPT) $(LIBSYMCRYPTENGINE)

all: $(TARGET)

$(LIBSYMCRYPT):
	cd ../SymCrypt
	mkdir -p bin
	cd bin
	cmake .. -DCMAKE_TOOLCHAIN_FILE=../cmake-toolchain/LinuxUserMode-AMD64.cmake
	cmake --build .
	mkdir -p $(TARGET_PATH)
	cp module/AMD64/LinuxUserMode/libsymcrypt.so $(LIBSYMCRYPT)

$(LIBSYMCRYPTENGINE): $(LIBSYMCRYPT)
	cd ../SymCrypt-OpenSSL
	cp $(LIBSYMCRYPT) ./
	ln -sf $(ROOT_PATH)/src/SymCrypt ~/SymCrypt
	mkdir -p bin
	cd bin
	cmake .. -DCMAKE_TOOLCHAIN_FILE=../cmake-toolchain/LinuxUserMode-AMD64.cmake
	cmake --build .
	rm ../libsymcrypt.so
	cp SymCryptEngine/dynamic/libsymcryptengine.so $(LIBSYMCRYPTENGINE)

$(TARGET): $(DEPENDS)
	mkdir -p $(INSTALL_PATH)
	mkdir -p $(DEBIAN_DIR)
	cp $(LIBSYMCRYPT) $(INSTALL_PATH)
	cp $(LIBSYMCRYPTENGINE) $(INSTALL_PATH)
	chmod o+r $(INSTALL_PATH)/*
	cp debian/* $(DEBIAN_DIR)/
	dpkg-deb --build $(BUILD_ROOT_DIR) $(TARGET)
