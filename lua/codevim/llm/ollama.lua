local curl = require('plenary.curl')
local json = require('cjson')
local config = require('codevim.config')

local M = {}

local function build_prompt(context, query)
  return string.format([[
Context:
%s

Query: %s

Response:
]], context, query)
end

function M.setup()
  M.ollama_config = config.get('llm').ollama
  M.model = config.get('llm').model

  if not M.ollama_config or not M.model then
    error("Ollama configuration or model not found")
  end
end

function M.query(prompt, context)
  local full_prompt = build_prompt(context, prompt)

  local response = curl.post(M.ollama_config.url .. '/api/generate', {
    body = json.encode({
      model = M.model,
      prompt = full_prompt,
      stream = false
    }),
    headers = {
      content_type = "application/json",
    },
    timeout = M.ollama_config.timeout or 30000
  })

  if response.status ~= 200 then
    error("Failed to query Ollama: " .. (response.body or "Unknown error"))
  end

  local result = json.decode(response.body)
  return result.response
end

function M.health_check()
  local response = curl.get(M.ollama_config.url .. '/api/version')

  if response.status ~= 200 then
    return false, "Failed to connect to Ollama"
  end

  return true, "Successfully connected to Ollama"
end

return M
