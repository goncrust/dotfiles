#!/bin/sh
# Installs the monochrome Betterbird tray icons and the pacman hook that
# reapplies them after upgrades, and keeps the tray icon always visible.
# Run with sudo, then restart Betterbird.
set -e

user=${SUDO_USER:?run this with sudo}

cd "$(dirname "$(readlink -f "$0")")/.."

# Copy the hook reads from, so it doesn't depend on the dotfiles location
install -Dm644 -t /usr/local/share/betterbird-tray betterbird-tray/default.svg betterbird-tray/newmail.svg

install -Dm644 -t /etc/pacman.d/hooks pacman.d/hooks/betterbird-tray-icon.hook

# Replace the icons now instead of waiting for the next upgrade
install -m644 -t /opt/betterbird/chrome/icons/default betterbird-tray/default.svg betterbird-tray/newmail.svg

# Keep the tray icon visible while the window is open. Not exposed in Settings.
# F72D9E66FA3C07ED is the install ID for /opt/betterbird in installs.ini.
home=$(getent passwd "$user" | cut -d: -f6)
profile=$(sed -n '/^\[F72D9E66FA3C07ED\]/,/^$/s/^Default=//p' "$home/.thunderbird/installs.ini" 2>/dev/null || true)
if [ -z "$profile" ]; then
    echo "No Betterbird profile found: start Betterbird once, then rerun this." >&2
    exit 1
fi
pref='user_pref("mail.biff.show_tray_icon_always", true);'
userjs="$home/.thunderbird/$profile/user.js"
grep -qxF "$pref" "$userjs" 2>/dev/null ||
    sudo -u "$user" sh -c 'printf "%s\n" "$1" >> "$2"' sh "$pref" "$userjs"
