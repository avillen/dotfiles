###############################################################################
# Start with tmux

if [ -z "$TMUX" ]; then
  TERM=screen-256color-bce tmux new-session -A -s "dev"
fi

###############################################################################
# Variables

export GOROOT=/usr/local/go

export ZSH=$HOME/.oh-my-zsh
export PATH=/usr/local/bin:$PATH
export PATH="$HOME/.gem/bin:$PATH"
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:/$HOME/go/bin"
export PATH="$PATH:$GOROOT/bin"

export EDITOR=vim

# fzf
export FZF_DEFAULT_COMMAND='ag --nocolor --ignore _build -g ""'

# elixir
export ERL_AFLAGS="-kernel shell_history enabled"

# android
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

###############################################################################
# asdf

. $HOME/.asdf/asdf.sh

fpath=(${ASDF_DIR}/completions $fpath)
autoload -Uz compinit && compinit

###############################################################################
# Zsh

ZSH_THEME=lambder
plugins=(
  asdf
  elixir
  git
  golang
  kubectl
  rails
)
source $ZSH/oh-my-zsh.sh

###############################################################################
# Autojump
. /usr/share/autojump/autojump.sh

###############################################################################
# aliases

[[ -f ~/.aliases ]] && source ~/.aliases
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f /usr/local/bin/kubectl ] && source <(kubectl completion zsh)
[[ -s `brew --prefix`/etc/autojump.sh ]] && . `brew --prefix`/etc/autojump.sh


###############################################################################
# Boot commands

# touch todo && less todo

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/av/.sdkman"
[[ -s "/home/av/.sdkman/bin/sdkman-init.sh" ]] && source "/home/av/.sdkman/bin/sdkman-init.sh"


autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/terraform terraform
