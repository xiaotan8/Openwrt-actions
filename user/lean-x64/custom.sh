#!/bin/bash

echo "Test custom.sh"
# rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/packages/net/smartdns/Makefile
git clone https://github.com/pymumu/openwrt-smartdns.git                        feeds/packages/net/smartdns/
# git clone https://github.com/fw876/helloworld.git                             package/helloworld
# git clone https://github.com/jerrykuku/luci-theme-argon.git -b 18.06          feeds/luci/themes/luci-theme-argontyfreedom
rm -rf feeds/packages/libs/libcap
svn co https://github.com/openwrt/openwrt/trunk/package/libs/libcap             feeds/packages/libs/libcap
git clone https://github.com/pymumu/luci-app-smartdns.git -b lede               package/applications/luci-app-smartdns
git clone https://github.com/tty228/luci-app-serverchan.git                     package/applications/luci-app-serverchan
svn co https://github.com/Lienol/openwrt-package/branches/other/luci-app-adguardhome            package/applications/luci-app-adguardhome
git clone https://github.com/destan19/OpenAppFilter.git                         package/OpenAppFilter
git clone https://github.com/xiaorouji/openwrt-passwall.git -b packages         package/passwall-packages
git clone https://github.com/xiaorouji/openwrt-passwall.git -b luci-smartdns-new-version             package/passwall
svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash          package/luci-app-openclash
git clone https://github.com/KFERMercer/luci-app-tcpdump.git                    package/luci-app-tcpdump
rm -rf build_dir/target-x86_64_musl/open-vm-tools-11.3.0-18090558
git clone https://github.com/vmware/open-vm-tools.git                           build_dir/target-x86_64_musl/open-vm-tools
