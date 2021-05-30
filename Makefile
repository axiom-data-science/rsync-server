#//////////////////////////////////////////////////////////////
#//   ____                                                   //
#//  | __ )  ___ _ __  ___ _   _ _ __   ___ _ __ _ __   ___  //
#//  |  _ \ / _ \ '_ \/ __| | | | '_ \ / _ \ '__| '_ \ / __| //
#//  | |_) |  __/ | | \__ \ |_| | |_) |  __/ |  | |_) | (__  //
#//  |____/ \___|_| |_|___/\__,_| .__/ \___|_|  | .__/ \___| //
#//                             |_|             |_|          //
#//////////////////////////////////////////////////////////////
#//                                                          //
#//  Script, 2021                                            //
#//  Created: 30, May, 2021                                  //
#//  Modified: 30, May, 2021                                 //
#//  file: -                                                 //
#//  -                                                       //
#//  Source: https://github.com/axiom-data-science/rsync-server                                               //
#//          https://www.docker.com/blog/getting-started-with-docker-for-arm-on-linux/
#//          https://schinckel.net/2021/02/12/docker-%2B-makefile/
#//  OS: ALL                                                 //
#//  CPU: ALL                                                //
#//                                                          //
#//////////////////////////////////////////////////////////////
BASE_IMAGE := debian:buster-slim
IMAGE_NAME := bensuperpc/rsync-server
DOCKERFILE := Dockerfile

DOCKER := docker

TAG := $(shell date '+%Y%m%d')-$(shell git rev-parse --short HEAD)
DATE_FULL := $(shell date +%Y-%m-%d_%H:%M:%S)
UUID := $(shell cat /proc/sys/kernel/random/uuid)

#Not in debian buster : riscv64

ARCH_LIST = amd64 386 arm64 arm ppc64le s390x

$(ARCH_LIST): $(DOCKERFILE)
	$(DOCKER) buildx build . -f $(DOCKERFILE) -t $(IMAGE_NAME):$@-$(TAG) -t $(IMAGE_NAME):$@-latest \
	--build-arg BUILD_DATE=$(DATE_FULL) --build-arg DOCKER_IMAGE=$(BASE_IMAGE) --platform linux/$@

armv5: $(DOCKERFILE)
	$(DOCKER) buildx build . -f $(DOCKERFILE) -t $(IMAGE_NAME):armv5-$(TAG) -t $(IMAGE_NAME):armv5-latest \
	--build-arg BUILD_DATE=$(DATE_FULL) --build-arg DOCKER_IMAGE=$(BASE_IMAGE) --platform linux/arm/v5

armv6: $(DOCKERFILE)
	$(DOCKER) buildx build . -f $(DOCKERFILE) -t $(IMAGE_NAME):armv6-$(TAG) -t $(IMAGE_NAME):armv6-latest \
	--build-arg BUILD_DATE=$(DATE_FULL) --build-arg DOCKER_IMAGE=$(BASE_IMAGE) --platform linux/arm/v6
	
armv7: $(DOCKERFILE)
	$(DOCKER) buildx build . -f $(DOCKERFILE) -t $(IMAGE_NAME):armv7-$(TAG) -t $(IMAGE_NAME):armv7-latest \
	--build-arg BUILD_DATE=$(DATE_FULL) --build-arg DOCKER_IMAGE=$(BASE_IMAGE) --platform linux/arm/v7

armv8: $(DOCKERFILE)
	$(DOCKER) buildx build . -f $(DOCKERFILE) -t $(IMAGE_NAME):armv8-$(TAG) -t $(IMAGE_NAME):armv8-latest \
	--build-arg BUILD_DATE=$(DATE_FULL) --build-arg DOCKER_IMAGE=$(BASE_IMAGE) --platform linux/arm/v8
	
all: $(ARCH_LIST) armv5 armv6 armv7 armv8

push: all
	$(DOCKER) image push $(IMAGE_NAME) --all-tags

# https://github.com/linuxkit/linuxkit/tree/master/pkg/binfmt
qemu_x86:
	$(DOCKER) run --rm --privileged linuxkit/binfmt:5d33e7346e79f9c13a73c6952669e47a53b063d4-amd64

clean:
	$(DOCKER) images --filter='reference=$(IMAGE_NAME)' --format='{{.Repository}}:{{.Tag}}' | xargs -r $(DOCKER) rmi -f

.PHONY: build push clean qemu_x86 $(ARCH_LIST) armv5 armv6 armv7 armv8