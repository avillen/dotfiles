###############################################################################
# fix - (https://github.com/asdf-vm/asdf/issues/266)

autoload -Uz compinit
compinit

. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

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

###############################################################################
# Boot commands

tmux has-session -t random
if [ $? != 0 ]
then
  tmux new-session -s random
fi
tmux attach -t random

touch todo && less todo

