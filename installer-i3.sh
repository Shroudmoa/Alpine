#!/bin/sh

USER_NAME="${SUDO_USER:-$(whoami)}"
HOME_DIR=$(eval echo "~$USER_NAME")
DOTDIR="$HOME_DIR/Alpine"

if [ ! -d "$DOTDIR" ]; then
    exit 1
fi

doas sh -c "cat > /etc/apk/repositories <<EOF
http://dl-cdn.alpinelinux.org/alpine/edge/main
http://dl-cdn.alpinelinux.org/alpine/edge/community
http://dl-cdn.alpinelinux.org/alpine/edge/testing
EOF"

doas mkdir -p /etc/doas.d
echo "permit nopass $USER_NAME as root" | doas tee /etc/doas.d/doas.conf

doas apk update
doas apk upgrade

doas setup-xorg-base

doas apk add i3wm i3status dmenu xrandr setxkbmap feh dbus thunar flameshot font-dejavu adwaita-icon-theme alacritty sakura links w3m git curl make ncurses g++ fontconfig-dev libx11-dev libxinerama-dev libxft-dev

doas apk add librewolf 2>/dev/null

doas rc-update add dbus
doas rc-service dbus start

doas adduser $USER_NAME input

mkdir -p "$HOME_DIR/.config"

ln -sf "$DOTDIR/i3" "$HOME_DIR/.config/i3"
ln -sf "$DOTDIR/picom/picom.conf" "$HOME_DIR/.config/picom.conf"
ln -sf "$DOTDIR/sakura" "$HOME_DIR/.config/sakura"

echo "exec i3" > "$HOME_DIR/.xinitrc"
doas chown $USER_NAME:$USER_NAME "$HOME_DIR/.xinitrc"
