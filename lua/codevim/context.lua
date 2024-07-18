local config = require('codevim.config')
local indexer = require('codevim.indexer')

local M = {}

-- Detecta el tipo de archivo actual
local function detect_filetype()
  return vim.bo.filetype
end

-- Detecta el tipo de proyecto basándose en archivos o directorios clave
local function detect_project_type()
  local project_indicators = {
    { file = "package.json",     type = "nodejs" },
    { file = "Cargo.toml",       type = "rust" },
    { file = "go.mod",           type = "go" },
    { file = "pom.xml",          type = "java" },
    { file = "requirements.txt", type = "python" },
    { dir = ".git",              type = "git" },
    -- Añade más indicadores según sea necesario
  }

  local current_dir = vim.fn.getcwd()
  for _, indicator in ipairs(project_indicators) do
    if indicator.file and vim.fn.filereadable(current_dir .. '/' .. indicator.file) == 1 then
      return indicator.type
    elseif indicator.dir and vim.fn.isdirectory(current_dir .. '/' .. indicator.dir) == 1 then
      return indicator.type
    end
  end
  return "unknown"
end

-- Genera una descripción del proyecto actual
local function generate_project_description()
  local project_type = detect_project_type()
  local filetype = detect_filetype()
  return string.format("This is a %s project. The current file is of type %s.", project_type, filetype)
end


-- Genera instrucciones basadas en el tipo de archivo y proyecto
local function generate_instructions()
  local filetype = detect_filetype()
  local project_type = detect_project_type()

  local instructions = "Please provide assistance with the following context in mind:\n"

  if filetype == "python" then
    instructions = instructions .. "- Use Python 3 syntax\n- Follow PEP 8 style guidelines\n"
  elseif filetype == "javascript" or filetype == "typescript" then
    instructions = instructions .. "- Use modern JavaScript/TypeScript syntax\n- Consider ES6+ features\n"
  end

  if project_type == "nodejs" then
    instructions = instructions .. "- Consider Node.js best practices\n"
  elseif project_type == "rust" then
    instructions = instructions .. "- Prioritize memory safety and performance\n"
  end

  return instructions
end

-- Función para contar tokens (aproximación simple)
local function count_tokens(text)
  -- Esta es una aproximación muy básica. En la práctica, deberías usar
  -- un tokenizador específico para tu modelo de LLM.
  return #(text:gsub("%s+", "")) / 4
end

-- Función para truncar texto a un número máximo de tokens
local function truncate_to_token_limit(text, max_tokens)
  if count_tokens(text) <= max_tokens then
    return text
  end

  local truncated = ""
  local current_tokens = 0
  for word in text:gmatch("%S+") do
    local word_tokens = count_tokens(word)
    if current_tokens + word_tokens > max_tokens then
      break
    end
    truncated = truncated .. word .. " "
    current_tokens = current_tokens + word_tokens
  end

  return truncated:sub(1, -2) -- Eliminar el espacio final
end

-- Función para calcular la similitud entre dos textos (usando la distancia de Levenshtein)
local function similarity(s1, s2)
  local len1, len2 = #s1, #s2
  local matrix = {}
  for i = 0, len1 do matrix[i] = { [0] = i } end
  for j = 0, len2 do matrix[0][j] = j end

  for i = 1, len1 do
    for j = 1, len2 do
      local cost = (s1:sub(i, i) ~= s2:sub(j, j) and 1 or 0)
      matrix[i][j] = math.min(
        matrix[i - 1][j] + 1,
        matrix[i][j - 1] + 1,
        matrix[i - 1][j - 1] + cost
      )
    end
  end

  return 1 - (matrix[len1][len2] / math.max(len1, len2))
end

-- Función para obtener el contenido relevante de los archivos indexados
local function get_relevant_content()
  local indexed_content = indexer.get_indexed_content()
  local current_file_content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  current_file_content = table.concat(current_file_content, "\n")

  local relevant_chunks = {}
  for filename, content in pairs(indexed_content) do
    local sim = similarity(current_file_content, content)
    table.insert(relevant_chunks, { filename = filename, content = content, similarity = sim })
  end

  -- Ordenar por similitud descendente
  table.sort(relevant_chunks, function(a, b) return a.similarity > b.similarity end)

  -- Configuración
  local max_total_tokens = config.get('max_context_tokens') or 1000
  local reserved_tokens = 200 -- Para descripción del proyecto, instrucciones, etc.
  local available_tokens = max_total_tokens - reserved_tokens

  local result = ""
  local current_tokens = 0

  for _, chunk in ipairs(relevant_chunks) do
    local chunk_content = string.format("File: %s\nContent:\n%s\n\n", chunk.filename, chunk.content)
    local chunk_tokens = count_tokens(chunk_content)

    if current_tokens + chunk_tokens > available_tokens then
      -- Truncar el último chunk si es necesario
      local remaining_tokens = available_tokens - current_tokens
      chunk_content = truncate_to_token_limit(chunk_content, remaining_tokens)
      result = result .. chunk_content
      break
    end

    result = result .. chunk_content
    current_tokens = current_tokens + chunk_tokens

    if current_tokens >= available_tokens then
      break
    end
  end

  return result
end

function M.setup()
  -- Cualquier configuración inicial necesaria
end

function M.generate_context()
  local context = {
    project_description = generate_project_description(),
    relevant_content = get_relevant_content(),
    instructions = generate_instructions(),
  }

  return string.format([[
Project Description:
%s

Relevant Content:
%s

Instructions:
%s
]], context.project_description, context.relevant_content, context.instructions)
end

return M
