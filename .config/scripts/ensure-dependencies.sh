#!/usr/bin/env bash
# Checks that all dependencies used by dotfiles scripts are installed.
# Prints warnings for any missing tools. Designed to be sourced from .zshrc_local.

_check_dep() {
  command -v "$1" &>/dev/null
}

_ensure_dependencies() {
  local missing=()
  local os
  os="$(uname -s)"

  # ── Cross-platform dependencies ──────────────────────────────────────
  local common_deps=(
    git
    tmux
    fzf
    fd
    zoxide
    pass
    gpg
    ffmpeg
    gifsicle
    rembg
    magick
    autossh
    kubectl
    op
    rg
  )

  for dep in "${common_deps[@]}"; do
    _check_dep "$dep" || missing+=("$dep")
  done

  # ── macOS-only dependencies ──────────────────────────────────────────
  if [[ "$os" == "Darwin" ]]; then
    local macos_deps=(
      kitty
      kitten
    )
    for dep in "${macos_deps[@]}"; do
      _check_dep "$dep" || missing+=("$dep")
    done
  fi

  # ── Linux-only dependencies (Wayland/Hyprland) ──────────────────────
  if [[ "$os" == "Linux" ]]; then
    local linux_deps=(
      pfetch
      kitty
      kitten
      gsettings
      waybar
      swww
      wallust
      makoctl
      notify-send
      Hyprland
    )
    for dep in "${linux_deps[@]}"; do
      _check_dep "$dep" || missing+=("$dep")
    done
  fi

  # ── Report ──────────────────────────────────────────────────────────
  if [[ ${#missing[@]} -gt 0 ]]; then
    local red=$'\033[1;31m'
    local yellow=$'\033[1;33m'
    local dim=$'\033[2m'
    local reset=$'\033[0m'

    local w=48
    local bar
    bar=$(printf '─%.0s' $(seq 1 $w))
    local header="Missing Dependencies (${#missing[@]} total)"

    echo ""
    echo "${red}╭${bar}╮${reset}"
    printf "${red}│${reset}  ${yellow}%-$((w - 4))s${reset}  ${red}│${reset}\n" "$header"
    echo "${red}├${bar}┤${reset}"
    for dep in "${missing[@]}"; do
      printf "${red}│${reset}  ${yellow}✗${reset}  %-$((w - 5))s${red}│${reset}\n" "$dep"
    done
    echo "${red}╰${bar}╯${reset}"
    echo ""
  fi
}

_ensure_dependencies
unset -f _ensure_dependencies _check_dep
