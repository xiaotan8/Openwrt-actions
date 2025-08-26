#!/bin/bash
# custom.sh - OpenWrt build customization script
# 功能: 自动禁用 kmod-openvswitch 和 kmod-ovpn-dco

set -e

echo "==> [custom.sh] Start applying custom patches..."

# 自动查找 .config
CONFIG_FILE=""
for path in \
    "./openwrt/.config" \
    "./.config" \
    "$GITHUB_WORKSPACE/openwrt/.config" \
    "$GITHUB_WORKSPACE/.config" \
    "../openwrt/.config" \
    "../../openwrt/.config"
do
    if [ -f "$path" ]; then
        CONFIG_FILE="$path"
        break
    fi
done

if [ -z "$CONFIG_FILE" ]; then
    echo "❌ 没找到 .config 文件，请确认 custom.sh 的执行路径！"
    pwd
    ls -al
    exit 1
fi

echo "==> Using config: $CONFIG_FILE"

# 打补丁: 禁用 openvswitch 和 ovpn-dco
sed -i "/CONFIG_PACKAGE_kmod-openvswitch/d" "$CONFIG_FILE"
sed -i "/CONFIG_PACKAGE_kmod-ovpn-dco/d" "$CONFIG_FILE"

echo "# CONFIG_PACKAGE_kmod-openvswitch is not set" >> "$CONFIG_FILE"
echo "# CONFIG_PACKAGE_kmod-ovpn-dco is not set" >> "$CONFIG_FILE"

# 验证
echo "==> Verifying patch..."
if grep -q "# CONFIG_PACKAGE_kmod-openvswitch is not set" "$CONFIG_FILE" && \
   grep -q "# CONFIG_PACKAGE_kmod-ovpn-dco is not set" "$CONFIG_FILE"; then
    echo "✅ Patch applied successfully."
else
    echo "❌ Patch failed!"
    exit 1
fi

echo "==> [custom.sh] Done."
