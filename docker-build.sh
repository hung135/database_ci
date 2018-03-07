#!/usr/bin/env bash
export MACHINE_NAME="default"



docker-machine start $MACHINE_NAME
docker-machine env
eval $(docker-machine env)
pwd
docker build -t hung135/database_ci .
