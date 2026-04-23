#!/bin/sh

set -u  # error on undefined vars (but NOT exit on package fails)

FAILED_PKGS=""

install_pkg() {
    PKG="$1"
    echo "==> Installing $PKG..."

    if doas apk add "$PKG"; then
        echo "✔ $PKG installed"
    else
        echo "✖ $PKG FAILED"
        FAILED_PKGS="$FAILED_PKGS $PKG"
    fi
}

echo "==> Updating system..."
doas apk update && doas apk upgrade || echo "⚠ update/upgrade failed (continuing)"

echo "==> Installing base Xorg + i3..."
for pkg in \
    xorg-server \
    i3wm \
    i3status \
    dmenu
do
    install_pkg "$pkg"
done

echo "==> Installing essentials..."
for pkg in \
    alacritty \
    xterm \
    dbus \
    xf86-input-libinput \
    mesa-dri-gallium \
    font-dejavu
do
    install_pkg "$pkg"
done

echo "==> Installing optional tools..."
for pkg in \
    rofi \
    feh \
    picom
do
    install_pkg "$pkg"
done

echo "==> Enabling dbus..."
if doas rc-update add dbus && doas rc-service dbus start; then
    echo "✔ dbus enabled"
else
    echo "⚠ dbus setup failed"
fi

echo "==> Creating .xinitrc..."
cat <<EOF > "$HOME/.xinitrc"
exec i3
EOF

echo ""
echo "=============================="
echo " Installation finished"
echo "=============================="

if [ -n "$FAILED_PKGS" ]; then
    echo "⚠ These packages failed to install:"
    for pkg in $FAILED_PKGS; do
        echo " - $pkg"
    done
else
    echo "✔ All packages installed successfully"
fi

echo ""
echo "Run: startx"
echo "Then: Mod+Enter to open terminal"
