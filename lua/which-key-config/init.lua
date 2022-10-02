require("which-key").setup {}

require("which-key").register({
  t = {
    name = "Test",
    a = { ":TestSuit<CR>", "All" },
    f = { ":TestFile<CR>", "File" },
    l = { ":TestLast<CR>", "Last" },
    n = { ":TestNearest<CR>", "Nearest" },
    v = { "<cmd>AV<CR>", "Visit" }
  },
  c = {
    name = "CI",
    b = { ":! lab mr browse<CR>", "Browse MR" },
    i = { ":FloatermNew lab ci view<CR>", "View pipeline" }
  },
}, { prefix = "<leader>", mode = "n" })

require("which-key").register({
  g = {
    name = "Git",
    b = { ":'<,'>GBrowse<CR>", "Browse" },
  },
  t = {
    name = "Text",
    s = { ":'<,'>sort<CR>", "Sort" },
  },
}, { prefix = "<leader>", mode = "v" })

