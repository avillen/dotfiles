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
  # -n es imprescindible en los enlaces a directorio (nvim): sin el, cuando
  # $dst ya es un symlink a directorio, ln resuelve el enlace y crea el nuevo
  # DENTRO ($DOTFILES/nvim/nvim) en vez de reemplazarlo. Con -n trata el
  # symlink como fichero y lo sobreescribe, que es lo que se quiere al
  # reejecutar el instalador. Lo cubre tests/test_install.sh.
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

# Plugin propio: arrancar claude al abrir un worktree. Va con `plugin link` y
# no con `plugin install` porque vive en este repo. herdr cachea el manifest al
# enlazar, asi que se re-enlaza siempre: si no, un cambio en herdr-plugin.toml
# no se cogeria nunca.
#
# Es el unico paso del instalador que NO es un symlink en $HOME: toca el estado
# global de herdr (su servidor vivo, via socket). Por eso se salta cuando el
# repo no esta dentro de $HOME, que es como corre tests/test_install.sh: desde
# una copia en /tmp y con HOME falso. Sin la guarda, ese test dejaria el plugin
# de verdad apuntando a un directorio que borra al terminar — el socket llega
# por HERDR_SOCKET_PATH, que esta exportado en cada panel. Y de paso, ejecutar
# install.sh desde un worktree de dotfiles tampoco secuestra el plugin.
case "$DOTFILES" in
  "$HOME"/*)
    if command -v herdr > /dev/null 2>&1; then
      herdr plugin unlink worktree-agent > /dev/null 2>&1
      if herdr plugin link "$DOTFILES/herdr/plugins/worktree-agent" > /dev/null; then
        echo "  [plugin] worktree-agent"
      else
        echo "  [error]  no he podido enlazar el plugin worktree-agent" >&2
      fi
    else
      echo "  [skip]   herdr no esta instalado: plugin worktree-agent sin enlazar"
    fi
    ;;
  *)
    echo "  [skip]   $DOTFILES esta fuera de \$HOME: plugin worktree-agent sin enlazar"
    ;;
esac

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
