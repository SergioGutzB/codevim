local config = require('codevim.config')
local scan = require('plenary.scandir')
local Path = require('plenary.path')

local M = {}

-- Almacena el contenido indexado
M.indexed_content = {}

-- Función para leer el contenido de un archivo
local function read_file(file_path)
  local file = io.open(file_path, "r")
  if not file then return nil end
  local content = file:read("*all")
  file:close()
  return content
end

-- Función para verificar si un archivo debe ser indexado
local function should_index_file(file_path)
  local patterns = config.get('index_files')
  if not patterns or type(patterns) ~= "table" then
    vim.notify("La configuración 'index_files' no es válida.", vim.log.levels.ERROR)
    return false
  end

  local file_name = vim.fn.fnamemodify(file_path, ":t")
  for _, pattern in ipairs(patterns) do
    if file_name:match(pattern) then
      return true
    end
  end
  return false
end

-- Función para indexar un solo archivo
local function index_file(file_path)
  if should_index_file(file_path) then
    local content = read_file(file_path)
    if content then
      M.indexed_content[file_path] = content
    end
  end
end

-- Función para indexar todos los archivos en un directorio
local function index_directory(dir_path)
  local files = scan.scan_dir(dir_path, {
    hidden = false,
    add_dirs = false,
    respect_gitignore = true
  })

  for _, file_path in ipairs(files) do
    index_file(file_path)
  end
end

-- Función para iniciar el proceso de indexación
function M.index_files()
  M.indexed_content = {} -- Reiniciar el contenido indexado
  local current_dir = vim.fn.getcwd()
  index_directory(current_dir)
end

-- Función para obtener el contenido indexado
function M.get_indexed_content()
  return M.indexed_content
end

-- Función para actualizar un archivo específico en el índice
function M.update_file(file_path)
  index_file(file_path)
end

-- Función para eliminar un archivo del índice
function M.remove_file(file_path)
  M.indexed_content[file_path] = nil
end

-- Configura un autocomando para reindexar cuando se guarda un archivo
local function setup_auto_index()
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("CodeVimBufWritePost", { clear = true }),
    callback = function(ev)
      M.update_file(ev.file)
    end,
  })
end

function M.setup()
  if not config.get('index_files') then
    vim.notify("La configuración 'index_files' no está definida. No se realizará la indexación.", vim.log.levels.WARN)
    return
  end
  M.index_files()    -- Indexar archivos al inicio
  setup_auto_index() -- Configurar autocomando para reindexar
end

return M

