#!/usr/bin/env bash
# Cache the Arch Linux news feed for the waybar updates tooltip, and notify on
# items published since the last run. Driven by arch-news.timer (every 6h).
#
# Renders the Pango block at fetch time so waybar-updates-news.sh stays trivial.
#
# Usage:  ~/.config/scripts/arch-news-fetch.sh

set -euo pipefail

FEED="https://archlinux.org/feeds/news/"
KEEP=5
RECENT_DAYS=7

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/arch-news"
TOOLTIP="$CACHE_DIR/tooltip.pango"
WATERMARK="$CACHE_DIR/notified"

mkdir -p "$CACHE_DIR"

feed=$(mktemp)
trap 'rm -f "$feed"' EXIT
curl -sfL --max-time 20 "$FEED" -o "$feed"

# Ampersand first, or it double-escapes the entities the other rules produce.
pango_escape() { sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'; }

item() { xmllint --xpath "string(/rss/channel/item[$1]/$2)" "$feed" 2>/dev/null || true; }

seen=$(cat "$WATERMARK" 2>/dev/null || echo 0)
newest=$seen
cutoff=$(($(date +%s) - RECENT_DAYS * 86400))

block="<b>Arch News</b>"
fresh=()

for i in $(seq 1 "$KEEP"); do
  title=$(item "$i" title)
  if [[ -z $title ]]; then
    break
  fi
  published=$(date -d "$(item "$i" pubDate)" +%s)

  entry=$(printf '%s' "$title" | pango_escape)
  if ((published > cutoff)); then
    entry="<b>$entry</b>"
  fi
  block+=$'\n'"<span alpha='60%'>$(date -d "@$published" +'%b %d')</span>  $entry"

  if ((published > seen)); then
    fresh+=("$title")
  fi
  if ((published > newest)); then
    newest=$published
  fi
done

# Replace atomically -- waybar-updates-news.sh re-reads this on every tooltip.
printf '%s\n' "$block" >"$TOOLTIP.new"
mv "$TOOLTIP.new" "$TOOLTIP"

# A missing watermark means first run: adopt the feed silently instead of
# firing a notification for every item already in it.
if [[ -f $WATERMARK ]]; then
  for ((i = ${#fresh[@]} - 1; i >= 0; i--)); do
    notify-send -a "Arch News" "Arch Linux news" "${fresh[i]}"
  done
fi
printf '%s\n' "$newest" >"$WATERMARK"
