# Proxmox Backup Server

[![Container Release (Proxmox Backup Server)](https://github.com/leberkaslabs/docker-image-proxmox-backup-server/actions/workflows/build.yml/badge.svg)](https://github.com/leberkaslabs/docker-image-proxmox-backup-server/actions/workflows/build.yml)

This repository provides a Docker image for [Proxmox Backup Server](https://www.proxmox.com/en/products/proxmox-backup-server/overview).

```bash
docker pull dudecalledbro/proxmox-backup-server:latest
```

## Build

This image build is scheduled with GitHub Actions and will be pushed to DockerHub. The image will also be rebuilt, if the `main` branch is updated. If you need to build the image locally, ensure [Docker](https://docs.docker.com/engine/installation/) is installed and execute the following:

```bash
docker build -t proxmox-backup-server:latest .
```

## License

Copyright (c) 2026 Niclas Spreng
