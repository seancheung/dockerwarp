#!/bin/bash

set -ex

mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun

mkdir -p /run/dbus
if [ -f /run/dbus/pid ]; then
  rm /run/dbus/pid
fi
dbus-daemon --config-file=/usr/share/dbus-1/system.conf

warp-svc --accept-tos &

sleep "$WARP_SLEEP"

if [ ! -f /var/lib/cloudflare-warp/reg.json ] && [ ! -f /var/lib/cloudflare-warp/mdm.xml ]; then
    warp-cli registration new && echo "Warp client registered!"
    if [ -n "$WARP_LICENSE_KEY" ]; then
        echo "License key found, registering license..."
        warp-cli registration license "$WARP_LICENSE_KEY" && echo "Warp license registered!"
    fi
    warp-cli mode proxy
    warp-cli proxy port ${WARP_PROXY_PORT:-40000}
    warp-cli connect
else
    echo "Warp client already registered, skip registration"
fi

gost -L=:1080 -F=127.0.0.1:${WARP_PROXY_PORT:-40000} "$@"