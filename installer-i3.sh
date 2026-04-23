#!/bin/sh

set -e

echo "==> Updating system..."
sudo apk update
sudo apk upgrade

echo "==> Installing base Xorg + i3..."
sudo apk add \
    xorg-server \
    i3wm \
    i3status \
    dmenu

echo "==> Installing essentials..."
sudo apk add \
    alacritty \
    xterm \
    dbus \
    xf86-input-libinput \
    mesa-dri-gallium \
    font-dejavu

echo "==> Installing optional tools..."
sudo apk add \
    rofi \
    feh \
    picom || true

echo "==> Enabling dbus..."
sudo rc-update add dbus
sudo rc-service dbus start

echo "==> Creating .xinitrc..."
cat <<EOF > "$HOME/.xinitrc"
exec i3
EOF

echo "==> Installation complete!"
echo ""
echo "Run: startx"
echo "Then press: Mod+Enter to open terminal"
