#!/bin/sh
# To add this repository please do:

if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

${SUDO} apt-get update
${SUDO} apt-get -y install lsb-release ca-certificates wget
${SUDO} wget -O /usr/share/keyrings/greensec.github.io-valkey-debian.key https://greensec.github.io/valkey-debian/public.key
echo "deb [signed-by=/usr/share/keyrings/greensec.github.io-valkey-debian.key] https://greensec.github.io/valkey-debian/repo $(lsb_release -sc) main" | ${SUDO} tee /etc/apt/sources.list.d/valkey-debian.list
${SUDO} apt-get update
