-- Might want to add more options, check :help vim.o

-- Set leader key to space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- It takes the nerd font set in the terminal
vim.g.have_nerd_font = true

-- Make line numbers default add relative line numbers, to help with jumping.
vim.o.number = true
vim.o.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim. Scheduled because it might take a moment
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- Enable break indent
vim.o.breakindent = true

-- Enable undo/redo changes even after closing and reopening a file
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or at least one capital letters in the search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default (for example for git symbols
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 15

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`), ask for confirmation
vim.o.confirm = true

-- A TAB character looks like 4 spaces
vim.o.tabstop = 4

-- Pressing the TAB key will insert spaces instead of a TAB character
vim.o.expandtab = true

-- Number of spaces inserted instead of a TAB character
vim.o.softtabstop = 4

-- Number of spaces inserted when indenting
vim.o.shiftwidth = 4
