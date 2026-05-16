#!/usr/bin/env bash
# install.sh — bootstrap macOS, Ubuntu, or WSL2 from a fresh state.
# Usage: sh -c "$(curl -fsLS https://raw.githubusercontent.com/tavobarrientos/setup/main/install.sh)"

set -euo pipefail

REPO="tavobarrientos/setup"
log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; exit 1; }

uname_s=$(uname -s)
is_wsl=false
case "$uname_s" in
  Darwin) os=darwin ;;
  Linux)
    os=linux
    if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; then
      is_wsl=true
    fi
    ;;
  *) die "Unsupported OS: $uname_s" ;;
esac

log "Detected OS=$os is_wsl=$is_wsl"

ensure_xcode_clt() {
  if xcode-select -p >/dev/null 2>&1; then
    log "Xcode Command Line Tools already installed"
  else
    log "Installing Xcode Command Line Tools (a dialog will appear — accept it)"
    xcode-select --install || true
    until xcode-select -p >/dev/null 2>&1; do
      sleep 10
      log "Waiting for Xcode Command Line Tools install to finish..."
    done
  fi
}

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    log "Homebrew already installed"
  else
    log "Installing Homebrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

ensure_apt_basics() {
  log "Refreshing apt and installing base packages"
  sudo apt-get update -y
  sudo apt-get install -y curl git ca-certificates gnupg lsb-release
}

ensure_chezmoi() {
  if command -v chezmoi >/dev/null 2>&1; then
    log "chezmoi already installed"
    return
  fi
  log "Installing chezmoi"
  case "$os" in
    darwin) brew install chezmoi ;;
    linux)
      sh -c "$(curl -fsLS https://chezmoi.io/get)" -- -b "$HOME/.local/bin"
      export PATH="$HOME/.local/bin:$PATH"
      ;;
  esac
}

run_chezmoi() {
  log "Running chezmoi init --apply $REPO (is_wsl=$is_wsl)"
  chezmoi init --apply --promptBool is_wsl="$is_wsl" "$REPO"
}

main() {
  if [ "$os" = "darwin" ]; then
    ensure_xcode_clt
    ensure_homebrew
  else
    ensure_apt_basics
  fi
  ensure_chezmoi
  run_chezmoi
  log "Bootstrap complete. Open a new shell to pick up the new environment."
  cat <<'POST'

Post-bootstrap manual steps:
  1. gh auth login         # GitHub auth (Copilot CLI uses it)
  2. lpass login <email>   # LastPass CLI (Linux/WSL only)
  3. Sign into LastPass browser extension and Microsoft 365.
  4. (macOS) Sign into the App Store so the Xcode IDE install completes.
  5. (Windows-side) Swap the PowerShell profile + Oh My Posh theme placeholders
     for your real copies from OneDrive.
POST
}

main "$@"
