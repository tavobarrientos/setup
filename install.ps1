# install.ps1 — bootstrap a fresh Windows 11 host.
# Runs from Windows PowerShell 5.1 (the OS default); installs PowerShell 7
# (pwsh) first so the rest of the bootstrap — and every chezmoi .ps1 script
# afterward — can use the modern shell.
# Usage: iwr -useb https://raw.githubusercontent.com/tavobarrientos/setup/main/install.ps1 | iex

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$Repo = 'tavobarrientos/setup'

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Warn($msg) { Write-Host "!! $msg"  -ForegroundColor Yellow }

function Test-Command($name) {
  return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

function Ensure-Winget {
  if (Test-Command winget) {
    Write-Step "winget already present"
    return
  }
  Write-Warn "winget not found. Install 'App Installer' from the Microsoft Store, then re-run this script."
  Start-Process 'ms-windows-store://pdp/?productid=9NBLGGH4NNS1'
  exit 1
}

function Ensure-GitForWindows {
  if (Test-Command git) {
    Write-Step "Git for Windows already installed"
    return
  }
  Write-Step "Installing Git for Windows"
  winget install --id Git.Git -e --silent --accept-package-agreements --accept-source-agreements
}

function Ensure-PowerShell7 {
  # Windows 11 ships with Windows PowerShell 5.1 only. We need pwsh 7 because:
  #   - chezmoi's [interpreters.ps1] block points at `pwsh -NoLogo -NoProfile`
  #   - The user's profile lives in ~/Documents/PowerShell/ (the pwsh 7 path)
  #   - PSReadLine/CompletionPredictor target pwsh 7 behavior.
  if (Test-Command pwsh) {
    Write-Step "PowerShell 7 already installed"
    return
  }
  Write-Step "Installing PowerShell 7 (Microsoft.PowerShell)"
  winget install --id Microsoft.PowerShell -e --silent `
    --accept-package-agreements --accept-source-agreements

  # winget set the machine PATH but THIS process inherited PATH at launch,
  # so prepend the install dir so `pwsh` resolves immediately.
  $pwshDir = Join-Path $env:ProgramFiles 'PowerShell\7'
  if (Test-Path $pwshDir) {
    $env:PATH = "$pwshDir;$env:PATH"
  }

  if (-not (Test-Command pwsh)) {
    Write-Warn "PowerShell 7 install reported success but 'pwsh' isn't on PATH yet."
    Write-Warn "Close this terminal, open a new one, and re-run install.ps1."
    exit 1
  }
}

function Ensure-ExecutionPolicy {
  # Set CurrentUser execution policy to RemoteSigned (more secure than Unrestricted):
  #   - Local .ps1 files run freely (chezmoi-extracted scripts, the pwsh profile, etc.)
  #   - Scripts downloaded from the internet must be signed before they'll run
  # Scope CurrentUser writes to HKCU and is shared between Windows PowerShell 5.1
  # and PowerShell 7, so this single call covers both.
  $current = Get-ExecutionPolicy -Scope CurrentUser
  if ($current -eq 'RemoteSigned') {
    Write-Step "ExecutionPolicy already RemoteSigned (CurrentUser)"
    return
  }
  Write-Step "Setting ExecutionPolicy = RemoteSigned (CurrentUser); was: $current"
  Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
}

function Ensure-Chezmoi {
  if (Test-Command chezmoi) {
    Write-Step "chezmoi already installed"
    return
  }
  Write-Step "Installing chezmoi"
  winget install --id twpayne.chezmoi -e --silent --accept-package-agreements --accept-source-agreements
  # Make freshly-installed shims visible in this session
  $env:PATH = "$env:PATH;$env:LOCALAPPDATA\Microsoft\WinGet\Links"
}

function Set-YaziFileOne {
  $filePath = 'C:\Program Files\Git\usr\bin\file.exe'
  if (-not (Test-Path $filePath)) {
    Write-Warn "Git for Windows file.exe not found at $filePath; YAZI_FILE_ONE not set yet."
    return
  }
  Write-Step "Setting YAZI_FILE_ONE user env var -> $filePath"
  [Environment]::SetEnvironmentVariable('YAZI_FILE_ONE', $filePath, 'User')
  $env:YAZI_FILE_ONE = $filePath
}

function Ensure-WSL {
  $wslStatus = wsl --status 2>$null
  if ($LASTEXITCODE -eq 0 -and $wslStatus) {
    Write-Step "WSL already installed"
  } else {
    Write-Step "Installing WSL with Ubuntu (a reboot may be required)"
    wsl --install -d Ubuntu --no-launch
  }
}

function Invoke-Chezmoi {
  Write-Step "Running chezmoi init --apply $Repo"
  chezmoi init --apply --prompt-bool is_wsl=false $Repo
}

function Main {
  Ensure-Winget
  Ensure-GitForWindows
  Ensure-PowerShell7        # MUST run before Invoke-Chezmoi: chezmoi shells out to pwsh.
  Ensure-ExecutionPolicy    # MUST run before chezmoi spawns any .ps1 (OMP setup, modules).
  Ensure-Chezmoi
  Set-YaziFileOne
  Ensure-WSL
  Invoke-Chezmoi
  Write-Step "Windows host bootstrap complete."
  Write-Host @"

Post-bootstrap manual steps:
  1. gh auth login           # GitHub auth (Copilot CLI uses it)
  2. Open an Ubuntu shell (Start menu) and run inside WSL:
       sh -c "`$(curl -fsLS https://raw.githubusercontent.com/$Repo/main/install.sh)"
  3. Sign into LastPass browser extension and Microsoft 365.
"@
}

Main
