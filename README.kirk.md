# release kubelet for kirk

## Prepare

```
mkdir -p $GOPATH/src/k8s.io
cd $GOPATH/src/k8s.io
git clone git@github.com:qbox/kubernetes.git
git clone git@github.com:kirk-enterprise/release.git
```

## Build 

```
cd $GOPATH/src/k8s.io/kubernetes
./build/run.sh make WHAT='cmd/kubelet' # kubelet binary will be generated at _output/dockerized/bin/linux/amd64/kubelet
```

## Packaging

### debian

```
VERSION=$($GOPATH/src/k8s.io/kubernetes/_output/dockerized/bin/linux/amd64/kubelet --version | cut -d ' ' -f 2)
echo "VERSION: $VERSION"
cd $GOPATH/src/k8s.io/release
git checkout kirk-release 
./debian/run.sh -v <version> -r <pkgRevision>
```

注：

- <version> 为 kubelet 版本，从 kubelet --version 获取，比如：1.6.1-3+9b2e939be6afda
- <pkgRevision> 为 debian 包版本，比如：0 或 1 或 2 等

#### checking

打包完后，包会存放在 release/debian/bin/stable/xenial/ 目录下。

测试：

```
dpkg -i debian/bin/stable/xenial/kubelet_1.6.1-3+9b2e939be6afda-02_amd64.deb
```

### rpm

For our usage, we only package kubelet and kubernetes-cni.

```
cd $GOPATH/src/k8s.io/release
git checkout kirk-release
cd rpm
cp $GOPATH/src/k8s.io/kubernetes/_output/dockerized/bin/linux/amd64/kubelet .
```

#### update kubelet.spec and build

编辑 rpm/kubelet.spec 文件，主要是：

- 更新版本号 KUBE_VERSION`，注意需要将 - 变成 _ ，比如：`1.7.12-29+8320ccc842e9ac` -> `1.7.12_29+8320ccc842e9ac`
- 更新 changelog

```
./docker-build.sh amd64/x86_64
```
