-- Ajustes solo para markdown. Aqui y no en config/options.lua porque son lo
-- contrario de lo que se quiere en codigo.

-- El global es wrap = false: en codigo cortar la linea es lo correcto, pero en
-- prosa obliga a hacer scroll horizontal para leer un parrafo.
vim.opt_local.wrap = true

-- Corta por palabra, no por caracter.
vim.opt_local.linebreak = true

-- La continuacion de una linea partida mantiene el sangrado, asi que un item
-- de lista largo sigue leyendose como un item y no como texto suelto.
vim.opt_local.breakindent = true

-- Con wrap activo, j y k saltan el parrafo entero (se mueven por linea real).
-- gj/gk se mueven por linea visual, que es lo que se espera al leer. Se
-- intercambian solo cuando no hay count, para que 5j siga siendo 5 lineas.
vim.keymap.set({ "n", "x" }, "j", function()
  return vim.v.count == 0 and "gj" or "j"
end, { buffer = true, expr = true, desc = "Bajar por linea visual" })

vim.keymap.set({ "n", "x" }, "k", function()
  return vim.v.count == 0 and "gk" or "k"
end, { buffer = true, expr = true, desc = "Subir por linea visual" })
