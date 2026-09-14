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

          -- ========================================================
          -- 差分（:diffthis / fugitive など）の色
          -- ========================================================
          -- 方針:「行全体は薄く、実際に変わった箇所だけを濃く」。
          -- 行全体を濃く塗ると変更箇所が埋もれるので、行の背景は
          -- どの行が変わったかが分かる最小限の薄さにとどめ、
          -- 行内の変更部分（DiffText / DiffTextAdd）だけを濃く塗って
          -- そこに視線が行くようにする。色は緑＝追加 / 赤＝削除の2色だけで、青は使わない。
          -- 行内をどの単位で切り出すかは lua/base.lua の diffopt inline:word 側。

          -- ---- 行全体（薄い / fg = none で元の構文色を残す） ----
          hl.DiffAdd    = { bg = "#1b3326", fg = "none" }    -- 追加行:薄い緑
          hl.DiffDelete = { bg = "#332026", fg = "#6b444c" } -- 削除行:薄い赤（fg は埋め草記号 ╱ の色）
          -- 変更のあった行。Vim は左右どちらの側も同じ DiffChange で塗るため
          -- 緑にも赤にも寄せられない。ここは無彩色のごく薄い塗りにして、
          -- 色の判断は下の行内ハイライトに任せる。
          hl.DiffChange = { bg = "#2b2f3d", fg = "none" }

          -- ---- 行内の変更箇所（濃い） ----
          -- DiffText    = 変更前 / 削除されたテキスト
          -- DiffTextAdd = 追加されたテキスト（Neovim 0.11+。既定では DiffText に
          --               リンクされていて区別が付かないので明示的に上書きする）
          hl.DiffText    = { bg = "#9c3446", fg = "#ffffff", bold = true }
          hl.DiffTextAdd = { bg = "#2b8054", fg = "#ffffff", bold = true }
          -- diff の折り畳み行が背景に溶けて境界を見失わないよう、
          -- 背景をわずかに落として区切りとして機能させる
          hl.Folded     = { bg = c.bg_dark, fg = c.comment }
        end,
      }
      vim.cmd([[colorscheme tokyonight-storm]])

      -- 別の colorscheme に切り替えると上の on_highlights は効かなくなり、
      -- diff 色がそのテーマの淡い既定値に戻ってしまう。
      -- ColorScheme イベントで塗り直して、どのテーマでも同じ視認性を保つ。
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("high_contrast_diff", { clear = true }),
        callback = function()
          local set = vim.api.nvim_set_hl
          set(0, "DiffAdd", { bg = "#1b3326" })
          set(0, "DiffDelete", { bg = "#332026", fg = "#6b444c" })
          set(0, "DiffChange", { bg = "#2b2f3d" })
          set(0, "DiffText", { bg = "#9c3446", fg = "#ffffff", bold = true })
          set(0, "DiffTextAdd", { bg = "#2b8054", fg = "#ffffff", bold = true })
        end,
      })
    end
  },
}
