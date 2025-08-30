#!/bin/bash

echo "Test custom.sh"
git clone --depth=1 https://github.com/xiaotan8/luci-app-accesscontrol.git package/applications/luci-app-accesscontrol
sed -i 's/PKG_HASH:=150019a03f1ec2e4b5849740a72badf5ea094d5754bd59dd30119523a3ce9398/PKG_HASH:=abcb3d3bfa99297dfb92b8fb4f1f78d0948a01281fdfc76c9c460a2c3d5c7f79/' feeds/packages/net/smartdns/Makefile
