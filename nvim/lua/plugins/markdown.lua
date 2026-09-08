return {
  -- Renderizado de markdown dentro del propio buffer
  --
  -- No es un preview en el navegador ni una ventana aparte: repinta el buffer
  -- que estas editando. Los marcadores (#, *, `, |) se ocultan via conceal y
  -- en su sitio aparecen cabeceras con fondo, vinetas, checkboxes y tablas
  -- alineadas. Sigue siendo el fichero de verdad: escribes markdown normal.
  --
  -- anti_conceal (default, no se toca) revela la sintaxis cruda solo en la
  -- linea donde esta el cursor, que es lo que hace que se pueda editar sin
  -- pelearse con el conceal.
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      -- Necesita los parsers markdown y markdown_inline, que se instalan en
      -- el ts.install() de plugins/ui.lua.
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown" },
    opts = {
      -- Solo markdown. El default incluye tambien los buffers de ayuda de
      -- nvim, donde el conceal estorba mas que ayuda.
      file_types = { "markdown" },

      heading = {
        -- Sin signo en la columna de signos: esa la ocupan gitsigns y los
        -- diagnosticos del LSP.
        sign = false,
        -- El icono va delante del texto en la misma linea, en vez de ocupar
        -- el ancho completo desplazando la cabecera.
        position = "inline",
      },

      code = {
        -- Bloque completo con lenguaje y borde, no solo el fondo.
        style = "full",
        -- El fondo llega hasta el final del codigo, no hasta el final de la
        -- ventana: con wrap activo lo segundo queda sucio.
        width = "block",
        left_pad = 2,
        right_pad = 2,
      },

      -- Desactivado a proposito: renderizar LaTeX necesita latex2text
      -- (python-pylatexenc), que no esta instalado. Sin esto, cada bloque de
      -- matematicas suelta un error al abrir el fichero.
      latex = { enabled = false },
    },
  },
}
