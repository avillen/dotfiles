#!/usr/bin/env bash
# Arranca claude en el panel de un worktree recien abierto.
#
# Se ejecuta de dos formas (ver herdr-plugin.toml):
#
#   evento    worktree.created / worktree.opened, con el payload en
#             $HERDR_PLUGIN_EVENT_JSON. Es el camino normal: lo dispara el
#             `herdr worktree open` del plugin worktrunk.
#   accion    invocada a mano (prefix+alt+c), con el workspace enfocado en
#             $HERDR_PLUGIN_CONTEXT_JSON.
#
# No parte paneles ni monta ningun layout: el panel raiz del workspace ya nace
# con el cwd del worktree, que es la gracia de `herdr worktree open`.
set -uo pipefail

# herdr lanza los comandos de plugin con un PATH minimo, donde jq no esta.
# claude no hace falta aqui: lo lanza la shell interactiva del panel.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:${PATH:-}"

H="${HERDR_BIN_PATH:-herdr}"

ev="${HERDR_PLUGIN_EVENT_JSON:-}"
ctx="${HERDR_PLUGIN_CONTEXT_JSON:-}"

# Un evento que no se puede atender no es un error del usuario: se calla y deja
# el motivo en el log del plugin (`herdr plugin log list --plugin worktree-agent`).
# La accion, en cambio, avisa en su panel.
give_up() {
  printf 'worktree-agent: %s\n' "$1" >&2
  [ -n "$ev" ] && exit 0
  exit 1
}

if [ -n "$ev" ]; then
  # `worktree.opened` salta tambien al volver a un worktree cuyo workspace ya
  # esta vivo. Eso es un cambio de foco, no un nacimiento: ahi ya hay un claude,
  # o el usuario lo ha cerrado y no hay que resucitarselo.
  printf '%s' "$ev" | jq -e '.data.already_open == true' >/dev/null 2>&1 && exit 0

  ws=$(printf '%s' "$ev" | jq -r '.data.workspace.workspace_id // .data.worktree.open_workspace_id // empty' 2>/dev/null)
  # Los eventos llegan sin panel enfocado.
  focused=""
else
  ws=$(printf '%s' "$ctx" | jq -r '.workspace_id // empty' 2>/dev/null)
  focused=$(printf '%s' "$ctx" | jq -r '.focused_pane_id // empty' 2>/dev/null)
fi

[ -n "$ws" ] || give_up "sin workspace en el contexto"

# Una sola foto de los paneles para todo. Una lista que falla o no se entiende
# no puede pasar por "aqui no hay nada": arrancaria un segundo claude.
panes=$("$H" pane list --workspace "$ws" 2>/dev/null) \
  && [ -n "$panes" ] \
  && printf '%s' "$panes" | jq -e '.result.panes' >/dev/null 2>&1 \
  || give_up "no puedo leer los paneles de $ws"

# Idempotencia: si ya hay un agente en el workspace, no se toca nada.
#
# Se mira el campo `agent` que trae cada panel de `pane list` (herdr >= 0.8) y
# NO el numero de paneles: reviewr abre el suyo con el MISMO evento, asi que
# contar paneles seria una carrera. Un panel de reviewr o una shell pelada no
# llevan `agent`, solo lo lleva un agente reconocido.
printf '%s' "$panes" | jq -e 'any(.result.panes[]; .agent != null)' >/dev/null 2>&1 && exit 0

# El panel donde va claude. En un workspace recien nacido hay uno solo y ya
# tiene el cwd del worktree.
#
# Se elige por numero de panel y no por el orden de la lista: es estable, y en
# un workspace nuevo el panel raiz es siempre el mas bajo, gane la carrera con
# reviewr quien la gane.
target=$focused
if [ -z "$target" ]; then
  target=$(printf '%s' "$panes" | jq -r '
    [.result.panes[] | select(.pane_id | test("^[^:]+:p[0-9]+$"))]
    | sort_by(.pane_id | split(":")[1][1:] | tonumber)
    | .[0].pane_id // empty' 2>/dev/null)
fi
[ -n "$target" ] || target=$(printf '%s' "$panes" | jq -r '.result.panes[0].pane_id // empty' 2>/dev/null)
[ -n "$target" ] || give_up "el workspace $ws no tiene paneles"

# `pane run` escribe el comando en la shell interactiva del panel y la terminal
# lo bufferea hasta que acaba de cargar, asi que no hay que esperar al prompt:
# eso es lo que obligaba al bucle de reintentos de `agent start` del viejo `hd`.
# El agente lo reconoce herdr solo, via la integracion oficial de claude.
"$H" pane run "$target" claude >/dev/null 2>&1 \
  || give_up "no he podido lanzar claude en $target"

printf 'worktree-agent: claude en %s\n' "$target"
