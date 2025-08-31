# BorgBackup Server Docker

This repository provides a Docker image for running a BorgBackup server with SSH access. It is based on Alpine Linux and is designed for secure, containerized backup operations using Borg.

## Features
- BorgBackup installed in a chroot environment for enhanced security
- SSH server for secure remote access
- Customizable SSH authorized keys for user authentication
- Easy integration with Docker Compose

## Quick Start (Recommended)
Use the prebuilt image from GitHub Container Registry:

```yaml
services:
  borgbackup-server:
    image: ghcr.io/pm-dennis/borgbackup-server:latest
    environment:
      - SSH_AUTHORIZED_KEYS=ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... user@host
    ports:
      - "2222:22"
    volumes:
      - ./data:/chroot/home
```

- Replace the value of `SSH_AUTHORIZED_KEYS` with your public SSH key(s).
- Mount your backup data to `/chroot/home`.

## Advanced Setup (Custom Build)
If you need to customize the BorgBackup server (e.g., change the username), you can build the image yourself:

```sh
docker build -t borgbackup-server .
```

### Build Arguments
- `BORG_USER` (default: `borgbackup`): The username for the BorgBackup server. Set as a build argument.

Example:
```sh
docker build --build-arg BORG_USER=myuser -t borgbackup-server .
```

Then use your custom image in `docker-compose.yml`:
```yaml
services:
  borgbackup-server:
    image: borgbackup-server
    environment:
      - SSH_AUTHORIZED_KEYS=ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... user@host
    ports:
      - "2222:22"
    volumes:
      - ./data:/chroot/home
```
