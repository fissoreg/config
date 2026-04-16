return {
  -- ayu colorscheme
  {
    "Shatur/neovim-ayu",
    lazy = false,
    priority = 1000,
    config = function()
      require("ayu").setup({ mirage = true })
      vim.cmd.colorscheme("ayu")
    end,
  },

  -- agent-review.nvim
  {
    "fissoreg/agent-review.nvim",
    keys = {
      { "<leader>ra", mode = "x", "<Plug>(AgentReviewAdd)", desc = "Add review comment" },
      { "<leader>rp", "<Plug>(AgentReviewPreview)", desc = "Preview review comments" },
      { "<leader>rs", "<Plug>(AgentReviewSend)", desc = "Send review comments" },
      { "<leader>rc", "<Plug>(AgentReviewClear)", desc = "Clear review comments" },
      { "<leader>rt", "<Plug>(AgentReviewTarget)", desc = "Set tmux target" },
    },
    opts = {},
  },

  -- diffview.nvim (git diff viewer, pairs well with agent-review)
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open diff view" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close diff view" },
    },
    opts = {},
  },
}
