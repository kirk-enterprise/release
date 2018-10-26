#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

ROOT=$(unset CDPATH && cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)
cd $ROOT

# build kubelet deb and rpm packages
cd $GOPATH/src/k8s.io/kubernetes
./build/run.sh make WHAT='cmd/kubelet'

## debian
VERSION=$($GOPATH/src/k8s.io/kubernetes/_output/dockerized/bin/linux/amd64/kubelet --version | cut -d ' ' -f 2)
echo "VERSION: $VERSION"
cd $GOPATH/src/k8s.io/release
git checkout kirk-release 
./debian/run.sh -v $VERSION -r 0

## rpm
cd $GOPATH/src/k8s.io/release
git checkout kirk-release
cd rpm
cp $GOPATH/src/k8s.io/kubernetes/_output/dockerized/bin/linux/amd64/kubelet .
./docker-build.sh amd64/x86_64
