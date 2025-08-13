#!/bin/bash

echo "Test custom.sh"
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
git clone https://github.com/xiaorouji/openwrt-passwall-packages package/passwall-packages
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/luci/applications/luci-app-passwall2
rm -rf feeds/luci/applications/luci-app-nikki
rm -rf feeds/luci/applications/luci-app-OpenClash
git clone https://github.com/xiaorouji/openwrt-passwall package/passwall-luci
git clone https://github.com/vernesong/OpenClash -b master package/openclash
rm -rf feeds/luci/themes/luci-theme-argon
git clone https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon
rm -rf feeds/packages/net/smartdns
git clone https://github.com/pymumu/openwrt-smartdns.git                     feeds/packages/net/smartdns/
rm -rf feeds/luci/applications/luci-app-smartdns
git clone https://github.com/pymumu/luci-app-smartdns.git              package/applications/luci-app-smartdns
git clone https://github.com/tty228/luci-app-wechatpush.git     package/applications/luci-app-wechatpush
#git clone https://github.com/rufengsuixing/luci-app-adguardhome.git         package/applications/luci-app-adguardhome
#git clone https://github.com/destan19/OpenAppFilter.git                     package/applications/OpenAppFilter
git clone https://github.com/KFERMercer/luci-app-tcpdump.git                 package/applications/luci-app-tcpdump
git clone https://github.com/nikkinikki-org/OpenWrt-nikki.git                package/applications/OpenWrt-nikki
git clone https://github.com/jerrykuku/luci-app-argon-config.git             package/applications/luci-app-argon-config
