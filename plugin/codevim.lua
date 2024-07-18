local M = {}

function M.setup(opts)
  require('codevim.config').setup(opts)
  require('codevim.indexer').setup()
  require('codevim.context').setup()
  require('codevim.llm').setup()
  require('codevim.autocomplete').setup()
  require('codevim.spell').setup()
  require('codevim.suggest').setup()
  require('codevim.cache').setup()
  require('codevim.commands').setup()
end

return M
