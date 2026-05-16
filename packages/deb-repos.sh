#!/usr/bin/env bash
# deb-repos.sh — register all third-party apt repositories needed by apt.txt.
# Idempotent: each block checks for existing keyring/source first.
# Run with sudo or by a user with sudo rights.

set -euo pipefail

ARCH=$(dpkg --print-architecture)
CODENAME=$(lsb_release -cs)
KEYRING_DIR=/etc/apt/keyrings
SOURCES_DIR=/etc/apt/sources.list.d

sudo install -d -m 0755 "$KEYRING_DIR"

# --- Microsoft (covers VS Code, Edge, Teams, Azure CLI, Functions Core Tools, .NET) ---
# Regenerate if missing OR zero-byte: a failed first run can leave an empty
# keyring that a plain [ ! -f ] guard would never replace. [ ! -s ] is true
# when the file is missing or empty.
if [ ! -s "$KEYRING_DIR/microsoft.gpg" ]; then
  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
    | sudo gpg --dearmor -o "$KEYRING_DIR/microsoft.gpg"
fi
# apt updates run as the unprivileged _apt user and must be able to read the
# keyring, otherwise: "repository ... is not signed / can't be done securely".
sudo chmod a+r "$KEYRING_DIR/microsoft.gpg"

# VS Code
echo "deb [arch=$ARCH signed-by=$KEYRING_DIR/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
  | sudo tee "$SOURCES_DIR/vscode.list" >/dev/null

# Microsoft Edge
echo "deb [arch=$ARCH signed-by=$KEYRING_DIR/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" \
  | sudo tee "$SOURCES_DIR/microsoft-edge.list" >/dev/null

# Microsoft Teams (Linux build)
echo "deb [arch=$ARCH signed-by=$KEYRING_DIR/microsoft.gpg] https://packages.microsoft.com/repos/ms-teams stable main" \
  | sudo tee "$SOURCES_DIR/teams.list" >/dev/null

# Azure CLI — Microsoft publishes this feed only for specific (mostly LTS)
# Ubuntu codenames; brand-new releases 404 on dists/<codename>/Release. The
# azure-cli package is distribution-agnostic, so probe the live codename and
# fall back to the newest known-good dist if Microsoft hasn't published it yet.
AZ_CLI_DIST="$CODENAME"
if ! curl -fsI "https://packages.microsoft.com/repos/azure-cli/dists/$AZ_CLI_DIST/Release" >/dev/null 2>&1; then
  for fallback in noble jammy focal; do
    if curl -fsI "https://packages.microsoft.com/repos/azure-cli/dists/$fallback/Release" >/dev/null 2>&1; then
      echo "azure-cli: Microsoft has no '$CODENAME' feed; falling back to '$fallback'"
      AZ_CLI_DIST="$fallback"
      break
    fi
  done
fi
echo "deb [arch=$ARCH signed-by=$KEYRING_DIR/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_CLI_DIST main" \
  | sudo tee "$SOURCES_DIR/azure-cli.list" >/dev/null

# .NET / prod feed (covers dotnet-sdk-10.0 and azure-functions-core-tools-4)
UBUNTU_VER=$(lsb_release -rs)
curl -fsSL "https://packages.microsoft.com/config/ubuntu/${UBUNTU_VER}/packages-microsoft-prod.deb" -o /tmp/packages-microsoft-prod.deb
sudo dpkg -i /tmp/packages-microsoft-prod.deb || true
rm -f /tmp/packages-microsoft-prod.deb

# --- GitHub CLI ---
if [ ! -f "$KEYRING_DIR/githubcli-archive-keyring.gpg" ]; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo dd of="$KEYRING_DIR/githubcli-archive-keyring.gpg"
  sudo chmod a+r "$KEYRING_DIR/githubcli-archive-keyring.gpg"
fi
echo "deb [arch=$ARCH signed-by=$KEYRING_DIR/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | sudo tee "$SOURCES_DIR/github-cli.list" >/dev/null

# --- Ghostty (community PPA — fall back to GitHub release tarball if PPA missing) ---
if ! grep -rq "ghostty" "$SOURCES_DIR" 2>/dev/null; then
  sudo add-apt-repository -y ppa:ppa-verse/ghostty 2>/dev/null || \
    echo "Ghostty PPA not available — install manually from https://ghostty.org/download"
fi

sudo apt-get update -y
