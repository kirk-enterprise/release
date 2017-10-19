#!/bin/bash

ROOT=$(unset CDPATH && cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)
cd $ROOT

function usage() {
    cat <<EOF
Usage: $(basename $0) -v x.x.x+ke.xxxxxxx -r n

Examples:

    $(basename $0) -v 1.7.3+ke.abc1234 -r 0
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

if [[ ! "$PKG_REVISION" =~ ^[0-9]{1,2}$ ]]; then
    echo "error: invalid pkg revision, should be a number, range from 0-99, e.g. 0, 1, 2."
    usage
    exit 1
fi

docker build --tag=debian-packager debian 
docker run --volume="$(pwd)/debian:/src" --volume="${GOPATH}/src/k8s.io/kubernetes:/kubernetes" debian-packager \
    -arch amd64 --kube-version $KUBE_VERSION --pkg-revision $PKG_REVISION
