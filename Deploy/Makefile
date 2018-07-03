

IMAGE = amarburg/covis-postprocess:latest

help:
	@echo "make matlab          Use Matlab compiler to build Python package 'pycovis-postprocess'"
	@echo "make build           Build the docker image"
	@echo "make force_build     Build the docker image with --no-cache"
	@echo "make push            Push the docker image to DockerHub"
	@echo "make test            Run pytest in the docker image"
	@echo "make version         Demo which runs scripts/version.py in the Docker image"


#== Tasks related to building and testing Docker scripts ==
build:       pycovis-matlab/setup.py pycovis-postprocess/pycovis/postprocess/*.py
	docker build --tag ${IMAGE} .

force_build: pycovis-matlab/setup.py
	docker build --tag ${IMAGE} --no-cache .

push: build
	docker push ${IMAGE}

test: build
	docker run --rm \
						-v $(shell pwd)/input:/input:ro \
						-v $(shell pwd)/output:/output \
						${IMAGE} -m pytest




#== Some examples of running python scripts in the Docker image... ==
version: build
	docker run -i --rm ${IMAGE} scripts/version.py

imaging: build
	rm -rf $(shell pwd)/test_data/output/*
	docker run --rm \
					-v $(shell pwd)/test_data/input:/input \
					-v $(shell pwd)/test_data/output:/output \
 					${IMAGE} scripts/process_sweep.py


##== Matlab packaging rules. ==
## Must be run on a machine with Matlab Compiler SDK installed

COVIS_REPO=..
COVIS_INPUT=${COVIS_REPO}/Common/input
MCC=mcc

matlab: pycovis-matlab/setup.py

pycovis-matlab/setup.py: ${COVIS_REPO}/Common/*.m ${COVIS_REPO}/Imaging/*.m
	mkdir -p pycovis-matlab/
	${MCC} -v -d pycovis-matlab/ -W python:pycovis.matlab -T link:lib $^
	cp -r $(COVIS_INPUT) pycovis-matlab/

.PHONY: build force_build test help build_matlab version imaging
