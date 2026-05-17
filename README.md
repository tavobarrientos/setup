# setup

Cross-platform machine bootstrap for macOS, Ubuntu, WSL2, and Windows 11.
Drives [chezmoi](https://www.chezmoi.io/) to install apps, runtimes, shell
frameworks, and dotfiles in one command.

## Quick start

### macOS / Ubuntu / WSL

```bash
sh -c "$(curl -fsLS https://raw.githubusercontent.com/tavobarrientos/setup/main/install.sh)"
```

The script auto-detects WSL and skips the GUI/font work there.

### Windows 11

Open **Windows PowerShell** (the built-in 5.1 that ships with Windows — you
don't have pwsh 7 yet on a fresh box; this script will install it):

```powershell
iwr -useb https://raw.githubusercontent.com/tavobarrientos/setup/main/install.ps1 | iex
```

`install.ps1` does, in order: winget → Git for Windows → **PowerShell 7
(pwsh)** → chezmoi → WSL2 + Ubuntu → `chezmoi apply` (which then runs the
winget bundle, Oh My Posh setup, PowerShell module installs, etc.).

For a clean Windows box, after `install.ps1` finishes, open the new Ubuntu
shell and run `install.sh` inside it to complete the WSL side.

## What gets installed

### Shells & prompt
- **zsh + Oh My Zsh** on macOS / Ubuntu / WSL (zsh is set as the default shell).
- **PowerShell 7 + Oh My Posh** on Windows.
- **MesloLGM Nerd Font** on macOS / Ubuntu / Windows.

### Core CLI (every OS unless noted)
`git`, `gh`, `fzf`, `ripgrep`, `fd`, `bat`, `eza`, `jq`, `zoxide`, `neovim`,
`uv`, `fnm`, `lazygit`, `yazi` (with optional extended tools:
`ffmpeg`, `7zip`/`p7zip`, `poppler`, `imagemagick`).

`tmux` is installed via snap on Ubuntu and WSL (when systemd is enabled);
skipped on Windows.

### Cloud / agent CLIs
Azure CLI, Azure Functions Core Tools v4, GitHub Copilot CLI, Claude Code,
OpenCode, OpenSpec.

### Languages
- **.NET 10 SDK** (winget / Brew / apt)
- **Node.js** via `fnm` (LTS)
- **Python 3.12** via `uv`

### GUI apps (per-OS, see [`packages/`](packages/))

| App | macOS | Ubuntu | Windows | WSL |
|---|:-:|:-:|:-:|:-:|
| VS Code | ✓ | ✓ | ✓ | use host via Remote-WSL |
| Cursor | ✓ | ✓ | ✓ | — |
| Claude desktop | ✓ | — | ✓ | — |
| Docker Desktop | ✓ | — | ✓ | — |
| Docker Engine + compose | — | ✓ | — | ✓ |
| Microsoft Edge | ✓ | ✓ | preinstalled | — |
| Microsoft Teams | ✓ | ✓ | ✓ | — |
| Microsoft 365 (Office) | ✓ | LibreOffice instead | ✓ | — |
| Slack | ✓ | ✓ | ✓ | — |
| Spotify | ✓ | ✓ | ✓ | — |
| Notion | ✓ | ✓ | ✓ | — |
| LastPass app | ✓ | `lastpass-cli` + ext | ✓ | `lastpass-cli` |
| Ghostty | ✓ | — | — | — |
| PowerToys | — | — | ✓ | — |
| Visual Studio 2026 Community | — | — | ✓ | — |
| Postman | ✓ | ✓ | ✓ | — |
| JetBrains Rider | ✓ | — | — | — |
| Xcode + CLT | ✓ | — | — | — |

### VS Code extensions

See [`packages/vscode-extensions.txt.tmpl`](packages/vscode-extensions.txt.tmpl).
Swift extension is installed on macOS only.

## Repo layout

```
setup/
├── install.sh              # macOS / Ubuntu / WSL bootstrap
├── install.ps1             # Windows bootstrap
├── .chezmoiroot            # tells chezmoi source dir is `home/`
├── home/                   # chezmoi source state
│   ├── .chezmoi.toml.tmpl  # init-time prompts for name/email
│   ├── dot_zshrc.tmpl      # → ~/.zshrc
│   ├── dot_bashrc          # → ~/.bashrc (fallback)
│   ├── dot_config/         # → ~/.config/...
│   └── run_onchange_before_*  # OS-templated install scripts (one installs the
│                              # pwsh profile from packages/powershell/)
└── packages/               # package manifests, one per OS
```

## Post-bootstrap manual steps

1. `gh auth login` — GitHub auth, used by Copilot CLI.
2. Sign into LastPass (browser extension + Microsoft 365 sign-in).
3. **macOS only:** sign into the App Store so the `mas`-driven Xcode install
   completes.
4. Generate SSH keys / configure git signing — out of scope by design.

## Updating

The repo is the source of truth. On any machine:

```bash
chezmoi update     # pull latest + re-apply
chezmoi apply      # re-apply without pulling
chezmoi data       # inspect template variables (OS, is_wsl, etc.)
chezmoi diff       # preview pending changes
```

To add a package: edit the right file in `packages/`, commit, then
`chezmoi update` on each machine. The package-install scripts re-run
automatically when their hashes change.

## Customizing per-machine

Per-machine overrides go in `~/.config/chezmoi/chezmoi.toml`. The init
template prompts for `name`, `email`, and `is_wsl` once and stores them
there; everything else is templated from those plus chezmoi's built-in
`.chezmoi.os` / `.chezmoi.arch`.
