#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

ROOT=$(unset CDPATH && cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)
cd $ROOT

function usage() {
    cat <<EOF
Usage: $(basename $0) -v <kubeVersion> -r <pkgVersion>

Examples:

    $(basename $0) -v 1.7.3-15+f2fa44d6d7b2cf -r 0
EOF
}

KUBE_VERSION=""
PKG_REVISION=""

while getopts "h?v:r:" opt; do
    case "$opt" in
    h|\?)
        usage
        exit 0
        ;;  
    v)  
        KUBE_VERSION="${OPTARG}"
        ;;
    r)
        PKG_REVISION="${OPTARG}"
        ;;
    esac
done

if [[ ! "$KUBE_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9]+(\+[0-9a-z]{14})?)?$ ]]; then
    echo "error: invalid kube version, e.g. 1.7.3-15+f2fa44d6d7b2cf"
    usage
    exit 1
fi

if [[ ! "$PKG_REVISION" =~ ^[0-9]{1,2}$ ]]; then
    echo "error: invalid pkg revision, should be a number, range from 0-99, e.g. 0, 1, 2."
    usage
    exit 1
fi

docker build --tag=debian-packager debian 
docker run --volume="$(pwd)/debian:/src" --volume="${GOPATH}/src/k8s.io/kubernetes:/kubernetes" debian-packager \
    -arch amd64 --kube-version "$KUBE_VERSION" --pkg-revision "$PKG_REVISION"
