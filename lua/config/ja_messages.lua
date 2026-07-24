-- ============================================================================
-- error / notify メッセージの日本語化レイヤー（ベストエフォート）
-- ----------------------------------------------------------------------------
-- LSP診断メッセージは言語サーバーが英語で生成するため、Neovim側では
-- 「表示直前に文字列を差し替える」ことしかできない。プラグイン通知も同様に
-- ソース内の英語文字列を直書きしているため、vim.notify を包んで置換する。
--
-- したがってここは「よく出るメッセージをパターン辞書で置換する」方式。
-- 未知のメッセージは英語のまま表示される。新しい訳を足したくなったら
-- 下の diagnostic_rules / notify_rules にルールを追記するか、あるいは
-- M.add_diagnostic_rule / M.add_notify_rule を setup() 後に呼べばよい。
--
-- ルールの形式: { "Luaパターン", "置換文字列" }
--   - パターンは Lua パターン（正規表現ではない）。特殊文字は % でエスケープ:
--       ( ) . % + - * ? [ ] ^ $   →   %( %) %. %% %+ %- %* %? %[ %] %^ %$
--   - 置換文字列では %1 %2 ... でキャプチャを引き継げる。
--   - `(.-)` は「最短一致キャプチャ」。可変部分（識別子・型名など）に使う。
--   - 末尾の `%.?$` は「ピリオドがあってもなくても行末」の意味。
--   - 続きの説明文まで含めて丸ごと捨てたいときは末尾を `.*$` にする。
--   - 上から順に照合し、最初にマッチしたルールを適用する。したがって
--     「より具体的なルールを上に、汎用ルールを下に」並べること。
--
-- 対応LSP: lua_ls / ts_ls / phpactor / gopls / ruby_lsp / ziggy / clangd
-- 対応通知: lazy.nvim / conform.nvim / telescope / git-conflict / vim.lsp
-- ============================================================================

local M = {}

