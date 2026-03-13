#!/bin/sh
set -e

BIN="/usr/local/bin/mihomo"
TMP="/tmp/mihomo.$$"

mkdir -p "$TMP"

cleanup() {
    rm -rf "$TMP"
}
trap cleanup EXIT

echo "Checking latest mihomo release..."

LATEST=$(wget -qO- https://api.github.com/repos/MetaCubeX/mihomo/releases/latest 2>/dev/null \
    | grep '"tag_name":' \
    | sed -E 's/.*"([^"]+)".*/\1/' || true)

if [ -z "$LATEST" ]; then
    echo "Cannot reach GitHub"

    if [ -x "$BIN" ]; then
        echo "Using existing mihomo binary"
        exit 0
    else
        echo "No internet and mihomo not installed"
        exit 1
    fi
fi

echo "Latest version: $LATEST"

CURRENT="none"
if [ -x "$BIN" ]; then
    CURRENT=$($BIN -v 2>/dev/null | grep -oE 'v[0-9.]+' | head -n1 || echo "unknown")
fi

echo "Installed version: $CURRENT"

if [ "$CURRENT" = "$LATEST" ]; then
    echo "mihomo already latest"
    exit 0
fi

ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        FILE="mihomo-linux-amd64-compatible-${LATEST}.gz"
        ;;
    aarch64)
        FILE="mihomo-linux-arm64-${LATEST}.gz"
        ;;
    armv7l|armv7)
        FILE="mihomo-linux-armv7-${LATEST}.gz"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

URL="https://github.com/MetaCubeX/mihomo/releases/download/${LATEST}/${FILE}"

echo "Downloading $URL"

wget -O "$TMP/mihomo.gz" "$URL"

gunzip "$TMP/mihomo.gz"

chmod +x "$TMP/mihomo"

mv "$TMP/mihomo" "$BIN"

echo "mihomo updated to $LATEST"
