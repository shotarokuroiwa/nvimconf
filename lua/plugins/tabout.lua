return {
  "abecodes/tabout.nvim",
  event = "InsertCharPre",
  priority = 1000,
  opts = {
    tabkey = "<Tab>",          -- Tabで外に出る
    backwards_tabkey = "<S-Tab>", -- Shift+Tabで戻る
    act_as_tab = true,         -- 出れない時は普通のTab
    act_as_shift_tab = false,
    enable_backwards = true,
    completion = true,         -- cmpと共存
    tabouts = {
      { open = "'", close = "'" },
      { open = '"', close = '"' },
      { open = "`", close = "`" },
      { open = "(", close = ")" },
      { open = "[", close = "]" },
      { open = "{", close = "}" },
    },
    ignore_beginning = true,
  },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "hrsh7th/nvim-cmp",
  },
}