UBUNTU_VERSION?=20.04
TOOL?=hotspotdrivenframework
DOCKER_IMAGE?=ubuntu:$(UBUNTU_VERSION)-$(TOOL)
DOCKER_FILE?=Dockerfile-ubuntu-$(UBUNTU_VERSION)
DynamoRIO_PATH?=$(shell pwd)/DynamoRIO
ZIPS=.tar.gz
ARCH=$(shell uname -m)
EXTRALIB_PATH:=$(shell pwd)/SPECWorkload/ExtraLib
ifeq ($(ARCH), aarch64)
	DYNAMORIO_GIT_RELEASE?="https://github.com/DynamoRIO/dynamorio/releases/download/release_9.0.1/DynamoRIO-AArch64-Linux-9.0.1.tar.gz"
	DYNAMORIO_NAME?=DynamoRIO-AArch64-Linux-9.0.1
else ifeq ($(ARCH), x86_64)
	DYNAMORIO_GIT_RELEASE?="https://github.com/DynamoRIO/dynamorio/releases/download/release_9.0.1/DynamoRIO-Linux-9.0.1.tar.gz"
	DYNAMORIO_NAME?="DynamoRIO-Linux-9.0.1"
else
        $(error Unsupported architecture!)
endif

run:
	docker run --privileged=true  --rm -it -v "${PWD}:${PWD}" --user $(shell id -u):$(shell id -g) -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro  -w "${PWD}" $(DOCKER_IMAGE)
run-root:
	docker run --privileged=true  --rm -it -v "${PWD}:${PWD}" --user root -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro  -w "${PWD}" $(DOCKER_IMAGE)


tools:
	@if [ ! -d "DynamoRIO" ]; then \
		$(info Downloading DynamoRIO) \
		wget  $(DYNAMORIO_GIT_RELEASE); \
		tar -zxf  $(DYNAMORIO_NAME)$(ZIPS); \
		mv  $(DYNAMORIO_NAME) DynamoRIO ; \
		echo $(DYNAMORIO_NAME)$(ZIPS); \
	fi

build: $(DOCKER_FILE).build

# Use a .PHONY target to build all of the docker images if requested
Dockerfile%.build: Dockerfile%
	docker build   $(DOCKER_BUILD_OPT) -f $(<) -t ubuntu:$(subst Dockerfile-ubuntu-,,$(<))-$(TOOL) .

clean:
	rm -rf $(DYNAMORIO_DIR)$(ZIPS)

distclean: clean
	rm -rf DynamoRIO 

.PHONY: build  run tools clean distclean
