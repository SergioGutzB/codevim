local M = {}

function M.setup()
  -- Definir comandos de Neovim y keymaps
  vim.api.nvim_create_user_command('IAToggleAutocomplete', function()
    -- Implementar lógica para activar/desactivar autocompletado
  end, {})

  vim.api.nvim_create_user_command('IAToggleSpell', function()
    -- Implementar lógica para activar/desactivar corrección ortográfica
  end, {})

  vim.api.nvim_create_user_command('IAToggleSuggest', function()
    -- Implementar lógica para activar/desactivar sugerencias
  end, {})

  -- Configurar keymaps
  local keymaps = require('ia_autocomplete.config').get('keymaps')
  vim.keymap.set('n', keymaps.toggle_autocomplete, ':IAToggleAutocomplete<CR>', { silent = true })
  vim.keymap.set('n', keymaps.toggle_spell, ':IAToggleSpell<CR>', { silent = true })
  vim.keymap.set('n', keymaps.toggle_suggest, ':IAToggleSuggest<CR>', { silent = true })
end

return M
