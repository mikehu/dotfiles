#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

###–– Defaults ––###
REMOTE_IP=""
REMOTE_USER="$(whoami)"
CTX_SUBSTR="nx-lxc"
SSH_KEY="$HOME/.ssh/id_ed25519"

usage() {
  cat <<EOF
Usage: $(basename "$0") -i ip [-u user] [-c ctx_substr] [-k ssh_key] [-h]

  -i  MAC‑Mini IP address        (required)
  -u  MAC‑Mini SSH user          (default: $REMOTE_USER)
  -c  Kube‑context substring     (default: $CTX_SUBSTR)
  -k  SSH key for tunneling      (default: $SSH_KEY)
  -h  Show this help and exit
EOF
  exit 1
}

###–– Parse flags ––###
while getopts "i:u:c:k:h" opt; do
  case $opt in
    i) REMOTE_IP="$OPTARG" ;;
    u) REMOTE_USER="$OPTARG" ;;
    c) CTX_SUBSTR="$OPTARG" ;;
    k) SSH_KEY="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
  esac
done
shift $((OPTIND-1))

# Validate mandatory
if [[ -z "$REMOTE_IP" ]]; then
  echo "Error: -i IP is required." >&2
  usage
fi

###–– Derived ––###
SSH_LAN="${REMOTE_USER}@${REMOTE_IP}"

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
REVERSE_FWD=( "-R3080:localhost:3080" "-R5173:localhost:5173" )
PRIV_FWD=( "-L80:localhost:80" "-L443:localhost:443" )

###–– Launch ––###
cleanup_tunnels
kill_remote

autossh -M0 -f -N -g \
  "${LOCAL_FWD[@]}" "${REVERSE_FWD[@]}" \
  -i "$SSH_KEY" "$SSH_LAN"

sudo ssh -f -N \
  "${PRIV_FWD[@]}" \
  -i "$SSH_KEY" "$SSH_LAN"
