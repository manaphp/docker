#!/bin/bash

set -xe

BUILD_DIR=$(realpath $(dirname "$0"))

for version in php80 php81
do
  bash -c "$BUILD_DIR/build.sh $version"
done