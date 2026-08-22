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

emit() { # payload
  local news
  news=$(cat "$TOOLTIP" 2>/dev/null || true)
  if [[ -n $news ]]; then
    jq -c --arg news "$news" '.tooltip += "\n\n" + $news' <<<"$1" ||
      printf '%s\n' "$1"
  else
    printf '%s\n' "$1"
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
