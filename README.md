# Valkey Debian Packages

This repository contains the packaging configuration for automatically building Debian packages of [Valkey](https://github.com/valkey-io/valkey). Valkey is a flexible distributed key-value database that is optimized for caching and other realtime workloads.

## Repository Information

Pre-built packages are available at: [https://greensec.github.io/valkey-debian/](https://greensec.github.io/valkey-debian/)

## Supported Debian/Ubuntu Versions

### Debian
- buster (10)
- bullseye (11)
- bookworm (12)

### Ubuntu
- jammy (22.04 LTS)
- noble (24.04 LTS)

### Automated Builds

This repository uses GitHub Actions to automatically build packages for all supported distributions.

### How to add this repository:

#### Automatically via script
```bash
wget -O- https://greensec.github.io/valkey-debian/add-repository.sh | bash
apt-get install valkey
```

#### Manually
```bash
apt-get install wget lsb-release ca-certificates
wget -O /usr/share/keyrings/greensec.github.io-valkey-debian.key https://greensec.github.io/valkey-debian/public.key
echo "deb [signed-by=/usr/share/keyrings/greensec.github.io-valkey-debian.key] https://greensec.github.io/valkey-debian/repo $(lsb_release -sc) main" > /etc/apt/sources.list.d/valkey-debian.list
apt-get update && apt-get install valkey
```

## Acknowledgements

This package is based on the work of the Valkey developers and the Debian Valkey team.

### Original Valkey Project
- [Valkey Official Website](https://valkey.io/)
- [GitHub Repository](https://github.com/valkey-io/valkey)
