return {
  "supermaven-inc/supermaven-nvim",
  config = function()
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "<Tab>",
        clear_suggestion = "<C-]>",
        accept_word = "<C-j>",
      },
      color = {
        suggestion_color = "#808080",
        cterm = 244,
      },
      disable_inline_completion = true, -- Disable by default
    })
  end,
  keys = {
    {
      "<leader>at",
      "<cmd>SupermavenToggle<cr>",
      desc = "Toggle AI suggestions",
    },
  },
}
