#!/bin/bash

echo "Test custom.sh"
git clone --depth=1 https://github.com/xiaotan8/luci-app-accesscontrol.git package/applications/luci-app-accesscontrol


SMARTDNS_MAKEFILE="feeds/packages/net/smartdns/Makefile"

if [ -f "$SMARTDNS_MAKEFILE" ]; then
  echo ">>> 检测到 smartdns Makefile，开始修复 PKG_HASH"

  # 解析版本号
  PKG_VERSION=$(grep "^PKG_VERSION:=" "$SMARTDNS_MAKEFILE" | cut -d= -f2)
  PKG_SOURCE="smartdns-$PKG_VERSION.tar.zst"
  TMP_DL="smartdns.tar.zst"

  # 下载源码包
  echo ">>> 下载 smartdns v$PKG_VERSION ..."
  curl -L -o "$TMP_DL" "https://github.com/pymumu/smartdns/archive/refs/tags/Release-$PKG_VERSION.tar.gz" 2>/dev/null || true

  if [ -f "$TMP_DL" ]; then
    # 计算 sha256
    NEW_HASH=$(sha256sum "$TMP_DL" | awk '{print $1}')
    echo ">>> 新 HASH: $NEW_HASH"

    # 修改 Makefile
    sed -i "s/PKG_HASH:=.*/PKG_HASH:=$NEW_HASH/" "$SMARTDNS_MAKEFILE"
    echo ">>> smartdns PKG_HASH 已更新完成"
    rm -f "$TMP_DL"
  else
    echo "!!! smartdns 源码下载失败，跳过修复"
  fi
else
  echo "!!! 未找到 smartdns Makefile，跳过"
fi
