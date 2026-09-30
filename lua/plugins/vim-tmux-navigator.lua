-- The plugin's terminal-mode mappings use Vim's `<C-w>:` which Neovim passes
-- through to the terminal job as literal text, so define our own mappings.
vim.g.tmux_navigator_no_mappings = 1

vim.pack.add {'https://github.com/christoomey/vim-tmux-navigator'}

for key, cmd in pairs {
  ['<C-h>'] = 'TmuxNavigateLeft',
  ['<C-j>'] = 'TmuxNavigateDown',
  ['<C-k>'] = 'TmuxNavigateUp',
  ['<C-l>'] = 'TmuxNavigateRight',
  ['<C-\\>'] = 'TmuxNavigatePrevious',
} do
  vim.keymap.set({ 'n', 't' }, key, '<cmd>' .. cmd .. '<cr>', { silent = true, desc = cmd })
end
