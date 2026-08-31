#!/bin/sh
# Hook post-start de worktrunk: prepara un entorno Docker propio del worktree.
#
# Ademas del entorno Docker, se encarga a mano de los symlinks de .venv y de
# la copia de .claude/settings.local.json: worktrunk eso lo resolveria con
# `wt step copy-ignored`, que copiaria los 557 MB de .venv.
#
# No hace falta lanzarlo en segundo plano: los hooks post-start de worktrunk ya
# corren asi, no bloquean la creacion del worktree.
#
# Por que hace falta: hay repos cuyo Makefile fija el proyecto de compose con
# '-p' y cuyos targets son 'docker compose exec'. Como el bind mount ..:/app se
# fija al CREAR el contenedor, un 'make test' desde un worktree entra en el
# contenedor del checkout principal y testea el codigo de la rama base.
set -eu

# Config local, fuera del repo. Ver worktrunk/local.env.example.
LOCAL_ENV="${DOTFILES_LOCAL_ENV:-$HOME/.config/dotfiles/local.env}"
[ -f "$LOCAL_ENV" ] && . "$LOCAL_ENV"

here=$(dirname "$0")
project=$("$here/wt-compose-project.sh") || {
  echo "wt-docker-setup: no estoy en un worktree enlazado, no hago nada"
  exit 0
}

# Estos dos guardas son los que acotan el hook: en un repo sin Makefile o sin
# compose no hace nada, asi que es inofensivo tenerlo configurado de mas.
[ -f Makefile ] || exit 0
[ -f docker/docker-compose.yml ] || exit 0

main=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")

# Symlink y no copia: son 557 MB y solo los lee el LSP.
for d in .venv .venv-observability; do
  [ -e "$main/$d" ] && [ ! -e "$d" ] && ln -s "$main/$d" "$d"
done

[ -f "$main/.claude/settings.local.json" ] && [ ! -f .claude/settings.local.json ] && {
  mkdir -p .claude
  cp "$main/.claude/settings.local.json" .claude/settings.local.json
}

# El worktree necesita su propia copia de la config de worktrunk: esta
# gitignorada, asi que un checkout limpio no la trae, y sin ella un `wt remove`
# lanzado desde dentro no encontraria el hook pre-remove.
[ -f "$main/.config/wt.toml" ] && [ ! -f .config/wt.toml ] && {
  mkdir -p .config
  cp "$main/.config/wt.toml" .config/wt.toml
}

# El override local esta gitignored, asi que es seguro generarlo por worktree.
# Se genera SIN 'ports:' a proposito: 8000 y 5432 los tiene publicados el
# checkout principal y el segundo entorno no arrancaria. Los tests no necesitan
# puertos publicados, la app habla con 'db' por la red de compose.
mkdir -p docker
cat > docker/docker-compose.local.yml <<'YAML'
# Generado por wt-docker-setup.sh (hook post-start de worktrunk).
# Igual que el override del checkout principal pero sin 'ports:', para que
# varios worktrees puedan tener su entorno arriba a la vez.
services:
  app:
    command: /app/scripts/app-command.sh --reload
    entrypoint:
      - /app/scripts/wait-for-it.sh
      - db:5432
      - --timeout=0
      - --strict
      - --
YAML

# Si el CLAUDE.md del repo hardcodea el proyecto compartido en su comando de
# pytest, eso no lo arregla ninguna variable de entorno: '-p' gana siempre, y
# desde un worktree ese comando entra en el contenedor del checkout principal.
# Lo denegamos SOLO en la copia del worktree. Los patrones llevan ' -f' /
# ' exec' a proposito: sin eso el prefijo 'docker compose -p <compartido>'
# casaria tambien con el proyecto legitimo '<compartido>-<handle>' y bloquearia
# el comando bueno.
if [ -z "${WT_SHARED_PROJECT:-}" ]; then
  echo "wt-docker-setup: WT_SHARED_PROJECT sin definir, no escribo reglas deny"
else
WT_SHARED_PROJECT="$WT_SHARED_PROJECT" \
python3 - <<'PY' || echo "wt-docker-setup: AVISO no he podido escribir las reglas deny"
import json, os

path = ".claude/settings.local.json"
shared = os.environ["WT_SHARED_PROJECT"]
patterns = [
    f"Bash(docker compose -p {shared} -f:*)",
    f"Bash(docker compose -p {shared} exec:*)",
    f"Bash(docker exec {shared}-app-1:*)",
]

settings = {}
if os.path.exists(path):
    with open(path) as f:
        settings = json.load(f)

deny = settings.setdefault("permissions", {}).setdefault("deny", [])
added = [p for p in patterns if p not in deny]
deny.extend(added)

os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")

print(f"wt-docker-setup: {len(added)} regla(s) deny anadidas a {path}")
PY
fi

echo "wt-docker-setup: arrancando entorno '$project'"
make PROJECT_NAME="$project" env-start || exit 1

i=0
while [ "$i" -lt 30 ]; do
  make PROJECT_NAME="$project" migrate && exit 0
  i=$((i + 1))
  sleep 2
done
echo "wt-docker-setup: las migraciones no han pasado tras 30 intentos" >&2
exit 1
