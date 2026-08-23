#!/bin/bash

# /run is tmpfs, so this needs to be recreated on every start
install -d -o backup -g backup -m 0700 /run/proxmox-backup

until [[ -e /etc/proxmox-backup/csrf.key ]]; do
  echo "[PROXY] waiting for proxmox-backup-api to finish initializing..."
  sleep 1
done

echo "[PROXY] starting proxmox-backup-proxy"
exec setpriv --reuid backup --regid backup --clear-groups \
    /usr/lib/*/proxmox-backup/proxmox-backup-proxy
