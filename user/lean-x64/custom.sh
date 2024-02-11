#!/bin/bash

echo "Test custom.sh"
# rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/packages/net/smartdns/Makefile
git clone https://github.com/pymumu/openwrt-smartdns.git                        feeds/packages/net/smartdns/
# git clone https://github.com/fw876/helloworld.git                             package/helloworld
# git clone https://github.com/jerrykuku/luci-theme-argon.git -b 18.06          feeds/luci/themes/luci-theme-argontyfreedom
#rm -rf feeds/packages/libs/libcap
#svn co https://github.com/openwrt/openwrt/trunk/package/libs/libcap             feeds/packages/libs/libcap
git clone https://github.com/pymumu/luci-app-smartdns.git -b lede               package/applications/luci-app-smartdns
git clone https://github.com/tty228/luci-app-serverchan.git                     package/applications/luci-app-serverchan
git clone https://github.com/rufengsuixing/luci-app-adguardhome.git            package/applications/luci-app-adguardhome
git clone https://github.com/destan19/OpenAppFilter.git                         package/OpenAppFilter
# git clone https://github.com/xiaorouji/openwrt-passwall-packages.git      package/passwall-packages
# git clone https://github.com/xiaorouji/openwrt-passwall.git -b luci-smartdns-dev       package/passwall
# svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash          package/luci-app-openclash
git clone https://github.com/KFERMercer/luci-app-tcpdump.git                    package/luci-app-tcpdump
# rm -rf feeds/packages/utils/open-vm-tools
# svn co https://github.com/xiaotan8/packages/trunk/utils/open-vm-tools           feeds/packages/utils/open-vm-tools
