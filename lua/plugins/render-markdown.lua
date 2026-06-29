-- lua/plugins/render-markdown.lua
return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("render-markdown").setup({
      -- カーソル行でも装飾を解除しない（表が左に詰まるのを防ぐ）
      anti_conceal = {
        enabled = true,
      },
      -- 表を枠線（ボーダー）で囲う
      pipe_table = {
        enabled = true,
        -- 'full' = 上下左右をボーダーで完全に囲う
        style = "full",
        -- セルを内容に合わせてパディング
        cell = "padded",
        -- ボーダー文字（角丸）
        border = {
          "┌", "┬", "┐",
          "├", "┼", "┤",
          "└", "┴", "┘",
          "│", "─",
        },
      },
      -- 見出しを見やすく
      heading = {
        enabled = true,
      },
      -- コードブロックの表示
      code = {
        enabled = true,
        style = "full",
      },
    })
  end,
}
