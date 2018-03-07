#!/usr/bin/env bash
export MACHINE_NAME="default"



docker-machine start $MACHINE_NAME
docker-machine env
eval $(docker-machine env)
pwd
docker rm test-run -f
docker run --rm -it hung135/database_ci:latest
