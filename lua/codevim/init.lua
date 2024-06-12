-- -- init.lua
-- local ollama = require('codevim.ollama')
--
-- local M = {}
--
-- -- Function to setup the plugin
-- function M.setup(opts)
--   ollama.setup(opts.ollama)
-- end
--
-- -- Function to provide code completion
-- function M.complete()
--   -- Example code completion logic
--   local line = vim.api.nvim_get_current_line()
--   local suggestions = ollama.get_completions(line)
--   return suggestions
-- end
--
-- -- Add the function to Neovim's completion trigger
-- vim.api.nvim_set_keymap('i', '<C-Space>', 'v:lua.require"codevim".complete()', { expr = true, noremap = true })
--
-- return M
--
-- codevim/lua/codevim/init.lua

local ollama = require('codevim.ollama')

local M = {}

-- Function to setup the plugin
function M.setup(opts)
  ollama.setup(opts.ollama)
end

-- Function to provide code completion
function M.complete()
  -- Get the current line
  local line = vim.api.nvim_get_current_line()

  -- Get suggestions from Ollama
  local suggestions = ollama.get_completions(line)

  -- Format suggestions for popup menu
  local formatted_suggestions = {}
  for _, suggestion in ipairs(suggestions) do
    formatted_suggestions[#formatted_suggestions + 1] = suggestion
  end

  -- Show popup menu and handle selection
  local selected_suggestion = vim.api.nvim_input_list(formatted_suggestions, { prompt = "Select completion: " })

  -- If a suggestion is selected, insert it and update cursor position
  if selected_suggestion then
    vim.api.nvim_insert(selected_suggestion)

    -- Get the current row and column
    local row, col = vim.api.nvim_get_curpos(0)

    -- Create the position string without curly braces
    local position = "{" .. row .. ", " .. col .. "}"

    -- Set the cursor position
    vim.api.nvim_buf_set_position(0, position)
  end
end

-- Add the function to Neovim's completion trigger
vim.api.nvim_set_keymap('i', '<Tab>', 'v:lua.require"codevim".complete()', { expr = true, noremap = true })

return M
