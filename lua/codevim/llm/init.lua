local M = {}

function M.setup()
  local provider = require('codevim.config').get('llm').provider
  M.provider = require('codevim.llm.' .. provider)
  M.provider.setup()
end

function M.query(prompt)
  return M.provider.query(prompt)
end

return M
