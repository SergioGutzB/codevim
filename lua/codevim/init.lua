local M = {}

-- Función para cargar un módulo de manera segura
local function safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    vim.notify("Error al cargar el módulo " .. module .. ": " .. result, vim.log.levels.ERROR)
    return nil
  end
  return result
end

-- Función de configuración principal
function M.setup(opts)
  -- Cargar y configurar los módulos
  local config = safe_require('codevim.config')
  if not config then return end
  config.setup(opts)

  local modules = {
    'indexer',
    'context',
    'llm',
    'autocomplete',
    'spell',
    'suggest',
    'cache',
    'commands'
  }

  for _, module_name in ipairs(modules) do
    local module = safe_require('codevim.' .. module_name)
    if module and module.setup then
      module.setup()
    end
  end

  -- Configurar comandos y keymaps globales
  M.setup_global_commands()
end

-- Función para configurar comandos globales
function M.setup_global_commands()
  vim.api.nvim_create_user_command('CodeVimToggle', function(opts)
    local feature = opts.args
    local module = safe_require('codevim.' .. feature)
    if module and module.toggle then
      module.toggle()
    else
      vim.notify("Característica no válida o no implementada: " .. feature, vim.log.levels.WARN)
    end
  end, {
    nargs = 1,
    complete = function()
      return { 'autocomplete', 'spell', 'suggest' }
    end
  })
end

-- Función para realizar autocompletado
function M.autocomplete()
  local autocomplete = safe_require('codevim.autocomplete')
  if autocomplete then
    return autocomplete.complete()
  end
end

-- Función para realizar corrección ortográfica
function M.spell_check()
  local spell = safe_require('codevim.spell')
  if spell then
    return spell.check()
  end
end

-- Función para generar sugerencias
function M.suggest()
  local suggest = safe_require('codevim.suggest')
  if suggest then
    return suggest.generate()
  end
end

-- Función para reindexar el proyecto
function M.reindex()
  local indexer = safe_require('codevim.indexer')
  if indexer then
    indexer.index_files()
    vim.notify("Proyecto reindexado", vim.log.levels.INFO)
  end
end

-- Función para limpiar la caché
function M.clear_cache()
  local cache = safe_require('codevim.cache')
  if cache then
    cache.clear()
    vim.notify("Caché limpiada", vim.log.levels.INFO)
  end
end

return M
