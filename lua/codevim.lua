-- lua/codevim.lua

-- Funciones para autocompletar y generar código
local function autocomplete_code()
  local current_line = vim.api.nvim_buf_get_lines(0, 0)[0]:match(".*$")
  local prompt = "Autocompletar: " .. current_line

  -- Enviar la solicitud al LLM
  if vim.api.nvim_get_config("codevim.llm_model") == "Ollama" then
    local response = vim.api.nvim_exec("!o" .. prompt)
  else
    local response = vim.api.nvim_exec("!codeqwen" .. prompt)
  end

  -- Insertar la respuesta del LLM
  vim.api.nvim_buf_insert(0, -1, response)
end

local function generate_code()
  local prompt = "Generar código:"

  -- Enviar la solicitud al LLM
  if vim.api.nvim_get_config("codevim.llm_model") == "Ollama" then
    local response = vim.api.nvim_exec("!o" .. prompt)
  else
    local response = vim.api.nvim_exec("!codeqwen" .. prompt)
  end

  -- Insertar la respuesta del LLM
  vim.api.nvim_buf_insert(0, -1, response)
end

-- Mapeos de teclas
vim.api.nvim_buf_set_keymap(0, "g<leader>ac", "<Esc>", {
  mode = "n",
  silent = true,
})

vim.api.nvim_buf_set_keymap(0, "g<leader>gc", "<Esc>", {
  mode = "n",
  silent = true,
})

-- Opciones del búfer
vim.api.nvim_buf_set_option(0, "omnifunc", "o")

