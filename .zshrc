###############################################################################
# Paths

export ZSH=$HOME/.oh-my-zsh
export PATH=/usr/local/bin:$PATH
export PATH="$HOME/code/devkit/bin:$PATH"

###############################################################################
# Zsh

ZSH_THEME=geoffgarside
source $ZSH/oh-my-zsh.sh

plugins=(git asdf)

###############################################################################
# asdf

. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

###############################################################################
# aliases

[[ -f ~/.aliases ]] && source ~/.aliases
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
