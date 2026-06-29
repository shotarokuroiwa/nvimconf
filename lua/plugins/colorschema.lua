return {
  -- {
  --   "shaunsingh/nord.nvim",
  --   lazy = false,
  --   priority = 1000, -- make sure to load this before all the other start plugins
  --   config = function()
  --     -- vim.g.nord_disable_background = true
  --     vim.cmd([[colorscheme nord]])
  --   end
  -- },
  -- {
  --   -- "nyoom-engineering/oxocarbon.nvim",
  --   "version-1/oxocarbon.nvim",
  --   lazy = true,
  --   priority = 1000, -- make sure to load this before all the other start plugins
  --   config = function()
  --     vim.opt.background = "dark"
  --     vim.cmd([[colorscheme oxocarbon]])
  --     -- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  --     -- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  --     -- vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
  --   end
  -- },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("tokyonight").setup {
        transparent = true,
        styles = {
          sidebars = "transparent",
          floats = "transparent",
        },
        on_highlights = function(hl, c)
          hl.Comment = {
            fg = "#468a55", 
            italic = true 
          } 
          hl.TelescopeNormal        = {
            bg = "none",
            fg = c.fg_dark,
          }
          hl.TelescopeResultsNormal = {
            bg = "none",
          }
          hl.TelescopePreviewNormal = {
            bg = "none",
          }
          hl.TelescopePromptNormal  = {
            bg = "none",
          }
          hl.TelescopePromptPrefix  = {
            bg = "none",
          }
          hl.TelescopeBorder        = {
            bg = "none",
          }
          hl.TelescopePromptBorder = {
            bg = "none",
          }
          hl.TelescopePromptTitle  = {
            bg = "none",
            fg = c.fg_dark,
          }
          hl.TelescopePreviewTitle = {
            bg = "none",
            fg = c.fg_dark,
          }
          hl.TelescopeResultsTitle = {
            bg = "none",
            fg = c.fg_dark,
          }
          hl.WhichKeyNormal        = {
            bg = c.bg_dark
          }
          hl.LazyNormal            = {
            bg = "none",
            fg = c.fg_dark,
          }
        end,
      }
      vim.cmd([[colorscheme tokyonight-storm]])
    end
  },
}
