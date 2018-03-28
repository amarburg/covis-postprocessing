

IMAGE = amarburg/covis-postprocess:latest

build:
	docker build . --IMAGE ${IMAGE}

force_build:
	docker build . --IMAGE ${IMAGE} --no-cache

push: build
	docker push ${IMAGE}

test: build
	docker run --rm \
						-v $(shell pwd)/input:/input:ro \
						-v $(shell pwd)/output:/output \
						${IMAGE} -m pytest


## Some examples of running python scripts in the Docker image...
version:
	./run_in_docker.sh scripts/version.py
	docker run --rm $(IMAGE)

imaging:
	docker run --rm \
					-v $(shell pwd)/input:/input:ro \
					-v $(shell pwd)/output:/output \
 					scripts/imaging.py


help:
	echo "make build           Build the docker image"
	echo "make force_build     Build the docker image with --no-cache"
	echo "make test            Run pytest in the docker image"
	echo "make build_matlab         "


##== Matlab packaging rules. ==
## Must be run on a machine with Matlab Compiler SDK installed

COVIS_REPO=..
COVIS_SRCS=${COVIS_REPO}/Common/input 
MCC=mcc

build_matlab: ${COVIS_REPO}/Common/covis_*.m
	mkdir -p pycovis-postprocess/
	${MCC} -v -d pycovis-postprocess/ -W python:pycovis.postprocess -T link:lib $^
	cp -r $$COVIS_SRCS} pycovis-postprocess/


.PHONY: build force_build test help build_matlab version
