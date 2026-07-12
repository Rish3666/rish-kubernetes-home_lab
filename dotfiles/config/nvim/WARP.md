# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Overview

This is a personal Neovim configuration based on [LazyVim](https://lazyvim.github.io/), a Neovim starter template that uses the [lazy.nvim](https://github.com/folke/lazy.nvim) plugin manager. LazyVim provides a modular, extensible configuration with sensible defaults.

## Architecture

### Bootstrap Flow
The configuration starts in `init.lua` which requires `config.lazy`. This bootstraps lazy.nvim and loads all plugins through LazyVim's plugin system.

### Directory Structure
- **lua/config/**: Core configuration files automatically loaded by LazyVim
  - `lazy.lua`: Bootstraps lazy.nvim and sets up the plugin loading system
  - `options.lua`: Vim options (extends LazyVim defaults)
  - `keymaps.lua`: Custom keybindings (extends LazyVim defaults)
  - `autocmds.lua`: Autocommands including transparent background setup
  
- **lua/plugins/**: Plugin specifications - each file returns a table that configures one or more plugins
  - Files here are automatically loaded by lazy.nvim
  - Can add new plugins, override LazyVim plugin configs, or disable plugins
  - `example.lua` is disabled (returns early) but contains comprehensive examples

### Plugin Loading System
LazyVim uses a layered approach:
1. LazyVim base plugins (`lazyvim.plugins`)
2. Optional "extras" for languages/tools (via `lazyvim.json`)
3. User plugins in `lua/plugins/`

Custom plugin files override or extend LazyVim defaults. The `opts` field merges with parent specs, allowing incremental customization.

## Commands

### Neovim/LazyVim Management
```bash
# Open Neovim
nvim

# Open with specific file
nvim <file>

# Check plugin status (inside Neovim)
:Lazy

# Update plugins (inside Neovim)
:Lazy update

# Check health
:checkhealth
```

### Code Formatting
```bash
# Format Lua files with stylua (if installed)
stylua .

# Stylua config in stylua.toml: 2 spaces, 120 column width
```

### Testing Changes
Test configuration changes by:
1. Restart Neovim to see if it loads without errors
2. Run `:checkhealth` to diagnose issues
3. Check `:Lazy` for plugin loading status

## Custom Features

### Quick Run Keybinding (`<leader>r`)
Runs the current file in a split terminal based on filetype:
- Python: `python3 <file>`
- C/C++: Compile and run
- JavaScript: `node <file>`
- TypeScript: `ts-node <file>`
- Go: `go run <file>`
- Rust: Compile and run
- And many more (see `lua/config/keymaps.lua`)

### AI Integration
Two AI systems are configured:

**CodeCompanion** (Gemini-powered):
- `<leader>aa`: CodeCompanion Actions
- `<leader>ac`: Toggle Chat
- `<leader>ai`: Inline Assistant
- Requires `GEMINI_API_KEY` environment variable

**Supermaven** (Autocomplete):
- `<Tab>`: Accept suggestion
- `<C-]>`: Clear suggestion
- `<C-j>`: Accept word
- `<leader>at`: Toggle AI suggestions

### UI Customizations
- **Colorscheme**: Gruvbox (hard contrast) with transparent background
- **Transparency**: Applied to Normal, NormalFloat, NormalNC, and SignColumn
- Transparency persists across colorscheme changes via autocmd

## Adding Plugins

Create a new file in `lua/plugins/` that returns a table:

```lua
return {
  "author/plugin-name",
  config = function()
    require("plugin-name").setup({
      -- config here
    })
  end,
  keys = {
    { "<leader>xx", "<cmd>PluginCommand<cr>", desc = "Description" },
  },
}
```

### Common Plugin Patterns
- **Override LazyVim plugin**: Reference `"LazyVim/LazyVim"` with new `opts`
- **Extend config**: Use `opts = function(_, opts)` to modify existing config
- **Disable plugin**: Add `enabled = false`
- **LSP servers**: Add to `nvim-lspconfig` opts under `servers` key
- **Mason tools**: Add to `mason.nvim` opts under `ensure_installed`

See `lua/plugins/example.lua` for comprehensive examples (currently disabled).

## Important Files

- **lazy-lock.json**: Locks plugin versions (don't manually edit)
- **lazyvim.json**: LazyVim metadata and enabled extras
- **.neoconf.json**: Neoconf/Neodev configuration for Lua LSP
- **stylua.toml**: Lua formatter configuration

## Environment Variables

- `GEMINI_API_KEY`: Required for CodeCompanion AI features
