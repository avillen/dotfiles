return {
  {
    "ChmaraX/herdr-nvim",
    -- La mitad nvim del plugin: anotaciones de codigo que se mandan al agente.
    -- La mitad herdr (sidebar + picker) se instala aparte con
    -- `herdr plugin install ChmaraX/herdr-nvim` y se bindea en
    -- ~/.config/herdr/config.toml.
    --
    -- Keymaps que trae con prefix "<leader>a" (libre en esta config):
    --   <leader>ac  comentar linea / seleccion
    --   <leader>al  listar comentarios
    --   <leader>as  pegar comentarios en el input del agente
    --   <leader>aS  enviarlos al agente (auto-submit)
    opts = {},
  },
}
