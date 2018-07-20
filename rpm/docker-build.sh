#!/bin/sh
set -e

# update kubelet.spec
DATE=$(date +'%a %b %d %Y')
VERSION=$(./kubelet --version | cut -d ' ' -f 2 | tr -s '-' '_')
echo "DATE: $DATE"
echo "VERSION: $VERSION"

cat kubelet.spec.orig | sed "s/{{DATE}}/${DATE}/g" | sed "s/{{VERSION}}/${VERSION}/g" > kubelet.spec

# build

docker build -t kubelet-rpm-builder .
echo "Cleaning output directory..."
sudo rm -rf output/*
mkdir -p output
docker run -ti --rm -v $PWD/output/:/root/rpmbuild/RPMS/ kubelet-rpm-builder $1
sudo chown -R $USER $PWD/output

echo
echo "----------------------------------------"
echo
echo "RPMs written to: "
ls $PWD/output/*/
echo
echo "Yum repodata written to: "
ls $PWD/output/*/repodata/
