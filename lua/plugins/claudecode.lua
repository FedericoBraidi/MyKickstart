-- Claude Code integration (IDE protocol: context, selections, native diffs)

vim.pack.add {
  'https://github.com/coder/claudecode.nvim',
  'https://github.com/folke/snacks.nvim', -- used for the terminal window
}

require('claudecode').setup {
  -- Optional tweaks:
  -- terminal = { split_side = 'right', split_width_percentage = 0.35 },
}

local map = vim.keymap.set

-- Core
map('n', '<leader>ac', '<cmd>ClaudeCode<cr>', { desc = 'Claude: Toggle' })
map('n', '<leader>af', '<cmd>ClaudeCodeFocus<cr>', { desc = 'Claude: Focus' })
map('n', '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', { desc = 'Claude: Select model' })

-- Context
map('n', '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', { desc = 'Claude: Add current buffer' })
map('x', '<leader>as', '<cmd>ClaudeCodeSend<cr>', { desc = 'Claude: Send selection' })

-- Diffs
map('n', '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', { desc = 'Claude: Accept diff' })
map('n', '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', { desc = 'Claude: Deny diff' })
