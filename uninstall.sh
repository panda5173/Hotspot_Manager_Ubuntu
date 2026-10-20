#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -eq 0 ]] || exec sudo bash "$0" "$@"
systemctl stop hotspot-manager.service 2>/dev/null || true
rm -f /usr/bin/hotspot-manager /etc/systemd/system/hotspot-manager.service \
      /usr/share/applications/hotspot-manager.desktop /etc/sudoers.d/hotspot-manager \
      /usr/share/icons/hicolor/scalable/apps/hotspot-manager{,-on,-off}.svg
rm -rf /usr/lib/hotspot-manager /run/hotspot-manager
systemctl daemon-reload
[[ "${1:-}" == "--purge" ]] && rm -rf /etc/hotspot-manager /var/lib/hotspot-manager
u="${SUDO_USER:-}"; [[ -n "$u" ]] && rm -f "$(getent passwd "$u" | cut -d: -f6)/.config/autostart/hotspot-manager.desktop"
echo "Removed. (Use --purge to also delete settings and usage history.)"
