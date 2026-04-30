# ── tmux auto-start ─────────────────────────────────────────────────────────
if command -v tmux &>/dev/null && [ -z "$TMUX" ]; then
  tmux attach -t default 2>/dev/null || tmux new-session -s default
fi

# ── Homebrew ────────────────────────────────────────────────────────────────
export PATH="/opt/homebrew/bin:$PATH"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Path to your nvm installation.
export NVM_DIR="$HOME/.nvm" && [ -s "$(brew --prefix nvm)/nvm.sh" ] && . "$(brew --prefix nvm)/nvm.sh"

ZSH_THEME="lambder"

plugins=(
    git
    kubectl
)

source $ZSH/oh-my-zsh.sh

# ── Personal aliases ────────────────────────────────────────────────────────
[ -f "$HOME/.aliases" ] && source "$HOME/.aliases"

# ── Work aliases ────────────────────────────────────────────────────────────
[ -f "$HOME/code/tools/mo.tools.devtools/.bash_aliases" ] && \
source "$HOME/code/tools/mo.tools.devtools/.bash_aliases"

# ── Google Cloud SDK ────────────────────────────────────────────────────────
[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ] && \
  source "$HOME/google-cloud-sdk/path.zsh.inc"
[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ] && \
  source "$HOME/google-cloud-sdk/completion.zsh.inc"

# ── Autojump ────────────────────────────────────────────────────────────────
[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh

# ── Tmux window name = project (git root or current dir) ────────────────────
_tmux_set_window_name() {
  [ -z "$TMUX" ] && return
  local name
  name=$(git rev-parse --show-toplevel 2>/dev/null)
  name=${name:+$(basename "$name")}
  name=${name:-$(basename "$PWD")}
  tmux rename-window "$name"
}
chpwd_functions+=(_tmux_set_window_name)
_tmux_set_window_name
