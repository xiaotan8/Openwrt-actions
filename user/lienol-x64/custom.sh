#!/bin/bash
# custom.sh - OpenWrt 自定义补丁脚本

set -e

echo ">>> 进入 OpenWrt 源码目录..."
cd openwrt || { echo "❌ 没找到 openwrt 目录"; exit 1; }

echo ">>> 开始禁用不需要的内核模块和包..."

# 1. 禁用 openvswitch
grep -q "CONFIG_PACKAGE_kmod-openvswitch" .config && \
    sed -i "s/^CONFIG_PACKAGE_kmod-openvswitch=.*/# CONFIG_PACKAGE_kmod-openvswitch is not set/" .config || \
    echo "# CONFIG_PACKAGE_kmod-openvswitch is not set" >> .config

# 2. 禁用 ovpn-dco
grep -q "CONFIG_PACKAGE_kmod-ovpn-dco" .config && \
    sed -i "s/^CONFIG_PACKAGE_kmod-ovpn-dco=.*/# CONFIG_PACKAGE_kmod-ovpn-dco is not set/" .config || \
    echo "# CONFIG_PACKAGE_kmod-ovpn-dco is not set" >> .config

# 3. 禁用 ubootenv-nvram
grep -q "CONFIG_PACKAGE_ubootenv-nvram" .config && \
    sed -i "s/^CONFIG_PACKAGE_ubootenv-nvram=.*/# CONFIG_PACKAGE_ubootenv-nvram is not set/" .config || \
    echo "# CONFIG_PACKAGE_ubootenv-nvram is not set" >> .config

# 4. 禁用 Rust 及 Cargo（防止 host 编译失败）
./scripts/feeds uninstall rust || true
./scripts/feeds uninstall cargo || true

# 5. 验证修改是否生效
echo ">>> 验证配置修改结果:"
grep -E "openvswitch|ovpn-dco|ubootenv-nvram" .config || echo "✅ 已正确禁用相关包"
echo "✅ Rust feed 状态:"
./scripts/feeds list -r | grep rust || echo "已移除 rust feed"

echo ">>> 补丁执行完成 ✅"
