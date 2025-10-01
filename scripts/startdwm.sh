#!/bin/bash

# Setup monitors
xrandr --output LVDS-1 --mode 1366x768 --primary \
       --output VGA-1 --mode 1440x900 --left-of LVDS-1

# Pick wallpaper
WALLPAPER="$HOME/dotfiles/wallpapers/bloodrock-steppes.png"

# Run pywal to generate colors from wallpaper
wal -i "$WALLPAPER" -n   # -n prevents pywal from reloading terminals

# Merge wal colors into Xresources (with your dwm extras)
ln -sf ~/.cache/wal/colors.Xresources ~/.Xresources
if [ -f ~/.config/wal/templates/xrdb_extra ]; then
    cat ~/.Xresources ~/.cache/wal/xrdb_extra | xrdb -merge
else
    xrdb -merge ~/.Xresources
fi

# Set wallpaper (feh just paints it, pywal already knows it)
feh --bg-fill "$WALLPAPER" &

# Start status bar
dwmblocks &

# Launch dwm (patched with xrdb support)
exec dwm

