if [[ ! "$PATH" =~ ".*$HOME/.local/bin.*" ]]; then
    export PATH=~/.local/bin:$PATH
fi

setopt histignorealldups sharehistory

bindkey -v

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

# Load menu selection module
zmodload zsh/complist

# Configure completion to show a menu and allow cycling
zstyle ':completion:*' menu yes select=1

# Optional: allow arrow keys to move in the menu
bindkey -M menuselect '^[[A' up-line-or-history    # Up arrow
bindkey -M menuselect '^[[B' down-line-or-history  # Down arrow
bindkey -M menuselect '^[[C' forward-char          # Right arrow
bindkey -M menuselect '^[[D' backward-char         # Left arrow

eval "$(dircolors)"
if [[ -n $LS_COLORS ]]; then
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi

# Code copied from comments in https://github.com/starship/starship/pull/4205
zle-line-init() {
  emulate -L zsh

  [[ $CONTEXT == start ]] || return 0

  while true; do
    zle .recursive-edit
    local -i ret=$?
    [[ $ret == 0 && $KEYS == $'\4' ]] || break
    [[ -o ignore_eof ]] || exit 0
  done

  local saved_prompt=$PROMPT
  local saved_rprompt=$RPROMPT

  # Set prompt value from character module
  PROMPT="$(starship module -s ${STARSHIP_CMD_STATUS:-0} character)"
  RPROMPT=''
  zle .reset-prompt
  PROMPT=$saved_prompt
  RPROMPT=$saved_rprompt

  if (( ret )); then
    zle .send-break
  else
    zle .accept-line
  fi
  return ret
}
zle -N zle-line-init

eval "$(starship init zsh)"

source ~/.zsh-plugins/omz/extract.plugin.zsh
source ~/.zsh-plugins/omz/command-not-found.plugin.zsh
autoload -U colors && colors
source ~/.zsh-plugins/omz/colored-man-pages.plugin.zsh
source ~/.zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


alias rm='trash-put'
alias ls='eza'
alias l='eza'
alias ll='eza -lg'
alias la='eza -a'
alias bat='bat --theme gruvbox-dark'
alias lg='lazygit'
alias rg='rg --column --no-heading --smart-case --color=always'
alias v='nvim --server $NVIM --remote'
alias vi='nvim --server $NVIM --remote'
alias vim='nvim --server $NVIM --remote'
alias vd='nvim -d'
export VISUAL=nvim
export EDITOR=nvim
set -o vi

[[ $TMUX == "" ]] && export TERM="xterm-256color"

# alias cp -- Show progress while file is copying and make backup
# -p - preserve permissions
# -o - preserve owner
# -g - preserve group
# -l - preserve symlinks
# -h - output in human-readable format
# --progress - display progress
# -b - instead of just overwriting an existing file, save the original
# -r - recurse into directories
# --backup-dir=/tmp/rsync - move backup copies to "/tmp/rsync"
# -e /dev/null - only work on local files
alias cp="rsync -poglhbr --backup-dir=/tmp/rsync -e /dev/null --info=progress2 "

dexec() {
    docker exec -it $1 bash -c "stty cols $COLUMNS rows $LINES && bash";
}

export CMAKE_EXPORT_COMPILE_COMMANDS=ON
if [[ `uname` == "Linux" && `lsb_release -i` =~ ".*Debian" ]]; then
    export DEBUGINFOD_URLS="https://debuginfod.debian.net"
fi

[[ ! -f ~/.cargo/env ]] || source ~/.cargo/env

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
