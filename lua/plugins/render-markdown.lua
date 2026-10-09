local function gh(repo) return 'https://github.com/' .. repo end

-- Render markdown in the buffer (headings, tables, code blocks, checkboxes, ...)
-- Uses the treesitter `markdown` / `markdown_inline` parsers and mini.icons
vim.pack.add { gh 'MeanderingProgrammer/render-markdown.nvim' }
require('render-markdown').setup {
  completions = { blink = { enabled = true } },
}

vim.keymap.set('n', '<leader>tm', '<cmd>RenderMarkdown toggle<CR>', { desc = '[T]oggle [M]arkdown rendering' })
