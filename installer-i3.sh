#!/bin/sh

# ==== AUTO-DETECT USER ====
USER_NAME="${SUDO_USER:-$(whoami)}"
HOME_DIR=$(eval echo "~$USER_NAME")
MIRROR="http://dl-cdn.alpinelinux.org/alpine"

echo "[+] Using user: $USER_NAME"

# ==== REPOSITORIES ====
echo "[+] Setting repositories to edge..."
doas sh -c "cat > /etc/apk/repositories <<EOF
$MIRROR/edge/main
$MIRROR/edge/community
$MIRROR/edge/testing
EOF"

# ==== DOAS CONFIG ====
echo "[+] Configuring doas (nopass)..."
doas mkdir -p /etc/doas.d
echo "permit nopass $USER_NAME as root" | doas tee /etc/doas.d/doas.conf

# ==== SYSTEM UPDATE ====
echo "[+] Updating system..."
doas apk update
doas apk upgrade

# ==== XORG + I3 ====
echo "[+] Installing Xorg..."
doas setup-xorg-base

echo "[+] Installing i3 and essentials..."
doas apk add \
    i3wm i3status dmenu sakura \
    xrandr setxkbmap feh dbus \
    font-dejavu adwaita-icon-theme \
    chromium thunar flameshot

# ==== GROUPS ====
echo "[+] Adding user to input group..."
doas adduser $USER_NAME input

# ==== LIGHTDM ====
echo "[+] Installing LightDM..."
doas apk add lightdm lightdm-gtk-greeter
doas rc-update add lightdm

# ==== PICOM ====
echo "[+] Installing Picom..."
doas apk add picom
mkdir -p "$HOME_DIR/.config/picom"
doas cp /etc/xdg/picom.conf.example "$HOME_DIR/.config/picom/picom.conf"
doas chown -R "$USER_NAME:$USER_NAME" "$HOME_DIR/.config"

# ==== DEV TOOLS ====
echo "[+] Installing developer tools..."
doas apk add \
    git make libx11-dev libxinerama-dev \
    libxft-dev g++ fontconfig-dev \
    ncurses curl

# ==== SERVICES ====
echo "[+] Enabling dbus..."
doas rc-update add dbus
doas rc-service dbus start

# ==== THEMES ====
echo "[+] Installing GTK tools and themes..."
doas apk add lxappearance mate-themes papirus-icon-theme capitaine-cursors

# ==== AUDIO ====
echo "[+] Installing ALSA..."
doas apk add alsa-utils

# ==== XINIT ====
echo "[+] Creating .xinitrc..."
echo "exec i3" > "$HOME_DIR/.xinitrc"
doas chown "$USER_NAME:$USER_NAME" "$HOME_DIR/.xinitrc"

echo "[+] Done!"
echo "Reboot or run 'startx' to launch i3."
