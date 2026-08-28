return {
  'toppair/peek.nvim',
  ft = { 'markdown' },
  build = 'deno task --quiet build:fast',
  config = function()
    require('peek').setup {
      theme = 'dark', -- matches GitHub-style dark
      app = 'qutebrowser', -- or "chromium", "brave", etc.
    }
    vim.api.nvim_create_user_command('PeekOpen', require('peek').open, {})
    vim.api.nvim_create_user_command('PeekClose', require('peek').close, {})
  end,
}
