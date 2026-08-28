-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

-- debug.lua

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    'jedrzejboczar/nvim-dap-cortex-debug',
  },
  keys = {
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>b',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>B',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Set Breakpoint',
    },
    {
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: See last session result.',
    },
  },
  config = function()
    print 'dap debug.lua loaded' -- add this
    local dap = require 'dap'
    local dapui = require 'dapui'

    dap.adapters.lldb = {
      type = 'executable',
      command = '/usr/bin/lldb-dap',
    }

    require('dap-cortex-debug').setup {
      debug = true, -- log debug messages
      -- path to cortex-debug extension, supports vim.fn.glob
      -- by default tries to guess: mason.nvim or VSCode extensions
      extension_path = nil,
      lib_extension = nil, -- shared libraries extension, tries auto-detecting, e.g. 'so' on unix
      node_path = 'node', -- path to node.js executable
      dapui_rtt = true, -- register nvim-dap-ui RTT element
      -- make :DapLoadLaunchJSON register cortex-debug for C/C++, set false to disable
      dap_vscode_filetypes = { 'c', 'cpp' },
      rtt = {
        buftype = 'Terminal', -- 'Terminal' or 'BufTerminal' for terminal buffer vs normal buffer
      },
    }

    local dap_cortex_debug = require 'dap-cortex-debug'

    dap.configurations.c = {
      {
        name = 'Launch LLDB',
        type = 'lldb',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = true,
        args = {},
        runInTerminal = false,
      },
      dap_cortex_debug.openocd_config {
        name = 'Debug with OpenOCD',
        servertype = 'external',
        cwd = vim.fn.getcwd(),
        executable = vim.fn.getcwd() .. '/spi_testing.elf',
        -- configFiles = { '${workspaceFolder}/build/openocd/connect.cfg' },
        configFiles = {
          'interface/stlink.cfg',
          'target/stm32f4x.cfg',
        },
        device = 'STM32F401RE',
        svdFile = vim.fn.getcwd() .. '../Generic/STM32F401.svd',
        gdbTarget = 'localhost:3333',
        rttConfig = dap_cortex_debug.rtt_config(0),
        showDevDebugOutput = true,
        debug = true,
      },
      dap_cortex_debug.openocd_config {
        name = 'Debug MSPM0G3507 with OpenOCD',
        servertype = 'external',
        cwd = vim.fn.getcwd(),
        executable = vim.fn.getcwd() .. '/build/mspm0g3507_app.elf',
        configFiles = {
          'interface/xds110.cfg',
          'target/ti/mspm0.cfg',
        },
        device = 'MSPM0G3507',
        svdFile = vim.fn.expand '~/.local/share/svd/MSPM0G350X.svd',
        gdbTarget = 'localhost:3333',
        rttConfig = dap_cortex_debug.rtt_config(0),
        showDevDebugOutput = true,
        debug = true,
      },
    }

    -- Python / Debugpy
    local function get_python_path()
      local cwd = vim.fn.getcwd()

      if vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
        return cwd .. '/.venv/bin/python'
      elseif vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
        return cwd .. '/venv/bin/python'
      elseif vim.fn.executable '/usr/bin/python3' == 1 then
        return '/usr/bin/python3'
      else
        return vim.fn.exepath 'python3'
      end
    end

    dap.adapters.python = {
      type = 'executable',
      command = get_python_path(),
      args = { '-m', 'debugpy.adapter' },
    }

    dap.configurations.python = {
      {
        type = 'python',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        cwd = '${workspaceFolder}',
        justMyCode = false,
        pythonPath = get_python_path,
      },
      {
        type = 'python',
        request = 'attach',
        name = 'Attach to debugpy :5678',
        connect = {
          host = '127.0.0.1',
          port = 5678,
        },
      },
    }

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      handlers = {},
      ensure_installed = { 'delve' },
    }

    dapui.setup {
      layouts = {
        {
          elements = {
            { id = 'scopes', size = 0.4 },
            { id = 'console', size = 0.4 },
          },
          position = 'left',
          size = 40,
        },
      },
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local breakpoint_icons = vim.g.have_nerd_font
        and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close
  end,
}
