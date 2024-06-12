# codevim

codevim is a Neovim plugin for intelligent code completion and generation using Ollama and Codeqwen.

## Installation

To install this plugin using [lazy.nvim](https://github.com/folke/lazy.nvim), add the following to your Neovim configuration:

```lua
-- ~/.config/nvim/lua/plugins/codevim.lua
return {
  {
    "SergioGutzB/codevim",
    opts = {
      ollama = {
        api_key = 'your_ollama_api_key',
        -- other config options
      },
      codeqwen = {
        api_key = 'your_codeqwen_api_key',
        -- other config options
      }
    }
  }
}

