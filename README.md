# Hotspot Manager 1.3
Main Wi-Fi + hotspot on one adapter (create_ap), with tray, start at login, device controls and usage history.

Install:   ./install.sh          (or ./build-deb.sh, then sudo apt install ./build/hotspot-manager_1.3_all.deb)
Remove:    ./uninstall.sh [--purge]

CLI:  hotspot-manager --on | --off | --toggle | --restart [--no-wait]
      hotspot-manager --status [--json]      (exit code 0 = running/paused, 3 = off)
      hotspot-manager --qr                   (show QR window)

1.3: hotspot-only fallback, auto-recover (3 tries), fallback 2.4 GHz network, internet check,
     device nicknames, notifications, allow-list, QR code, upload limits, monthly usage,
     tray quick actions, command line.
1.2: pause/resume when main Wi-Fi drops; colourful theme.
1.1: max devices, MAC block, auto-off, website/IP blocking, download limits.

Files: config /etc/hotspot-manager/config.json (root, 0600) · usage /var/lib/hotspot-manager/usage.json
       nicknames + app prefs ~/.config/hotspot-manager/prefs.json · live status + log /run/hotspot-manager/
Debug: journalctl -u hotspot-manager -f   ·   cat /run/hotspot-manager/hotspot.log
<img width="775" height="738" alt="image" src="https://github.com/user-attachments/assets/0ec22bad-13ab-4a9f-a6e1-0731d33746c4" />
<img width="775" height="738" alt="image" src="https://github.com/user-attachments/assets/c14d85f8-968a-45e8-89d3-c46fbfa03827" />
<img width="771" height="646" alt="image" src="https://github.com/user-attachments/assets/61fae2b1-8f4f-41f0-9239-b631607a99a6" />