-- LSP診断メッセージの翻訳ルール --------------------------------------------
M.diagnostic_rules = {
  -- ── lua_ls (Lua Language Server) ─────────────────────────────────────
  { "^Undefined global `(.-)`%.?$", "未定義のグローバル変数 `%1` です。" },
  { "^Undefined variable `(.-)`%.?$", "未定義の変数 `%1` です。" },
  { "^Undefined field `(.-)`%.?$", "未定義のフィールド `%1` です。" },
  { "^Undefined doc name `(.-)`%.?$", "ドキュメントに定義されていない名前 `%1` です。" },
  { "^Unused local `(.-)`%.?$", "未使用のローカル変数 `%1` です。" },
  { "^Unused function `(.-)`%.?$", "未使用の関数 `%1` です。" },
  { "^Unused function%.?$", "未使用の関数です。" },
  { "^Unused label `(.-)`%.?$", "未使用のラベル `%1` です。" },
  { "^Cannot find declaration of `(.-)`%.?$", "`%1` の宣言が見つかりません。" },
  { "^Cannot assign `(.-)` to `(.-)`%.?$", "`%1` を `%2` に代入できません。" },
  { "^Duplicate field `(.-)`%.?$", "フィールド `%1` が重複しています。" },
  { "^Duplicate doc field `(.-)`%.?$", "ドキュメントのフィールド `%1` が重複しています。" },
  { "^Duplicate index `(.-)`%.?$", "インデックス `%1` が重複しています。" },
  { "^Redundant parameter `(.-)`%.?$", "余分な引数 `%1` です。" },
  { "^Redundant value%.?$", "余分な値です。" },
  { "^Redundant return value%.?$", "余分な戻り値です。" },
  { "^Missing parameter%.?$", "引数が不足しています。" },
  { "^Missing argument%.?$", "引数が不足しています。" },
  { "^Need check nil%.?$", "nil のチェックが必要です。" },
  { "^Assign to undefined field `(.-)`%.?$", "未定義のフィールド `%1` に代入しています。" },
  { "^Fields cannot be injected into the reference of `(.-)`.*$", "`%1` の参照にフィールドを追加できません。" },
  { "^Deprecated%.?$", "非推奨です。" },
  { "^`(.-)` is deprecated%.?$", "`%1` は非推奨です。" },
  { "^Trailing space%.?$", "行末に空白があります。" },
  { "^Circular doc class.*$", "ドキュメントのクラス定義が循環しています。" },

  -- ── ts_ls (TypeScript / JavaScript Language Server) ──────────────────
  { "^Cannot find name '(.-)'%.?$", "名前 '%1' が見つかりません。" },
  { "^Cannot find name '(.-)'%. Did you mean '(.-)'%??$", "名前 '%1' が見つかりません。'%2' の誤りではありませんか？" },
  { "^Cannot find module '(.-)'.*$", "モジュール '%1' が見つかりません。" },
  { "^Cannot find namespace '(.-)'%.?$", "名前空間 '%1' が見つかりません。" },
  { "^Cannot use namespace '(.-)' as a type%.?$", "名前空間 '%1' は型として使えません。" },
  { "^Cannot redeclare block%-scoped variable '(.-)'%.?$", "ブロックスコープ変数 '%1' を再宣言できません。" },
  { "^Duplicate identifier '(.-)'%.?$", "識別子 '%1' が重複しています。" },
  { "^'(.-)' is declared but its value is never read%.?$", "'%1' は宣言されていますが使用されていません。" },
  { "^'(.-)' is declared but never used%.?$", "'%1' は宣言されていますが使用されていません。" },
  { "^'(.-)' is possibly 'undefined'%.?$", "'%1' は undefined の可能性があります。" },
  { "^'(.-)' is possibly 'null'%.?$", "'%1' は null の可能性があります。" },
  { "^'(.-)' is possibly 'null' or 'undefined'%.?$", "'%1' は null または undefined の可能性があります。" },
  { "^'(.-)' refers to a value, but is being used as a type here.*$", "'%1' は値を指していますが、ここでは型として使われています。" },
  { "^'(.-)' only refers to a type, but is being used as a value here%.?$", "'%1' は型を指すだけで、ここでは値として使えません。" },
  { "^Property '(.-)' does not exist on type '(.-)'%.?$", "プロパティ '%1' は型 '%2' に存在しません。" },
  { "^Property '(.-)' is missing in type '(.-)' but required in type '(.-)'%.?$", "プロパティ '%1' は型 '%2' にありませんが、型 '%3' では必須です。" },
  { "^Property '(.-)' is private and only accessible within class '(.-)'%.?$", "プロパティ '%1' は private で、クラス '%2' の内部からのみアクセスできます。" },
  { "^Type '(.-)' is not assignable to type '(.-)'%.?$", "型 '%1' は型 '%2' に代入できません。" },
  { "^Type '(.-)' has no properties in common with type '(.-)'%.?$", "型 '%1' は型 '%2' と共通のプロパティを持ちません。" },
  { "^Argument of type '(.-)' is not assignable to parameter of type '(.-)'%.?$", "型 '%1' の引数は、型 '%2' の引数に代入できません。" },
  { "^Expected (%d+) arguments, but got (%d+)%.?$", "引数は %1 個必要ですが、%2 個が渡されました。" },
  { "^Expected (%d+)%-(%d+) arguments, but got (%d+)%.?$", "引数は %1〜%2 個必要ですが、%3 個が渡されました。" },
  { "^Expected at least (%d+) arguments, but got (%d+)%.?$", "引数は少なくとも %1 個必要ですが、%2 個が渡されました。" },
  { "^Parameter '(.-)' implicitly has an 'any' type%.?$", "引数 '%1' は暗黙的に 'any' 型になっています。" },
  { "^Variable '(.-)' implicitly has an 'any' type%.?$", "変数 '%1' は暗黙的に 'any' 型になっています。" },
  { "^Member '(.-)' implicitly has an 'any' type%.?$", "メンバー '%1' は暗黙的に 'any' 型になっています。" },
  { "^Binding element '(.-)' implicitly has an 'any' type%.?$", "分割代入の要素 '%1' は暗黙的に 'any' 型になっています。" },
  { "^Element implicitly has an 'any' type.*$", "要素が暗黙的に 'any' 型になっています。" },
  { "^Object is possibly 'null'%.?$", "オブジェクトが null の可能性があります。" },
  { "^Object is possibly 'undefined'%.?$", "オブジェクトが undefined の可能性があります。" },
  { "^Object is possibly 'null' or 'undefined'%.?$", "オブジェクトが null または undefined の可能性があります。" },
  { "^No overload matches this call%.?$", "この呼び出しに一致するオーバーロードがありません。" },
  { "^Not all code paths return a value%.?$", "すべての経路で値が返されていません。" },
  { "^Unreachable code detected%.?$", "到達不能なコードが検出されました。" },
  { "^Unused label%.?$", "未使用のラベルです。" },
  { "^A 'return' statement can only be used within a function body%.?$", "'return' 文は関数本体の中でのみ使えます。" },
  { "^'await' expressions are only allowed within async functions.*$", "'await' 式は async 関数の中でのみ使えます。" },
  { "^Function lacks ending return statement and return type does not include 'undefined'%.?$", "関数の末尾に return 文がなく、戻り値の型に 'undefined' が含まれていません。" },
  { "^JSX element type '(.-)' does not have any construct or call signatures%.?$", "JSX 要素の型 '%1' にはコンストラクタ／呼び出しシグネチャがありません。" },
  { "^An object literal cannot have multiple properties with the same name%.?$", "オブジェクトリテラルに同名のプロパティを複数持つことはできません。" },

  -- ── gopls (Go Language Server) ───────────────────────────────────────
  { "^undefined: (.-)$", "未定義です: %1" },
  { "^undeclared name: (.-)$", "宣言されていない名前です: %1" },
  { "^declared and not used: (.-)$", "宣言されていますが使用されていません: %1" },
  { "^(.-) declared and not used$", "%1 は宣言されていますが使用されていません" },
  { "^(.-) declared but not used$", "%1 は宣言されていますが使用されていません" },
  { '^"(.-)" imported and not used$', '"%1" はインポートされていますが使用されていません' },
  { "^(.-) redeclared in this block$", "%1 はこのブロック内で再宣言されています" },
  { "^missing return$", "return 文がありません" },
  { "^missing return at end of function$", "関数の末尾に return 文がありません" },
  { "^no new variables on left side of :=$", ":= の左辺に新しい変数がありません" },
  { "^unreachable code$", "到達不能なコードです" },
  { "^not enough arguments in call to (.-)$", "%1 の呼び出しで引数が不足しています" },
  { "^too many arguments in call to (.-)$", "%1 の呼び出しで引数が多すぎます" },
  { "^too many return values$", "戻り値が多すぎます" },
  { "^assignment to entry in nil map$", "nil マップの要素へ代入しています" },
  { "^syntax error: (.-)$", "構文エラー: %1" },

  -- ── clangd (C / C++ Language Server) ─────────────────────────────────
  { "^use of undeclared identifier '(.-)'$", "宣言されていない識別子 '%1' を使用しています" },
  { "^unknown type name '(.-)'$", "不明な型名 '%1' です" },
  { "^unused variable '(.-)'.*$", "未使用の変数 '%1' です" },
  { "^unused parameter '(.-)'.*$", "未使用の引数 '%1' です" },
  { "^no member named '(.-)' in '(.-)'$", "'%2' に '%1' という名前のメンバーはありません" },
  { "^implicit declaration of function '(.-)'.*$", "関数 '%1' が暗黙的に宣言されています" },
  { "^variable '(.-)' is uninitialized when used here.*$", "変数 '%1' は初期化されないまま使用されています" },
  { "^redefinition of '(.-)'$", "'%1' が再定義されています" },
  { "^expected ';' after (.-)$", "%1 の後に ';' が必要です" },
  { "^expected ';' at end of declaration$", "宣言の末尾に ';' が必要です" },
  { "^expected expression$", "式が必要です" },
  { "^expected identifier or '%('$", "識別子または '(' が必要です" },
  { "^control reaches end of non%-void function$", "値を返す関数の末尾に到達しています（return がありません）" },
  { "^control may reach end of non%-void function$", "値を返す関数の末尾に到達する可能性があります（return 漏れ）" },
  { "^too few arguments to function call, expected (%d+), have (%d+)$", "関数呼び出しの引数が不足しています。%1 個必要ですが %2 個です" },
  { "^too many arguments to function call, expected (%d+), have (%d+)$", "関数呼び出しの引数が多すぎます。%1 個必要ですが %2 個です" },
  { "^'(.-)' file not found$", "ファイル '%1' が見つかりません" },
  { "^field has incomplete type '(.-)'$", "フィールドの型 '%1' が不完全です" },
  { "^assigning to '(.-)' from incompatible type '(.-)'.*$", "互換性のない型 '%2' から '%1' へ代入しています" },
  { "^member reference type '(.-)' is not a pointer.*$", "メンバー参照の型 '%1' はポインタではありません（'.' の誤りかもしれません）" },
  { "^comparison of integers of different signs.*$", "符号の異なる整数どうしを比較しています" },

  -- ── phpactor (PHP Language Server, best-effort) ──────────────────────
  { '^Undefined variable "(.-)"%.?$', '未定義の変数 "%1" です。' },
  { '^Undefined variable %$(.-)%.?$', "未定義の変数 $%1 です。" },
  { '^Class "(.-)" not found%.?$', 'クラス "%1" が見つかりません。' },
  { '^Call to unknown method "(.-)".*$', '未知のメソッド "%1" を呼び出しています。' },
  { '^"(.-)" is an undefined method.*$', '"%1" は未定義のメソッドです。' },
  { "^Missing return type.*$", "戻り値の型が指定されていません。" },

  -- ── ruby_lsp / RuboCop (Ruby, best-effort) ───────────────────────────
  { "^Useless assignment to variable %- `(.-)`%.?$", "変数 `%1` への代入は使われていません。" },
  { "^Unused method argument %- `(.-)`%.?$", "メソッド引数 `%1` は使われていません。" },
  { "^Unused block argument %- `(.-)`%.?$", "ブロック引数 `%1` は使われていません。" },
  { "^unexpected token (.-)$", "予期しないトークンです: %1" },

  -- ── 汎用（言語共通でよく出るもの。必ず一番下に置く） ─────────────────
  { "^Unused variable '?`?(.-)'?`?%.?$", "未使用の変数 '%1' です。" },
  { "^Missing semicolon%.?$", "セミコロンがありません。" },
  { "^Unexpected token%.?$", "予期しないトークンです。" },
  { "^Syntax error%.?$", "構文エラーです。" },
}

