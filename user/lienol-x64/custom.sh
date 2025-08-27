bash
#!/bin/bash
set -e

echo "==> OpenWrt 自定义配置脚本"
echo "==> 作者: 自定义脚本"
echo "==> 时间: $(date)"
echo "=========================================="

# 定义函数 - 修复 Rust 编译错误
fix_rust_compile_error() {
    local RUST_MAKEFILE="feeds/packages/lang/rust/Makefile"
    
    if [ -f "$RUST_MAKEFILE" ]; then
        echo "[INFO] 修复 Rust Makefile (禁用 download-ci-llvm)"
        
        # 备份原文件
        if [ ! -f "${RUST_MAKEFILE}.bak" ]; then
            cp "$RUST_MAKEFILE" "${RUST_MAKEFILE}.bak"
            echo "[INFO] 已备份原文件: ${RUST_MAKEFILE}.bak"
        fi
        
        # 修改配置
        sed -i 's/download-ci-llvm=true/download-ci-llvm=false/g' "$RUST_MAKEFILE"
        
        # 验证修改
        if grep -q "download-ci-llvm=false" "$RUST_MAKEFILE"; then
            echo "[OK] Rust Makefile 已成功修改 ✅"
            echo "修改内容: download-ci-llvm=true → download-ci-llvm=false"
        else
            echo "[WARN] Rust Makefile 修改可能未生效"
        fi
    else
        echo "[WARN] 未找到 Rust Makefile: $RUST_MAKEFILE"
        echo "[INFO] 跳过 Rust 编译修复"
    fi
}

# 定义函数 - 修改默认网络配置
fix_config_generate() {
    local CONFIG_GENERATE="package/base-files/files/bin/config_generate"
    
    if [ -f "$CONFIG_GENERATE" ]; then
        echo "[INFO] 找到 config_generate 文件: $CONFIG_GENERATE"
        echo "[INFO] 修改默认 LAN 网络参数"
        
        # 备份原文件
        if [ ! -f "${CONFIG_GENERATE}.bak" ]; then
            cp "$CONFIG_GENERATE" "${CONFIG_GENERATE}.bak"
            echo "[INFO] 已备份原文件: ${CONFIG_GENERATE}.bak"
        fi
        
        # 修改默认 IP 地址 (192.168.1.1 → 10.10.10.10)
        sed -i 's/192\.168\.1\.1/10.10.10.10/g' "$CONFIG_GENERATE"
        
        # 修改默认网关 (192.168.1.1 → 10.10.10.1)
        sed -i 's/192\.168\.1\.1/10.10.10.1/g' "$CONFIG_GENERATE"
        
        # 添加默认 DNS - 使用更兼容的 sed 语法
        if grep -q "ipaddr=10.10.10.10" "$CONFIG_GENERATE"; then
            # 在 ipaddr 行后添加 DNS 配置
            sed -i '/ipaddr=10.10.10.10/a\set network.lan.dns=10.10.10.10' "$CONFIG_GENERATE"
        fi
        
        echo "[INFO] 网络配置修改完成"
        echo "默认 IP: 192.168.1.1 → 10.10.10.10"
        echo "默认网关: 192.168.1.1 → 10.10.10.1"
        echo "默认 DNS: 10.10.10.10"
        
        # 验证修改
        echo "-------- 验证修改结果 --------"
        grep -n "10.10.10.10" "$CONFIG_GENERATE" | head -3
        grep -n "10.10.10.1" "$CONFIG_GENERATE" | head -2
        echo "-----------------------------"
        
    else
        echo "[WARN] 未找到 config_generate 文件: $CONFIG_GENERATE"
        echo "[INFO] 跳过网络配置修改"
    fi
}

# 定义函数 - 检查并回退内核版本
check_and_rollback_kernel() {
    local TARGET_MK="target/linux/x86/Makefile"
    
    echo "==> 检查并回退内核到 6.6 LTS"
    
    if [ ! -f "$TARGET_MK" ]; then
        echo "❌ 没找到 $TARGET_MK"
        echo "❌ 请确认:"
        echo "   1. 当前目录是否为 OpenWrt 源码根目录"
        echo "   2. 设备架构是否为 x86"
        echo "   3. 是否已运行 './scripts/feeds update -a'"
        exit 1
    fi
    
    # 获取当前内核版本
    local CURRENT_VER
    if grep -q "KERNEL_PATCHVER:=" "$TARGET_MK"; then
        CURRENT_VER=$(grep -E "KERNEL_PATCHVER:=" "$TARGET_MK" | awk -F= '{print $2}' | tr -d ' ')
        echo "当前内核版本: $CURRENT_VER"
    else
        echo "❌ 无法确定当前内核版本"
        exit 1
    fi
    
    # 如果不是 6.6 就回退
    if [ "$CURRENT_VER" != "6.6" ]; then
        echo "==> 内核版本不是 6.6，自动回退到 6.6 LTS..."
        
        # 备份原文件
        if [ ! -f "${TARGET_MK}.bak" ]; then
            cp "$TARGET_MK" "${TARGET_MK}.bak"
            echo "[INFO] 已备份原文件: ${TARGET_MK}.bak"
        fi
        
        # 修改主内核版本
        sed -i 's/^KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=6.6/' "$TARGET_MK"
        
        # 修改测试内核版本（如果存在）
        if grep -q "^KERNEL_TESTING_PATCHVER" "$TARGET_MK"; then
            sed -i 's/^KERNEL_TESTING_PATCHVER:=.*/KERNEL_TESTING_PATCHVER:=6.6/' "$TARGET_MK"
            echo "[INFO] 已修改测试内核版本为 6.6"
        fi
        
        echo "✅ 内核版本已从 $CURRENT_VER 回退到 6.6 LTS"
    else
        echo "✅ 内核已是 6.6 LTS，无需修改"
    fi
}

