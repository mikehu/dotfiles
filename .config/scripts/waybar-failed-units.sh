#!/usr/bin/env bash
# Failed systemd unit reporting for the waybar custom/failed-units module.
# The built-in systemd-failed-units module only renders a count with no
# tooltip, so a bare "1" gives you nothing to act on.
#
#   (no args)   emit waybar JSON: count as text, units + descriptions as tooltip
#   --details   readable report with recent journal lines, then offer to clear
#
# Usage:  ~/.config/scripts/waybar-failed-units.sh [--details]

set -uo pipefail

DESC_WIDTH=70
JOURNAL_LINES=15

# Ampersand first, or it double-escapes the entities the other rules produce.
pango_escape() { sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'; }

failed_units() {
  systemctl --failed --no-legend --plain 2>/dev/null | awk 'NF {print "system", $1}'
  systemctl --user --failed --no-legend --plain 2>/dev/null | awk 'NF {print "user", $1}'
}

describe() { # scope unit
  if [[ $1 == user ]]; then
    systemctl --user show -p Description --value "$2" 2>/dev/null
  else
    systemctl show -p Description --value "$2" 2>/dev/null
  fi
}

emit_json() {
  local scope unit desc count=0 tooltip=""

  while read -r scope unit; do
    if [[ -z $unit ]]; then
      continue
    fi
    count=$((count + 1))
    desc=$(describe "$scope" "$unit" | cut -c "1-$DESC_WIDTH" | pango_escape)
    tooltip+="<b>$(printf '%s' "$unit" | pango_escape)</b> <span alpha='60%'>($scope)</span>"$'\n'
    tooltip+="    $desc"$'\n'
  done < <(failed_units)

  # Empty text collapses the module, matching the built-in's hide-on-ok.
  if ((count == 0)); then
    jq -nc '{text: "", tooltip: ""}'
    return
  fi

  jq -nc --arg text "$count" --arg tooltip "${tooltip%$'\n'}" \
    '{text: $text, tooltip: ($tooltip + "\n\nClick for details"), class: "failed"}'
}

show_details() {
  local scope unit found=0 reply

  while read -r scope unit; do
    if [[ -z $unit ]]; then
      continue
    fi
    found=1
    printf '\033[1;31m%s\033[0m  (%s)\n' "$unit" "$scope"
    if [[ $scope == user ]]; then
      systemctl --user status "$unit" --no-pager -n "$JOURNAL_LINES" || true
    else
      systemctl status "$unit" --no-pager -n "$JOURNAL_LINES" || true
    fi
    printf '\n'
  done < <(failed_units)

  if ((found == 0)); then
    printf 'No failed units.\n'
    return
  fi

  printf 'Clear these failed states? [y/N] '
  read -r reply
  if [[ ${reply,,} == y ]]; then
    sudo systemctl reset-failed
    systemctl --user reset-failed
    printf 'Cleared.\n'
  fi
}

if [[ ${1:-} == --details ]]; then
  show_details
else
  emit_json
fi
