#!/bin/bash
# ==========================================
# Custom OpenWrt Patch Script
# ==========================================

set -e

echo "==> [custom.sh] Start applying custom patches..."

# 确保在 openwrt 根目录执行
if [ ! -d "./package" ] || [ ! -f "./Makefile" ]; then
    echo "❌ 没找到 OpenWrt 根目录，请在 openwrt/ 下运行！"
    exit 1
fi

# 确保有 .config 文件
if [ ! -f ".config" ]; then
    echo "❌ 没找到 .config 文件，请先执行 make menuconfig 或复制现成配置！"
    exit 1
fi

# ===============================
# 1. 删除 openvswitch 包目录
# ===============================
if [ -d "package/network/utils/openvswitch" ]; then
    echo "==> 移除 package/network/utils/openvswitch"
    rm -rf package/network/utils/openvswitch
fi

# ===============================
# 2. 强制清理 .config 配置
# ===============================
echo "==> 清理 .config 里的 openvswitch 配置"
sed -i '/CONFIG_PACKAGE_kmod-openvswitch/d' .config
sed -i '/CONFIG_PACKAGE_openvswitch/d' .config

# 追加禁用配置
cat >> .config <<EOF
# CONFIG_PACKAGE_kmod-openvswitch is not set
# CONFIG_PACKAGE_openvswitch is not set
EOF

# ===============================
# 3. 验证结果
# ===============================
if grep -q "openvswitch" .config; then
    echo "❌ openvswitch 仍然存在于 .config，请检查依赖包！"
    exit 1
else
    echo "✅ openvswitch 已成功禁用"
fi

echo "==> [custom.sh] Finished!"
