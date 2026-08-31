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

echo "→ herdr"
mkdir -p "$HOME/.config/herdr"
link "$DOTFILES/herdr/config.toml" "$HOME/.config/herdr/config.toml"

mkdir -p "$HOME/.local/bin"
link "$DOTFILES/herdr/hd" "$HOME/.local/bin/hd"

echo "→ nvim"
mkdir -p "$HOME/.config"
link "$DOTFILES/nvim" "$HOME/.config/nvim"

echo "Done."
