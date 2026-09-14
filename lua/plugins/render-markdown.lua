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
      -- 見出しレベル（#, ##, ###, ####）に応じて階層インデントを付ける
      -- # は左端（節の見出し）、## から 1 段ずつ字下げ:  #=0 / ##=2 / ###=4 / ####=6 桁
      -- 表示上の仮想テキストなので、ファイルの実テキストには空白は入らない
      indent = {
        enabled = true,
        -- インサートモード中もインデントを維持する（入力中に行が左へ飛ばない）
        render_modes = { "n", "c", "t", "i" },
        -- 1 レベルあたりの追加インデント幅
        per_level = 2,
        -- このレベル以下の見出しは字下げしない（1 なので # は左端のまま）
        skip_level = 1,
        -- false = 見出し行も本文と同じ段に揃える
        skip_heading = false,
        -- ガイド線は出さず空白のみ
        icon = " ",
      },
      -- コードブロックの表示
      code = {
        enabled = true,
        style = "full",
      },
    })
  end,
}
