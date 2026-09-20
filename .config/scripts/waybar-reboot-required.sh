#!/usr/bin/env bash
# Reboot-required reporting for the waybar custom/updates module.
# Arch drops the running kernel's module tree on upgrade and DKMS only builds
# against the new one, so a -Syu can leave the live system unable to load any
# module at all. The NVIDIA case is worse: userspace jumps to the new version
# while the old nvidia.ko stays resident, and every *new* process silently
# loses Vulkan while the running desktop keeps working. Nothing surfaces this
# until something fails in a way that looks unrelated.
#
#   (no args)   emit waybar JSON for a standalone module
#   --status    emit {state, tooltip} for custom/updates to fold in
#   --details   readable report, then offer to reboot
#
# Usage:  ~/.config/scripts/waybar-reboot-required.sh [--status|--details]

set -uo pipefail

# Upgrading any of these after boot means the running system differs from disk.
WATCH=(linux linux-lts linux-zen systemd glibc nvidia-utils nvidia-open-dkms)

HEADER_CRITICAL="[Reboot required!]"
HEADER_PENDING="[Reboot pending]"

pango_escape() { sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'; }

# Epoch of the current boot, read from /proc so no date parsing is involved.
boot_epoch() {
  local up
  read -r up _ < /proc/uptime
  printf '%s' "$(( $(date +%s) - ${up%.*} ))"
}

nvidia_loaded_version() {
  grep -oE '[0-9]+\.[0-9]+\.[0-9]+' /proc/driver/nvidia/version 2>/dev/null | head -1
}

nvidia_installed_version() {
  pacman -Q nvidia-utils 2>/dev/null | awk '{print $2}' | cut -d- -f1
}

# CRITICAL: modprobe cannot work at all -- the running kernel's tree is gone.
kernel_orphaned() {
  [[ ! -d /usr/lib/modules/$(uname -r) ]]
}

# CRITICAL: loaded nvidia.ko disagrees with the installed userspace libraries.
# This is the one that breaks Vulkan/Wine while the desktop looks fine.
nvidia_mismatch() {
  local loaded installed
  [[ -r /proc/driver/nvidia/version ]] || return 1
  loaded=$(nvidia_loaded_version)
  installed=$(nvidia_installed_version)
  [[ -n $loaded && -n $installed && $loaded != $installed ]]
}

# PENDING: watched package installed after boot. Uses the pacman db entry's
# mtime rather than `pacman -Qi` Install Date, which is locale-formatted.
upgraded_since_boot() {
  local boot pkg dir
  boot=$(boot_epoch)
  for pkg in "${WATCH[@]}"; do
    # The [0-9] guard keeps `linux` from matching `linux-firmware`.
    dir=$(find /var/lib/pacman/local -maxdepth 1 -name "${pkg}-[0-9]*" -print -quit 2>/dev/null)
    [[ -n $dir ]] || continue
    if (( $(stat -c %Y "$dir" 2>/dev/null || echo 0) > boot )); then
      printf '%s\n' "$pkg"
    fi
  done
}

# Populates `critical` (one sentence each) and `stale` (bare package names).
collect() {
  local pkg
  critical=() stale=()

  if kernel_orphaned; then
    critical+=("kernel $(uname -r) has no module tree — modprobe is broken")
  fi
  if nvidia_mismatch; then
    critical+=("nvidia $(nvidia_loaded_version) loaded vs $(nvidia_installed_version) installed — Vulkan is broken")
  fi
  while read -r pkg; do
    [[ -n $pkg ]] && stale+=("$pkg")
  done < <(upgraded_since_boot)
}

# Header first so the state is readable at a glance; detail below it. The
# stale packages collapse onto one dimmed line -- which ones they are matters
# far less than the fact that the running system is behind disk.
build_tooltip() { # uses `critical` and `stale` from collect()
  local line tooltip=""

  if (( ${#critical[@]} )); then
    tooltip+="<b>$(printf '%s' "$HEADER_CRITICAL" | pango_escape)</b>"$'\n\n'
  else
    tooltip+="<b>$(printf '%s' "$HEADER_PENDING" | pango_escape)</b>"$'\n\n'
  fi

  for line in "${critical[@]}"; do
    tooltip+="$(printf '%s' "$line" | pango_escape)"$'\n'
  done

  if (( ${#stale[@]} )); then
    tooltip+="<span alpha='60%'>upgraded since boot: "
    tooltip+="$(printf '%s' "${stale[*]}" | sed 's/ /, /g' | pango_escape)"
    tooltip+="</span>"$'\n'
  fi

  printf '%s' "${tooltip%$'\n'}"
}

state_of() { # uses `critical` and `stale`
  if (( ${#critical[@]} )); then
    printf 'critical'
  elif (( ${#stale[@]} )); then
    printf 'pending'
  else
    printf 'none'
  fi
}

emit_json() {
  local -a critical stale
  local count
  collect
  count=$(( ${#critical[@]} + ${#stale[@]} ))

  # Empty text collapses the module, matching custom/failed-units.
  if (( count == 0 )); then
    jq -nc '{text: "", tooltip: ""}'
    return
  fi

  jq -nc --arg text "$count" --arg tooltip "$(build_tooltip)" --arg class "$(state_of)" \
    '{text: $text, tooltip: ($tooltip + "\n\nClick for details"), class: $class}'
}

# Machine-readable state, so custom/updates can fold this in and the bar shows
# one indicator instead of two.
emit_status() {
  local -a critical stale
  local state
  collect
  state=$(state_of)

  if [[ $state == none ]]; then
    jq -nc '{state: "none", tooltip: ""}'
    return
  fi

  jq -nc --arg state "$state" --arg tooltip "$(build_tooltip)" \
    '{state: $state, tooltip: $tooltip}'
}

show_details() {
  local -a critical stale
  local line reply
  collect

  if (( ${#critical[@]} == 0 && ${#stale[@]} == 0 )); then
    printf 'No reboot required.\n'
    return
  fi

  if (( ${#critical[@]} )); then
    printf '\033[1;31m%s\033[0m\n\n' "$HEADER_CRITICAL"
  else
    printf '\033[1;33m%s\033[0m\n\n' "$HEADER_PENDING"
  fi

  for line in "${critical[@]}"; do
    printf '  \033[1;31m•\033[0m %s\n' "$line"
  done
  if (( ${#stale[@]} )); then
    printf '  \033[2mupgraded since boot: %s\033[0m\n' "$(printf '%s' "${stale[*]}" | sed 's/ /, /g')"
  fi
  printf '\n'

  printf 'Reboot now? [y/N] '
  read -r reply
  if [[ ${reply,,} == y ]]; then
    systemctl reboot
  fi
}

case ${1:-} in
  --details) show_details ;;
  --status) emit_status ;;
  *) emit_json ;;
esac
