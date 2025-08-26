#!/bin/bash
set -e

echo "==> [custom.sh] Start applying custom patches..."

if [ ! -d "./target/linux/x86" ]; then
    echo "❌ 没找到 target/linux/x86 目录！"
    exit 1
fi

# 1. 在内核配置中启用 psample 模块
CONFIG_FILE="target/linux/x86/config-6.12"

if ! grep -q "^CONFIG_PSAMPLE" "$CONFIG_FILE"; then
    echo "==> 启用 CONFIG_PSAMPLE=m"
    echo "CONFIG_PSAMPLE=m" >> "$CONFIG_FILE"
else
    echo "==> CONFIG_PSAMPLE 已存在，跳过添加"
fi

# 2. 验证是否写入成功
if grep -q "^CONFIG_PSAMPLE=m" "$CONFIG_FILE"; then
    echo "✅ CONFIG_PSAMPLE=m 已写入 $CONFIG_FILE"
else
    echo "❌ 未能写入 CONFIG_PSAMPLE"
    exit 1
fi
