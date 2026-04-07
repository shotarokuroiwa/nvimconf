return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {
    map_bs = true,
    map_cr = true,
  },
  config = function(_, opts)
    local npairs = require("nvim-autopairs")
    npairs.setup(opts)

    -- cmpと連携（超重要）
    local cmp = require("cmp")
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")

    cmp.event:on(
      "confirm_done",
      cmp_autopairs.on_confirm_done()
    )
  end,
}