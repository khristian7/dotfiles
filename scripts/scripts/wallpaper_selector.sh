#!/bin/bash
#  ██╗    ██╗ █████╗ ██╗     ██╗     ██████╗  █████╗ ██████╗ ███████╗██████╗
#  ██║    ██║██╔══██╗██║     ██║     ██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
#  ██║ █╗ ██║███████║██║     ██║     ██████╔╝███████║██████╔╝█████╗  ██████╔╝
#  ██║███╗██║██╔══██║██║     ██║     ██╔═══╝ ██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗
#  ╚███╔███╔╝██║  ██║███████╗███████╗██║     ██║  ██║██║     ███████╗██║  ██║
#   ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝
#
#  ██╗      █████╗ ██╗   ██╗███╗   ██╗ ██████╗██╗  ██╗███████╗██████╗
#  ██║     ██╔══██╗██║   ██║████╗  ██║██╔════╝██║  ██║██╔════╝██╔══██╗
#  ██║     ███████║██║   ██║██╔██╗ ██║██║     ███████║█████╗  ██████╔╝
#  ██║     ██╔══██║██║   ██║██║╚██╗██║██║     ██╔══██║██╔══╝  ██╔══██╗
#  ███████╗██║  ██║╚██████╔╝██║ ╚████║╚██████╗██║  ██║███████╗██║  ██║
#  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
#
#	Heavily inspired by:  develcooking - https://github.com/develcooking/hyprland-dotfiles
# Info    - This script runs the rofi launcher, to select
#             the wallpapers included in the theme you are in.

# --- Configuration ----------------------------------------------------------
wall_dir="${HOME}/.config/wallpapers"
cache_dir="${HOME}/.cache/thumbnails/wal_selector"
rofi_config="${HOME}/.config/rofi/wallpaper-sel-config.rasi"
rofi_cmd=(rofi -dmenu -config "$rofi_config")

# Accepted extensions (lowercase, no dots)
exts=(jpg jpeg png webp)

# Thumbnail geometry
thumb_w=500
thumb_h=500

# --- Helper functions -------------------------------------------------------
die() {
  printf '%s\n' "$*" >&2
  exit 1
}

log() { printf '[%(%F %T)T] %s\n' -1 "$*"; }

# Make sure the cache dir exists
mkdir -p "$cache_dir" || die "Cannot create cache dir $cache_dir"

# ---------------------------------------------------------------------------
# Build an associative array of "real-path → basename" for all wallpapers.
# We lowercase the extension so *.JPG also matches.
declare -A wallpapers
for ext in "${exts[@]}"; do
  for f in "$wall_dir"/*."$ext" "$wall_dir"/*."${ext^^}"; do
    [[ -f $f ]] || continue
    wallpapers[$f]=$(basename "$f")
  done
done

((${#wallpapers[@]})) || die "No wallpapers found in $wall_dir"

# ---------------------------------------------------------------------------
# Generate missing thumbnails in parallel.
log "Generating thumbnails…"
jobs=()
for wp in "${!wallpapers[@]}"; do
  thumb="$cache_dir/${wallpapers[$wp]}"
  [[ -s $thumb ]] && continue
  magick "$wp" \
    -strip -thumbnail "${thumb_w}x${thumb_h}^" \
    -gravity center -extent "${thumb_w}x${thumb_h}" \
    "$thumb" &
  jobs+=($!)
done
[[ ${#jobs[@]} -gt 0 ]] && wait "${jobs[@]}"

# ---------------------------------------------------------------------------
# Build Rofi list *once* in an array so we can recover the full path later.
declare -a rofi_lines
declare -A name_to_path

for wp in "${!wallpapers[@]}"; do
  name=${wallpapers[$wp]}
  name_to_path[$name]=$wp
  rofi_lines+=("$name")
done

# Sort alphabetically for deterministic order.
IFS=$'\n' sorted_names=($(sort <<<"${rofi_lines[*]}"))
unset IFS

# ---------------------------------------------------------------------------
# Launch Rofi
choice=$(
  printf '%s\n' "${sorted_names[@]}" |
    "${rofi_cmd[@]}" -format 'i s' -selected-row 0
) || exit 0 # user aborted

# Rofi returns "index name"; we only need the name.
wall_name=${choice#* }

# ---------------------------------------------------------------------------
# Set wallpaper
wall_path=${name_to_path[$wall_name]}
[[ -n $wall_path ]] || die "Internal error: unknown wallpaper $wall_name"

log "Setting wallpaper to $wall_name"
waypaper --wallpaper "$wall_path"
