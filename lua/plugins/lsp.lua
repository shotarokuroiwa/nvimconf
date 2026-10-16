return {
  "neovim/nvim-lspconfig",
  config = function()
    local M = {}
    local map = vim.keymap.set

    -- export on_attach & capabilities
    M.on_attach = function(_, bufnr)
      local function opts(desc)
        return { buffer = bufnr, desc = "LSP " .. desc }
      end

      local buf = vim.lsp.buf
      map("n", "gD", buf.declaration, opts "Go to declaration")
      map("n", "gd", buf.definition, opts "Go to definition")
      map("n", "gi", buf.implementation, opts "Go to implementation")
      map("n", "<leader>sh", buf.signature_help, opts "Show signature help")
      map("n", "<leader>wa", buf.add_workspace_folder, opts "Add workspace folder")
      map("n", "<leader>wr", buf.remove_workspace_folder, opts "Remove workspace folder")

      map("n", "<leader>wl", function()
        print(vim.inspect(buf.list_workspace_folders()))
      end, opts "List workspace folders")

      map("n", "<leader>D", buf.type_definition, opts "Go to type definition")
      -- map("n", "<leader>ra", require "nvchad.lsp.renamer", opts "NvRenamer")

      map({ "n", "v" }, "<leader>ca", buf.code_action, opts "Code action")
      map("n", "gr", buf.references, opts "Show references")
    end

    M.capabilities = vim.lsp.protocol.make_client_capabilities()

    M.capabilities.textDocument.completion.completionItem = {
      documentationFormat = { "markdown", "plaintext" },
      snippetSupport = true,
      preselectSupport = true,
      insertReplaceSupport = true,
      labelDetailsSupport = true,
      deprecatedSupport = true,
      commitCharactersSupport = true,
      tagSupport = { valueSet = { 1 } },
      resolveSupport = {
        properties = {
          "documentation",
          "detail",
          "additionalTextEdits",
        },
      },
    }

    local has_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if has_cmp_nvim_lsp then
      M.capabilities = cmp_nvim_lsp.default_capabilities(M.capabilities)
    end

    local default_server_opts = {
      on_attach = M.on_attach,
      capabilities = M.capabilities,
    }

    -- lua_ls
    vim.lsp.config("lua_ls", vim.tbl_extend("force", default_server_opts, {
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = {
              vim.fn.expand "$VIMRUNTIME/lua",
              vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
              vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types",
              vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
              "${3rd}/luv/library",
            },
            maxPreload = 100000,
            preloadFileSize = 10000,
          },
        },
      },
    }))

    -- ts_ls
    -- プロジェクトに typescript が無いときの予備。Homebrew の typescript は 7 系（Go 版）で
    -- tsserver.js が無く ts_ls が起動できないため、6 系を nvim のデータ dir に入れて使う:
    --   npm i --prefix ~/.local/share/nvim/typescript typescript@6
    local ts_fallback = vim.fn.stdpath("data") .. "/typescript/node_modules/typescript/lib"
    vim.lsp.config("ts_ls", vim.tbl_extend("force", default_server_opts,
      vim.uv.fs_stat(ts_fallback) and { init_options = { tsserver = { fallbackPath = ts_fallback } } } or {}))

    -- phpactor
    vim.lsp.config("phpactor", vim.tbl_extend("force", default_server_opts, {
      cmd = { "phpactor", "language-server" },
      filetypes = { "php" },
    }))

    -- gopls
    vim.lsp.config("gopls", default_server_opts)

    -- ruby_lsp
    vim.lsp.config("ruby_lsp", default_server_opts)

    -- ziggy
    vim.lsp.config("ziggy", default_server_opts)

    -- clangd
    local clangd_cmd = { "clangd", "--header-insertion=iwyu", "--all-scopes-completion" }
    if vim.fn.has("win32") == 1 then
      table.insert(clangd_cmd, 2, "--query-driver=C:/Users/shota/scoop/apps/gcc/15.2.0/bin/gcc.exe")
    end
    vim.lsp.config("clangd", vim.tbl_extend("force", default_server_opts, {
      cmd = clangd_cmd,
      initializationOptions = {
        clangdFileStatus = true,
        usePlaceholders = true,
        completeUnimported = true,
        semanticHighlighting = true,
      }
    }))

    vim.lsp.enable "lua_ls"
    vim.lsp.enable "ts_ls"
    vim.lsp.enable "phpactor"
    vim.lsp.enable "gopls"
    vim.lsp.enable "ruby_lsp"
    vim.lsp.enable "ziggy"
    vim.lsp.enable "clangd"
  end
}
