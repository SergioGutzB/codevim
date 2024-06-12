-- ollama.lua
local Job = require('plenary.job')

local M = {}

function M.setup(config)
  M.config = config
end

function M.get_completions(line)
  local result = nil
  Job:new({
    command = 'ollama',
    args = { 'run', M.config.model, '--input', line },
    on_exit = function(j, return_val)
      if return_val == 0 then
        result = table.concat(j:result(), "\n")
      end
    end,
  }):sync()
  return result
end

return M
