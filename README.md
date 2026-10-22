# Hotspot Manager 1.4
Main Wi-Fi + hotspot on one adapter (create_ap), with tray, start at login, device controls and usage history.

Install:   ./install.sh          (or ./build-deb.sh, then sudo apt install ./build/hotspot-manager_1.4_all.deb)
Remove:    ./uninstall.sh [--purge]

CLI:  hotspot-manager --on | --off | --toggle | --restart [--no-wait]
      hotspot-manager --status [--json]      (exit code 0 = running/paused, 3 = off)
      hotspot-manager --qr

1.4: boot fix - create_ap.service (from linux-wifi-hotspot) is stopped+masked so no hotspot starts at boot;
     new hotspot-manager-boot.service removes leftovers (ap0, /tmp/create_ap.*, firewall, NM unmanaged)
     and hands the Wi-Fi back to NetworkManager; login auto-on waits for main Wi-Fi; Usage tab no longer
     cut off on the right.
1.3: fallback, auto-recover, nicknames, notifications, allow-list, QR, upload limit, monthly usage, CLI.

Check after reboot:  systemctl is-enabled create_ap hotspot-manager hotspot-manager-boot
                     (expected: masked / disabled / enabled)
Debug: journalctl -b -u hotspot-manager-boot -u hotspot-manager · cat /run/hotspot-manager/hotspot.log
