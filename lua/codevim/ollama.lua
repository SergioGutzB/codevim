-- ollama.lua
local Job = require('plenary.job')

local M = {}

function M.setup(config)
  M.config = config
end

local function make_http_request(url, data)
  local json_data = vim.fn.json_encode(data)
  local curl_command = string.format("curl -X POST %s -d '%s'", url, json_data)

  local result = Job:new({
    command = "sh",        -- Ejecutar en una shell
    args = { "-c", curl_command },
    cwd = vim.fn.getcwd(), -- Directorio actual
    capture_output = true, -- Capturar la salida estándar
  }):sync()

  result = vim.inspect(result)
  print("result ", result)

  if result.done then
    return result.message.content
  else
    return nil, "Error al hacer la solicitud: " .. tostring(result.code)
  end
end

function M.get_completions(line)
  local result = nil
  -- URL y datos de la solicitud
  local url = "http://localhost:11434/api/generate"
  local data = {
    model = "codeqwen",
    prompt = line,
    temperature = 0.7,
    max_lenght = 512,
    stream = false
  }
  local response, error_message = make_http_request(url, data)

  if response then
    return response
  else
    return error_message
  end
end

return M
