#!/bin/bash

echo "Test custom.sh"
rm -rf feeds/luci/themes/luci-theme-argon
git clone https://github.com/jerrykuku/luci-theme-argon.git       feeds/luci/themes/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-jd-dailybonus.git package/luci-app-jd-dailybonus
git clone https://github.com/tty228/luci-app-serverchan.git       package/luci-app-serverchan
git clone https://github.com/destan19/OpenAppFilter.git           package/diy/OpenAppFilter
git clone https://github.com/xiaorouji/openwrt-passwall.git -b packages      package/diy/passwall-packages
git clone https://github.com/xiaorouji/openwrt-passwall.git -b luci     package/diy/passwall
# git clone  https://github.com/fw876/helloworld.git                package/helloworld
# rm -rf ./target/linux/generic/hack-5.10/952-net-conntrack-events-support-multiple-registrant.patch
# wget -P ./target/linux/generic/hack-5.10/ https://raw.githubusercontent.com/coolsnowwolf/lede/master/target/linux/generic/hack-5.10/952-net-conntrack-events-support-multiple-registrant.patch
