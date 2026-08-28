return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  ---@module "ibl"
  ---@type ibl.config
  opts = {
    -- character used for indent guides
    indent = {
      char = '│',
      tab_char = '│',
      -- you can use a table with several chars for rainbow effect
      -- char = { '│', '¦', '┆' },
    },

    -- turn the "scope" feature completely off (no scope highlighting)
    scope = {
      enabled = false,
      show_start = false,
      show_end = false,
    },

    -- exclude buffers/filetypes where you don't want any guides
    exclude = {
      filetypes = {
        'help',
        'alpha',
        'dashboard',
        'NvimTree',
        'neo-tree',
        'packer',
        'TelescopePrompt',
        'lazy',
        'git',
        'gitcommit',
        'Trouble',
        'TroublePreview',
        'toggleterm',
      },
      buftypes = { 'terminal', 'prompt' },
    },
  },
}
