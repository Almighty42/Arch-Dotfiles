return {
  'johmsalas/text-case.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim' },

  config = function()
    local textcase = require 'textcase'
    textcase.setup {}
    require('telescope').load_extension 'textcase'
  end,

  keys = {
    -- Default invocation prefix used by text-case
    'ga',
    {
      'ga.',
      '<cmd>TextCaseOpenTelescope<CR>',
      mode = { 'n', 'x' },
      desc = 'Text-case Telescope',
    },
  },

  cmd = {
    'Subs',
    'TextCaseOpenTelescope',
    'TextCaseOpenTelescopeQuickChange',
    'TextCaseOpenTelescopeLSPChange',
    'TextCaseStartReplacingCommand',
  },

  lazy = false,
}
