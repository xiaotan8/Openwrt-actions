#!/usr/bin/env bash
# shellcheck disable=SC2016

trap 'rm -rf "$TMPDIR"' EXIT
TMPDIR=$(mktemp -d) || exit 1

NO_SFE=false
LOCAL_PACKAGE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-sfe)
            NO_SFE=true
            shift
            ;;
        --local-pkg)
            LOCAL_PACKAGE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if ! [ -d "./package" ]; then
    echo "./package not found"
    exit 1
fi

VERSION_NUMBER=$(sed -n '/VERSION_NUMBER:=$(if $(VERSION_NUMBER),$(VERSION_NUMBER),.*)/p' include/version.mk | sed -e 's/.*$(VERSION_NUMBER),//' -e 's/)//')
kernel_versions="$(find "./include" | sed -n '/kernel-[0-9]/p' | sed -e "s@./include/kernel-@@" | sed ':a;N;$!ba;s/\n/ /g')"
if [ -z "$kernel_versions" ]; then
    kernel_versions="$(find "./target/linux/generic" | sed -n '/kernel-[0-9]/p' | sed -e "s@./target/linux/generic/kernel-@@" | sed ':a;N;$!ba;s/\n/ /g')"
fi
if [ -z "$kernel_versions" ]; then
    echo "Error: Unable to get kernel version, script exited"
    exit 1
fi
echo "kernel version: $kernel_versions, No SFE: $NO_SFE"

if [ -d "./package/turboacc" ]; then
    echo "./package/turboacc already exists, delete it? [Y/N]"
    read -r answer
    if [[ $answer =~ ^[Yy]$ ]]; then
        rm -rf "./package/turboacc"
    else
        echo "You selected 'No', script exited"
        exit 0
    fi
fi

git clone --depth=1 --single-branch https://github.com/chenmozhijin/turboacc "$TMPDIR/turboacc/turboacc" || exit 1
if [ -n "$LOCAL_PACKAGE" ]; then
    echo "Using local package: $LOCAL_PACKAGE"
    cp -RT "$LOCAL_PACKAGE" "$TMPDIR/package" || exit 1
else
    git clone --depth=1 --single-branch --branch "package" https://github.com/chenmozhijin/turboacc "$TMPDIR/package" || exit 1
fi

cp -r "$TMPDIR/turboacc/turboacc/luci-app-turboacc" "$TMPDIR/turboacc/luci-app-turboacc"
rm -rf "$TMPDIR/turboacc/turboacc"
cp -r "$TMPDIR/package/nft-fullcone" "$TMPDIR/turboacc/nft-fullcone" || exit 1
if [ "$NO_SFE" = false ]; then
    cp -r "$TMPDIR/package/shortcut-fe" "$TMPDIR/turboacc/shortcut-fe"
fi

for kernel_version in $kernel_versions; do
    patch_952_path="./target/linux/generic/hack-$kernel_version/952-net-conntrack-events-support-multiple-registrant.patch"
    patch_953_path="./target/linux/generic/hack-$kernel_version/953-net-patch-linux-kernel-to-support-shortcut-fe.patch"
    patch_613_path="./target/linux/generic/pending-$kernel_version/613-netfilter_optional_tcp_window_check.patch"

    # 自动匹配补丁文件
    if [ -a "$patch_952_path" ]; then
        patch_952="$patch_952_path"
    else
        echo "Warning: Patch 952 for kernel version $kernel_version not found."
    fi

    if [ -a "$patch_953_path" ]; then
        patch_953="$patch_953_path"
    else
        echo "Warning: Patch 953 for kernel version $kernel_version not found."
    fi

    if [ -a "$patch_613_path" ]; then
        patch_613="$patch_613_path"
    else
        echo "Warning: Patch 613 for kernel version $kernel_version not found."
    fi

    # 如果没有找到补丁文件，跳过当前版本
    if [ -z "$patch_952" ] && [ -z "$patch_953" ] && [ -z "$patch_613" ]; then
        echo "Error: No patches found for kernel version $kernel_version. Skipping."
        continue
    fi

    # 删除现有的补丁文件（如果有的话）
    for file_path in "$patch_952" "$patch_953" "$patch_613"; do
        if [ -a "$file_path" ]; then
            echo "$file_path already exists, delete."
            rm -rf "$file_path"
        fi
    done

    # 将补丁文件复制到目标路径
    if [ -n "$patch_952" ]; then
        cp -f "$patch_952" "./target/linux/generic/hack-$kernel_version/"
    fi
    if [ -n "$patch_953" ]; then
        cp -f "$patch_953" "./target/linux/generic/hack-$kernel_version/"
    fi
    if [ -n "$patch_613" ]; then
        cp -f "$patch_613" "./target/linux/generic/pending-$kernel_version/"
    fi

    # 更新内核配置文件
    if ! grep -q "CONFIG_NF_CONNTRACK_CHAIN_EVENTS" "./target/linux/generic/config-$kernel_version"; then
        echo "# CONFIG_NF_CONNTRACK_CHAIN_EVENTS is not set" >> "./target/linux/generic/config-$kernel_version"
    fi
    if [ "$NO_SFE" = false ] && ! grep -q "CONFIG_SHORTCUT_FE" "./target/linux/generic/config-$kernel_version"; then
        echo "# CONFIG_SHORTCUT_FE is not set" >> "./target/linux/generic/config-$kernel_version"
    fi
done

cp -r "$TMPDIR/turboacc" "./package/turboacc"

FIREWALL4_VERSION=$(grep -o 'PKG_SOURCE_VERSION:=.*' ./package/network/config/firewall4/Makefile | cut -d '=' -f 2)
NFTABLES_VERSION=$(grep -o 'PKG_VERSION:=.*' ./package/network/utils/nftables/Makefile | cut -d '=' -f 2)
LIBNFTNL_VERSION=$(grep -o 'PKG_VERSION:=.*' ./package/libs/libnftnl/Makefile | cut -d '=' -f 2)

rm -rf ./package/libs/libnftnl ./package/network/config/firewall4 ./package/network/utils/nftables

if ! [ -d "$TMPDIR/package/firewall4-$FIREWALL4_VERSION" ]; then
    echo "firewall4 version $FIREWALL4_VERSION not found, using latest version"
    FIREWALL4_VERSION=$(grep -o 'FIREWALL4_VERSION=.*' "$TMPDIR/package/version" | cut -d '=' -f 2)
fi
if ! [ -d "$TMPDIR/package/nftables-$NFTABLES_VERSION" ]; then
    echo "nftables version $NFTABLES_VERSION not found, using latest version"
    NFTABLES_VERSION=$(grep -o 'NFTABLES_VERSION=.*' "$TMPDIR/package/version" | cut -d '=' -f 2)
fi
if ! [ -d "$TMPDIR/package/libnftnl-$LIBNFTNL_VERSION" ]; then
    echo "libnftnl version $LIBNFTNL_VERSION not found, using latest version"
    LIBNFTNL_VERSION=$(grep -o 'LIBNFTNL_VERSION=.*' "$TMPDIR/package/version" | cut -d '=' -f 2)
fi
cp -RT "$TMPDIR/package/firewall4-$FIREWALL4_VERSION/firewall4" ./package/network/config/firewall4
cp -RT "$TMPDIR/package/libnftnl-$LIBNFTNL_VERSION/libnftnl" ./package/libs/libnftnl
cp -RT "$TMPDIR/package/nftables-$NFTABLES_VERSION/nftables" ./package/network/utils/nftables

echo "Finish"
exit 0
