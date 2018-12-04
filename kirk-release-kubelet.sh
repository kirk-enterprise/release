#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

ROOT=$(unset CDPATH && cd $(dirname "${BASH_SOURCE[0]}") && pwd)
cd $ROOT

KIRK_REPO_BASIC_AUTH=${KIRK_REPO_BASIC_AUTH:-}

if [ -z "$KIRK_REPO_BASIC_AUTH" ]; then
    echo "error: please specify KIRK_REPO_BASIC_AUTH"
    exit 1
fi

if [ -z "$KIRK_REPO_UPLOAD_URL" ]; then
    echo "error: please specify KIRK_REPO_UPLOAD_URL"
    exit 1
fi

function upload_package() {
    curl -u "$KIRK_REPO_BASIC_AUTH" -F file=@$1 "$KIRK_REPO_UPLOAD_URL"
}

# build kubelet binary
if [[ -n "${SKIP_BUILD:-}" ]]; then
    echo "info: build is skippped"
else
    cd $GOPATH/src/k8s.io/kubernetes
    ./build/run.sh make WHAT='cmd/kubelet'
fi
VERSION=$($GOPATH/src/k8s.io/kubernetes/_output/dockerized/bin/linux/amd64/kubelet --version | cut -d ' ' -f 2)
echo "Kubelet version: $VERSION"
VERSION_DEB=$(echo "$VERSION" | sed 's#^v##')
VERSION_RPM=$(echo "$VERSION" | sed 's#^v##' | sed 's#-#_#')

## build & push deb package
cd $GOPATH/src/k8s.io/release
echo "VERSION: $VERSION"
./debian/run.sh -v $VERSION -r 0
DEB_PKG_PATH=$(find debian/bin/stable/xenial -name "*${VERSION_DEB}*.deb")
if [ ! -f "$DEB_PKG_PATH" ]; then
    echo "error: kubelet deb package not found: $DEB_PKG_PATH"
    exit 1
fi
echo "Uploading package $DEB_PKG_PATH"
upload_package "$DEB_PKG_PATH"

## build & push rpm package
cd $GOPATH/src/k8s.io/release
cp $GOPATH/src/k8s.io/kubernetes/_output/dockerized/bin/linux/amd64/kubelet rpm/kubelet
cd rpm/
./docker-build.sh amd64/x86_64
cd ../
RPM_PKG_PATH=$(find rpm/output/x86_64/ -name "*${VERSION_RPM}*.rpm")
if [ ! -f "$RPM_PKG_PATH" ]; then
    echo "error: kubelet rpm package not found: $RPM_PKG_PATH"
    exit 1
fi
echo "Uploading package $RPM_PKG_PATH"
upload_package "$RPM_PKG_PATH"
