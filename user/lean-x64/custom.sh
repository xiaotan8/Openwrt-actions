#!/bin/bash
# custom.sh
# 在 OpenWrt 源码目录中执行（Actions 的 step 已经 cd openwrt）。
# 主要用于修复 sstp-client 在新 pppd 上缺失 chap-new.h 的编译问题。

set -e

echo "===> Running custom.sh in: $(pwd)"

# 简单检测当前目录是否是 OpenWrt 源码（看 scripts/feeds 是否存在）
if [ ! -x "scripts/feeds" ]; then
    echo "ERROR: scripts/feeds not found. Please run this script inside OpenWrt source directory."
    exit 1
fi

###############################################################################
# 1. 更新 & 安装 feeds（如果在 workflow 里已经做过，可按需注释掉）
###############################################################################
echo "===> Updating and installing feeds"
./scripts/feeds update -a
./scripts/feeds install -a

###############################################################################
# 2. 修正 sstp-client 的依赖（兜底，确保包含 +ppp）
###############################################################################
SSTP_MAKEFILE="feeds/packages/net/sstp-client/Makefile"

if [ -f "$SSTP_MAKEFILE" ]; then
    echo "===> Ensuring sstp-client depends on ppp in Makefile"

    awk '
    BEGIN { inpkg=0 }
    /^define Package\/sstp-client/ { inpkg=1 }
    inpkg && /^endef/ { inpkg=0 }
    inpkg && /^[[:space:]]*DEPENDS:=/ {
        if ($0 !~ /\+ppp/) {
            sub(/DEPENDS:=/, "DEPENDS:=+ppp ")
        }
    }
    { print }
    ' "$SSTP_MAKEFILE" > "$SSTP_MAKEFILE.tmp" && mv "$SSTP_MAKEFILE.tmp" "$SSTP_MAKEFILE"

else
    echo "WARNING: $SSTP_MAKEFILE not found, skip depends patch."
fi

###############################################################################
# 3. 为 sstp-client 添加补丁，兼容新的 pppd 头文件
###############################################################################
echo "===> Adding patch for sstp-client to handle missing pppd/chap-new.h"

SSTP_PATCH_DIR="feeds/packages/net/sstp-client/patches"
mkdir -p "$SSTP_PATCH_DIR"

# 简单版本：直接把 chap-new.h 换成 chap.h
cat > "$SSTP_PATCH_DIR/100-pppd-headers-compat.patch" << 'EOF'
--- a/src/pppd-plugin/sstp-plugin.c
+++ b/src/pppd-plugin/sstp-plugin.c
@@ -36,7 +36,7 @@
 #include <pppd/pppd.h>
 #include <pppd/fsm.h>
 #include <pppd/lcp.h>
-#include <pppd/chap-new.h>
+#include <pppd/chap.h>
 
 #include "sstp-api.h"
 #include "sstp-error.h"
EOF

# 如需兼容新旧 pppd 的 __has_include 版本，把上面的 cat 块删掉，
# 换成下面这个注释里的内容即可：
#: <<'ALT_EOF'
#cat > "$SSTP_PATCH_DIR/100-pppd-headers-compat.patch" << 'EOF'
#--- a/src/pppd-plugin/sstp-plugin.c
#+++ b/src/pppd-plugin/sstp-plugin.c
#@@ -36,7 +36,15 @@
# #include <pppd/pppd.h>
# #include <pppd/fsm.h>
# #include <pppd/lcp.h>
#-#include <pppd/chap-new.h>
#+
+#/* Newer pppd versions removed chap-new.h and only provide chap.h.
+# * Try to include chap-new.h if present, otherwise fall back to chap.h.
+# */
+#if __has_include(<pppd/chap-new.h>)
+#include <pppd/chap-new.h>
+#else
+#include <pppd/chap.h>
+#endif
# 
# #include "sstp-api.h"
# #include "sstp-error.h"
#EOF
#ALT_EOF

echo "===> sstp-client patch added: $SSTP_PATCH_DIR/100-pppd-headers-compat.patch"

###############################################################################
# 4. 其它自定义操作（按需追加）
###############################################################################
if [ -f "$SSTP_MAKEFILE" ]; then
    echo "===> Current sstp-client DEPENDS line:"
    grep -E '^[[:space:]]*DEPENDS:=' "$SSTP_MAKEFILE" || true
fi

echo "===> custom.sh finished successfully."
