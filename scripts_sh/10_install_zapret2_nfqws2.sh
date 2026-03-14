#!/bin/sh
set -e

BIN="/usr/local/bin/nfqws2"

echo "Checking latest zapret2 release..."

JSON=$(wget -qO- https://api.github.com/repos/bol-van/zapret2/releases/latest 2>/dev/null || true)

if [ -z "$JSON" ]; then
    echo "Cannot reach GitHub"

    if [ -x "$BIN" ]; then
        echo "Using existing nfqws2 binary"
        exit 0
    else
        echo "No internet and nfqws2 not installed"
        exit 1
    fi
fi

LATEST=$(echo "$JSON" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

echo "Latest version: $LATEST"

CURRENT="none"

if [ -x "$BIN" ]; then
    CURRENT=$($BIN -v 2>/dev/null | grep -oE 'v[0-9.]+' | head -n1 || echo "unknown")
fi

echo "Installed version: $CURRENT"

if [ "$CURRENT" = "$LATEST" ]; then
    echo "nfqws2 already latest"
    exit 0
fi

URL=$(echo "$JSON" \
    | grep browser_download_url \
    | grep '.tar.gz"' \
    | grep -v openwrt-embedded \
    | head -n1 \
    | cut -d '"' -f4)

if [ -z "$URL" ]; then
    echo "Release tar.gz not found"
    exit 1
fi

ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        FILE="binaries/linux-x86_64/nfqws2"
        ;;
    aarch64)
        FILE="binaries/linux-arm64/nfqws2"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "Finding nfqws2 inside archive..."

FILEPATH=$(wget -qO- "$URL" | tar -tz | grep "/$FILE$" | head -n1)

if [ -z "$FILEPATH" ]; then
    echo "nfqws2 not found in archive"
    exit 1
fi

echo "Downloading and extracting $FILEPATH"

wget -qO- "$URL" | tar -xzO "$FILEPATH" > "$BIN.tmp"

chmod +x "$BIN.tmp"
mv "$BIN.tmp" "$BIN"

echo "nfqws2 updated to $LATEST"
