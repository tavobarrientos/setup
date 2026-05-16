# Shared aliases sourced by both .zshrc and .bashrc.

# Listing
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -l --icons --group-directories-first'
  alias la='eza -la --icons --group-directories-first'
  alias lt='eza --tree --level=2 --icons'
fi

# bat replaces cat with syntax highlighting (Ubuntu names it batcat)
command -v batcat >/dev/null 2>&1 && alias bat='batcat'
command -v bat    >/dev/null 2>&1 && alias cat='bat --paging=never'

# fd on Ubuntu is fdfind
command -v fdfind >/dev/null 2>&1 && alias fd='fdfind'

# Git shortcuts
alias gs='git status'
alias gc='git commit'
alias gca='git commit --amend'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias glog='git log --oneline --graph --decorate'
alias lg='lazygit'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Tools
alias y='yazi'
alias k='kubectl'
alias dc='docker compose'
