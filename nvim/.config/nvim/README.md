# Neovim Config (neox5)

Configuration for Neovim, optimized for Go development, with Rose Pine theme and Tmux integration.

## Installation

1. **Clone the Repository**  

```bash
git clone git@github.com:neox5/nvim ~/.config/nvim
```

2. **Install Language Servers and Tools**

  | Language | Installation Command                                             | Description                           |
  |----------|------------------------------------------------------------------|---------------------------------------|
  | Go       | `go install golang.org/x/tools/gopls@latest`                     | Installs the Go language server       |

3. **Start Neovim**: Installs lazy.nvim and plugins automatically on the first start.

## Commands

| Command           | Description                                                     |
|-------------------|-----------------------------------------------------------------|
| `:PackerSync`     | Installs and updates plugins specified in the configuration     |
| `:PackerCleanup`  | Removes installed plugins and cache, resetting the plugin state |

## Configuration Overview

### General

| Setting         | Value      |
|-----------------|------------|
| Line numbers    | Enabled    |
| Rel. numbers    | Enabled    |
| Tab width       | 2 spaces   |
| Shift width     | 2 spaces   |
| Expand tab      | Enabled    |
| Termguicolors   | Enabled    |

### Theme

| Setting      | Value     |
|--------------|-----------|
| Colorscheme  | Rose Pine |

### Plugins

| Plugin                          | Function                                                                 |
|---------------------------------|--------------------------------------------------------------------------|
| `neovim/nvim-lspconfig`         | Provides configurations for setting up language servers (LSPs)          |
| `nvim-treesitter/nvim-treesitter` | Provides advanced syntax highlighting and code structure parsing      |
| `rose-pine/neovim`              | Adds the Rose Pine theme for a minimalist aesthetic                     |
| `folke/lazy.nvim`               | Plugin manager used to install and manage Neovim plugins                |

