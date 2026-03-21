# ── tmux auto-start ─────────────────────────────────────────────────────────
if command -v tmux &>/dev/null && [ -z "$TMUX" ]; then
  tmux attach -t default 2>/dev/null || tmux new-session -s default
fi

# ── Homebrew ────────────────────────────────────────────────────────────────
export PATH="/opt/homebrew/bin:$PATH"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="lambder"

plugins=(
    git
    kubectl
)

source $ZSH/oh-my-zsh.sh

# ── Personal aliases ────────────────────────────────────────────────────────
[ -f "$HOME/.aliases" ] && source "$HOME/.aliases"

# ── Google Cloud SDK ────────────────────────────────────────────────────────
[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ] && \
  source "$HOME/google-cloud-sdk/path.zsh.inc"
[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ] && \
  source "$HOME/google-cloud-sdk/completion.zsh.inc"

# ── Autojump ────────────────────────────────────────────────────────────────
[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh
