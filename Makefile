include .env

SHELL := /bin/bash

.PHONY: build forcebuild up down shell status

export IMAGE_NAME = arris/flutter-grpc-html2:latest
export CONTAINER_NAME = flutter-grpc-html2

GOPATH ?= ${X_GOPATH}
PROJECT_NAME ?= ${PROJECT_NAME}
PROJECT_NS ?= ${PROJECT_NS} 
PROJECT_BIN ?= ${PROJECT_BIN}
PROJECT_DIR ?= ${PROJECT_DIR}

build:
	source .env \
	    && docker build -t arris/dev -f ${PROJECT_DIR}/docker/Dockerfile.dev . \
	    && docker build \
		--build-arg GOPATH=${X_GOPATH} \
		--build-arg PROJECT_NAME=${PROJECT_NAME} \
		--build-arg PROJECT_NS=${PROJECT_NS} \
		--build-arg PROJECT_DIR=${PROJECT_DIR} \
		-t arris/go \
		-f ${PROJECT_DIR}/docker/Dockerfile.go \
		. \
	    && docker build -t arris/android -f ${PROJECT_DIR}/docker/Dockerfile.android . \
	    && docker build -t ${IMAGE_NAME} -f ${PROJECT_DIR}/docker/Dockerfile.flutter . 

forcebuild:
	source .env \
	    && docker build --no-cache -t arris/dev -f ${PROJECT_DIR}/docker/Dockerfile.dev . \
	    && docker build \
		--no-cache \
		--build-arg GOPATH=${X_GOPATH} \
		--build-arg PROJECT_NAME=${PROJECT_NAME} \
		--build-arg PROJECT_NS=${PROJECT_NS} \
		--build-arg PROJECT_DIR=${PROJECT_DIR} \
		-t arris/go \
		-f ${PROJECT_DIR}/docker/Dockerfile.go \
		. \
	    && docker build --no-cache -t arris/android -f ${PROJECT_DIR}/docker/Dockerfile.android . \
	    && docker build --no-cache -t ${IMAGE_NAME} -f ${PROJECT_DIR}/docker/Dockerfile.flutter . 

go-debug:
	docker run --rm -it --privileged \
                -e LINES=$(tput lines) \
                -e COLUMNS=$(tput cols) \
		-v /Users/arris/Code:/code \
 		--mount type=bind,src=${PROJECT_DIR},dst=${GOPATH}/src/${PROJECT_NS} \
		-p 5554:5554 \
		-p 5555:5555 \
		-w ${GOPATH}/src/${PROJECT_NS}/go-server/cmd/server \
		arris/go

go-shell:
	docker run --rm -it --privileged \
                -e LINES=$(tput lines) \
                -e COLUMNS=$(tput cols) \
		-v /Users/arris/Code:${GOPATH}/src \
		-p 5554:5554 \
		-p 5555:5555 \
		-p 3000:3000\
		-w ${GOPATH}/src/github.com/arrisray/flutter-grpc-html2/go-server/cmd/server \
		arris/go \
		bash

flutter-shell:
	docker run \
	    -e ADB_SERVER_SOCKET=tcp:host.docker.internal:5037 \
	    -v /Users/arris/Code/github.com/arrisray/flutter-grpc-html2:/src \
	    --rm -it $(IMAGE_NAME) \
	    bash

down: export CONTAINER_IDS := $(shell docker ps -qa --no-trunc --filter "status=exited")
down:
	docker stop $(CONTAINER_NAME)

clean: export CONTAINER_IDS=$(shell docker ps -qa --no-trunc --filter "status=exited")
clean:
	docker rm $(CONTAINER_NAME)

status:
	docker ps -a
