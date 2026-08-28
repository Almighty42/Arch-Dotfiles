return {
  'jameswolensky/marker-groups.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim', -- Required
    -- "ibhagwan/fzf-lua", -- Optional: fzf-lua picker
    -- 'folke/snacks.nvim', -- Optional: Snacks picker
    'nvim-telescope/telescope.nvim', -- Optional: Telescope picker
    -- mini.pick is part of mini.nvim; this plugin vendors mini.nvim for tests,
    -- but you can also install mini.nvim explicitly to use mini.pick system-wide
    -- "nvim-mini/mini.nvim",
  },
  config = function()
    require('marker-groups').setup {
      -- Default picker is 'vim' (built-in vim.ui)
      -- Accepted values: 'vim' | 'snacks' | 'fzf-lua' | 'mini.pick' | 'telescope'
      picker = 'telescope',
    }
  end,
}
