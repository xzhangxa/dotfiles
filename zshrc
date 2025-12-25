# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
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

if [[ ! "$PATH" =~ ".*$HOME/.local/bin.*" ]]; then
    export PATH=~/.local/bin:$PATH
fi
[[ ! -f ~/.cargo/env ]] || source ~/.cargo/env

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"

source ~/.zsh-plugins/powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export POWERLEVEL9K_DISABLE_GITSTATUS=true

source ~/.zsh-plugins/omz/extract.plugin.zsh
source ~/.zsh-plugins/omz/command-not-found.plugin.zsh
autoload -U colors && colors
source ~/.zsh-plugins/omz/colored-man-pages.plugin.zsh
source ~/.zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
