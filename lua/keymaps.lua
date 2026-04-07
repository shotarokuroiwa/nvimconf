local map = vim.api.nvim_set_keymap

-- esc
map("i", "jf", "<Esc>", { noremap = true, silent = true })
map("t", "jf", [[<C-\><C-n>]], { noremap = true, silent = true })

-- カーソル移動上下逆転
map("n", "j", "k", { noremap = true })
map("v", "j", "k", { noremap = true })
map("t", "j", "k", { noremap = true })

map("n", "k", "j", { noremap = true })
map("v", "k", "j", { noremap = true })
map("t", "k", "j", { noremap = true })

-- vim-move逆転
map("n", "<A-k>", ":m .+1<CR>==", { noremap = true, silent = true })
map("n", "<A-j>", ":m .-2<CR>==", { noremap = true, silent = true })

-- 括弧やクォーテーションの外に出る
map("i", "<a-l>", "<Right>", { noremap = true, silent = true })

-- ターミナル
vim.o.splitright = true
map("n", "<c-j>", ":vsplit | terminal<CR>", {  desc = "Terminal (vertical )" })
