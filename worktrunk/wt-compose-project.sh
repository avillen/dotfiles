#!/bin/sh
# Nombre de proyecto Docker Compose aislado para el worktree actual.
#
# El nombre se deduce de git, no del layout de directorios, asi que funciona
# con cualquier ubicacion del worktree:
#
#   repo:  basename del checkout PRINCIPAL (via --git-common-dir)
#   handle: la rama del worktree actual
#
#   <repo> + rama <rama>  ->  <repo>-<rama>
#
# WT_REPO_PREFIX / WT_REPO_SUFFIX recortan el prefijo y el sufijo de la
# convencion de nombres de repos que uses (ver worktrunk/local.env.example).
#
# Sale 1 sin imprimir nada si no estamos en un worktree enlazado, para que en
# el checkout principal el comportamiento por defecto no cambie.
set -eu

# Config local, fuera del repo. Ver worktrunk/local.env.example.
LOCAL_ENV="${DOTFILES_LOCAL_ENV:-$HOME/.config/dotfiles/local.env}"
[ -f "$LOCAL_ENV" ] && . "$LOCAL_ENV"

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 1

# En un worktree enlazado, --git-common-dir apunta al .git del principal.
common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || exit 1
main=$(dirname "$common")

# En el checkout principal, common es su propio .git: no hay que aislar nada.
[ "$main" = "$(git rev-parse --show-toplevel)" ] && exit 1

# Sin prefijo/sufijo configurados no se recorta nada: el basename entero vale
# igual, solo sale un nombre mas largo.
repo=$(basename "$main")
repo=${repo#${WT_REPO_PREFIX:-}}
repo=${repo%${WT_REPO_SUFFIX:-}}

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || exit 1
[ "$branch" = "HEAD" ] && branch=$(basename "$(git rev-parse --show-toplevel)")

# Los nombres de proyecto de compose solo admiten [a-z0-9_-].
printf '%s-%s' "$repo" "$branch" \
  | tr 'A-Z' 'a-z' \
  | tr -c 'a-z0-9_-' '-'
printf '\n'
