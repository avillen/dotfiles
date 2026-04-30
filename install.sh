#!/usr/bin/env bash
# Dotfiles installer — creates symlinks from $HOME to dotfiles/
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$1" dst="$2"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "  [backup] $dst → $dst.bak"
    mv "$dst" "$dst.bak"
  fi
  ln -sf "$src" "$dst"
  echo "  [link]   $dst → $src"
}

echo "→ zsh"
link "$DOTFILES/zsh/.zshrc"   "$HOME/.zshrc"
link "$DOTFILES/zsh/.aliases" "$HOME/.aliases"

echo "→ git"
link "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"
mkdir -p "$HOME/.config/git"
link "$DOTFILES/git/coauthors" "$HOME/.config/git/coauthors"

echo "→ tmux"
link "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"

echo "→ workmux"
mkdir -p "$HOME/.config/workmux"
link "$DOTFILES/workmux/config.yaml" "$HOME/.config/workmux/config.yaml"

echo "→ nvim"
mkdir -p "$HOME/.config"
link "$DOTFILES/nvim" "$HOME/.config/nvim"

echo "Done."
