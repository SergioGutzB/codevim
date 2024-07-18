local config = require('codevim.config')
local context = require('codevim.context')
local llm = require('codevim.llm')

local M = {}

M.enabled = config.get('enable_spell')

-- Función para obtener la palabra bajo el cursor
local function get_word_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local start_col = vim.fn.match(line:sub(1, col + 1), "\\k*$")
  local end_col = vim.fn.match(line:sub(col), "^\\k*") + col
  return line:sub(start_col + 1, end_col)
end

-- Función para verificar la ortografía de una palabra
function M.check_spelling(word)
  if not M.enabled then
    vim.notify("La corrección ortográfica está desactivada", vim.log.levels.WARN)
    return
  end

  local ctx = context.generate_context()
  ctx = ctx .. "\n\nVerifica la ortografía de la siguiente palabra: " .. word
  ctx = ctx .. "\nSi la palabra está mal escrita, proporciona la corrección. Si está bien escrita, responde 'Correcto'."

  local response = llm.generate(ctx)

  if response:match("^Correcto") then
    return nil
  else
    return response:match("^([%w%p]+)")
  end
end

-- Función para verificar la ortografía de una línea
local function check_line(line_num)
  local line = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
  local words = vim.split(line, "%s+")
  local corrections = {}

  for i, word in ipairs(words) do
    local correction = M.check_spelling(word)
    if correction then
      table.insert(corrections, { word = word, correction = correction, col = line:find(word, 1, true) })
    end
  end

  return corrections
end

-- Función para verificar la ortografía del archivo completo
function M.check_file()
  if not M.enabled then
    vim.notify("La corrección ortográfica está desactivada", vim.log.levels.WARN)
    return
  end

  local lines = vim.api.nvim_buf_line_count(0)
  local all_corrections = {}

  for i = 1, lines do
    local line_corrections = check_line(i)
    if #line_corrections > 0 then
      all_corrections[i] = line_corrections
    end
  end

  -- Mostrar resultados
  if vim.tbl_isempty(all_corrections) then
    vim.notify("No se encontraron errores ortográficos en el archivo.", vim.log.levels.INFO)
  else
    local qf_list = {}
    for line_num, corrections in pairs(all_corrections) do
      for _, correction in ipairs(corrections) do
        table.insert(qf_list, {
          filename = vim.fn.expand('%:p'),
          lnum = line_num,
          col = correction.col,
          text = string.format("'%s' podría ser '%s'", correction.word, correction.correction)
        })
      end
    end
    vim.fn.setqflist(qf_list)
    vim.cmd('copen')
    vim.notify("Se encontraron errores ortográficos. Revisa la quickfix list.", vim.log.levels.WARN)
  end
end

-- Función para verificar la ortografía de la línea actual
function M.check_current_line()
  if not M.enabled then
    vim.notify("La corrección ortográfica está desactivada", vim.log.levels.WARN)
    return
  end

  local line_num = vim.api.nvim_win_get_cursor(0)[1]
  local corrections = check_line(line_num)

  if #corrections == 0 then
    vim.notify("No se encontraron errores ortográficos en la línea actual.", vim.log.levels.INFO)
  else
    for _, correction in ipairs(corrections) do
      vim.notify(string.format("'%s' podría ser '%s'", correction.word, correction.correction), vim.log.levels.WARN)
    end
  end
end

-- Función para activar/desactivar la corrección ortográfica
function M.toggle()
  M.enabled = not M.enabled
  local status = M.enabled and "activada" or "desactivada"
  vim.notify("Corrección ortográfica " .. status, vim.log.levels.INFO)
end

-- Función para configurar keymaps
local function setup_keymaps()
  local keymaps = config.get('keymaps')
  if keymaps.trigger_spell then
    vim.api.nvim_set_keymap('n', keymaps.trigger_spell, '<cmd>lua require("codevim.spell").check_current_line()<CR>',
      { noremap = true, silent = true })
  end
  if keymaps.trigger_spell_file then
    vim.api.nvim_set_keymap('n', keymaps.trigger_spell_file, '<cmd>lua require("codevim.spell").check_file()<CR>',
      { noremap = true, silent = true })
  end
end

-- Función principal de verificación ortográfica (ahora solo para la palabra bajo el cursor)
function M.check()
  local word = get_word_under_cursor()
  if word and word ~= "" then
    local correction = M.check_spelling(word)
    if correction then
      vim.notify(string.format("'%s' podría ser '%s'", word, correction), vim.log.levels.WARN)
    else
      vim.notify("La palabra está escrita correctamente.", vim.log.levels.INFO)
    end
  else
    vim.notify("No se encontró una palabra bajo el cursor", vim.log.levels.WARN)
  end
end

-- Función de configuración
function M.setup()
  M.enabled = config.get('enable_spell')
  setup_keymaps()
end

return M

