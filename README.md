## feed-wocampus
OpenWrt 下的河北联通校园宽带拨号工具（使用 wo 的校园 app 认证协议），替代原有的闪讯 PPPoE 拨号

### 2022.2.27
学校已通知即将修改认证方式为 portal 认证，PPPoE 及 app 认证方式被弃用，所以本库也无法使用了。等全面切换到 portal 验证后再分析认证方式。

### 如何编译
1. 修改 feeds.conf.default，最后一行添加 ```src-git wocampus https://github.com/web1n/feed-wocampus```
2. 刷新 feeds
```
./scripts/feeds update -a
./scripts/feeds install -a
```
3. 使用 ```make menuconfig``` 命令，在 LuCI-> Protocols 中选中 luci-proto-wocampus 软件包
4. 编译

### 使用方法
选中 OpenWrt 后台-> 接口-> 对应的接口-> 选择河北联通校园协议-> 填写 ***wo 的校园*** 用户名密码后保存-> 等待登录成功

### License
Apache License  
本项目仅限测试使用，请勿将其用于其他用途，请在下载 24 小时内删除。
