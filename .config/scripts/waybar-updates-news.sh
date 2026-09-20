#!/usr/bin/env bash
# Wrap waybar-updates, appending cached Arch news to each tooltip it emits, and
# keep that cache fresh. Set as the `exec` for the waybar custom/updates module.
#
# waybar-updates only writes output when the package checksum changes, so a
# plain filter would leave the news half of the tooltip frozen for as long as
# the package set is stable. Instead of blocking forever on read, time out every
# TICK_SECONDS: refresh the cache when stale, then re-emit the last payload so
# waybar picks up the new text. That also means no systemd timer is needed --
# the news is only worth fetching while the bar that displays it is running.
#
# No `-e`: a transient jq or fetch failure should degrade to the plain
# waybar-updates output, not kill the module for the rest of the session.
#
# Usage:  ~/.config/scripts/waybar-updates-news.sh

set -uo pipefail

FETCH="$HOME/.config/scripts/arch-news-fetch.sh"
REBOOT="$HOME/.config/scripts/waybar-reboot-required.sh"
TOOLTIP="${XDG_CACHE_HOME:-$HOME/.cache}/arch-news/tooltip.pango"
TICK_SECONDS=600
STALE_SECONDS=21600 # 6h

refresh_if_stale() {
  if [[ -f $TOOLTIP ]]; then
    local age=$(($(date +%s) - $(stat -c %Y "$TOOLTIP")))
    if ((age < STALE_SECONDS)); then
      return
    fi
  fi
  "$FETCH" >/dev/null 2>&1 || true
}

# A fully-updated system that has not rebooted is not running what is on disk,
# so the green check is a lie until the reboot happens. Fold that state in here
# rather than adding a second module: pending updates and a pending reboot are
# the same "your system is out of sync" story, one step apart.
reboot_overlay() { # payload -> payload
  local reboot state tip
  reboot=$("$REBOOT" --status 2>/dev/null) || { printf '%s\n' "$1"; return; }
  state=$(jq -r '.state' <<<"$reboot" 2>/dev/null) || { printf '%s\n' "$1"; return; }
  tip=$(jq -r '.tooltip' <<<"$reboot" 2>/dev/null)

  case $state in
    # Something is already broken (orphaned modules, nvidia mismatch). This
    # outranks pending updates -- you cannot fix it by updating harder.
    critical)
      jq -c --arg tip "$tip" \
        '.alt = "reboot-critical" | .class = "reboot-critical"
         | .tooltip = ($tip + "\n\n" + .tooltip)' <<<"$1" ||
        printf '%s\n' "$1"
      ;;
    # Nothing broken yet, just stale. Only displaces "updated" -- if real
    # updates are pending, that icon is the more useful thing to show.
    pending)
      jq -c --arg tip "$tip" \
        'if .alt == "updated" then .alt = "reboot-required" | .class = "reboot-required" else . end
         | .tooltip = ($tip + "\n\n" + .tooltip)' <<<"$1" ||
        printf '%s\n' "$1"
      ;;
    *) printf '%s\n' "$1" ;;
  esac
}

emit() { # payload
  local news payload
  payload=$(reboot_overlay "$1")
  news=$(cat "$TOOLTIP" 2>/dev/null || true)
  if [[ -n $news ]]; then
    jq -c --arg news "$news" '.tooltip += "\n\n" + $news' <<<"$payload" ||
      printf '%s\n' "$payload"
  else
    printf '%s\n' "$payload"
  fi
}

refresh_if_stale

last=""
while :; do
  IFS= read -r -t "$TICK_SECONDS" line
  status=$?

  if ((status == 0)); then
    last=$line
  elif ((status > 128)); then
    # read(1) returns >128 only on timeout; anything else here is EOF.
    refresh_if_stale
  else
    break
  fi

  if [[ -n $last ]]; then
    emit "$last"
  fi
done < <(waybar-updates "$@")
