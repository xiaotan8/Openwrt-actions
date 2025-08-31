#!/bin/bash
set -e

echo "=============================="
echo ">>> Running custom.sh ..."
echo "=============================="

# 1. 删除冲突或旧包
# ==============================

# ==============================
# 3. 修复 boost-system 已删除的问题
# ==============================
fix_boost_dependency() {
    echo "[Step] 修复 boost-system 依赖问题"

    TARGET_MAKEFILES=(
        "package/feeds/packages/domoticz/Makefile"
        "package/feeds/packages/i2pd/Makefile"
        "package/feeds/packages/kea/Makefile"
        "package/feeds/packages/libtorrent-rasterbar/Makefile"
    )

    for mk in "${TARGET_MAKEFILES[@]}"; do
        if [ -f "$mk" ]; then
            echo "  -> 修复 $mk"
            sed -i 's/\+boost-system/+boost/g' "$mk"
        fi
    done
}
fix_boost_dependency

# ==============================
# 4. 修复 shadowsocksr-libev 编译问题
# ==============================
fix_ssr_build() {
    echo "[Step] 修复 shadowsocksr-libev 编译问题"

    SSR_DIR="package/passwall-packages/shadowsocksr-libev"
    if [ -d "$SSR_DIR" ]; then
        echo "  -> 替换为 Lede 版本"
        rm -rf "$SSR_DIR"
        git clone --depth=1 https://github.com/coolsnowwolf/lede.git tmp_lede
        if [ -d tmp_lede/package/lean/shadowsocksr-libev ]; then
            mv tmp_lede/package/lean/shadowsocksr-libev package/passwall-packages/
            echo "  -> 已成功替换为 Lede 版本 ✅"
        else
            echo "  -> Lede 包未找到，使用 -Wno-error 修复"
            local SSR_MK="$SSR_DIR/Makefile"
            if [ -f "$SSR_MK" ]; then
                sed -i '/Build\/Configure/a\ \tCFLAGS+=" -Wno-error"' "$SSR_MK"
                echo "  -> 已添加 -Wno-error ✅"
            fi
        fi
        rm -rf tmp_lede
    else
        echo "  -> 未找到 shadowsocksr-libev，跳过"
    fi
}
fix_ssr_build

# ==============================
# 5. 更新 feeds
# ==============================
./scripts/feeds update -a
./scripts/feeds install -a

echo "=============================="
echo ">>> custom.sh done ✅"
echo "=============================="
