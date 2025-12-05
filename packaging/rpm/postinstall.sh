#!/bin/bash
set -e

# Create facette user if missing
if ! id facette >/dev/null 2>&1; then
    useradd -r -s /usr/sbin/nologin -M facette
fi

# Ensure directories
mkdir -p /etc/facette
mkdir -p /var/log/facette
mkdir -p /var/lib/facette
mkdir -p /var/cache/facette

chown -R facette:facette /var/log/facette /var/lib/facette /var/cache/facette || true

# Install default config (backup existing)
TEMPLATE=/usr/share/facette/facette.yaml
CONFIG=/etc/facette/facette.yaml

if [ -f "$TEMPLATE" ]; then
    if [ -f "$CONFIG" ]; then
        cp "$CONFIG" "${CONFIG}.bak.$(date +%Y%m%d%H%M%S)"
    fi
    cp "$TEMPLATE" "$CONFIG"
fi

# Install logrotate
if [ -f /usr/share/facette/logrotate ]; then
    install -m 0644 /usr/share/facette/logrotate /etc/logrotate.d/facette
fi

# Install systemd override template if not present
mkdir -p /etc/systemd/system/facette.service.d
if [ -f /usr/share/facette/override.conf ] && [ ! -f /etc/systemd/system/facette.service.d/override.conf ]; then
    cp /usr/share/facette/override.conf /etc/systemd/system/facette.service.d/override.conf
fi

systemctl daemon-reload || true
systemctl enable facette.service || true
systemctl restart facette.service || true

exit 0
