local M = {}

local ns = vim.api.nvim_create_namespace 'range_blame'

local function get_git_root(file)
  local dir = vim.fn.fnamemodify(file, ':p:h')
  local result = vim.system({ 'git', '-C', dir, 'rev-parse', '--show-toplevel' }):wait()
  if result.code ~= 0 then return nil end
  return result.stdout:gsub('\n', '')
end

function M.blame_selection()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  -- Exit visual mode to have the limits of the selection
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)

  vim.schedule(function()
    local start_line = vim.fn.getpos("'<")[2]
    local end_line = vim.fn.getpos("'>")[2]
    local file = vim.api.nvim_buf_get_name(bufnr)
    if file == '' then return end

    local git_root = get_git_root(file)
    if not git_root then
      print 'Not inside a git repository'
      return
    end

    -- Relative path from git root
    local rel_file = vim.fn.fnamemodify(file, ':.')

    local result = vim
      .system({
        'git',
        '-C',
        git_root,
        'blame',
        '-L',
        start_line .. ',' .. end_line,
        '--porcelain',
        rel_file,
      })
      :wait()

    if result.code ~= 0 then return end

    -- Get results of the command
    local lines = vim.split(result.stdout, '\n')
    local commit_cache = {}
    local current_hash = nil
    local current_output_line = start_line

    for _, line in ipairs(lines) do
      -- git blame --porcelain collapses results for commits already referenced, so we need to remember the data
      local hash = line:match '^(%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x)'
      if hash then
        current_hash = hash
        if not commit_cache[hash] then commit_cache[hash] = { author = 'Unknown', date = 'N/A', summary = 'Empty' } end
      end

      local author = line:match '^author (.+)'
      if author then commit_cache[current_hash].author = author end

      local time = line:match '^author%-time (%d+)'
      if time then commit_cache[current_hash].date = os.date('%Y-%m-%d', tonumber(time)) end

      local summary = line:match '^summary (.+)'
      if summary then commit_cache[current_hash].summary = summary end

      if line:sub(1, 1) == '\t' then
        local info = commit_cache[current_hash]
        local display_text = string.format('%s • %s • %s', info.author, info.date, info.summary)
        vim.api.nvim_buf_set_extmark(bufnr, ns, current_output_line - 1, 0, {
          virt_text = { { display_text, 'Comment' } },
          virt_text_pos = 'eol',
        })
        current_output_line = current_output_line + 1
      end
    end
  end)
end

return M
