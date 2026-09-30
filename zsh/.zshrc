# ── bin ─────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ── Homebrew ────────────────────────────────────────────────────────────────
export PATH="/opt/homebrew/bin:$PATH"

# ── herdr auto-start ────────────────────────────────────────────────────────
# Abrir Ghostty entra directo en la sesion de herdr. Va aqui a proposito, antes de oh-my-zsh, nvm, gcloud y
# autojump: esta shell solo existe para lanzar el cliente, y cada panel de
# herdr abre la suya que si carga todo eso. Necesita el PATH de las dos lineas
# de arriba, que es donde vive el binario (~/.local/bin).
#
# Las guardas, en orden:
#   HERDR_ENV      ya estamos DENTRO de un panel: sin esto, cada panel nuevo
#                  intentaria abrir otro cliente. herdr ademas bloquea los
#                  lanzamientos anidados por diseno, pero mejor no llegar ahi.
#   CLAUDECODE     las shells que abre claude code tambien leen este .zshrc.
#   TERM_PROGRAM   solo Ghostty. Deja fuera cualquier otra terminal (la de
#                  VS Code, la de macOS) y las sesiones por ssh, que no
#                  propagan la variable: ahi herdr se arranca a mano.
#   HERDR_AUTOSTART=0  valvula de escape para una shell suelta.
#
# Sin `exec`: si herdr falla o te detachas con prefix+q te quedas en esta
# shell en vez de perder la ventana. Si prefieres que la ventana se cierre al
# detachar, cambia la linea por `exec herdr`.
if [[ -o interactive ]] \
  && [[ -t 1 ]] \
  && [[ -z "$HERDR_ENV" ]] \
  && [[ -z "$CLAUDECODE" ]] \
  && [[ "$TERM_PROGRAM" == "ghostty" ]] \
  && [[ "${HERDR_AUTOSTART:-1}" != "0" ]] \
  && command -v herdr &>/dev/null
then
  herdr
fi

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
#
# No se apoya en _wt_compose_project ni en $_WT_PROJECT_SCRIPT a proposito: el
# snapshot de shell de Claude Code replica esta funcion (con los alias ya
# expandidos) pero NO las variables ni las funciones con guion bajo delante, asi
# que ahi el helper no existe. Con la version anterior eso hacia fallar el 'if'
# y caia al else, lanzando el target con el '-p' que trae el Makefile, es decir
# contra el contenedor de OTRO worktree y sin decir nada: verde falso.
# Si no se puede deducir el proyecto, mejor abortar que adivinar.
make() {
  local root project script
  root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [ -z "$root" ] || ! grep -qE '^PROJECT_NAME[[:space:]]*:?=' "$root/Makefile" 2>/dev/null; then
    command make "$@"
    return
  fi

  script="${_WT_PROJECT_SCRIPT:-$HOME/dotfiles/worktrunk/wt-compose-project.sh}"
  if [ ! -x "$script" ]; then
    print -u2 "make: no encuentro '$script', no puedo deducir el proyecto de compose."
    print -u2 "      Este Makefile fija el proyecto con '-p', asi que sin deducirlo los targets"
    print -u2 "      irian contra el contenedor de otro worktree."
    print -u2 "      Pasalo a mano:  make $* PROJECT_NAME=<proyecto>"
    return 1
  fi

  if project=$("$script"); then
    command make PROJECT_NAME="$project" "$@"
  elif [ -n "${WT_SHARED_PROJECT:-}" ]; then
    # El script sale 1 en el checkout principal: ahi no hay nada que aislar, y
    # el proyecto correcto es el que diga la config, no el default del Makefile.
    command make PROJECT_NAME="$WT_SHARED_PROJECT" "$@"
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

# ── worktrunk: integracion con la shell ─────────────────────────────────────
# Define la funcion `wt` que envuelve al binario. El binario se comunica con la
# shell por ficheros de directiva (WORKTRUNK_DIRECTIVE_CD_FILE y _EXEC_FILE), o
# sea que sin esta funcion `wt switch` cambia de worktree pero no te deja dentro.
#
# Deja de ser opcional al pasar el plugin de herdr a open_mode = "tab" (ver
# herdr/worktrunk.toml): en ese modo el picker lanza `wt switch` en la shell
# interactiva del tab nuevo y depende de ella para el cd. En el modo workspace
# no hacia falta, porque ahi el plugin llama al binario desde su propio bash y
# con --no-cd.
#
# Va al final del fichero a proposito, DESPUES de oh-my-zsh: las completions de
# wt necesitan compinit hecho antes, y oh-my-zsh es el unico que lo hace aqui.
# Subir esta linea por encima las pierde en silencio, sin ningun error.
#
# La guarda de fuera no sobra aunque el script que se evalua traiga la suya:
# sin ella, `$(command wt config shell init zsh)` se ejecutaria igual en una
# maquina sin wt y soltaria el error en cada shell.
if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
