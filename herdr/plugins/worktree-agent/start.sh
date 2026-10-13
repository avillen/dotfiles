#!/usr/bin/env bash
# Arranca claude en el panel enfocado.
#
# Lo invoca la accion del plugin (prefix+alt+c), con el workspace y el panel
# enfocados en $HERDR_PLUGIN_CONTEXT_JSON. No parte paneles ni monta ningun
# layout.
set -uo pipefail

# herdr lanza los comandos de plugin con un PATH minimo, donde jq no esta.
# claude no hace falta aqui: lo lanza la shell interactiva del panel.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:${PATH:-}"

H="${HERDR_BIN_PATH:-herdr}"

ctx="${HERDR_PLUGIN_CONTEXT_JSON:-}"

give_up() {
  printf 'worktree-agent: %s\n' "$1" >&2
  exit 1
}

ws=$(printf '%s' "$ctx" | jq -r '.workspace_id // empty' 2>/dev/null)
target=$(printf '%s' "$ctx" | jq -r '.focused_pane_id // empty' 2>/dev/null)

[ -n "$ws" ] || give_up "sin workspace en el contexto"
[ -n "$target" ] || give_up "sin panel enfocado en el contexto"

# Una lista que falla o no se entiende no puede pasar por "aqui no hay nada":
# arrancaria un segundo claude.
panes=$("$H" pane list --workspace "$ws" 2>/dev/null) \
  && [ -n "$panes" ] \
  && printf '%s' "$panes" | jq -e '.result.panes' >/dev/null 2>&1 \
  || give_up "no puedo leer los paneles de $ws"

# Idempotencia. Se mira el campo `agent` que trae cada panel de `pane list`
# (herdr >= 0.8): un panel de reviewr o una shell pelada no lo llevan, solo lo
# lleva un agente reconocido.
#
# Solo el panel destino, no el space: un space de investigacion lleva un tab por
# repo y quiere su claude en cada uno, asi que "ya hay un agente en el space" no
# puede impedir arrancar el segundo.
printf '%s' "$panes" | jq -e --arg p "$target" \
  'any(.result.panes[]; .pane_id == $p and .agent != null)' >/dev/null 2>&1 && exit 0

# El panel lo elige el usuario, asi que puede no estar libre: si tiene algo en
# primer plano, `pane run` escribiria en ese programa (el panel de reviewr, un
# test corriendo) en vez de en una shell. Un panel en su prompt tiene el grupo
# de procesos en primer plano == su propia shell.
info=$("$H" pane process-info --pane "$target" 2>/dev/null) \
  || give_up "no puedo leer el estado de $target"
printf '%s' "$info" | jq -e \
  '.result.process_info | .foreground_process_group_id == .shell_pid' >/dev/null 2>&1 \
  || give_up "$target esta ocupado: dejalo en su prompt o enfoca otro panel"

# `pane run` escribe el comando en la shell interactiva del panel. El agente lo
# reconoce herdr solo, via la integracion oficial de claude.
"$H" pane run "$target" claude >/dev/null 2>&1 \
  || give_up "no he podido lanzar claude en $target"

printf 'worktree-agent: claude en %s\n' "$target"
