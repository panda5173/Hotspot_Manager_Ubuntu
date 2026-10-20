#!/usr/bin/env bash
# Build hotspot-manager_<ver>_all.deb
set -euo pipefail
cd "$(dirname "$0")"
VER=1.3; P=build/hotspot-manager_${VER}_all
rm -rf build; mkdir -p "$P/DEBIAN"
install -Dm755 src/hsctl "$P/usr/lib/hotspot-manager/hsctl"
install -Dm755 src/hotspot-manager "$P/usr/bin/hotspot-manager"
install -Dm644 data/hotspot-manager.service "$P/lib/systemd/system/hotspot-manager.service"
install -Dm644 data/hotspot-manager.desktop "$P/usr/share/applications/hotspot-manager.desktop"
install -Dm440 data/hotspot-manager.sudoers "$P/etc/sudoers.d/hotspot-manager"
for i in hotspot-manager hotspot-manager-on hotspot-manager-off; do
  install -Dm644 "data/$i.svg" "$P/usr/share/icons/hicolor/scalable/apps/$i.svg"
done
cat > "$P/DEBIAN/control" <<CTL
Package: hotspot-manager
Version: $VER
Architecture: all
Maintainer: IT <it@localhost>
Depends: python3, python3-gi, gir1.2-gtk-3.0, gir1.2-ayatanaappindicator3-0.1, iw, iproute2, iptables, kmod, qrencode, sudo, hostapd, procps
Recommends: dnsmasq-base | dnsmasq, network-manager
Section: net
Priority: optional
Description: Wi-Fi hotspot manager (main Wi-Fi + hotspot) for create_ap
 Lightweight GTK app with tray icon, start at login, device controls,
 allow-list, QR code, notifications and usage history.
 Requires create_ap (linux-wifi-hotspot).
CTL
cat > "$P/DEBIAN/postinst" <<'PI'
#!/bin/sh
set -e
mkdir -p /etc/hotspot-manager /var/lib/hotspot-manager
chmod 440 /etc/sudoers.d/hotspot-manager
systemctl daemon-reload || true
gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
command -v create_ap >/dev/null || echo "WARNING: create_ap not found - install linux-wifi-hotspot."
PI
cat > "$P/DEBIAN/prerm" <<'PR'
#!/bin/sh
systemctl stop hotspot-manager.service 2>/dev/null || true
PR
cat > "$P/DEBIAN/postrm" <<'PO'
#!/bin/sh
[ "$1" = purge ] && rm -rf /etc/hotspot-manager /var/lib/hotspot-manager
systemctl daemon-reload 2>/dev/null || true
PO
chmod 755 "$P/DEBIAN/"{postinst,prerm,postrm}
dpkg-deb --root-owner-group --build "$P" >/dev/null
echo "Built: $P.deb"
