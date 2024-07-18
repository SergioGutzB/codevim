local config = require('codevim.config')
local autocomplete = require('codevim.autocomplete')
local spell = require('codevim.spell')
local suggest = require('codevim.suggest')
local indexer = require('codevim.indexer')
local cache = require('codevim.cache')

local M = {}

local function toggle_feature(feature)
  local current_state = config.get(feature)
  config.set(feature, not current_state)
  vim.notify(string.format("%s %s", feature, not current_state and "activado" or "desactivado"), vim.log.levels.INFO)
end

local function create_commands()
  vim.api.nvim_create_user_command('CodeVimToggle', function(opts)
    local feature = opts.args
    if feature == 'autocomplete' or feature == 'spell' or feature == 'suggest' then
      toggle_feature('enable_' .. feature)
    else
      vim.notify("Característica no válida. Use 'autocomplete', 'spell', o 'suggest'.", vim.log.levels.ERROR)
    end
  end, {
    nargs = 1,
    complete = function()
      return { 'autocomplete', 'spell', 'suggest' }
    end
  })

  vim.api.nvim_create_user_command('CodeVimReindex', function()
    indexer.index_files()
    vim.notify("Proyecto reindexado", vim.log.levels.INFO)
  end, {})

  vim.api.nvim_create_user_command('CodeVimClearCache', function()
    cache.clear()
    vim.notify("Caché limpiada", vim.log.levels.INFO)
  end, {})
end

local function create_keymaps()
  local keymaps = config.get('keymaps')

  vim.keymap.set('n', keymaps.toggle_autocomplete, function()
    toggle_feature('enable_autocomplete')
  end, { silent = true, desc = "Toggle CodeVim autocompletion" })

  vim.keymap.set('n', keymaps.toggle_spell, function()
    toggle_feature('enable_spell')
  end, { silent = true, desc = "Toggle CodeVim spell checking" })

  vim.keymap.set('n', keymaps.toggle_suggest, function()
    toggle_feature('enable_suggest')
  end, { silent = true, desc = "Toggle CodeVim suggestions" })

  vim.keymap.set('i', keymaps.trigger_complete, function()
    if config.get('enable_autocomplete') then
      autocomplete.complete()
    end
  end, { silent = true, desc = "Trigger CodeVim autocompletion" })

  vim.keymap.set('n', keymaps.trigger_spell, function()
    if config.get('enable_spell') then
      spell.check()
    end
  end, { silent = true, desc = "Trigger CodeVim spell checking" })

  vim.keymap.set('n', keymaps.trigger_suggest, function()
    if config.get('enable_suggest') then
      suggest.generate()
    end
  end, { silent = true, desc = "Trigger CodeVim suggestions" })
end

function M.setup()
  create_commands()
  create_keymaps()
end

return M
