#!/bin/bash
set -e

echo "==> 检查并回退内核到 6.6 LTS"

# 直接在 openwrt 根目录运行，不再 cd
TARGET_MK="target/linux/x86/Makefile"

if [ ! -f "$TARGET_MK" ]; then
  echo "❌ 没找到 $TARGET_MK，确认架构是否为 x86？"
  exit 1
fi

# 获取当前内核版本
CURRENT_VER=$(grep -E "KERNEL_PATCHVER:=" $TARGET_MK | cut -d= -f2)
echo "当前内核版本: $CURRENT_VER"

# 如果不是 6.6 就回退
if [ "$CURRENT_VER" != "6.6" ]; then
  echo "==> 内核版本不是 6.6，自动回退..."
  sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=6.6/' $TARGET_MK
  sed -i 's/KERNEL_TESTING_PATCHVER:=.*/KERNEL_TESTING_PATCHVER:=6.6/' $TARGET_MK || true
else
  echo "✅ 内核已是 6.6，无需修改"
fi

# 确保需要的内核模块
cat >> .config <<EOF
CONFIG_PACKAGE_kmod-psample=y
CONFIG_PACKAGE_kmod-openvswitch=y
CONFIG_PACKAGE_kmod-ovpn-dco=y
EOF

# 验证
echo "==> 验证修改结果"
grep KERNEL_PATCHVER $TARGET_MK
grep "kmod-openvswitch" .config || echo "⚠️ openvswitch 未写入 .config"
grep "kmod-psample" .config || echo "⚠️ psample 未写入 .config"
grep "kmod-ovpn-dco" .config || echo "⚠️ ovpn-dco 未写入 .config"

echo "==> 内核版本检测 & 回退逻辑执行完成 ✅"
