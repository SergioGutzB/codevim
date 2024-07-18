# codevim

Un plugin de Neovim para autocompletado, corrección ortográfica y sugerencias usando IA con Ollama.

## Requisitos

- Neovim 0.5+
- [Ollama](https://ollama.ai/) instalado y configurado
- [lazy.nvim](https://github.com/folke/lazy.nvim) (gestor de plugins)

## Instalación

Usando lazy.nvim, añade esto a tu configuración:

```lua
{
  "SergioGutzB/codevim",
  config = function()
    require("codevim").setup({
      -- Tu configuración personalizada aquí
    })
  end,
}
