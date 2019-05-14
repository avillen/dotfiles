###############################################################################
# Paths

export ZSH=$HOME/.oh-my-zsh
export PATH=/usr/local/bin:$PATH
export PATH="$HOME/code/devkit/bin:$PATH"

###############################################################################
# asdf

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
