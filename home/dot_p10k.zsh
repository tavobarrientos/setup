# ~/.p10k.zsh — Powerlevel10k prompt, managed by chezmoi.
#
# Hand-authored port of the Windows oh-my-posh theme
# (packages/powershell/omp-theme.omp.json) to Powerlevel10k. Keeps the omp
# theme's original vibrant per-segment colors and its two-line frame.
# Based on p10k's "rainbow" preset (colored backgrounds + powerline separators).
#
# Edit and `source ~/.p10k.zsh` to apply changes live. Segments map to omp as:
#   shellname->shell  context->user/root  dir->path  vcs->git
#   dotnet_version->dotnet  virtualenv->python  status->exit
#   | battery  spotify(custom)  os_icon  time
#
# Icons are \uXXXX escapes (Nerd Font v3 / MesloLGS NF) so this file stays pure
# ASCII. Truecolor (%F{#rrggbb}) needs a truecolor terminal; degrades on 256-color.

# Temporarily change options (verbatim from the rainbow preset).
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # Zsh >= 5.1 is required.
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # Nerd Font v3 icons (the repo installs MesloLGS NF; omp used nerdFontsVersion 3).
  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_ICON_PADDING=moderate

  # Don't warn about console output during zsh init (zshrc evals brew/fnm/zoxide).
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
  # Blank line before each prompt.
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

  #############################[ Prompt elements ]#############################
  # Line 1 left -> omp left block; line 2 = prompt char under the frame.
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    shellname               # custom: terminal icon + "zsh"   (omp shell)
    context                 # user, root cog, ssh icon        (omp session/root)
    dir                     # current folder                  (omp path)
    vcs                     # git status                      (omp git)
    dotnet_version          # .NET SDK in project dirs        (omp dotnet)
    virtualenv              # python venv + version           (omp python)
    status                  # exit code, ok/error             (omp status/exit)
    newline                 # -> line 2
    prompt_char             # the prompt symbol after the frame
  )
  # Line 1 right -> omp right block.
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    battery                 # charge + state color            (omp battery)
    spotify                 # custom: now playing             (omp spotify)
    os_icon                 # OS glyph                        (omp os)
    time                    # clock                           (omp time)
  )

  ##############################[ Frame / shape ]##############################
  # Powerline separators ( / ) and leading/trailing diamonds
  # ( / ).
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=$''
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=$''
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=$''
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=$''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=$''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=$''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=$''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=$''

  # Two-line frame in omp blue (#0077c2).
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=$'%F{#0077c2}╭─%f'
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX=$'%F{#0077c2}├─%f'
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=$'%F{#0077c2}╰─%f'

  # Prompt char: omp bottom glyph (), no box, ok/err coloring.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION=$''
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION=$''
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION=$''
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION=$''
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#e0f8ff'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#ef5350'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=

  ############################[ Segment: shell ]##############################
  # omp `shell`: terminal icon () + name, blue diamond. No native segment.
  typeset -g POWERLEVEL9K_SHELLNAME_BACKGROUND='#0077c2'
  typeset -g POWERLEVEL9K_SHELLNAME_FOREGROUND='#ffffff'
  function prompt_shellname()         { p10k segment -b '#0077c2' -f '#ffffff' -t $' zsh'; }
  function instant_prompt_shellname() { prompt_shellname; }

  ###########################[ Segment: context ]#############################
  # omp `session`/`root`: user (), ssh icon (), red cog () as root.
  typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND='#c386f1'
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND='#ffffff'
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND='#ef5350'
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND='#FFFB38'
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE=$' %n'
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE=$' %n'
  typeset -g POWERLEVEL9K_CONTEXT_SSH_TEMPLATE=$'  %n'
  # Always show the user segment (omp shows it unconditionally).
  typeset -g POWERLEVEL9K_ALWAYS_SHOW_CONTEXT=true
  typeset -g POWERLEVEL9K_CONTEXT_VISUAL_IDENTIFIER_EXPANSION=

  #############################[ Segment: dir ]###############################
  # omp `path` folder style: show current folder only, pink.
  typeset -g POWERLEVEL9K_DIR_BACKGROUND='#fd79a8'
  typeset -g POWERLEVEL9K_DIR_FOREGROUND='#ffffff'
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last
  typeset -g POWERLEVEL9K_DIR_VISUAL_IDENTIFIER_EXPANSION=

  #############################[ Segment: vcs ]###############################
  # omp `git`: HEAD + ahead/behind + staged/unstaged + stash, dark navy / peach.
  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=$' '
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
  local state
  for state in CLEAN MODIFIED UNTRACKED CONFLICTED LOADING; do
    typeset -g POWERLEVEL9K_VCS_${state}_BACKGROUND='#193549'
    typeset -g POWERLEVEL9K_VCS_${state}_FOREGROUND='#fab1a0'
  done
  unset state
  # Use the rainbow preset's formatter (recolored for the navy background).
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  function my_git_formatter() {
    emulate -L zsh
    if [[ -n $P9K_CONTENT ]]; then
      typeset -g my_git_format=$P9K_CONTENT
      return
    fi
    local       meta='%F{#fab1a0}'   # peach, matches omp git fg
    local      clean='%F{#fab1a0}'
    local   modified='%F{#f9e2af}'   # yellow for staged/unstaged
    local  untracked='%F{#a6e3a1}'   # green for untracked
    local conflicted='%F{#f38ba8}'   # red for conflicts
    local res
    if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
      local branch=${(V)VCS_STATUS_LOCAL_BRANCH}
      (( $#branch > 32 )) && branch[13,-13]="…"
      res+="${clean}${(g::)POWERLEVEL9K_VCS_BRANCH_ICON}${branch//\%/%%}"
    fi
    [[ -z $VCS_STATUS_LOCAL_BRANCH && -z $VCS_STATUS_TAG ]] &&
      res+="${meta}@${clean}${VCS_STATUS_COMMIT[1,8]}"
    if (( VCS_STATUS_COMMITS_AHEAD || VCS_STATUS_COMMITS_BEHIND )); then
      (( VCS_STATUS_COMMITS_BEHIND )) && res+=" ${clean}⇣${VCS_STATUS_COMMITS_BEHIND}"
      (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && res+=" "
      (( VCS_STATUS_COMMITS_AHEAD  )) && res+="${clean}⇡${VCS_STATUS_COMMITS_AHEAD}"
    fi
    (( VCS_STATUS_STASHES        )) && res+=" ${clean}*${VCS_STATUS_STASHES}"
    [[ -n $VCS_STATUS_ACTION     ]] && res+=" ${conflicted}${VCS_STATUS_ACTION}"
    (( VCS_STATUS_NUM_CONFLICTED )) && res+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}"
    (( VCS_STATUS_NUM_STAGED     )) && res+=" ${modified}+${VCS_STATUS_NUM_STAGED}"
    (( VCS_STATUS_NUM_UNSTAGED   )) && res+=" ${modified}!${VCS_STATUS_NUM_UNSTAGED}"
    (( VCS_STATUS_NUM_UNTRACKED  )) && res+=" ${untracked}${(g::)POWERLEVEL9K_VCS_UNTRACKED_ICON}${VCS_STATUS_NUM_UNTRACKED}"
    (( VCS_STATUS_HAS_UNSTAGED == -1 )) && res+=" ${modified}─"
    typeset -g my_git_format=$res
  }
  # Register as a math function so p10k can call it via $(( my_git_formatter() ))
  # inside VCS_CONTENT_EXPANSION. Without this, prompt expansion fails at render
  # time with "unknown function: my_git_formatter" and the raw template prints.
  functions -M my_git_formatter 2>/dev/null
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter()))+${my_git_format}}'

  #########################[ Segment: dotnet_version ]########################
  # omp `dotnet`: .NET SDK version (icon ), shown only in .NET dirs.
  typeset -g POWERLEVEL9K_DOTNET_VERSION_BACKGROUND='#6c5ce7'
  typeset -g POWERLEVEL9K_DOTNET_VERSION_FOREGROUND='#ffffff'
  typeset -g POWERLEVEL9K_DOTNET_VERSION_PROJECT_ONLY=true
  typeset -g POWERLEVEL9K_DOTNET_VERSION_VISUAL_IDENTIFIER_EXPANSION=$''

  ##########################[ Segment: virtualenv ]###########################
  # omp `python`: venv + python version (icon ), purple.
  typeset -g POWERLEVEL9K_VIRTUALENV_BACKGROUND='#906cff'
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND='#100e23'
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=true
  typeset -g POWERLEVEL9K_VIRTUALENV_VISUAL_IDENTIFIER_EXPANSION=$''
  typeset -g POWERLEVEL9K_VIRTUALENV_{LEFT,RIGHT}_DELIMITER=

  ############################[ Segment: status ]#############################
  # omp `status`/`exit`: check () on success, cross () on error.
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
  typeset -g POWERLEVEL9K_STATUS_OK=true
  typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND='#2e9599'
  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND='#ffffff'
  typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION=$''
  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND='#f1184c'
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND='#ffffff'
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION=$''
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_BACKGROUND='#f1184c'
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND='#ffffff'
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_VISUAL_IDENTIFIER_EXPANSION=$''

  ###########################[ Segment: battery ]#############################
  # omp `battery`: state-colored, percentage + icon.
  typeset -g POWERLEVEL9K_BATTERY_FOREGROUND='#193549'
  typeset -g POWERLEVEL9K_BATTERY_VERBOSE=false
  typeset -g POWERLEVEL9K_BATTERY_CHARGED_BACKGROUND='#4caf50'      # Full
  typeset -g POWERLEVEL9K_BATTERY_CHARGING_BACKGROUND='#40c4ff'     # Charging
  typeset -g POWERLEVEL9K_BATTERY_DISCONNECTED_BACKGROUND='#ffeb3b' # On battery, healthy
  typeset -g POWERLEVEL9K_BATTERY_LOW_BACKGROUND='#ff5722'          # Low / discharging
  typeset -g POWERLEVEL9K_BATTERY_LOW_THRESHOLD=20

  ###########################[ Segment: spotify ]#############################
  # omp `spotify`: now playing. No native p10k segment -- custom (below).
  typeset -g POWERLEVEL9K_SPOTIFY_BACKGROUND='#1db954'
  typeset -g POWERLEVEL9K_SPOTIFY_FOREGROUND='#193549'
  # macOS -> osascript; Linux/WSL -> playerctl. Fast guard, silent when closed.
  function prompt_spotify() {
    emulate -L zsh
    local state artist track icon
    if [[ "$OSTYPE" == darwin* ]]; then
      pgrep -xq Spotify 2>/dev/null || return   # no launch side-effect
      state=$(osascript -e 'tell application "Spotify" to player state as string' 2>/dev/null) || return
      [[ -z $state || $state == stopped ]] && return
      artist=$(osascript -e 'tell application "Spotify" to artist of current track as string' 2>/dev/null)
      track=$(osascript -e 'tell application "Spotify" to name of current track as string' 2>/dev/null)
    else
      command -v playerctl >/dev/null 2>&1 || return
      state=$(playerctl -p spotify status 2>/dev/null) || return
      case $state in Playing) state=playing;; Paused) state=paused;; *) return;; esac
      artist=$(playerctl -p spotify metadata artist 2>/dev/null)
      track=$(playerctl -p spotify metadata title 2>/dev/null)
    fi
    case $state in
      [Pp]laying) icon=$'';;   # omp playing_icon
      [Pp]aused)  icon=$'';;   # omp paused_icon
      *)          return;;
    esac
    local text="$icon"
    [[ -n $artist || -n $track ]] && text+=" ${artist} - ${track}"
    p10k segment -b '#1db954' -f '#193549' -t "$text"
  }
  # Deliberately no instant_prompt_spotify: the external query never runs at startup.

  ###########################[ Segment: os_icon ]#############################
  # omp `os`: OS glyph, slate / cyan.
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND='#546E7A'
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND='#26C6DA'

  #############################[ Segment: time ]##############################
  # omp `time`: clock (), "_2 Jan, 15:04" -> "%e %b, %H:%M".
  typeset -g POWERLEVEL9K_TIME_BACKGROUND='#40c4ff'
  typeset -g POWERLEVEL9K_TIME_FOREGROUND='#ffffff'
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%e %b, %H:%M}'
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false
  typeset -g POWERLEVEL9K_TIME_VISUAL_IDENTIFIER_EXPANSION=$''

  # Apply changes immediately when sourcing in an already-running shell.
  (( ! $+functions[p10k] )) || p10k reload
}

# Restore options.
(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
