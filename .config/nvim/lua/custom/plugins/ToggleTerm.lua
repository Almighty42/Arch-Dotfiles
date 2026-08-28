return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    opts = {},
    keys = {
      { '<leader>tt', '<cmd>ToggleTerm<cr>', desc = 'Toggle Terminal' },
      {
        '<leader>tc',
        '<cmd>TermExec cmd="clear && gcc --debug main.c -o main"<cr>',
        desc = 'Compile and run main.c',
      },
    },
  },
}
