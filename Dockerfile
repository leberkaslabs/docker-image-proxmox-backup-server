FROM docker.io/library/debian:13.6-slim

LABEL org.opencontainers.image.source="https://github.com/leberkaslabs/docker-image-proxmox-backup-server"

# Setup Proxmox Backup Server Repository
ADD --chmod=0644 \
    https://enterprise.proxmox.com/debian/proxmox-release-trixie.gpg \
    /usr/share/keyrings/proxmox-archive-keyring.gpg

COPY <<EOT /etc/apt/sources.list.d/proxmox.sources
Types: deb
URIs: http://download.proxmox.com/debian/pbs
Suites: trixie
Components: pbs-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOT

# Install packages
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin
RUN apt-get -qy update \
    && apt-get install -qy --no-install-recommends \
        curl \
        proxmox-archive-keyring \
        proxmox-backup-server \
        supervisor \
        tzdata \
    && rm -rf /etc/apt/sources.list.d/pbs-enterprise.sources \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man

# Configure supervisor
COPY supervisor /etc/supervisor
RUN chmod +x /etc/supervisor/scripts/*.sh

VOLUME /etc/proxmox-backup
VOLUME /var/log/proxmox-backup
VOLUME /var/lib/proxmox-backup

EXPOSE 8007

CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
HEALTHCHECK --interval=15s --timeout=10s --retries=3 --start-period=30s \
    CMD curl -kf https://localhost:8007/ || exit 1
