# Migración de iTerm a Ghostty

## Objetivo

Sustituir iTerm por Ghostty como terminal de uso diario, usando la apariencia
nativa de Ghostty y manteniendo el acceso automático a Herdr. iTerm permanecerá
instalado como respaldo.

## Instalación y propiedad de la configuración

Ghostty se instalará como cask de Homebrew. La configuración versionada vivirá
en `ghostty/config`, y `install.sh` creará el enlace
`~/.config/ghostty/config -> <dotfiles>/ghostty/config`, siguiendo el patrón
existente para Neovim y Herdr. Una configuración local preexistente se
respaldará mediante la función `link` existente.

## Apariencia

`ghostty/config` no impondrá opciones visuales. Ghostty elegirá su tema, fuente,
tamaño, dimensiones y atajos nativos; el archivo permanece versionado para que
el instalador pueda provisionar una ruta estable donde añadir overrides después
de probar los defaults en el uso diario.

## Autoarranque de Herdr

El bloque de `zsh/.zshrc` reconocerá Ghostty mediante
`TERM_PROGRAM=ghostty` en lugar de `iTerm.app`. Mantendrá las guardas actuales
para shells interactivas, TTY, paneles Herdr, Claude Code y la válvula
`HERDR_AUTOSTART=0`.

Se añadirá una guarda para `$TMUX`, evitando abrir Herdr dentro de una sesión
tmux iniciada manualmente. Si Herdr falla o el usuario se separa, la shell de
Ghostty continuará disponible porque el lanzamiento seguirá sin `exec`.

## Validación y activación

La migración se considerará completa cuando:

1. Ghostty esté instalado y su ejecutable responda.
2. `~/.config/ghostty/config` apunte al archivo versionado.
3. Ghostty acepte la configuración sin errores y su salida efectiva coincida
   con la de un archivo de configuración vacío.
4. `zsh -n zsh/.zshrc` y `bash -n install.sh` pasen.
5. Una shell Ghostty interactiva cumpla las condiciones de autoarranque, y una
   shell dentro de tmux quede excluida.
6. La configuración existente de Herdr siga pasando `herdr config check`.

No se desinstalará iTerm, no se cambiarán asociaciones globales de macOS y no
se añadirán ajustes de Ghostty que no sean necesarios para reproducir el flujo
acordado.
