

TAG = amarburg/covis-postprocess:latest

build:
	docker build . --tag ${TAG}

force_build:
	docker build . --tag ${TAG} --no-cache

push: build
	docker push ${TAG}

test: build
	docker run --rm -v /Users/aaron/workspace/COVIS/covis-test-data:/input:ro -v output:/output ${TAG} -m pytest



## Some examples of running python scripts in the Docker image...
version:
	./run_in_docker.sh scripts/version.py

imaging:
	DOCKER_OPTS="-v /Users/aaron/workspace/COVIS/covis-test-data:/input:ro -v /Users/aaron/workspace/COVIS/docker-covis-postprocess/output:/output" \
	./run_in_docker.sh scripts/imaging.py


help:
	echo "make build           Build the docker image"
	echo "make force_build     Build the docker image with --no-cache"
	echo "make test            Run pytest in the docker image"
	echo "make build_matlab         "


##== Matlab packaging rules. ==
## Must be run on a machine with Matlab Compiler SDK installed

COVIS_REPO=..
MCC=mcc

build_matlab: ${COVIS_REPO}/Common/covis_*.m
	mkdir -p pycovis-postprocess/
	${MCC} -v -d pycovis-postprocess/ -W python:pycovis.postprocess -T link:lib $^
	cp -r ${COVIS_REPO}/Common/input pycovis-postprocess/


.PHONY: build force_build test help build_matlab version
