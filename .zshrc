###############################################################################
# Start with tmux

if [ -z "$TMUX" ]; then
  tmux new-session -A -s "dev"
fi

###############################################################################
# Variables

export ZSH=$HOME/.oh-my-zsh
export PATH=/usr/local/bin:$PATH
export PATH="$HOME/.gem/bin:$PATH"
export PATH="$PATH:$HOME/development/flutter/bin"

exportEDITOR=vim

# elixir
export ERL_AFLAGS="-kernel shell_history enabled"

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
plugins=(
  asdf
  elixir
  git
)
source $ZSH/oh-my-zsh.sh

###############################################################################
# Autojump
. /usr/share/autojump/autojump.sh

###############################################################################
# aliases

[[ -f ~/.aliases ]] && source ~/.aliases
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

###############################################################################
# Boot commands

# touch todo && less todo

