#!/bin/bash

ROOT=$(unset CDPATH && cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)
cd $ROOT

docker build --tag=debian-packager debian 
docker run --volume="$(pwd)/debian:/src" --volume="${GOPATH}/src/k8s.io/kubernetes:/kubernetes" debian-packager \
    -arch amd64 $@
