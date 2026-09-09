local function gh(repo) return 'https://github.com/' .. repo end

-- [[ Configure Treesitter ]]
--  Used to highlight, edit, and navigate code
--
--  See `:help nvim-treesitter-intro`

-- NOTE: You can also specify a branch or a specific commit
vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }

-- Ensure basic parsers are installed
local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'python', 'xml', 'javascript' }
require('nvim-treesitter').install(parsers)

---@param buf integer
---@param language string
local function treesitter_try_attach(buf, language)
  -- Check if a parser exists and load it
  if not vim.treesitter.language.add(language) then return end
  -- Enable syntax highlighting and other treesitter features
  vim.treesitter.start(buf, language)

  -- Enable treesitter based folds
  -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  -- vim.wo.foldmethod = 'expr'

  -- Check if treesitter indentation is available for this language, and if so enable it
  -- in case there is no indent query, the indentexpr will fallback to the vim's built in one
  local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil

  -- Enable treesitter based indentation
  if has_indent_query then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
end

local available_parsers = require('nvim-treesitter').get_available()
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local language = vim.treesitter.language.get_lang(args.match)

    if language and vim.treesitter.language.add(language) then
      vim.treesitter.start(args.buf, language)
    end
  end,
})

vim.pack.add {
  { src = gh 'nvim-treesitter/nvim-treesitter-context' },
}

require('treesitter-context').setup {
  enable = true,
  max_lines = 3,
  multiline_threshold = 20,
}

-- Jump to the first line of the parent context
vim.keymap.set('n', '<leader>p', function()
  require('treesitter-context').go_to_context(vim.v.count1)
end, { desc = 'Jump to parent context start' })
