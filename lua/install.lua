-- lua/install.lua

local vim_version = vim.api.nvim_get_version()

if vim_version:match("nightly") then
  -- Instalar el plugin utilizando lazy.nvim
  vim.cmd("lazy.nvim.install { 'SergioGutzB/codevim', config = { llm_model = 'Ollama' } }")
else
  error("Neovim nightly version required")
end
