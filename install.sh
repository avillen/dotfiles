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
  ln -sfn "$src" "$dst"
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

echo "→ ghostty"
mkdir -p "$HOME/.config/ghostty"
link "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"

echo "→ herdr"
mkdir -p "$HOME/.config/herdr"
link "$DOTFILES/herdr/config.toml" "$HOME/.config/herdr/config.toml"

# Config del plugin reviewr: fichero suyo, con su propia ruta por plugin_id.
mkdir -p "$HOME/.config/herdr/plugins/config/persiyanov.reviewr"
link "$DOTFILES/herdr/reviewr.toml" \
  "$HOME/.config/herdr/plugins/config/persiyanov.reviewr/config.toml"

mkdir -p "$HOME/.local/bin"
link "$DOTFILES/herdr/hd" "$HOME/.local/bin/hd"

echo "→ config local"
# No es un symlink: lleva valores propios de la maquina y el repo es publico.
mkdir -p "$HOME/.config/dotfiles"
if [ -f "$HOME/.config/dotfiles/local.env" ]; then
  echo "  [skip]   $HOME/.config/dotfiles/local.env ya existe"
else
  cp "$DOTFILES/worktrunk/local.env.example" "$HOME/.config/dotfiles/local.env"
  echo "  [nuevo]  $HOME/.config/dotfiles/local.env — rellenalo"
fi

echo "→ nvim"
mkdir -p "$HOME/.config"
link "$DOTFILES/nvim" "$HOME/.config/nvim"

echo "Done."
