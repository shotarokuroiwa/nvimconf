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