# 定义函数 - 配置内核模块
configure_kernel_modules() {
    echo "==> 配置必需的内核模块"
    
    # 创建或修改 .config 文件
    if [ ! -f .config ]; then
        echo "[INFO] 创建新的 .config 文件"
        touch .config
    fi
    
    # 需要配置的模块列表
    local modules=(
        "kmod-psample"
        "kmod-openvswitch"
        "kmod-ovpn-dco"
    )
    
    for module in "${modules[@]}"; do
        local config_name="CONFIG_PACKAGE_${module}"
        
        # 检查是否已配置
        if grep -q "^${config_name}=y" .config; then
            echo "✅ ${module} 已配置"
        else
            # 移除可能存在的其他配置（如 =m 或 =n）
            sed -i "/^${config_name}=/d" .config 2>/dev/null || true
            # 添加新配置
            echo "${config_name}=y" >> .config
            echo "✅ ${module} 已添加到配置"
        fi
    done
    
    echo "[INFO] 内核模块配置完成"
}

# 定义函数 - 验证所有修改
verify_changes() {
    echo ""
    echo "=========================================="
    echo "==> 验证所有修改"
    echo "=========================================="
    
    # 验证内核版本
    echo "[验证] 内核版本配置:"
    if [ -f "target/linux/x86/Makefile" ]; then
        grep "KERNEL_PATCHVER" "target/linux/x86/Makefile" || echo "❌ 未找到内核版本配置"
    else
        echo "❌ target/linux/x86/Makefile 不存在"
    fi
    
    # 验证内核模块
    echo ""
    echo "[验证] 内核模块配置:"
    local modules=("kmod-psample" "kmod-openvswitch" "kmod-ovpn-dco")
    for module in "${modules[@]}"; do
        if grep -q "CONFIG_PACKAGE_${module}=y" .config 2>/dev/null; then
            echo "✅ ${module}: 已启用"
        else
            echo "❌ ${module}: 未正确配置"
        fi
    done
    
    # 验证 Rust 配置
    echo ""
    echo "[验证] Rust 配置:"
    if [ -f "feeds/packages/lang/rust/Makefile" ]; then
        if grep -q "download-ci-llvm=false" "feeds/packages/lang/rust/Makefile"; then
            echo "✅ Rust download-ci-llvm: 已禁用"
        else
            echo "❌ Rust download-ci-llvm: 未修改"
        fi
    else
        echo "⚠️  Rust Makefile 不存在"
    fi
    
    # 验证网络配置
    echo ""
    echo "[验证] 网络配置:"
    if [ -f "package/base-files/files/bin/config_generate" ]; then
        local count_ip=$(grep -c "10.10.10.10" "package/base-files/files/bin/config_generate")
        local count_gw=$(grep -c "10.10.10.1" "package/base-files/files/bin/config_generate")
        
        if [ "$count_ip" -gt 0 ]; then
            echo "✅ 默认 IP: 10.10.10.10 (找到 $count_ip 处)"
        else
            echo "❌ 默认 IP: 未修改"
        fi
        
        if [ "$count_gw" -gt 0 ]; then
            echo "✅ 默认网关: 10.10.10.1 (找到 $count_gw 处)"
        else
            echo "❌ 默认网关: 未修改"
        fi
    else
        echo "⚠️  config_generate 文件不存在"
    fi
}

# 主执行逻辑
main() {
    echo "开始执行自定义配置..."
    echo "当前工作目录: $(pwd)"
    echo ""
    
    # 执行各个配置步骤
    check_and_rollback_kernel
    echo ""
    
    configure_kernel_modules
    echo ""
    
    fix_rust_compile_error
    echo ""
    
    fix_config_generate
    echo ""
    
    verify_changes
    echo ""
    
    echo "=========================================="
    echo "✅ 所有自定义配置完成！"
    echo "✅ 接下来您可以运行:"
    echo "   make menuconfig  # 进行其他配置"
    echo "   make -j$(nproc)  # 开始编译"
    echo "=========================================="
}

# 执行主函数
main "$@"
