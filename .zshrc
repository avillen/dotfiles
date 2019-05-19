###############################################################################
# Start with tmux

if [ -z "$TMUX" ]; then
  tmux new-session -A -s "$USER"
fi

###############################################################################
# Variables

export ZSH=$HOME/.oh-my-zsh
export PATH=/usr/local/bin:$PATH
export PATH="$HOME/code/devkit/bin:$PATH"
export PATH="$HOME/.gem/bin:$PATH"
export EDITOR=vim

###############################################################################
# asdf

# fix - (https://github.com/asdf-vm/asdf/issues/266)
autoload -Uz compinit
compinit

. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

###############################################################################
# aliases

[[ -f ~/.aliases ]] && source ~/.aliases
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

###############################################################################
# Zsh

ZSH_THEME=geoffgarside
plugins=(git asdf)
source $ZSH/oh-my-zsh.sh

###############################################################################
# Boot commands

# touch todo && less todo

