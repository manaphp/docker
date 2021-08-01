#!/bin/bash

set -xe

BUILD_DIR=$(realpath $(dirname "$0"))

for version in php71 php72 php73 php74 php80
do
  bash -c "$BUILD_DIR/build.sh $version"
done