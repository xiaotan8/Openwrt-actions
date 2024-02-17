#!/bin/bash

echo "Test custom.sh"
rm -rf feeds/packages/net/smartdns/Makefile
git clone https://github.com/pymumu/openwrt-smartdns.git                        feeds/packages/net/smartdns/
git clone https://github.com/pymumu/luci-app-smartdns.git -b lede               package/applications/luci-app-smartdns
git clone https://github.com/tty228/luci-app-wechatpush.git -b openwrt-18.06    package/applications/luci-app-serverchan
git clone https://github.com/rufengsuixing/luci-app-adguardhome.git            package/applications/luci-app-adguardhome
git clone https://github.com/destan19/OpenAppFilter.git                         package/OpenAppFilter
git clone https://github.com/KFERMercer/luci-app-tcpdump.git                    package/luci-app-tcpdump
# 解决 luci-app-passwall 1+2 状态页延时检测为 0.00 ms 的问题【sbwml大佬提供】
rm -rf feeds/packages/net/curl
git clone https://github.com/sbwml/feeds_packages_net_curl feeds/packages/net/curl
