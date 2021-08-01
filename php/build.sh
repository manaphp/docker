#!/bin/bash

if [ $# -lt 1 ]; then
  echo 'usage: ./build.sh php<version>'
  exit 1;
fi

set -xe

PHP_VERSION=${1:-'php74'}
IMAGE_TAG=${2:-$(date +%y%m%d)}
IMAGE_URI="manaphp/${PHP_VERSION}:${IMAGE_TAG}"
IMAGE_URI_LATEST="manaphp/${PHP_VERSION}:latest"

BUILD_DIR=$(realpath $(dirname "$0"))

if [ "$http_proxy" == '' ]; then
  docker build --tag $IMAGE_URI --tag $IMAGE_URI_LATEST --file $BUILD_DIR/${PHP_VERSION}.dockerfile $BUILD_DIR
else
  docker build --tag $IMAGE_URI --tag $IMAGE_URI_LATEST --file $BUILD_DIR/${PHP_VERSION}.dockerfile --build-arg http_proxy=$http_proxy $BUILD_DIR
fi
docker push $IMAGE_URI && docker push $IMAGE_URI_LATEST