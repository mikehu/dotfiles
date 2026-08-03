#!/usr/bin/env bash
# Arch system-level setup that stow cannot carry: /etc config, systemd units and
# boot configuration. Everything here lives outside $HOME, so it is lost on a
# fresh Arch install unless reapplied.
#
# Idempotent: safe to re-run. Each step checks its own state first.
#
# Usage:  sudo ~/.config/scripts/setup-arch.sh
#         sudo ~/.config/scripts/setup-arch.sh --dry-run

set -euo pipefail

DRY_RUN=false
[[ ${1:-} == "--dry-run" ]] && DRY_RUN=true

LAN_SUBNET="${LAN_SUBNET:-10.0.0.0/22}" # override if the network changes

info() { printf '  \033[1;34m->\033[0m %s\n' "$1"; }
skip() { printf '  \033[2m--\033[0m %s\n' "$1"; }
head_() { printf '\n\033[1m%s\033[0m\n' "$1"; }

run() {
  if $DRY_RUN; then
    printf '  \033[2m[dry-run]\033[0m %s\n' "$*"
  else
    "$@"
  fi
}

if [[ $EUID -ne 0 ]] && ! $DRY_RUN; then
  echo "needs root: sudo $0" >&2
  exit 1
fi

# ── Shutdown speed ────────────────────────────────────────────────────
# Default DefaultTimeoutStopSec is 90s. A shell process that ignores SIGTERM
# therefore stalls shutdown for a minute and a half before SIGKILL.
head_ "systemd shutdown timeout"
if [[ -f /etc/systemd/system.conf.d/10-faster-shutdown.conf ]]; then
  skip "system timeout already configured"
else
  info "setting DefaultTimeoutStopSec=5s"
  run mkdir -p /etc/systemd/system.conf.d
  $DRY_RUN || printf '[Manager]\nDefaultTimeoutStopSec=5s\n' >/etc/systemd/system.conf.d/10-faster-shutdown.conf
fi
if [[ -f /etc/systemd/system/user@.service.d/faster-shutdown.conf ]]; then
  skip "user@.service timeout already configured"
else
  info "setting TimeoutStopSec=5s for user@.service"
  run mkdir -p /etc/systemd/system/user@.service.d
  $DRY_RUN || printf '[Service]\nTimeoutStopSec=5s\n' >/etc/systemd/system/user@.service.d/faster-shutdown.conf
fi

# ── Package cache + pre-download ──────────────────────────────────────
# checkupdates(1) rather than `pacman -Syuw`: it uses a temporary database, so
# it cannot leave the real sync DB ahead of installed packages (partial-upgrade
# risk). Nothing is installed automatically.
head_ "pacman maintenance"
if systemctl is-enabled --quiet paccache.timer 2>/dev/null; then
  skip "paccache.timer already enabled"
else
  info "enabling weekly package cache pruning"
  run systemctl enable --now paccache.timer
fi

if [[ -f /etc/systemd/system/pacman-predownload.timer ]]; then
  skip "pre-download timer already present"
else
  info "installing nightly pre-download timer"
  if ! $DRY_RUN; then
    cat >/etc/systemd/system/pacman-predownload.service <<'EOF'
[Unit]
Description=Pre-download pending pacman updates
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/checkupdates -d
Nice=19
IOSchedulingClass=idle
EOF
    cat >/etc/systemd/system/pacman-predownload.timer <<'EOF'
[Unit]
Description=Pre-download pending pacman updates daily

[Timer]
OnCalendar=daily
RandomizedDelaySec=2h
Persistent=true

[Install]
WantedBy=timers.target
EOF
  fi
  run systemctl daemon-reload
  run systemctl enable --now pacman-predownload.timer
fi

# ── Firewall ──────────────────────────────────────────────────────────
# Default-deny inbound, with the LAN services this machine actually runs.
# SSH is rate-limited rather than subnet-scoped so off-LAN access still works.
head_ "firewall"
if ! command -v ufw >/dev/null; then
  skip "ufw not installed - skipping (pacman -S ufw)"
elif grep -q '^ENABLED=yes' /etc/ufw/ufw.conf 2>/dev/null; then
  # ufw.conf is world-readable; `ufw status` needs root and would misreport
  # during an unprivileged --dry-run.
  skip "ufw already enabled"
else
  info "configuring ufw for subnet $LAN_SUBNET"
  run ufw default deny incoming
  run ufw default allow outgoing
  run ufw limit 22/tcp comment 'ssh (rate-limited)'
  run ufw allow from "$LAN_SUBNET" to any port 22000 comment 'syncthing sync'
  run ufw allow from "$LAN_SUBNET" to any port 21027 proto udp comment 'syncthing discovery'
  run ufw allow from "$LAN_SUBNET" to any port 5353 proto udp comment 'mDNS spotifyd/avahi'
  run ufw allow from "$LAN_SUBNET" to any port 4444 proto tcp comment 'spotifyd connect'
  run ufw --force enable
  run systemctl enable ufw
fi

# ── Boot splash ───────────────────────────────────────────────────────
# Plymouth covers kernel + systemd boot AND shutdown. GRUB's theme only covers
# the boot menu, which ends the moment the kernel starts.
head_ "plymouth boot splash"
if ! command -v plymouth >/dev/null; then
  skip "plymouth not installed - skipping (pacman -S plymouth)"
else
  regen_initramfs=false
  regen_grub=false

  if grep -qE '^HOOKS=.*\bplymouth\b' /etc/mkinitcpio.conf; then
    skip "plymouth hook already in mkinitcpio HOOKS"
  else
    info "adding plymouth hook (must follow base and udev)"
    run cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.bak
    $DRY_RUN || sed -i 's/^HOOKS=(base udev /HOOKS=(base udev plymouth /' /etc/mkinitcpio.conf
    regen_initramfs=true
  fi

  if grep -qE '^GRUB_CMDLINE_LINUX_DEFAULT=.*\bsplash\b' /etc/default/grub; then
    skip "splash already in GRUB cmdline"
  else
    info "adding splash to GRUB_CMDLINE_LINUX_DEFAULT"
    run cp /etc/default/grub /etc/default/grub.bak
    $DRY_RUN || sed -i 's/^\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)"/\1 splash"/' /etc/default/grub
    regen_grub=true
  fi

  $regen_initramfs && run mkinitcpio -P
  $regen_grub && run grub-mkconfig -o /boot/grub/grub.cfg
fi

head_ "done"
cat <<'EOF'
  Not covered here (user-scope, run WITHOUT sudo):
    systemctl --user enable --now elephant.service   # walker backend
    xdg-settings set default-web-browser app.zen_browser.zen.desktop
    plymouth-set-default-theme -R bgrt               # after installing plymouth
EOF
