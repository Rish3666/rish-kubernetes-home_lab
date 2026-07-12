# 💤 My Neovim Configuration

A personalized Neovim setup built on [LazyVim](https://github.com/LazyVim/LazyVim) with AI-powered coding assistance and a custom development workflow.

## ✨ Features

- 🎨 **Gruvbox Theme** with transparent background for a clean terminal look
- 🤖 **Dual AI Integration**:
  - [CodeCompanion](https://github.com/olimorris/codecompanion.nvim) powered by Google Gemini for chat and inline assistance
  - [Supermaven](https://github.com/supermaven-inc/supermaven-nvim) for intelligent code completion
- ⚡ **Quick Run** - Execute files in any language with a single keybinding
- 🔧 **LazyVim** - Modern plugin manager with lazy loading for optimal performance

## 📋 Requirements

- Neovim >= 0.9.0
- Git
- A [Nerd Font](https://www.nerdfonts.com/) (optional, but recommended)
- For AI features: `GEMINI_API_KEY` environment variable

## 🚀 Installation

### Quick Start

1. **Backup your existing config** (if any):
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. **Clone this repository**:
   ```bash
   git clone https://github.com/Rish3666/nvim-config.git ~/.config/nvim
   ```

3. **Start Neovim**:
   ```bash
   nvim
   ```
   Plugins will be automatically installed on first launch.

4. **Set up AI features** (optional):
   ```bash
   export GEMINI_API_KEY="your-api-key-here"
   ```
   Add this to your `.zshrc` or `.bashrc` to make it permanent.

## ⌨️ Key Mappings

### Custom Keybindings

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>r` | Normal | Run current file in split terminal |
| `<leader>iv` | Normal | View image with viu |

### AI Features

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>aa` | Normal/Visual | CodeCompanion Actions |
| `<leader>ac` | Normal/Visual | Toggle Chat |
| `<leader>ai` | Normal/Visual | Inline Assistant |
| `<leader>at` | Normal | Toggle AI suggestions |
| `<Tab>` | Insert | Accept Supermaven suggestion |
| `<C-]>` | Insert | Clear Supermaven suggestion |
| `<C-j>` | Insert | Accept word |

### Default LazyVim Keybindings

Refer to the [LazyVim keymaps documentation](https://lazyvim.github.io/keymaps) for the full list of default keybindings.

## 🎯 Quick Run Feature

Press `<leader>r` to instantly run your current file. Supported languages:

- **Python** → `python3`
- **JavaScript** → `node`
- **TypeScript** → `ts-node`
- **Go** → `go run`
- **Rust** → Compile and run
- **C/C++** → Compile with gcc/g++ and run
- **Java** → Compile and run
- **Ruby** → `ruby`
- **PHP** → `php`
- **Lua** → `lua`
- **Shell** → `bash`/`zsh`

## 🔌 Plugins

### Core Plugins (from LazyVim)
- [lazy.nvim](https://github.com/folke/lazy.nvim) - Plugin manager
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) - Syntax highlighting
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - LSP configuration
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Fuzzy finder
- [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) - File explorer

### Custom Plugins
- [gruvbox.nvim](https://github.com/ellisonleao/gruvbox.nvim) - Colorscheme
- [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim) - AI chat and inline assistance
- [supermaven-nvim](https://github.com/supermaven-inc/supermaven-nvim) - AI code completion

## 📁 Structure

```
~/.config/nvim/
├── init.lua                  # Entry point
├── lua/
│   ├── config/
│   │   ├── lazy.lua         # Plugin manager bootstrap
│   │   ├── options.lua      # Vim options
│   │   ├── keymaps.lua      # Custom keybindings
│   │   └── autocmds.lua     # Autocommands
│   └── plugins/
│       ├── colorscheme.lua  # Gruvbox configuration
│       ├── codecompanion.lua # AI chat/inline assistant
│       ├── supermaven.lua   # AI completion
│       └── example.lua      # Plugin examples (disabled)
├── lazy-lock.json           # Plugin version lock
└── stylua.toml              # Lua formatter config
```

## 🛠️ Customization

### Adding New Plugins

Create a new file in `lua/plugins/` and return a plugin spec:

```lua
return {
  "username/plugin-name",
  config = function()
    require("plugin-name").setup({
      -- your config here
    })
  end,
}
```

### Modifying Settings

- **Vim options**: Edit `lua/config/options.lua`
- **Keybindings**: Edit `lua/config/keymaps.lua`
- **Autocommands**: Edit `lua/config/autocmds.lua`

See `lua/plugins/example.lua` for comprehensive plugin customization examples.

## 🎨 Colorscheme

This config uses **Gruvbox** with:
- Hard contrast mode
- Transparent background (for terminal transparency)
- Persistent transparency across colorscheme changes

To change the colorscheme, edit `lua/plugins/colorscheme.lua`.

## 📚 Resources

- [LazyVim Documentation](https://lazyvim.github.io/)
- [Neovim Documentation](https://neovim.io/doc/)
- [lazy.nvim](https://github.com/folke/lazy.nvim)

## 🤝 Contributing

Feel free to fork this config and customize it to your needs!

## 📝 License

MIT
