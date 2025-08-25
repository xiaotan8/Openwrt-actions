#!/bin/bash
# custom.sh - OpenWrt build customization script

# 进入 OpenWrt 源码目录
cd openwrt || exit 1

echo "==> Apply custom patches: disable openvswitch & ovpn-dco"

# 补丁文件写到 tmp 目录
cat > /tmp/disable-ovs-ovpn-dco.patch <<'EOF'
--- a/package/kernel/ovpn-dco/Makefile
+++ b/package/kernel/ovpn-dco/Makefile
@@ -9,6 +9,9 @@
 PKG_RELEASE:=1

 include $(INCLUDE_DIR)/kernel.mk
+
+# Disable ovpn-dco due to kernel >= 6.12 incompatibility
+PKG_FLAGS:=hold

 PKG_SOURCE_URL:=https://github.com/OpenVPN/ovpn-dco.git
 PKG_SOURCE_PROTO:=git
--- a/package/kernel/openvswitch/Makefile
+++ b/package/kernel/openvswitch/Makefile
@@ -10,6 +10,9 @@
 PKG_RELEASE:=1

 include $(INCLUDE_DIR)/kernel.mk
+
+# Disable openvswitch (not needed in this build)
+PKG_FLAGS:=hold

 PKG_SOURCE_URL:=https://github.com/openvswitch/ovs.git
 PKG_SOURCE_PROTO:=git
EOF

# 应用补丁
if git apply --check /tmp/disable-ovs-ovpn-dco.patch; then
    git apply /tmp/disable-ovs-ovpn-dco.patch
    echo "✅ Patch applied successfully"
else
    echo "⚠️ Patch already applied or not applicable, skipping"
fi

# 验证是否生效：检查 Makefile 是否包含 PKG_FLAGS:=hold
echo "==> Verify patch result"
if grep -q "PKG_FLAGS:=hold" package/kernel/ovpn-dco/Makefile \
   && grep -q "PKG_FLAGS:=hold" package/kernel/openvswitch/Makefile; then
    echo "✅ Patch verification passed (ovpn-dco & openvswitch disabled)"
else
    echo "❌ Patch verification failed!"
    exit 1
fi
