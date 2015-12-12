# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="agnoster"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Uncomment this to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how often before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want to disable command autocorrection
# DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much,
# much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment following line if you want to  shown in the command execution time stamp
# in the history command output. The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|
# yyyy-mm-dd
# HIST_STAMPS="mm/dd/yyyy"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)

if [[ $(uname) == "Darwin" ]]; then
	export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
	export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
fi

[[ $TMUX == "" ]] && export TERM="xterm-256color"

eval `dircolors ~/.dir_colors`
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;016m\E[48;5;220m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

ZSH_TMUX_AUTOSTART=true
ZSH_TMUX_AUTOQUIT=false

plugins=(git tmux extract command-not-found)

source $ZSH/oh-my-zsh.sh

# User configuration
alias rm='trash-put'
alias ls='ls --color -F'
alias ll='ls -l'
alias la='ls -A'
alias l='ls'
if [[ $(uname) == "Darwin" ]]; then
	alias v='mvim -v'
	alias vi='mvim -v'
	alias vim='mvim -v'
	alias vd='mvimdiff -v'
else
	alias v='vim'
	alias vi='vim'
	alias vd='vimdiff'
fi
set -o vi
export VISUAL=vim
export EDITOR=vim

# alias cp -- Show progress while file is copying and make backup
# -p - preserve permissions
# -o - preserve owner
# -g - preserve group
# -h - output in human-readable format
# --progress - display progress
# -b - instead of just overwriting an existing file, save the original
# -r - recurse into directories
# --backup-dir=/tmp/rsync - move backup copies to "/tmp/rsync"
# -e /dev/null - only work on local files
alias cp="rsync -poghbr --backup-dir=/tmp/rsync -e /dev/null --progress "

export DEFAULT_USER="xin"

export PATH=~/bin:$PATH

if [[ $(uname) == "Darwin" ]]; then
	fpath=(/usr/local/share/zsh-completions $fpath)
fi
