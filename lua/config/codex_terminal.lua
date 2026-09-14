local M = {}

function M.setup()
  local group = vim.api.nvim_create_augroup("codex_terminal_input", { clear = true })

  local function configure(buf)
    if not vim.b[buf].codex_nvim_terminal then return end

    local function send(text)
      local channel = vim.b[buf].terminal_job_id
      if channel then vim.fn.chansend(channel, text) end
    end

    -- グローバルの fj を待たず f を送る（入力遅延・意図しないモード切替を防ぐ）。
    vim.keymap.set("t", "f", "f", { buffer = buf, nowait = true })
    -- Ctrl+K は端末トグルより Codex の入力編集を優先する。
    vim.keymap.set("t", "<C-k>", function() send("\11") end,
      { buffer = buf, desc = "Codex: Ctrl+K" })

    -- 改行はプラグインの複数行送信と同じ bracketed paste で渡す。
    -- Windows の端末で LF が Enter として解釈される場合にも送信を避ける。
    for _, key in ipairs({ "<S-CR>", "<C-j>" }) do
      vim.keymap.set("t", key, function() send("\27[200~\n\27[201~") end,
        { buffer = buf, desc = "Codex: insert newline" })
    end
  end

  vim.api.nvim_create_autocmd("TermOpen", {
    group = group,
    callback = function(args) configure(args.buf) end,
  })

  -- Alt+方向キーやマウスで戻る場合も、表示用の Normal モードから入力へ戻す。
  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    group = group,
    callback = function(args)
      if not vim.b[args.buf].codex_nvim_terminal then return end
      vim.schedule(function()
        if vim.api.nvim_get_current_buf() == args.buf
          and vim.bo[args.buf].buftype == "terminal"
          and vim.b[args.buf].terminal_job_id
          and vim.fn.jobwait({ vim.b[args.buf].terminal_job_id }, 0)[1] == -1 then
          vim.cmd("startinsert")
        end
      end)
    end,
  })

  -- :lua require('config.codex_terminal').setup() で既存セッションにも適用できる。
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    configure(buf)
  end
end

return M
