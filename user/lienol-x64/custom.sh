#!/bin/bash

echo "Test custom.sh"
rm -rf feeds/luci/themes/luci-theme-argon
git clone https://github.com/jerrykuku/luci-theme-argon.git       feeds/luci/themes/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config.git  Package/luci-app-argon-config
git clone https://github.com/jerrykuku/luci-app-jd-dailybonus.git package/luci-app-jd-dailybonus
git clone https://github.com/tty228/luci-app-serverchan.git       package/luci-app-serverchan
git clone https://github.com/destan19/OpenAppFilter.git           package/diy/OpenAppFilter
git clone https://github.com/xiaorouji/openwrt-passwall.git -b packages      package/diy/passwall-packages
git clone https://github.com/xiaorouji/openwrt-passwall.git -b luci     package/diy/passwall
# git clone  https://github.com/fw876/helloworld.git                package/helloworld
