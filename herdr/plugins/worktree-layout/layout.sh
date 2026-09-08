#!/usr/bin/env bash
# Layout de trabajo de un worktree: claude arriba, una terminal abajo.
#
#   +----------------------+
#   |        claude        |   75%
#   +----------------------+
#   |         zsh          |   25%
#   +----------------------+
#
# Se ejecuta de dos formas (ver herdr-plugin.toml):
#
#   evento    worktree.created / worktree.opened, con el payload en
#             $HERDR_PLUGIN_EVENT_JSON. Es el camino normal: lo dispara el
#             `herdr worktree open` del plugin worktrunk.
#   accion    invocada a mano (prefix+alt+l), con el workspace enfocado en
#             $HERDR_PLUGIN_CONTEXT_JSON.
#
# Sin panel de nvim: lo cubre el sidebar de herdr-nvim (prefix+e). Y sin panel
# de reviewr: ese lo abre reviewr por su cuenta, con estos mismos dos eventos
# (split a la derecha, sin robar el foco).
set -uo pipefail

# herdr lanza los comandos de plugin con un PATH minimo, donde jq no esta.
# claude no hace falta aqui: lo lanza la shell interactiva del panel.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:${PATH:-}"

H="${HERDR_BIN_PATH:-herdr}"

# La fraccion que se queda el panel que PARTIMOS, o sea el de claude; la
# terminal se lleva el resto. herdr no documenta el sentido de --ratio.
AGENT_RATIO=0.75

ev="${HERDR_PLUGIN_EVENT_JSON:-}"
ctx="${HERDR_PLUGIN_CONTEXT_JSON:-}"

# Un evento que no se puede atender no es un error del usuario: se calla y deja
# el motivo en el log del plugin (`herdr plugin log list --plugin worktree-layout`).
# La accion, en cambio, avisa en su panel.
give_up() {
  printf 'worktree-layout: %s\n' "$1" >&2
  [ -n "$ev" ] && exit 0
  exit 1
}

if [ -n "$ev" ]; then
  # `worktree.opened` salta tambien al volver a un worktree cuyo workspace ya
  # esta vivo. Eso es un cambio de foco, no un nacimiento: el layout ya esta
  # puesto, o el usuario lo ha deshecho y no hay que rehacerselo.
  printf '%s' "$ev" | jq -e '.data.already_open == true' >/dev/null 2>&1 && exit 0

  ws=$(printf '%s' "$ev" | jq -r '.data.workspace.workspace_id // .data.worktree.open_workspace_id // empty' 2>/dev/null)
  cwd=$(printf '%s' "$ev" | jq -r '.data.workspace.worktree.checkout_path // .data.worktree.path // empty' 2>/dev/null)
  # Los eventos llegan sin panel enfocado.
  focused=""
else
  ws=$(printf '%s' "$ctx" | jq -r '.workspace_id // empty' 2>/dev/null)
  cwd=$(printf '%s' "$ctx" | jq -r '.worktree.checkout_path // .focused_pane_cwd // empty' 2>/dev/null)
  focused=$(printf '%s' "$ctx" | jq -r '.focused_pane_id // empty' 2>/dev/null)
fi

[ -n "$ws" ] || give_up "sin workspace en el contexto"

# Una sola foto de los paneles para todo. Una lista que falla o no se entiende
# no puede pasar por "aqui no hay nada": duplicaria el layout.
panes=$("$H" pane list --workspace "$ws" 2>/dev/null) \
  && [ -n "$panes" ] \
  && printf '%s' "$panes" | jq -e '.result.panes' >/dev/null 2>&1 \
  || give_up "no puedo leer los paneles de $ws"

# Idempotencia: si ya hay un agente en el workspace, el layout esta hecho.
#
# Se mira el campo `agent` que trae cada panel de `pane list` (herdr >= 0.8) y
# NO el numero de paneles: reviewr abre el suyo con el MISMO evento, asi que
# contar paneles seria una carrera. Un panel de reviewr o una shell pelada no
# llevan `agent`, solo lo lleva un agente reconocido.
printf '%s' "$panes" | jq -e 'any(.result.panes[]; .agent != null)' >/dev/null 2>&1 && exit 0

# El panel donde va claude. En un workspace recien nacido hay uno solo y ya
# tiene el cwd del worktree, que es la gracia de `worktree open`: no hay que
# crear paneles nuevos para cambiarles el directorio.
#
# Se elige por numero de panel y no por el orden de la lista: es estable, y en
# un workspace nuevo el panel raiz es siempre el mas bajo, gane la carrera
# quien la gane.
target=$focused
if [ -z "$target" ]; then
  target=$(printf '%s' "$panes" | jq -r '
    [.result.panes[] | select(.pane_id | test("^[^:]+:p[0-9]+$"))]
    | sort_by(.pane_id | split(":")[1][1:] | tonumber)
    | .[0].pane_id // empty' 2>/dev/null)
fi
[ -n "$target" ] || target=$(printf '%s' "$panes" | jq -r '.result.panes[0].pane_id // empty' 2>/dev/null)
[ -n "$target" ] || give_up "el workspace $ws no tiene paneles"

# Si el payload no trajo ruta, la del propio panel sirve: ya esta en el worktree.
if [ -z "$cwd" ]; then
  cwd=$(printf '%s' "$panes" | jq -r --arg p "$target" \
    'first(.result.panes[] | select(.pane_id == $p) | .cwd // empty)' 2>/dev/null)
fi
[ -n "$cwd" ] || give_up "no se en que directorio esta $target"

# Primero el split y luego claude: asi el TUI arranca ya con su tamano final.
"$H" pane split "$target" --direction down --ratio "$AGENT_RATIO" \
  --cwd "$cwd" --no-focus >/dev/null 2>&1 \
  || give_up "no he podido partir $target"

# `pane run` escribe el comando en la shell interactiva del panel y la terminal
# lo bufferea hasta que acaba de cargar, asi que no hay que esperar al prompt:
# eso es lo que obligaba al bucle de reintentos de `agent start` del viejo `hd`.
# El agente lo reconoce herdr solo, via la integracion oficial de claude.
"$H" pane run "$target" claude >/dev/null 2>&1 \
  || give_up "no he podido lanzar claude en $target"

printf 'worktree-layout: claude en %s (%s)\n' "$target" "$cwd"
