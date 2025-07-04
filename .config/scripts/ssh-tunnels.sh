#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

###–– Defaults ––###
REMOTE_ADDR="nx-lxc.local"
REMOTE_USER="$(whoami)"
CTX_SUBSTR="nx-lxc"
SSH_KEY="$HOME/.ssh/id_ed25519"

usage() {
  cat <<EOF
Usage: $(basename "$0") -h host [-u user] [-c ctx_substr] [-k ssh_key]

  -h  Tunnel Host address        (required)
  -u  Tunnel SSH user            (default: $REMOTE_USER)
  -c  Kube‑context substring     (default: $CTX_SUBSTR)
  -k  SSH key for tunneling      (default: $SSH_KEY)
EOF
  exit 1
}

###–– Parse flags ––###
while getopts "h:u:c:k:" opt; do
  case $opt in
    h) REMOTE_ADDR="$OPTARG" ;;
    u) REMOTE_USER="$OPTARG" ;;
    c) CTX_SUBSTR="$OPTARG" ;;
    k) SSH_KEY="$OPTARG" ;;
    *) usage ;;
  esac
done
shift $((OPTIND-1))

# Validate mandatory
if [[ -z "$REMOTE_ADDR" ]]; then
  echo "Error: -i IP is required." >&2
  usage
fi

###–– Derived ––###
SSH_LAN="${REMOTE_USER}@${REMOTE_ADDR}"

###–– autossh tuning ––###
export AUTOSSH_POLL=60
export AUTOSSH_GATETIME=30

###–– Functions ––###
get_kube_ports(){
  grep -B1 "${CTX_SUBSTR}" ~/.kube/config \
    | grep "127\.0\.0\.1" \
    | cut -d: -f4
}
cleanup_tunnels(){
  pkill autossh 2>/dev/null || true
  sudo pkill -f "ssh -f -N" 2>/dev/null || true
}
kill_remote(){
  ssh -t "$SSH_LAN" \
    "lsof -t -sTCP:LISTEN -i :3080 -i :5173 | xargs --no-run-if-empty kill"
}

###–– Build forwards ––###
NODE_PORTS=(5557 6379 6820 7080 9090)
KUBE_PORTS=( $(get_kube_ports) )
LOCAL_FWD=()
for p in "${NODE_PORTS[@]}" "${KUBE_PORTS[@]:-}"; do
  LOCAL_FWD+=("-L" "${p}:localhost:${p}")
done

REVERSE_PORTS=(3080 5173)
REVERSE_FWD=()
for p in "${REVERSE_PORTS[@]}"; do
  REVERSE_FWD+=("-R" "${p}:localhost:${p}")
done

###–– Launch ––###
cleanup_tunnels
kill_remote

autossh -M0 -f -N -g \
  "${LOCAL_FWD[@]}" "${REVERSE_FWD[@]}" \
  -i "$SSH_KEY" "$SSH_LAN"

###–– Count ’em ––###
# Give SSH a sec to bind
sleep 3

# Check tunnels
ALL_PORTS=( "${NODE_PORTS[@]}" "${KUBE_PORTS[@]:-}" "${REVERSE_PORTS[@]}")
success=0
failed=()

# Check tunnels locally
for p in "${NODE_PORTS[@]}" "${KUBE_PORTS[@]:-}"; do
  if lsof -i TCP:"$p" -sTCP:LISTEN >/dev/null 2>&1; then
    ((success++))
  else
    failed+=("$p")
  fi
done

# Check reverse tunnels on remote host
for p in "${REVERSE_PORTS[@]}"; do
  if ssh "$SSH_LAN" "lsof -i TCP:$p -sTCP:LISTEN >/dev/null 2>&1"; then
    ((success++))
  else
    failed+=("$p")
  fi
done

total=${#ALL_PORTS[@]}
echo "✅ Established $success out of $total tunnels."

if (( ${#failed[@]} )); then
  (
    IFS=' '
    echo "⚠️ Failed to establish tunnels on ports: ${failed[*]}"
  )
fi
