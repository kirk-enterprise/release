#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

ROOT=$(unset CDPATH && cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)
cd $ROOT

# build images
cd $GOPATH/src/k8s.io/kubernetes
export KUBE_DOCKER_IMAGE_TAG=$(./hack/print-workspace-status.sh | awk -F' ' '/^gitVersion/ {print $2}' | tr -s '+' '_')
export KUBE_DOCKER_REGISTRY=index-dev.qiniu.io/kelibrary
env | grep '^KUBE'
make quick-release

# push images
BINS="kube-controller-manager kube-scheduler kube-apiserver kube-proxy"
for bin in $BINS; do
    echo -n "Pushing $KUBE_DOCKER_REGISTRY/$bin-amd64:$KUBE_DOCKER_IMAGE_TAG, version: "
    docker run $KUBE_DOCKER_REGISTRY/$bin-amd64:$KUBE_DOCKER_IMAGE_TAG $bin --version
    docker push $KUBE_DOCKER_REGISTRY/$bin-amd64:$KUBE_DOCKER_IMAGE_TAG
done
