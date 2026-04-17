local map = vim.api.nvim_set_keymap

-- esc
map("i", "jf", "<Esc>", { noremap = true, silent = true })
map("t", "jf", [[<C-\><C-n>]], { noremap = true, silent = true })

-- カーソル移動上下逆転
map("n", "j", "k", { noremap = true })
map("v", "j", "k", { noremap = true })
map("t", "j", "j", { noremap = true })

map("n", "k", "j", { noremap = true })
map("v", "k", "j", { noremap = true })
map("t", "k", "k", { noremap = true })

-- 行移動逆転
map("n", "<A-k>", ":m .+1<CR>==", { noremap = true, silent = true })
map("n", "<A-j>", ":m .-2<CR>==", { noremap = true, silent = true })

-- 複数行の移動（ビジュアルモード）
map("v", "<A-k>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
map("v", "<A-j>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

-- 括弧やクォーテーションの外に出る
map("i", "<a-l>", "<Right>", { noremap = true, silent = true })

-- ターミナル
map("n", "<C-j>", ":vsplit | wincmd l | terminal<CR>", { desc = "Terminal (vertical)" })

-- leager+g+gで先頭行頭へ
-- visualモードで行末へ
map("n", "gg", "gg0", { noremap = true, silent = true })
map("v", "G", "G$", { noremap = true, silent = true })

-- 画面移動左右
map("n", "<M-h>", "<C-w>h", { noremap = true, silent = true })
map("n", "<M-l>", "<C-w>l", { noremap = true, silent = true })

-- 現在のパス
vim.keymap.set('c', '%%', "getcmdtype() == ':' ? expand('%:p:h') .. '/' : '%%'", { expr = true })

-- 一括変換
map("n", "<Leader>s", ":%s/", { noremap = true })
map("v", "<Leader>s", ":s/", { noremap = true })

-- Leader + Enter で検索ハイライトを消す
map("n", "<Leader><CR>", ":nohlsearch<CR>", { noremap = true, silent = true })

-- 開いている全てのファイルで一括置換を開始
map("n", "<Leader>sa", ":bufdo %s/\\v", { noremap = true })
