#!/bin/bash

# Переменные для стилизации текста
YELLOW='\033[0;33m'
RED='\033[0;31m'
BOLD='\033[1m'

# Установка значений переменных в зависимости от переданных параметров
ENV=stage

if [ "$#" -eq 1 ]; then
  ENV=$1
fi

if [ "$ENV" == "stage" ]; then
  SERVER_IP=172.16.2.143
  DEPLOY_ENVIRONMENT=staging
elif [ "$ENV" == "prod" ]; then
  SERVER_IP=10.15.2.20
  DEPLOY_ENVIRONMENT=production
elif true; then
  echo -e "${BOLD}${RED}UNKNOWN ENVIRONMENT ${ENV} DEVELOPMENT INTERRUPTED"
  exit 1
fi

# Общие для любодго деплоя параметры
RELEASE_PATH=/home/admintv/cti_kaltura
COMPILED_PROJECT_PATH=$RELEASE_PATH/bin/cti_kaltura
BUILD_AT="/home/admintv/cti_kaltura_build/builds"
VERSION=1.0.0


# Деплоим текущую ветку
BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo -e "${BOLD}${YELLOW}START DEPLOYING $BRANCH IN $ENV ENVIRONMENT TO $SERVER_IP"

echo -e "${BOLD}${YELLOW}CLEANUP BUILD DIRECTORY"
ssh admintv@$SERVER_IP "rm -rf ${BUILD_AT}"

echo -e "${BOLD}${YELLOW}START BUILDING RELEASE"
SERVER_IP=$SERVER_IP MIX_ENV=$ENV BUILD_HOST=$SERVER_IP RELEASE_VERSION=$VERSION mix edeliver build release --branch=$BRANCH --mix-env=$ENV --version=$VERSION

echo -e "${BOLD}${YELLOW}START DEPLOYING RELEASE"
MIX_ENV=$ENV mix edeliver deploy release to $DEPLOY_ENVIRONMENT --clean-deploy --mix-env=$ENV --host=$SERVER_IP --version=$VERSION

echo -e "${BOLD}${YELLOW}RESTART PROJECT"
ssh admintv@$SERVER_IP "${COMPILED_PROJECT_PATH} stop ; ${COMPILED_PROJECT_PATH} start"
