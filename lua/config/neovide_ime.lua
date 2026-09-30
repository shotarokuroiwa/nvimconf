-- Neovide で日本語入力の未確定文字（preedit）を表示する。
-- Windows の Neovide は IME 自身の描画を抑制し、代わりに空の
-- neovide.preedit_handler() を呼ぶだけなので、確定（Enter）まで何も見えない。
-- ここでその handler を差し替え、カーソル位置に inline の仮想テキストとして描く。
-- バッファ自体は確定まで書き換えないので、undo や LSP には影響しない。
local M = {}

local ns = vim.api.nvim_create_namespace("neovide_ime_preedit")
local state = { buf = nil }

local function clear()
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    vim.api.nvim_buf_clear_namespace(state.buf, ns, 0, -1)
  end
  state.buf = nil
end

---@param text string 未確定文字列
---@param s? integer 変換中の文節の開始位置（byte）
---@param e? integer 変換中の文節の終了位置（byte）
local function preedit_handler(text, s, e)
  clear()
  if text == nil or text == "" then return end
  if not vim.fn.mode():match("^[iR]") then return end

  -- 変換中の文節を反転表示し、残りは下線で表示する
  local chunks = {}
  if s and e and e > s then
    if s > 0 then table.insert(chunks, { text:sub(1, s), "NeovideIMEPreedit" }) end
    table.insert(chunks, { text:sub(s + 1, e), "NeovideIMEPreeditSelected" })
    if e < #text then table.insert(chunks, { text:sub(e + 1), "NeovideIMEPreedit" }) end
  else
    chunks = { { text, "NeovideIMEPreedit" } }
  end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  state.buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_extmark(state.buf, ns, row - 1, col, {
    virt_text = chunks,
    virt_text_pos = "inline",
    right_gravity = false,
  })
end

function M.setup()
  if not vim.g.neovide then return end

  vim.api.nvim_set_hl(0, "NeovideIMEPreedit", { underline = true, default = true })
  vim.api.nvim_set_hl(0, "NeovideIMEPreeditSelected", { reverse = true, underline = true, default = true })

  -- neovide テーブルは Neovide が接続後に定義する（ユーザー init より後のこともある）ため、
  -- 定義されるまで少し待ってから handler を差し替える
  local function handler(text, s, e)
    vim.schedule(function() preedit_handler(text, s, e) end)
  end
  local tries = 0
  local function install()
    if type(_G.neovide) == "table" then
      _G.neovide.preedit_handler = handler
    elseif tries < 50 then
      tries = tries + 1
      vim.defer_fn(install, 100)
    end
  end
  vim.api.nvim_create_autocmd("UIEnter", { once = true, callback = install })

  -- 確定文字が入る直前・Insert を抜けたときに消す
  vim.api.nvim_create_autocmd({ "InsertCharPre", "InsertLeave", "BufLeave" }, {
    callback = clear,
  })
end

return M
