#!/bin/bash
set -e

# Ensure base directories exist
mkdir -p /octoprint/octoprint /octoprint/plugins

# Remove legacy octoprint binary left over in persistent volume from older Python containers
if [ -f "/octoprint/plugins/bin/octoprint" ]; then
    rm -f /octoprint/plugins/bin/octoprint
fi

# Adjust volume ownership for octoprint user
chown -R octoprint:octoprint /octoprint

# Dynamically adjust group permissions if serial device exists (/dev/ttyUSB0)
if [ -e "/dev/ttyUSB0" ]; then
    USB_GID=$(stat -c '%g' /dev/ttyUSB0 2>/dev/null || true)
    if [ -n "$USB_GID" ] && [ "$USB_GID" != "0" ]; then
        if ! id -G octoprint | grep -qw "$USB_GID"; then
            groupadd -g "$USB_GID" -f hostdialout 2>/dev/null || true
            usermod -aG "$USB_GID" octoprint 2>/dev/null || true
        fi
    fi
fi

# Verify/update config.yaml so restart command points to restart-octoprint
python3 /usr/local/bin/setup-config.py || true

# Execute OctoPrint supervisor loop as unprivileged 'octoprint' user
exec gosu octoprint /usr/local/bin/octoprint-loop.sh
