return {
  "nvim-tree/nvim-tree.lua",
  event = "VeryLazy",
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "TreeToggle" },
  },
  config = function()
    local function my_on_attach(bufnr)
      local api = require("nvim-tree.api")
      local map = vim.keymap.set
      local opts = function(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = false, silent = true, nowait = true }
      end
      api.config.mappings.default_on_attach(bufnr)

      map("n", "<CR>", function()
        local node = api.tree.get_node_under_cursor()
        if node then
          api.node.open.no_window_picker(node)
        end
      end, opts "Open: No Window Picker")
      map("n", "O", api.node.open.edit, opts "Open")
      vim.keymap.del("n", "<C-e>", { buffer = bufnr })
    end

    require("nvim-tree").setup({
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      filters = {
        dotfiles = false,
      },
      renderer = {
        indent_markers = {
          enable = true, -- 階層を分かりやすくする
        },
      },
      actions = {
        open_file = {
          window_picker = {
            enable = false, -- シンプルに開く
          },
        },        
      },
      update_focused_file = {
        enable = true,
        update_root = true,
      },
      git = {
        enable = false,
      },
      modified = {
        enable = true,
      },
      on_attach = my_on_attach,
    })
  end
}
