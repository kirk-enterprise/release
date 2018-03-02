# debian

## 打包

```
cd $GOPATH/src/k8s.io/release
git checkout kirk-release 
./debian/run.sh -v <version> -r <pkgRevision>
```

注：

- <version> 为 kubelet 版本，从 kubelet --version 获取，比如：1.6.1-3+9b2e939be6afda
- <pkgRevision> 为 debian 包版本，比如：0 或 1 或 2 等

## 检查

打包完后，包会存放在 release/debian/bin/stable/xenial/ 目录下。

测试：

```
dpkg -i debian/bin/stable/xenial/kubelet_1.6.1-3+9b2e939be6afda-02_amd64.deb
```
