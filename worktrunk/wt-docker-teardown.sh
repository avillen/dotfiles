#!/bin/sh
# Hook pre-remove de worktrunk: destruye el entorno Docker propio del worktree.
#
# worktrunk ejecuta pre-remove ANTES de borrar el checkout y con acceso a sus
# ficheros, que es justo lo que necesita `docker compose down`.
#
# Sin esto quedan contenedores parados y volumenes pgdata huerfanos por cada
# worktree borrado, sin nada que los referencie.
set -eu

here=$(dirname "$0")
project=$("$here/wt-compose-project.sh") || exit 0

[ -f docker/docker-compose.yml ] || exit 0

echo "wt-docker-teardown: destruyendo entorno '$project'"
docker compose -p "$project" \
  -f docker/docker-compose.yml \
  -f docker/docker-compose.local.yml \
  down -v --remove-orphans 2>&1 || true