-- プラグイン通知(vim.notify)の翻訳ルール -----------------------------------
M.notify_rules = {
  -- ── lazy.nvim ────────────────────────────────────────────────────────
  { "^No updates available$", "更新はありません" },
  { "^Checking for updates%.%.%.$", "更新を確認中..." },
  { "^Installing (%d+) plugins$", "%1 個のプラグインをインストール中" },
  { "^Updating (%d+) plugins$", "%1 個のプラグインを更新中" },
  { "^Cleaning (%d+) plugins$", "%1 個のプラグインを削除中" },
  { "^Config Change Detected%. Reloading%.%.%.$", "設定の変更を検知しました。再読み込み中..." },
  { "^Reloading%.%.%.$", "再読み込み中..." },

  -- ── conform.nvim (formatter) ─────────────────────────────────────────
  { "^No formatters found for this buffer.*$", "このバッファに対応するフォーマッタが見つかりません（:checkhealth conform を参照）" },
  { "^Formatter '(.-)' error:%s*(.*)$", "フォーマッタ '%1' でエラー: %2" },
  { "^Formatter '(.-)' not found$", "フォーマッタ '%1' が見つかりません" },
  { "^Formatter '(.-)' exited with code (%d+)$", "フォーマッタ '%1' が終了コード %2 で終了しました" },

  -- ── git-conflict.nvim ────────────────────────────────────────────────
  { "^No conflicts detected$", "コンフリクトはありません" },
  { "^Resolved conflicts$", "コンフリクトを解決しました" },

  -- ── telescope ────────────────────────────────────────────────────────
  { "^No results$", "結果がありません" },
  { "^No information available$", "情報がありません" },
  { "^Nothing currently selected$", "現在選択されている項目はありません" },

  -- ── vim.lsp 本体（ジャンプ・コードアクション等） ─────────────────────
  { "^No locations found$", "該当箇所が見つかりません" },
  { "^No code actions available$", "利用可能なコードアクションはありません" },
  { "^No references found$", "参照が見つかりません" },
  { "^No definition found$", "定義が見つかりません" },
  { "^No declaration found$", "宣言が見つかりません" },
  { "^No implementation found$", "実装が見つかりません" },
  { "^No type definition found$", "型定義が見つかりません" },
  { "^method (.-) is not supported by any of the servers registered for the current buffer$", "メソッド %1 は、現在のバッファに登録されたどのサーバーもサポートしていません" },
  { "^Rename failed$", "リネームに失敗しました" },

  -- ── 汎用 ─────────────────────────────────────────────────────────────
  { "^Not found$", "見つかりません" },
  { "^Done$", "完了しました" },
}

