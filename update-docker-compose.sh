#!/bin/bash

apt remove docker-compose

DOCKER_COMPOSE_PATH=$(which docker-compose)

rm -f $DOCKER_COMPOSE_PATH

if [[ $DOCKER_COMPOSE_PATH -eq '' ]]
	then DOCKER_COMPOSE_PATH='/usr/bin/docker-compose'
fi

VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d')

curl -L https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-$(uname -s)-$(uname -m) -o $DOCKER_COMPOSE_PATH

chmod 755 $DOCKER_COMPOSE_PATH
