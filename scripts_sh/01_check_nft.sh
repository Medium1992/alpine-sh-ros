if ! lsmod | grep nf_tables >/dev/null 2>&1; then
  echo "Not found nftables module kernel"
  if ! apk info -e iptables iptables-legacy >/dev/null 2>&1; then
    echo "Not found package iptables, install iptables"
    apk add --no-cache iptables iptables-legacy >/dev/null 2>&1
    rm -f /usr/sbin/iptables /usr/sbin/iptables-save /usr/sbin/iptables-restore
    ln -s /usr/sbin/iptables-legacy /usr/sbin/iptables
    ln -s /usr/sbin/iptables-legacy-save /usr/sbin/iptables-save
    ln -s /usr/sbin/iptables-legacy-restore /usr/sbin/iptables-restore
  fi
else
  echo "Found nftables module kernel"
  if ! apk info -e nftables >/dev/null 2>&1; then
    echo "Not found package nftables, install nftables"
    apk add --no-cache nftables >/dev/null 2>&1
  fi
  if apk info -e iptables iptables-legacy >/dev/null 2>&1; then
    echo "Delete package iptables"
    apk del iptables iptables-legacy >/dev/null 2>&1
  fi
fi