-- 指定ルール群でメッセージを翻訳する（最初にマッチしたルールを適用） -------
local function translate(msg, rules)
  if type(msg) ~= "string" then
    return msg
  end
  for _, rule in ipairs(rules) do
    local pat, rep = rule[1], rule[2]
    -- pcall で包み、壊れたパターンがあっても翻訳全体を巻き込まないようにする
    local ok, matched = pcall(string.find, msg, pat)
    if ok and matched then
      local ok2, result = pcall(string.gsub, msg, pat, rep)
      if ok2 then
        return result
      end
    end
  end
  return msg
end

M.translate = translate

-- ルールを外から追加するためのヘルパー（setup 後でも使える） ---------------
-- 具体的なルールほど先に評価されてほしいので、既定では先頭に挿入する。
function M.add_diagnostic_rule(pattern, replacement, append)
  local rule = { pattern, replacement }
  table.insert(M.diagnostic_rules, append and #M.diagnostic_rules + 1 or 1, rule)
end

function M.add_notify_rule(pattern, replacement, append)
  local rule = { pattern, replacement }
  table.insert(M.notify_rules, append and #M.notify_rules + 1 or 1, rule)
end

-- セットアップ --------------------------------------------------------------
function M.setup()
  -- 1) LSP診断メッセージ: 表示直前に format で差し替える
  --    virtual_text / float / virtual_lines のいずれで表示していても効くよう
  --    まとめて format を設定しておく。
  local function fmt(diagnostic)
    return translate(diagnostic.message, M.diagnostic_rules)
  end

  vim.diagnostic.config({
    virtual_text = { format = fmt },
    float = { format = fmt },
    virtual_lines = { format = fmt },
  })

  -- 2) プラグイン通知: vim.notify を包んで差し替える
  --    プラグイン読み込みより前にこのモジュールを require しておくことで、
  --    起動時に vim.notify を参照するプラグインにも包んだ版が渡る。
  --    setup() が二度呼ばれても多重ラップしないようフラグで守る。
  --    （Lua の関数値にはフィールドを持たせられないので、モジュール側に
  --      印を持つ。）
  if not M._notify_wrapped then
    local orig_notify = vim.notify
    vim.notify = function(msg, level, opts)
      if type(msg) == "table" then
        for i, line in ipairs(msg) do
          msg[i] = translate(line, M.notify_rules)
        end
      else
        msg = translate(msg, M.notify_rules)
      end
      return orig_notify(msg, level, opts)
    end
    M._notify_wrapped = true
  end
end

return M