local M = {}

M.defaults = {
  index_files = { "*.lua", "*.py", "*.js", "*.ts" },
  keymaps = {
    toggle_autocomplete = "<leader>ta",
    toggle_spell = "<leader>ts",
    toggle_suggest = "<leader>tg",
  },
  enable_autocomplete = true,
  enable_spell = true,
  enable_suggest = true,
  cache_enabled = true,
  max_context_tokens = 1000,
  llm = {
    provider = "ollama",
    model = "codeqwen",
    -- Configuraciones adicionales para Ollama
    ollama = {
      url = "http://localhost:11434",
      timeout = 30,
    },
    -- Espacio para configuraciones de otros proveedores de LLM
  },
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

function M.get(key)
  return M.options[key]
end

return M
