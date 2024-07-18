local ollama = require('codevim.ollama')
local utils = require('codevim.utils')

local M = {}

print("Iniciando Codevim...")

-- Función para configurar el plugin
function M.setup(opts)
  ollama.setup(opts.ollama)
  vim.keymap.set("n", "<leader>Z", function()
    M.saludar()
  end)
  vim.keymap.set("n", "<leader>h", function()
    M.version()
  end)
  vim.keymap.set("i", "<C-l>", function()
    M.complete()
  end)
end

function M.health()
  print("Every thing is OK!!!")
end

function M.version()
  print("Version 1.5")
end

function M.saludar()
  vim.ui.input({ prompt = "Tu nombre? " }, function(input)
    local bufnr = vim.api.nvim_get_current_buf()
    -- agregar a la ultima linea del bufer activo.
    vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { "Hola " .. input })
  end)
end

-- Función para proporcionar code completion
function M.complete()
  print('completing..')
  local line = utils.get_line_until_cursor()
  line = utils.format_string(line)
  print('line ' .. line)

  -- Obtener sugerencias desde Ollama
  local success, suggestions = pcall(ollama.get_completions, line)

  if not success then
    print("Error al obtener sugerencias:", suggestions)
    return {}
  end

  -- Si no hay sugerencias, retornar una lista vacía
  if not suggestions or #suggestions == 0 then
    print("No se encontraron:sugerencias")
    return {}
  end

  -- Formatear sugerencias para el menú emergente
  local formatted_suggestions = {}
  for _, suggestion in ipairs(suggestions) do
    formatted_suggestions[#formatted_suggestions + 1] = {
      label = suggestion,
      insertText = suggestion,
    }
  end

  -- Mostrar el menú emergente y manejar la selección
  local idx = vim.fn.inputlist(vim.tbl_map(function(item)
    return item.label
  end, formatted_suggestions))

  if idx <= 0 then
    return
  end

  -- Insertar la sugerencia seleccionada
  vim.api.nvim_put({ formatted_suggestions[idx].insertText }, 'l', true, true)

  -- Actualizar la posición del cursor
  local row, col = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_win_set_cursor(0, { row, col + #formatted_suggestions[idx].insertText })

  -- Opcional: Puedes registrar el uso de la sugerencia aquí
  -- Por ejemplo, para propósitos de análisis o aprendizaje automático
end

-- Configurar atajos de teclado para activar el autocompletado
-- vim.api.nvim_set_keymap('i', '<C-Tab>', 'v:lua.require"codevim".complete()', { expr = true, noremap = true })
-- vim.api.nvim_set_keymap('n', '<leader>h', 'v:lua.require"codevim".version()', { expr = true, noremap = true })

return M
