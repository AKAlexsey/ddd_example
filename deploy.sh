#!/bin/bash

SERVER_IP=172.16.2.143
RELEASE_PATH=/home/app/cti_kaltura
COMPILED_PROJECT_PATH=$RELEASE_PATH/bin/cti_kaltura
BUILD_AT="/tmp/edeliver/cti_kaltura/builds"
VERSION=1.0.0

# Деплоим текущую ветку
BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo 'CLEANUP BUILD DIRECTORY'
ssh app@$SERVER_IP "rm -rf ${BUILD_AT}"

echo 'START BUILDING RELEASE'
SERVER_IP=$SERVER_IP MIX_ENV=stage BUILD_HOST=$SERVER_IP RELEASE_VERSION=$VERSION mix edeliver build release --branch=$BRANCH --mix-env=stage --version=$VERSION

echo 'START DEPLOYING RELEASE'
MIX_ENV=stage mix edeliver deploy release to staging --clean-deploy --mix-env=stage --host=$SERVER_IP --version=$VERSION

echo 'RESTART PROJECT'
ssh app@$SERVER_IP "${COMPILED_PROJECT_PATH} stop && ${COMPILED_PROJECT_PATH} start"
