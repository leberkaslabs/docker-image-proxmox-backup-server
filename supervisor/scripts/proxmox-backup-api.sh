#!/bin/bash

# /etc, /var/lib, /var/log are volumes and /run is tmpfs - all of them need
# to exist with the right ownership before proxmox-backup-api can start
install -d -o backup -g backup -m 0700 /etc/proxmox-backup
install -d -o backup -g backup -m 0700 /run/proxmox-backup
install -d -o backup -g backup -m 0700 /var/lib/proxmox-backup
install -d -o backup -g backup -m 0700 /var/log/proxmox-backup

# recycle lock files left behind by an unclean shutdown
rm -f /etc/proxmox-backup/.*.lck /etc/proxmox-backup/*.lock

if [[ ! -e /etc/proxmox-backup/csrf.key ]] && [[ ! -e /etc/proxmox-backup/.initialized ]]; then
  echo "[API] seeding /etc/proxmox-backup with default configuration"
  cp -a /etc/proxmox-backup-default/. /etc/proxmox-backup/
  touch /etc/proxmox-backup/.initialized
fi

for mp in /etc/proxmox-backup /var/lib/proxmox-backup /var/log/proxmox-backup; do
  if ! mountpoint -q "$mp"; then
    echo "[API] warning: '$mp' is not a volume, data will be lost when the container is recreated"
  fi
done

if ! mountpoint -q /run; then
  echo "[API] warning: '/run' is not a tmpfs mount, proxmox-backup-api might not work correctly"
fi

# root@pam authenticates via PAM against the container's root user, so the
# PBS admin password is set via the OS - and /etc/shadow isn't persisted
# across container recreation, so this needs to run on every start.
if [[ -n "$PBS_ROOT_PASSWORD" ]] && [[ -n "$PBS_ROOT_PASSWORD_FILE" ]]; then
  echo "[API] error: PBS_ROOT_PASSWORD and PBS_ROOT_PASSWORD_FILE are mutually exclusive" >&2
  exit 1
elif [[ -n "$PBS_ROOT_PASSWORD_FILE" ]]; then
  echo "[API] setting root password from PBS_ROOT_PASSWORD_FILE"
  echo "root:$(< "$PBS_ROOT_PASSWORD_FILE")" | chpasswd
elif [[ -n "$PBS_ROOT_PASSWORD" ]]; then
  echo "[API] setting root password from PBS_ROOT_PASSWORD"
  echo "root:${PBS_ROOT_PASSWORD}" | chpasswd
fi

echo "[API] starting proxmox-backup-api"
exec /usr/lib/*/proxmox-backup/proxmox-backup-api
