#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

ROOT=$(unset CDPATH && cd $(dirname "${BASH_SOURCE[0]}") && pwd)
cd $ROOT

KUBE_DOCKER_REGISTRY=${KUBE_DOCKER_REGISTRY:-}
KUBE_DOCKER_USERNAME=${KUBE_DOCKER_USERNAME:-}
KUBE_DOCKER_PASSWORD=${KUBE_DOCKER_PASSWORD:-}

if [ -z "$KUBE_DOCKER_REGISTRY" ]; then
    echo "error: KUBE_DOCKER_REGISTRY is missing"
    exit 1
fi

# login docker
if [ -z "$KUBE_DOCKER_USERNAME" -o -z "$KUBE_DOCKER_PASSWORD" ]; then
    echo "error: please provide KUBE_DOCKER_USERNAME and KUBE_DOCKER_PASSWORD for $KUBE_DOCKER_REGISTRY"
    exit 1
else
    docker login -u "${KUBE_DOCKER_USERNAME}" --password-stdin $(echo $KUBE_DOCKER_REGISTRY | cut -d '/' -f 1) <<< "$KUBE_DOCKER_PASSWORD"
fi

# build images
cd $GOPATH/src/k8s.io/kubernetes
source build/common.sh

export KUBE_DOCKER_IMAGE_TAG=$(./hack/print-workspace-status.sh | awk -F' ' '/^gitVersion/ {print $2}' | tr -s '+' '_')
if [[ "$KUBE_DOCKER_IMAGE_TAG" =~ -dirty$ ]]; then
    echo "error: '-dirty' exists in image tag: $KUBE_DOCKER_IMAGE_TAG, please check"
    exit 1
fi
echo "KUBE_DOCKER_IMAGE_TAG: $KUBE_DOCKER_IMAGE_TAG"

if [[ -n "${SKIP_BUILD:-}" ]]; then
    echo "info: image build is skippped"
else
    make quick-release
fi

# push images
function push_images() {
    # NOTE: we only support amd64 for now
    local binaries=($(kube::build::get_docker_wrapped_binaries amd64))
    for wrappable in "${binaries[@]}"; do
		local oldifs=$IFS
		IFS=","
		set $wrappable
		IFS=$oldifs
		local binary_name="$1"
		local base_image="$2"
        echo -n "Pushing $KUBE_DOCKER_REGISTRY/$binary_name-amd64:$KUBE_DOCKER_IMAGE_TAG"
        docker push $KUBE_DOCKER_REGISTRY/$binary_name-amd64:$KUBE_DOCKER_IMAGE_TAG
    done
}

push_images
