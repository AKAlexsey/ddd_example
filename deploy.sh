#!/bin/bash

# Переменные для стилизации текста
YELLOW='\033[0;33m'
RED='\033[0;31m'
BOLD='\033[1m'

if [ "$#" -eq 1 ]; then
  ENV=$1
fi

if [ "$ENV" == "stage1" ]; then
  SERVER_IP=172.16.2.143
  DEPLOY_ENVIRONMENT=staging
  BUILD_USER="app"
elif [ "$ENV" == "stage2" ]; then
  SERVER_IP=172.16.2.6
  DEPLOY_ENVIRONMENT=staging
  BUILD_USER="app"
elif [ "$ENV" == "prod1" ]; then
  SERVER_IP=10.15.2.20
  DEPLOY_ENVIRONMENT=production
  BUILD_USER="admintv"
elif [ "$ENV" == "prod2" ]; then
  SERVER_IP=10.15.2.25
  DEPLOY_ENVIRONMENT=production
  BUILD_USER="admintv"
elif true; then
  echo -e "${BOLD}${RED}UNKNOWN ENVIRONMENT ${ENV} DEVELOPMENT INTERRUPTED"
  exit 1
fi

# Общие для любодго деплоя параметры
RELEASE_PATH=/home/$BUILD_USER/cti_kaltura
PROJECT_API_PATH=$RELEASE_PATH/api
COMPILED_PROJECT_PATH=$RELEASE_PATH/bin/cti_kaltura
BUILD_AT=/home/$BUILD_USER/cti_kaltura_build/builds
VERSION=1.0.0
LINK_VM_ARGS=/home/$BUILD_USER/cti_kaltura_build/vm.args
DELIVER_TO=/home/$BUILD_USER

# Деплоим текущую ветку
BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo -e "${BOLD}${YELLOW}START DEPLOYING $BRANCH IN $ENV ENVIRONMENT TO $SERVER_IP"

echo -e "${BOLD}${YELLOW}CLEANUP BUILD DIRECTORY"
ssh $BUILD_USER@$SERVER_IP "rm -rf ${BUILD_AT}"

echo -e "${BOLD}${YELLOW}START BUILDING RELEASE"
SERVER_IP=$SERVER_IP BUILD_AT=$BUILD_AT BUILD_USER=$BUILD_USER LINK_VM_ARGS=$LINK_VM_ARGS MIX_ENV=$ENV BUILD_HOST=$SERVER_IP RELEASE_VERSION=$VERSION mix edeliver build release --branch=$BRANCH --mix-env=$ENV --version=$VERSION

echo -e "${BOLD}${YELLOW}START DEPLOYING RELEASE"
DELIVER_TO=$DELIVER_TO MIX_ENV=$ENV LINK_VM_ARGS=$LINK_VM_ARGS mix edeliver deploy release to $DEPLOY_ENVIRONMENT --clean-deploy --mix-env=$ENV --host=$SERVER_IP --version=$VERSION

echo -e "${BOLD}${YELLOW}RESTART PROJECT"
ssh $BUILD_USER@$SERVER_IP "sudo service keepalived stop"
ssh $BUILD_USER@$SERVER_IP "sudo ${PROJECT_API_PATH}/stop_cti_kaltura.sh; sudo ${PROJECT_API_PATH}/start_cti_kaltura.sh"
ssh $BUILD_USER@$SERVER_IP "sudo service keepalived start"

echo -e "${BOLD}${YELLOW}RUNNING MIGRATIONS"
ssh $BUILD_USER@$SERVER_IP "${COMPILED_PROJECT_PATH} migrate"
