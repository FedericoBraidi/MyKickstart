-- plugins/odoo.lua
return {
  'whenrow/odoo-ls.nvim',
  dependencies = { 'neovim/nvim-lspconfig' },
  config = function()
    local odools = require 'odools'
    local h = os.getenv 'HOME'
    odools.setup {
      -- mandatory
      odoo_path = h .. '/Desktop/Roba/Work/odoo',
      python_path = '/usr/bin/python3',

      -- optional
      server_path = h .. '/.local/share/nvim/odoo/odoo_ls_server',
      addons = { h .. '/Desktop/Roba/Work/enterprise' },
      root_dir = h .. '/Desktop/Roba/Work/odoo',
    }
  end,
}
