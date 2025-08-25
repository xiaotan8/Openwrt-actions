#!/bin/bash
# custom.sh - OpenWrt build customization script
# 功能: 自动禁用 kmod-openvswitch 和 kmod-ovpn-dco，带补丁验证

set -e

echo "==> [custom.sh] Start applying custom patches..."

# 自动定位 openwrt 源码目录
if [ -d "openwrt" ]; then
    cd openwrt || exit 1
elif [ -d "$GITHUB_WORKSPACE/openwrt" ]; then
    cd "$GITHUB_WORKSPACE/openwrt" || exit 1
elif [ -d "../openwrt" ]; then
    cd ../openwrt || exit 1
else
    echo "❌ OpenWrt source directory not found!"
    pwd
    ls -al
    exit 1
fi

# 打补丁: 禁用 openvswitch 和 ovpn-dco
PATCH_FILE=".config"

echo "==> Patching .config to disable kmod-openvswitch and kmod-ovpn-dco..."
# 幂等修改，不会重复写
grep -q "CONFIG_PACKAGE_kmod-openvswitch" $PATCH_FILE && \
    sed -i "s/^CONFIG_PACKAGE_kmod-openvswitch=.*/# CONFIG_PACKAGE_kmod-openvswitch is not set/" $PATCH_FILE || \
    echo "# CONFIG_PACKAGE_kmod-openvswitch is not set" >> $PATCH_FILE

grep -q "CONFIG_PACKAGE_kmod-ovpn-dco" $PATCH_FILE && \
    sed -i "s/^CONFIG_PACKAGE_kmod-ovpn-dco=.*/# CONFIG_PACKAGE_kmod-ovpn-dco is not set/" $PATCH_FILE || \
    echo "# CONFIG_PACKAGE_kmod-ovpn-dco is not set" >> $PATCH_FILE

# 验证是否成功
echo "==> Verifying patch..."
if grep -q "# CONFIG_PACKAGE_kmod-openvswitch is not set" $PATCH_FILE && \
   grep -q "# CONFIG_PACKAGE_kmod-ovpn-dco is not set" $PATCH_FILE; then
    echo "✅ Patch applied successfully: openvswitch & ovpn-dco disabled."
else
    echo "❌ Patch failed!"
    exit 1
fi

echo "==> [custom.sh] Done."
