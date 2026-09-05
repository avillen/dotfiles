# Migración de iTerm a Ghostty

## Objetivo

Sustituir iTerm por Ghostty como terminal de uso diario, manteniendo la
apariencia actual y el acceso automático a Herdr. iTerm permanecerá instalado
como respaldo.

## Instalación y propiedad de la configuración

Ghostty se instalará como cask de Homebrew. La configuración versionada vivirá
en `ghostty/config`, y `install.sh` creará el enlace
`~/.config/ghostty/config -> <dotfiles>/ghostty/config`, siguiendo el patrón
existente para Neovim y Herdr. Una configuración local preexistente se
respaldará mediante la función `link` existente.

## Apariencia

Ghostty usará `JetBrainsMono Nerd Font Mono` a 13 puntos. La Nerd Font mantiene
los glifos usados por Neovim y 13 puntos mejora la lectura frente a los 12 de
iTerm sin alterar la densidad de forma drástica.

La ventana inicial será de 80 columnas por 25 filas, sin transparencia. Se
trasladará exactamente la paleta sRGB del perfil predeterminado de iTerm:

| Color | Valor |
|---|---|
| Fondo | `#fafafa` |
| Texto | `#101010` |
| Cursor | `#000000` |
| Texto bajo el cursor | `#ffffff` |
| Selección | `#b3d7ff` |
| Texto seleccionado | `#000000` |
| ANSI 0–7 | `#14191e`, `#b43c2a`, `#00c200`, `#c7c400`, `#2744c7`, `#c040be`, `#00c5c7`, `#c7c7c7` |
| ANSI 8–15 | `#686868`, `#dd7975`, `#58e790`, `#ece100`, `#a7abf2`, `#e17ee1`, `#60fdff`, `#ffffff` |

Se conservarán los atajos nativos de Ghostty. Herdr ya proporciona la
navegación, paneles y espacios de trabajo principales, por lo que no se
convertirán los atajos específicos de iTerm.

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
3. Ghostty acepte toda la configuración sin errores y reconozca la fuente.
4. `zsh -n zsh/.zshrc` y `bash -n install.sh` pasen.
5. Una shell Ghostty interactiva cumpla las condiciones de autoarranque, y una
   shell dentro de tmux quede excluida.
6. La configuración existente de Herdr siga pasando `herdr config check`.

No se desinstalará iTerm, no se cambiarán asociaciones globales de macOS y no
se añadirán ajustes de Ghostty que no sean necesarios para reproducir el flujo
acordado.
