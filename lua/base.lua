-- https://vimdoc.sourceforge.net/htmldoc/options.html
-- https://neovim.io/doc/user/quickref.html#option-list
local opt = vim.o
local g = vim.g
local api = vim.api
local diagnostic = vim.diagnostic
opt.encoding = 'utf-8'
opt.fileencodings = 'utf-8,cp932,shift_jis,euc-jp'
opt.iminsert = 1
opt.imsearch = 1
opt.number = true
opt.clipboard = "unnamedplus"
opt.list = true
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.autoindent = true
opt.smartindent = true
opt.wrap = false
opt.termguicolors = true
opt.wildmenu = true
opt.ruler = true
opt.smartcase = true
opt.showmatch = true
opt.updatetime = 1500
opt.winblend = 10

-- ============================================================
-- 差分表示の設定（Claude Code の修正案プレビュー / :diffthis 共通）
-- 「差分が見づらい」対策として追加。色の設定は
-- lua/plugins/colorschema.lua の on_highlights 側にある。
-- ============================================================
--   internal            : Neovim 内蔵の diff エンジンを使う（外部 diff 不要）
--   filler              : 片側にしか無い行を埋め草行で埋め、左右の行位置を揃える
--   closeoff            : 片方のウィンドウを閉じたら diff モードも自動解除する
--   algorithm:histogram : 変更のかたまりを人間の感覚に近い単位で検出するアルゴリズム
--   indent-heuristic    : インデントを考慮し、ブロックの切れ目が不自然にならないようにする
--   linematch:60        : 追加/削除された行同士を突き合わせ、行内のどの語が
--                         変わったか（DiffText）まで色分けする。数値は突き合わせを
--                         試みる最大行数で、大きいほど精密だが重くなる
--   inline:word         : 行内の差分を「単語単位」で切り出して強調する。
--                         既定の inline:simple は変わった範囲をひとかたまりで
--                         塗るので、実際には変わっていない語まで濃く見えてしまう。
--                         word にすると本当に変わった語だけが濃く塗られる
--                         （文字単位まで細かくしたいときは inline:char）
vim.opt.diffopt = {
  "internal",
  "filler",
  "closeoff",
  "algorithm:histogram",
  "indent-heuristic",
  "linematch:60",
  "inline:word",
}
-- filler で挿入される埋め草行を斜線で塗る。空行のままだと「元々空行なのか
-- 片側にしか行が無いのか」が区別できないため、斜線で明示する
vim.opt.fillchars:append({ diff = "╱" })

-- メッセージを日本語で表示
vim.cmd('language messages ja_JP.UTF-8')

-- LSP診断 / プラグイン通知メッセージの日本語化（パターン辞書によるベストエフォート）
-- 辞書に訳を追記したいときは lua/config/ja_messages.lua を編集する
require('config.ja_messages').setup()

-- mapleader
g.mapleader = ' '
g.maplocalleader = "\\"

-- autocmd
-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#show-line-diagnostics-automatically-in-hover-window
-- https://www.reddit.com/r/neovim/comments/oiyrvp/is_there_a_way_to_make_lsp_inline_diagnostic/
api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  group = api.nvim_create_augroup("float_diagnostic", { clear = true }),
  callback = function ()
    diagnostic.open_float(nil, {focus=false})
  end
})

-- fontsize（h の後ろの数字がサイズ。小さくしたいなら数字を下げる）
vim.o.guifont = "Cascadia Code:h11"
