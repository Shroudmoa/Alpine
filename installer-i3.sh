#!/bin/sh

# ==========================================

# Alpine + i3 Setup Script (VM-friendly)

# ==========================================

echo "== Updating repositories =="

doas sh -c 'cat > /etc/apk/repositories <<EOF
http://dl-cdn.alpinelinux.org/alpine/edge/main
http://dl-cdn.alpinelinux.org/alpine/edge/community
http://dl-cdn.alpinelinux.org/alpine/edge/testing
EOF'

doas apk update
doas apk upgrade

echo "== Installing base system (Xorg + i3) =="

doas setup-xorg-base

doas apk add 
i3wm i3status dmenu 
xterm 
sakura 
xrandr 
setxkbmap 
feh 
dbus 
font-dejavu 
adwaita-icon-theme 
chromium 
thunar 
flameshot 
xf86-input-libinput

echo "== Installing VM + graphics support =="

doas apk add 
virtualbox-guest-additions 
virtualbox-guest-modules-virt

doas rc-update add virtualbox-guest-additions

echo "== Installing compositor (picom) =="

doas apk add picom

mkdir -p ~/.config/picom

cp /etc/xdg/picom.conf.example ~/.config/picom/picom.conf

echo "== Fixing picom for VM (IMPORTANT) =="

# Force safe backend (prevents black windows & glitches)

sed -i 's/backend = "glx"/backend = "xrender"/g' ~/.config/picom/picom.conf

echo "== Installing dev tools =="

doas apk add 
git make 
libx11-dev libxinerama-dev libxft-dev 
g++ fontconfig-dev ncurses 
curl

echo "== Enabling services =="

doas rc-update add dbus
doas rc-service dbus start

echo "== Setting up i3 config =="

mkdir -p ~/.config/i3

cat > ~/.config/i3/config <<'EOF'
set $mod Mod4

font pango:monospace 10

set $term xterm
set $menu dmenu_run

# movement

bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

# move windows

bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

# basic

bindsym $mod+Return exec $term
bindsym $mod+d exec $menu
bindsym $mod+Shift+q kill
bindsym $mod+Shift+r restart
bindsym $mod+Shift+c reload

# layout

bindsym $mod+v split v
bindsym $mod+b split h
bindsym $mod+f fullscreen toggle

# resize mode

mode "resize" {
bindsym h resize shrink width 10 px
bindsym j resize grow height 10 px
bindsym k resize shrink height 10 px
bindsym l resize grow width 10 px

```
bindsym Return mode "default"
bindsym Escape mode "default"
```

}
bindsym $mod+r mode "resize"

# bar

bar {
status_command i3status
}

# ===== AUTOSTART (CLEAN + FIXED) =====

# IMPORTANT: only ONE picom instance!

exec --no-startup-id picom --config ~/.config/picom/picom.conf

# wallpaper (change path!)

exec --no-startup-id feh --bg-fill ~/wallpaper.jpg

exec --no-startup-id flameshot

# optional

# exec --no-startup-id nm-applet

EOF

echo "== Setting up .xinitrc =="

echo "exec i3" > ~/.xinitrc

echo "== Fixing input (scroll issues) =="

doas mkdir -p /etc/X11/xorg.conf.d

doas sh -c 'cat > /etc/X11/xorg.conf.d/30-touchpad.conf <<EOF
Section "InputClass"
Identifier "touchpad"
MatchIsTouchpad "on"
Driver "libinput"

```
Option "NaturalScrolling" "true"
Option "Tapping" "on"
```

EndSection
EOF'

echo "== DONE =="

echo "Next steps:"
echo "1. reboot"
echo "2. run: startx"
echo ""
echo "If resolution is wrong:"
echo "  xrandr --output Virtual1 --mode 1920x1080"
echo ""
echo "If you get black windows:"
echo "  disable picom or keep xrender backend"
