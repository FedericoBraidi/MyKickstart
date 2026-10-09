local function gh(repo) return 'https://github.com/' .. repo end

---@type (string|vim.pack.Spec)[]
local telescope_plugins = {
  gh 'nvim-lua/plenary.nvim',
  gh 'nvim-telescope/telescope.nvim',
  gh 'nvim-telescope/telescope-ui-select.nvim',
  gh 'nvim-telescope/telescope-live-grep-args.nvim',
}
if vim.fn.executable 'make' == 1 then table.insert(telescope_plugins, gh 'nvim-telescope/telescope-fzf-native.nvim') end

vim.pack.add(telescope_plugins)

local lga_actions = require 'telescope-live-grep-args.actions'
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

-- Forward-declared so each picker can switch to the other
local search_files, search_grep

-- Close the current picker and open another one with the same prompt text
local function switch_to(open)
  return function(prompt_bufnr)
    local text = action_state.get_current_line()
    actions.close(prompt_bufnr)
    open(text)
  end
end
local function switch_to_files(prompt_bufnr) switch_to(search_files)(prompt_bufnr) end

require('telescope').setup {
  extensions = {
    ['ui-select'] = { require('telescope.themes').get_dropdown() },
    live_grep_args = {
      auto_quoting = true, -- Keep it on for basic strings
      mappings = {
        i = {
          -- Pressing Ctrl+k quotes your current text so you can safely type flags
          ['<C-k>'] = lga_actions.quote_prompt(),
          -- Pressing Ctrl+i quotes the text and automatically appends a file glob flag
          ['<C-i>'] = lga_actions.quote_prompt { postfix = ' --iglob ' },
          -- Pressing Ctrl+f switches to [S]earch [F]iles keeping the text
          ['<C-f>'] = switch_to_files,
        },
        n = {
          ['<C-f>'] = switch_to_files,
        },
      },
    },
  },
}

pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')
pcall(require('telescope').load_extension, 'live_grep_args')

local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
search_files = function(default_text)
  builtin.find_files {
    cwd = vim.fn.expand '~',
    default_text = default_text,
    attach_mappings = function(_, map)
      -- Pressing Ctrl+g switches to [S]earch [G]rep keeping the text
      map({ 'i', 'n' }, '<C-g>', switch_to(search_grep))
      return true
    end,
  }
end

-- Repos searched by <leader>sg and <leader>sd
local odoo_repos = {
  vim.fn.expand '~/odoo',
  vim.fn.expand '~/enterprise',
  vim.fn.expand '~/upgrade',
  vim.fn.expand '~/upgrade-util',
}

search_grep = function(default_text)
  require('telescope').extensions.live_grep_args.live_grep_args {
    default_text = default_text,
    search_dirs = vim.deepcopy(odoo_repos), -- the extension expands paths in place
  }
end

vim.keymap.set('n', '<leader>sf', function() search_files() end, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', function() search_grep() end, { desc = '[S]earch [G]rep (supports "term -g *.xml" via live_grep_args)' })
-- Files with uncommitted changes (staged, unstaged, untracked) in all the
-- odoo_repos, previewed and opened at their first changed line
local function search_diff()
  local function git(root, args)
    local cmd = vim.list_extend({ 'git', '-C', root, '-c', 'core.quotePath=false' }, args)
    return vim.system(cmd, { text = true })
  end

  -- Start every git command first so they run in parallel
  local jobs = {}
  for _, root in ipairs(odoo_repos) do
    table.insert(jobs, {
      root = root,
      diff = git(root, { 'diff', 'HEAD', '-U0', '--no-color', '--no-ext-diff' }),
      untracked = git(root, { 'ls-files', '--others', '--exclude-standard' }),
    })
  end

  local files = {}
  for _, job in ipairs(jobs) do
    local function add(path, lnum) table.insert(files, { root = job.root, path = path, lnum = lnum }) end
    -- stdout is empty if the repo is missing
    local current
    for line in (job.diff:wait().stdout or ''):gmatch '[^\n]+' do
      if line:match '^%+%+%+ ' then
        current = line:match '^%+%+%+ b/(.+)$' -- nil for deleted files
      elseif current then
        local lnum = line:match '^@@ %-%S+ %+(%d+)'
        if lnum then
          add(current, math.max(tonumber(lnum), 1))
          current = nil -- only keep the first change of each file
        end
      end
    end
    for path in (job.untracked:wait().stdout or ''):gmatch '[^\n]+' do
      add(path, 1)
    end
  end

  local conf = require('telescope.config').values
  require('telescope.pickers')
    .new({}, {
      prompt_title = 'Uncommitted changes',
      finder = require('telescope.finders').new_table {
        results = files,
        entry_maker = function(file)
          local name = vim.fs.basename(file.root) .. '/' .. file.path
          return {
            value = file,
            ordinal = name,
            display = name,
            filename = file.root .. '/' .. file.path,
            lnum = file.lnum,
            col = 1,
          }
        end,
      },
      sorter = conf.generic_sorter {},
      previewer = conf.grep_previewer {},
    })
    :find()
end

vim.keymap.set('n', '<leader>sd', search_diff, { desc = '[S]earch [D]iff (uncommitted files)' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
  callback = function(event)
    local buf = event.buf

    -- Find references for the word under your cursor.
    vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })

    -- Jump to the implementation of the word under your cursor.
    vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })

    -- Jump to the definition of the word under your cursor.
    vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })

    -- Fuzzy find all the symbols in your current document.
    vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })

    -- Fuzzy find all the symbols in your current workspace.
    vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })

    -- Jump to the type of the word under your cursor.
    vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
  end,
})

-- Override default behavior and theme when searching
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to Telescope to change the theme, layout, etc.
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

-- It's also possible to pass additional configuration options.
--  See `:help telescope.builtin.live_grep()` for information about particular keys
vim.keymap.set(
  'n',
  '<leader>s/',
  function()
    builtin.live_grep {
      grep_open_files = true,
      prompt_title = 'Live Grep in Open Files',
    }
  end,
  { desc = '[S]earch [/] in Open Files' }
)

-- Shortcut for searching your Neovim configuration files
vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config', follow = true } end, { desc = '[S]earch [N]eovim files' })
