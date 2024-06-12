-- init.lua
local ollama = require('codevim.ollama')

local M = {}

-- Function to setup the plugin
function M.setup(opts)
  ollama.setup(opts.ollama)
end

-- Function to provide code completion
function M.complete()
  -- Example code completion logic
  local line = vim.api.nvim_get_current_line()
  local suggestions = ollama.get_completions(line)
  return suggestions
end

-- Add the function to Neovim's completion trigger
vim.api.nvim_set_keymap('i', '<C-Space>', 'v:lua.require"codevim".complete()', { expr = true, noremap = true })

return M
