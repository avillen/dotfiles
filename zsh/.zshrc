# ── tmux auto-start (desactivado) ───────────────────────────────────────────
# Desactivado durante el PoC de herdr: si tmux arranca solo, se come el ctrl+b
# y herdr nunca ve su prefix. Para volver, descomenta el bloque.
# if command -v tmux &>/dev/null && [ -z "$TMUX" ]; then
#   tmux attach -t default 2>/dev/null || tmux new-session -s default
# fi


# ── bin ─────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ── Homebrew ────────────────────────────────────────────────────────────────
export PATH="/opt/homebrew/bin:$PATH"

# ── asdf ────────────────────────────────────────────────────────────────────
export ASDF_DATA_DIR="$HOME/.asdf"
export PATH="$ASDF_DATA_DIR/shims:$PATH"

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

# ── Config local (no versionada) ────────────────────────────────────────────
# Valores propios de esta maquina/organizacion: nombres de repos, proyecto de
# compose compartido, aliases del trabajo. Vive fuera del repo a proposito,
# porque dotfiles es publico. Plantilla en worktrunk/local.env.example.
DOTFILES_LOCAL_ENV="${DOTFILES_LOCAL_ENV:-$HOME/.config/dotfiles/local.env}"
[ -f "$DOTFILES_LOCAL_ENV" ] && source "$DOTFILES_LOCAL_ENV"

# ── Personal aliases ────────────────────────────────────────────────────────
[ -f "$HOME/.aliases" ] && source "$HOME/.aliases"

# ── Work aliases ────────────────────────────────────────────────────────────
# La ruta la pone WORK_ALIASES en el local.env de arriba.
[ -n "${WORK_ALIASES:-}" ] && [ -f "$WORK_ALIASES" ] && source "$WORK_ALIASES"

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

# ── Entorno Docker propio por worktree (worktrunk) ──────────────────────────
# Hay repos que fijan el proyecto de compose con '-p' en el Makefile y cuyos
# targets son 'docker compose exec'. El bind mount ..:/app se fija al CREAR el
# contenedor, asi que un 'make test' desde un worktree entra en el contenedor
# del checkout principal y testea el codigo de la rama base (verde falso).
#
# Las asignaciones de variables por linea de comandos SI pisan un ':=' del
# Makefile, asi que aqui le damos a cada worktree su propio proyecto de compose
# sin tocar ningun fichero del repo.
# El nombre del proyecto de compose lo deduce de git, no del layout de
# directorios, asi que vale tanto en el checkout principal como en cualquier
# worktree de worktrunk.
_WT_PROJECT_SCRIPT="$HOME/dotfiles/worktrunk/wt-compose-project.sh"

_wt_compose_project() {
  [ -x "$_WT_PROJECT_SCRIPT" ] || return 1
  "$_WT_PROJECT_SCRIPT"
}

# Solo inyecta en worktrees y solo si ese Makefile define PROJECT_NAME.
make() {
  local root project
  root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [ -n "$root" ] \
     && grep -qE '^PROJECT_NAME[[:space:]]*:?=' "$root/Makefile" 2>/dev/null \
     && project=$(_wt_compose_project); then
    command make PROJECT_NAME="$project" "$@"
  else
    command make "$@"
  fi
}

# A que codigo apunta el contenedor del proyecto de este directorio.
lmwhere() {
  local root project mounted cid
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "no estas en un repo git"; return 1
  }
  project=$(_wt_compose_project) || project="${WT_SHARED_PROJECT:-}"
  [ -z "$project" ] && {
    echo "no estas en un worktree enlazado y WT_SHARED_PROJECT no esta definido"
    return 1
  }
  cid=$(docker ps -q \
    --filter "label=com.docker.compose.project=$project" \
    --filter label=com.docker.compose.service=app 2>/dev/null | head -1)
  [ -z "$cid" ] && {
    echo "⚠️  proyecto '$project': contenedor 'app' parado  →  make env-start"
    return 1
  }
  mounted=$(docker inspect "$cid" \
    -f '{{range .Mounts}}{{if eq .Destination "/app"}}{{.Source}}{{end}}{{end}}' 2>/dev/null)
  if [ "$mounted" = "$root" ]; then
    echo "✅ proyecto '$project' apunta a este worktree"
  else
    echo "❌ proyecto '$project' apunta a: $mounted"
    echo "   estas en:                    $root"
    echo "   →  make env-start"
    return 1
  fi
}
