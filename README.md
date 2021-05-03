## feed-wocampus
OpenWrt 下的河北联通校园宽带拨号工具，替代原有的闪讯 PPPoE 拨号。

### 如何编译
git clone 本仓库
```
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig
```

选中 wocampus 及 luci-proto-wocampus 软件包，编译即可。

### 使用方法
选中 OpenWrt 后台-> 接口-> 对应的接口-> 选择河北联通校园协议-> 填写用户名密码后保存-> 等待登录成功 enjoy~

### License
Apache License
本项目仅限测试使用，请勿将其用于其他用途，请在下载 24 小时内删除。