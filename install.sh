#!/usr/bin/env bash
# Hotspot Manager installer (Ubuntu / Debian)
set -euo pipefail
cd "$(dirname "$0")"
[[ $EUID -eq 0 ]] || exec sudo bash "$0" "$@"

echo "==> Installing dependencies"
apt-get install -y python3 python3-gi gir1.2-gtk-3.0 gir1.2-ayatanaappindicator3-0.1 \
    iw iproute2 iptables kmod qrencode >/dev/null
command -v create_ap >/dev/null || echo "WARNING: create_ap not found - install linux-wifi-hotspot first."

echo "==> Stopping running hotspot"
systemctl stop hotspot-manager.service 2>/dev/null || true
pkill -f 'wihotspot' 2>/dev/null || true

echo "==> Disabling conflicting boot-time hotspot services"
for u in create_ap.service wihotspot.service; do
  if systemctl list-unit-files "$u" --no-legend 2>/dev/null | grep -q .; then
    systemctl stop "$u" 2>/dev/null || true
    systemctl disable "$u" 2>/dev/null || true
    systemctl mask "$u" 2>/dev/null || true
    echo "    masked $u"
  fi
done
systemctl list-units --all --plain --no-legend 'create_ap@*' 2>/dev/null | awk '{print $1}' | \
  xargs -r -I{} sh -c 'systemctl stop {}; systemctl disable {}' 2>/dev/null || true

echo "==> Installing files"
install -Dm755 src/hsctl                 /usr/lib/hotspot-manager/hsctl
install -Dm755 src/hotspot-manager       /usr/bin/hotspot-manager
install -Dm644 data/hotspot-manager.service      /etc/systemd/system/hotspot-manager.service
install -Dm644 data/hotspot-manager-boot.service /etc/systemd/system/hotspot-manager-boot.service
install -Dm644 data/hotspot-manager.desktop /usr/share/applications/hotspot-manager.desktop
for i in hotspot-manager hotspot-manager-on hotspot-manager-off; do
  install -Dm644 "data/$i.svg" "/usr/share/icons/hicolor/scalable/apps/$i.svg"
done
install -dm755 /etc/hotspot-manager /var/lib/hotspot-manager

tmp=$(mktemp); cp data/hotspot-manager.sudoers "$tmp"
if visudo -cf "$tmp" >/dev/null; then install -m440 "$tmp" /etc/sudoers.d/hotspot-manager
else echo "ERROR: sudoers rule failed validation"; rm -f "$tmp"; exit 1; fi
rm -f "$tmp"

systemctl daemon-reload
systemctl disable hotspot-manager.service 2>/dev/null || true     # on-demand only, never at boot
systemctl enable hotspot-manager-boot.service >/dev/null 2>&1
/usr/bin/python3 /usr/lib/hotspot-manager/hsctl boot || true      # clean up right now as well
gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
update-desktop-database -q 2>/dev/null || true
pkill -f '/usr/bin/hotspot-manager' 2>/dev/null || true

u="${SUDO_USER:-}"
if [[ -n "$u" ]] && ! id -nG "$u" | grep -qw sudo; then
  echo "NOTE: $u is not in the 'sudo' group; you will be asked for a password on start/stop."
fi
echo "==> Done. Launch 'Hotspot Manager' from the app menu."
