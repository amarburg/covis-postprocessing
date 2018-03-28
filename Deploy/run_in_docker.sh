#!/bin/sh

cat $1 | docker run -i --rm ${DOCKER_OPTS} amarburg/covis-postprocess
