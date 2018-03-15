# rpm

For our usage, we only package kubelet and kubernetes-cni.

## 复制 kubelet 二进制到工作目录

```
cd $GOPATH/src/k8s.io/release
git checkout kirk-release
cd rpm
cp $GOPATH/src/k8s.io/kubernetes/_output/bin/kubelet .
```

## 更新 kubelet.spec

编辑 rpm/kubelet.spec 文件，主要是：

- 更新版本号 KUBE_VERSION`，注意需要将 - 变成 _ ，比如：`1.7.12-29+8320ccc842e9ac` -> `1.7.12_29+8320ccc842e9ac`
- 更新 changelog

## 打包

我们只需要 amd64/x86_64 :

```
./docker-build.sh amd64/x86_64
```
