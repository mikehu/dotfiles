#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<EOF
Usage: $(basename "$0") -i <REMOTE_HOST_IP> [-u <REMOTE_HOST_USER>]

  -i    IP address of the remote host (required)
  -u    SSH user on the remote host (defaults to current user)
EOF
  exit 1
}

# defaults
REMOTE_HOST_USER="$(whoami)"
REMOTE_HOST_IP=""

# parse flags
while getopts ":i:u:" opt; do
  case $opt in
    i) REMOTE_HOST_IP=$OPTARG ;;
    u) REMOTE_HOST_USER=$OPTARG ;;
    *) usage ;;
  esac
done

# require IP
[[ -z "$REMOTE_HOST_IP" ]] && usage

# local paths
LOCAL_KUBE_DIR="${HOME}/.kube"
REMOTE_CONFIG_LOCAL="${LOCAL_KUBE_DIR}/remote-config"
BACKUP_CONFIG="${LOCAL_KUBE_DIR}/config.bak"
TMP_FLATTENED="/tmp/kubeconfig.flat"

# determine remote home directory
if [[ "$REMOTE_HOST_USER" == "root" ]]; then
  REMOTE_HOME="/root"
else
  if ssh "${REMOTE_HOST_USER}@${REMOTE_HOST_IP}" test -f "/home/${REMOTE_HOST_USER}/.kube/config"; then
    REMOTE_HOME="/home/${REMOTE_HOST_USER}"
  elif ssh "${REMOTE_HOST_USER}@${REMOTE_HOST_IP}" test -f "/Users/${REMOTE_HOST_USER}/.kube/config"; then
    REMOTE_HOME="/Users/${REMOTE_HOST_USER}"
  else
    echo "❌ Could not find a kubeconfig in /home/${REMOTE_HOST_USER}/.kube/config or /Users/${REMOTE_HOST_USER}/.kube/config on ${REMOTE_HOST_IP}" >&2
    exit 1
  fi
fi

REMOTE_CONFIG="${REMOTE_HOME}/.kube/config"

# fetch remote kubeconfig
ssh "${REMOTE_HOST_USER}@${REMOTE_HOST_IP}" "cat '${REMOTE_CONFIG}'" > "${REMOTE_CONFIG_LOCAL}"

# merge & flatten
cp "${LOCAL_KUBE_DIR}/config" "${BACKUP_CONFIG}"
KUBECONFIG="${REMOTE_CONFIG_LOCAL}:${LOCAL_KUBE_DIR}/config" \
  kubectl config view --flatten > "${TMP_FLATTENED}"
mv "${TMP_FLATTENED}" "${LOCAL_KUBE_DIR}/config"

echo "✅ Merged ${REMOTE_HOST_USER}@${REMOTE_HOST_IP}:${REMOTE_CONFIG} into ${LOCAL_KUBE_DIR}/config"
echo "   (backup of previous config: ${BACKUP_CONFIG})"
