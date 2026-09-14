-- codex.nvim の `codex.cwd` モジュールを Windows 向けに差し替えるためのコピー。
--
-- 本家（nwiizo/codex.nvim v0.0.3）は「先頭が `/` なら絶対パス」という
-- POSIX 前提の判定をしているため、`C:/Users/...` が相対パス扱いになり
--   C:/Users/shota/AppData/Local/nvim/C:/Users/shota/AppData/Local/nvim
-- のように連結されて `:Codex` が起動できない（README も対応 OS は
-- macOS / Linux としている）。
--
-- 中身は本家 lua/codex/cwd.lua と同じで、absolute() だけ
-- vim.fs.abspath()（ドライブレター対応）を使うように直してある。
-- 本家が Windows 対応したらこのファイルごと消してよい。
local M = {}

---@param path string
---@return string
local function absolute(path)
  -- ここだけが本家との差分
  return vim.fs.normalize(vim.fs.abspath(vim.fn.expand(path)))
end

---@param path string
---@return string
local function canonical(path)
  local normalized = absolute(path)
  -- 本家は fs_realpath の戻り値をそのまま返しているが、Windows では
  -- realpath が `C:\a\b`（バックスラッシュ）、normalize が `C:/a/b`（スラッシュ）と
  -- 表記が食い違う。relative() は前方一致で判定しているので、
  -- 「片方だけ realpath が成功した」ときに相対化に失敗して絶対パスが返る。
  -- 揃えるために realpath の結果も normalize しておく。
  local real = vim.uv.fs_realpath(normalized)
  return real and vim.fs.normalize(real) or normalized
end

---@param path unknown
---@return string? directory
---@return string? error
local function directory(path)
  if type(path) ~= "string" or path == "" then
    return nil, "cwd provider must return a non-empty directory path"
  end
  local resolved = canonical(path)
  local stat = vim.uv.fs_stat(resolved)
  if not stat or stat.type ~= "directory" then
    return nil, "cwd is not a directory: " .. resolved
  end
  return resolved
end

---@param bufnr? integer
---@param policy string|fun(ctx: table): string?
---@param markers string[]
---@return string? path
---@return string? error
function M.resolve(bufnr, policy, markers)
  bufnr = bufnr or 0
  local name = vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_get_name(bufnr) or ""
  local file = name ~= "" and canonical(name) or nil
  local file_dir = file and vim.fs.dirname(file) or nil
  local nvim_cwd = canonical(vim.uv.cwd())

  if type(policy) == "function" then
    local ok, result = pcall(policy, {
      bufnr = bufnr,
      file = file,
      file_dir = file_dir,
      nvim_cwd = nvim_cwd,
    })
    if not ok then
      return nil, "cwd provider failed: " .. tostring(result)
    end
    return directory(result)
  end

  if policy == "root" then
    local root = vim.fs.root(file or nvim_cwd, markers)
    return directory(root or file_dir or nvim_cwd)
  elseif policy == "file" then
    return directory(file_dir or nvim_cwd)
  elseif policy == "nvim" then
    return directory(nvim_cwd)
  end

  return directory(policy)
end

---@param path string
---@param cwd string
---@return string
function M.relative(path, cwd)
  local normalized = canonical(path)
  local normalized_cwd = canonical(cwd)
  normalized_cwd = normalized_cwd:gsub("/+$", "")
  if normalized == normalized_cwd then
    return "."
  end
  local prefix = normalized_cwd .. "/"
  if normalized:sub(1, #prefix) == prefix then
    return normalized:sub(#prefix + 1)
  end
  return normalized
end

---@param path string
---@return string
function M.absolute(path)
  return absolute(path)
end

return M
