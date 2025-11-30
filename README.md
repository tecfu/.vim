# vimrc

## Prerequisites

- Mac: You will to want to use a terminal that supports Truecolor, like:
  - Alacritty
  - Extraterm

## Installation for Vim

### Clone this repository and its submodules into your home directory

```sh
git clone --recurse-submodules git://github.com/tecfu/.vim ~/.vim
```

### Run Install Script

```sh
. ~/.vim/INSTALL.sh
```

### coc.nvim

> Why use coc.nvim?
>
> - coc-snippets allows you to use VSCode snippets with vim
> - coc.nvim language server ease of install

- List all installed extensions

```vim
:CocList extensions
```

- Access coc-settings.json

```vim
:CocConfig
```

#### CoC Profiles

This configuration supports multiple, isolated `coc.nvim` profiles. Each profile has its own `coc-settings.json` and `extensions.json`, located in `~/.vim/coc-profiles/<profile_name>/`.

The active profile is determined by the `COC_PROFILE` environment variable. If it's not set, it defaults to `default`.

**Switching Profiles:**

To use a different profile for a single session, set the `COC_PROFILE` environment variable when launching Neovim. For example, to use a profile named `efm`:

```sh
COC_PROFILE=efm nvim
```

To make a profile the default for all sessions, you can export the variable in your shell's startup file (e.g., `~/.bashrc`, `~/.zshrc`):

```sh
export COC_PROFILE=efm
```

**Creating a New Profile:**

1.  Create a directory for your new profile:
    ```sh
    mkdir -p ~/.vim/coc-profiles/my-new-profile
    ```
2.  Add a `coc-settings.json` to that directory.
3.  Add an `extensions.json` to that directory to define the CoC extensions for that profile.

### Configuration Modes

This configuration supports three completion/LSP modes via the `NVIM_CONFIG` environment variable:

1. **`coc`** - Uses `coc.nvim` for completion and language server support
2. **`cmp-efm`** - Uses `nvim-cmp` for completion with `efm-langserver` for diagnostics
3. **`cmp-builtin`** (Default) - Uses `nvim-cmp` for completion with builtin language servers

#### Switching Modes

To use a different mode for a single session:

```sh
NVIM_CONFIG=coc nvim
```

To make a mode the default, export it in your shell's startup file (e.g., `~/.bashrc`, `~/.zshrc`):

```sh
export NVIM_CONFIG=cmp-efm
```

#### Mode 1: CoC (`coc`)

**What it is:** Uses the `coc.nvim` extension host, which provides VSCode-like language server integration.

**When to use:** If you prefer the VSCode extension ecosystem or need specific CoC extensions.

**Configuration:**

- Language servers are configured via CoC extensions in `~/.vim/coc-profiles/<profile>/extensions.json`
- Settings are in `~/.vim/coc-profiles/<profile>/coc-settings.json`
- See the [CoC Profiles](#coc-profiles) section above for managing multiple profiles

**Installing language servers:**

```vim
:CocInstall coc-tsserver coc-pyright coc-go
```

#### Mode 2: nvim-cmp + EFM (`cmp-efm`)

**What it is:** Uses `nvim-cmp` for completion and `efm-langserver` as a universal language server that wraps linters and formatters.

**When to use:** If you want a single language server that can handle multiple tools (ESLint, Prettier, etc.) with project-specific configurations.

**Configuration:**

- EFM configuration is in `~/.vim/efm-langserver-config.yaml`
- The wrapper script at `~/.vim/efm-langserver-linter-wrapper.sh` intelligently uses project-local configs when available
- See [Advanced Linting with EFM-Langserver](#advanced-linting-with-efm-langserver) section for details

**Installing language servers:**

- EFM-langserver itself: Install from [github.com/mattn/efm-langserver](https://github.com/mattn/efm-langserver)
- Individual tools (ESLint, Prettier, etc.): Install via npm/pip as needed

#### Mode 3: nvim-cmp + Builtin (`cmp-builtin`) - Default

**What it is:** Uses `nvim-cmp` for completion and native Neovim LSP with individual language servers.

**When to use:** For a modern, lightweight setup with direct LSP integration. Recommended for most users.

**Configuration:**

Language servers are dynamically loaded from `~/.vim/efm-langserver-config.yaml`. This provides a single source of truth for all your development tools.

**Adding a Language Server:**

To add a new LSP, edit `~/.vim/efm-langserver-config.yaml` and add a tool entry with the `lspconfig_name` field:

```yaml
tools:
  ts_ls: &ts_ls
    lspconfig_name: "ts_ls"
    checkInstalled: "which typescript-language-server"
    install: "npm install -g typescript-language-server typescript"
    rootMarkers: [".git/", "package.json", "tsconfig.json"]

  pyright: &pyright
    lspconfig_name: "pyright"
    checkInstalled: "which pyright"
    install: "npm install -g pyright"
    rootMarkers: [".git/", "requirements.txt"]
```

**Configuration Fields:**

- `lspconfig_name`: (Required) The name of the server in [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md)
- `checkInstalled`: Command to check if the server is installed
- `install`: Command to install the server
- `rootMarkers`: Array of files/directories that indicate the project root (optional, defaults to common markers)

**Installing language servers:**

You must install the actual language server binaries on your system. Use the `install` command from your YAML config:

```sh
# TypeScript/JavaScript
npm install -g typescript-language-server typescript

# Python
npm install -g pyright
# or: pip install pyright

# Go
go install golang.org/x/tools/gopls@latest

# Rust
rustup component add rust-analyzer
```

**Verifying LSP is working:**

1. Open a file of the appropriate type (e.g., `.js`, `.py`)
2. Run `:LspInfo` to see active language servers
3. You should see the server listed as attached to the buffer

**Debug Logging:**

To see detailed debug messages about LSP setup and attachment, set the `VIM_LOG_LEVEL` environment variable:

```sh
# Enable debug logging (level 3 or higher)
VIM_LOG_LEVEL=3 nvim yourfile.js

# Or export it for all sessions
export VIM_LOG_LEVEL=3
```

Then check `:messages` to see the debug output.

**Common language servers:**

- JavaScript/TypeScript: `ts_ls`
- Python: `pyright`, `basedpyright`, or `ruff`
- Go: `gopls`
- Rust: `rust_analyzer`
- C/C++: `clangd`
- Lua: `lua_ls`
- SQL: `sqlls`
- C#: `csharp_ls`

See the [full list of available servers](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md).

## Installation for Neovim

- Add the following to ~.config/nvim/init.vim:

```sh
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
```

- Install pynvim

_On Ubuntu and derivatives you will need to install python-distutils_

Example for python3.11

```sh
sudo apt install python3.11-distutils
```

_You may need to install a new version of pip (>23.1.2) before installing pynvim_

```sh
pip3 install pynvim
```

## Optional

### Advanced Linting with EFM-Langserver

A key feature of this setup is its use of `efm-langserver` for diagnostics and formatting, managed by a custom wrapper script. This provides an intelligent, project-aware linting system.

**How it works:**
The installer symlinks a generic wrapper script (`efm-langserver-linter-wrapper.sh`) that intelligently decides which configuration to use for a given linter:

1.  **If a project-local configuration file exists** (e.g., `eslint.config.js` in your project root), the wrapper will use it. This ensures project-specific rules are always respected.
2.  **If no local configuration is found**, the wrapper falls back to a personal, default configuration located in your home directory (e.g., `~/.config/eslint/`). This ensures even miscellaneous files are linted consistently.

The installer automatically symlinks:

- `efm-langserver-config.yaml` -> `~/.config/efm-langserver/config.yaml`
- `efm-langserver-linter-wrapper.sh` -> `~/.config/efm-langserver/efm-langserver-linter-wrapper.sh`

#### One-Time Setup for Fallback Configs

For the fallback mechanism to work, you must create the personal default configurations.

**For ESLint (JavaScript, JSON, Markdown code blocks):**

```bash
# Create a dedicated directory
mkdir -p ~/.config/eslint
cd ~/.config/eslint

# Initialize it as a self-contained Node.js project
npm init -y

# Install the necessary parsers and plugins locally
npm i -D eslint-plugin-jsonc jsonc-eslint-parser eslint-plugin-markdown

# Now, create your fallback ~/.config/eslint/eslint.config.js
```

**For Markdownlint (Markdown prose):**

```bash
mkdir -p ~/.config/markdownlint
# Create your fallback config file (e.g., to enable all default rules)
touch ~/.config/markdownlint/config.json
```

### Configure your terminal to use a Powerline font

- i.e.: Ubuntu Mono derivative Powerline

```sh
sudo apt-get install fonts-powerline
```

### Install Silver Searcher

```sh
sudo -S apt-get install silversearcher-ag
```

## Adding your own plugins

- This .vimrc uses junegunn/vim-plug to manage plugin installation. You can add
  new plugins by appending them to the file: .vimrc.plugins .

- Once you have added a new plugin, you can auto-generate a tabular brief
  summary in the README.md file by running a npm script that does this for you:

```sh
npm run update-plugin-list
```

## Troubleshooting

- CoC can't install plugins when a npm registry is private

```sh
npm config set registry https://registry.npmjs.org
```

### Color Scheme

- Vim
  onedark <https://github.com/joshdick/onedark.vim>

- Neovim (Mac)
  dracula <https://github.com/dracula/vim>

- Neovim (Other)
  tokyonight <https://github.com/folke/tokyonight.nvim>

## Plugin List

<!---PLUGINS-->

| Name                                         | Description                                                                                                 | Website                                                        |
| -------------------------------------------- | ----------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| ahmedkhalf/project.nvim                      | The superior project management solution for neovim.                                                        | http://github.com/ahmedkhalf/project.nvim                      |
| ap/vim-css-color                             | Preview colours in source code while editing                                                                | http://github.com/ap/vim-css-color                             |
| bling/vim-airline                            | lean & mean status/tabline for vim that's light as air                                                      | http://github.com/bling/vim-airline                            |
| bronson/vim-visual-star-search               | Start a \* or # search from a visual block                                                                  | http://github.com/bronson/vim-visual-star-search               |
| bullets-vim/bullets.vim                      | 🔫 Bullets.vim is a Vim/NeoVim plugin for automated bullet lists.                                           | http://github.com/bullets-vim/bullets.vim                      |
| CopilotC-Nvim/CopilotChat.nvim               | Chat with GitHub Copilot in Neovim                                                                          | http://github.com/CopilotC-Nvim/CopilotChat.nvim               |
| danro/rename.vim                             | Rename the current file in the vim buffer + retain relative path.                                           | http://github.com/danro/rename.vim                             |
| dhruvasagar/vim-table-mode                   | VIM Table Mode for instant table creation.                                                                  | http://github.com/dhruvasagar/vim-table-mode                   |
| easymotion/vim-easymotion                    | Vim motions on speed!                                                                                       | http://github.com/easymotion/vim-easymotion                    |
| fannheyward/telescope-coc.nvim               | coc.nvim integration for telescope.nvim                                                                     | http://github.com/fannheyward/telescope-coc.nvim               |
| FooSoft/vim-argwrap                          | Wrap and unwrap function arguments, lists, and dictionaries in Vim                                          | http://github.com/FooSoft/vim-argwrap                          |
| github/copilot.vim                           | Neovim plugin for GitHub Copilot                                                                            | http://github.com/github/copilot.vim                           |
| goatslacker/mango.vim                        | A color scheme for vim                                                                                      | http://github.com/goatslacker/mango.vim                        |
| godlygeek/tabular                            | Vim script for text filtering and alignment                                                                 | http://github.com/godlygeek/tabular                            |
| hrsh7th/cmp-buffer                           | nvim-cmp source for buffer words                                                                            | http://github.com/hrsh7th/cmp-buffer                           |
| hrsh7th/cmp-cmdline                          | nvim-cmp source for vim's cmdline                                                                           | http://github.com/hrsh7th/cmp-cmdline                          |
| hrsh7th/cmp-nvim-lsp                         | nvim-cmp source for neovim builtin LSP client                                                               | http://github.com/hrsh7th/cmp-nvim-lsp                         |
| hrsh7th/cmp-path                             | nvim-cmp source for path                                                                                    | http://github.com/hrsh7th/cmp-path                             |
| hrsh7th/nvim-cmp                             | A completion plugin for neovim coded in Lua.                                                                | http://github.com/hrsh7th/nvim-cmp                             |
| iamcco/markdown-preview.nvim                 | markdown preview plugin for (neo)vim                                                                        | http://github.com/iamcco/markdown-preview.nvim                 |
| inkarkat/vim-ArgsAndMore                     | Apply commands to multiple buffers and manage the argument list.                                            | http://github.com/inkarkat/vim-ArgsAndMore                     |
| itchyny/calendar.vim                         | A calendar application for Vim                                                                              | http://github.com/itchyny/calendar.vim                         |
| joshdick/onedark.vim                         | A dark Vim/Neovim color scheme inspired by Atom's One Dark syntax theme.                                    | http://github.com/joshdick/onedark.vim                         |
| joshuavial/aider.nvim                        | No description, website, or topics provided.                                                                | http://github.com/joshuavial/aider.nvim                        |
| kshenoy/vim-signature                        | Plugin to toggle, display and navigate marks                                                                | http://github.com/kshenoy/vim-signature                        |
| L3MON4D3/LuaSnip                             | Snippet Engine for Neovim written in Lua.                                                                   | http://github.com/L3MON4D3/LuaSnip                             |
| lewis6991/gitsigns.nvim                      | Git integration for buffers                                                                                 | http://github.com/lewis6991/gitsigns.nvim                      |
| liuchengxu/vista.vim                         | 🌵 Viewer & Finder for LSP symbols and tags                                                                 | http://github.com/liuchengxu/vista.vim                         |
| luochen1990/rainbow                          | Rainbow Parentheses Improved, shorter code, no level limit, smooth and fast, powerful configuration.        | http://github.com/luochen1990/rainbow                          |
| mbbill/undotree                              | The undo history visualizer for VIM                                                                         | http://github.com/mbbill/undotree                              |
| mechatroner/rainbow_csv                      | 🌈Rainbow CSV - Vim plugin: Highlight columns in CSV and TSV files and run queries in SQL-like language     | http://github.com/mechatroner/rainbow_csv                      |
| mfussenegger/nvim-dap                        | Debug Adapter Protocol client implementation for Neovim                                                     | http://github.com/mfussenegger/nvim-dap                        |
| mileszs/ack.vim                              | Vim plugin for the Perl module / CLI script 'ack'                                                           | http://github.com/mileszs/ack.vim                              |
| moll/vim-node                                | Tools and environment to make Vim superb for developing with Node.js. Like Rails.vim for Node.              | http://github.com/moll/vim-node                                |
| nathanaelkane/vim-indent-guides              | A Vim plugin for visually displaying indent levels in code                                                  | http://github.com/nathanaelkane/vim-indent-guides              |
| neoclide/coc.nvim                            | Nodejs extension host for vim & neovim, load extensions like VSCode and host language servers.              | http://github.com/neoclide/coc.nvim                            |
| neovim/nvim-lspconfig                        | Quickstart configs for Nvim LSP                                                                             | http://github.com/neovim/nvim-lspconfig                        |
| neovim/nvim-lspconfig                        | Quickstart configs for Nvim LSP                                                                             | http://github.com/neovim/nvim-lspconfig                        |
| nvim-lua/plenary.nvim                        | plenary: full; complete; entire; absolute; unqualified. All the lua functions I don't want to write twice.  | http://github.com/nvim-lua/plenary.nvim                        |
| nvim-neotest/nvim-nio                        | A library for asynchronous IO in Neovim                                                                     | http://github.com/nvim-neotest/nvim-nio                        |
| nvim-telescope/telescope-live-grep-args.nvim | Live grep with args                                                                                         | http://github.com/nvim-telescope/telescope-live-grep-args.nvim |
| nvim-telescope/telescope.nvim                | Find, Filter, Preview, Pick. All lua, all the time.                                                         | http://github.com/nvim-telescope/telescope.nvim                |
| nvim-treesitter/nvim-treesitter              | Nvim Treesitter configurations and abstraction layer                                                        | http://github.com/nvim-treesitter/nvim-treesitter              |
| olimorris/codecompanion.nvim                 | ✨ AI Coding, Vim Style                                                                                     | http://github.com/olimorris/codecompanion.nvim                 |
| othree/eregex.vim                            | Perl/Ruby style regexp notation for Vim                                                                     | http://github.com/othree/eregex.vim                            |
| preservim/vim-markdown                       | Markdown Vim Mode                                                                                           | http://github.com/preservim/vim-markdown                       |
| rcarriga/nvim-dap-ui                         | A UI for nvim-dap                                                                                           | http://github.com/rcarriga/nvim-dap-ui                         |
| saadparwaiz1/cmp_luasnip                     | luasnip completion source for nvim-cmp                                                                      | http://github.com/saadparwaiz1/cmp_luasnip                     |
| scrooloose/vim-slumlord                      | Inline previews for Plantuml sequence diagrams. OMG!                                                        | http://github.com/scrooloose/vim-slumlord                      |
| tecfu/vim-move                               | Plugin to move lines and selections up and down                                                             | http://github.com/tecfu/vim-move                               |
| tecfu/YankRing.vim                           | Maintains a history of previous yanks, changes and deletes                                                  | http://github.com/tecfu/YankRing.vim                           |
| theHamsta/nvim-dap-virtual-text              | No description, website, or topics provided.                                                                | http://github.com/theHamsta/nvim-dap-virtual-text              |
| tpope/vim-commentary                         | commentary.vim: comment stuff out                                                                           | http://github.com/tpope/vim-commentary                         |
| tpope/vim-fugitive                           | fugitive.vim: A Git wrapper so awesome, it should be illegal                                                | http://github.com/tpope/vim-fugitive                           |
| tpope/vim-obsession                          | obsession.vim: continuously updated session files                                                           | http://github.com/tpope/vim-obsession                          |
| tpope/vim-rhubarb                            | rhubarb.vim: GitHub extension for fugitive.vim                                                              | http://github.com/tpope/vim-rhubarb                            |
| tpope/vim-surround                           | surround.vim: Delete/change/add parentheses/quotes/XML-tags/much more with ease                             | http://github.com/tpope/vim-surround                           |
| tpope/vim-unimpaired                         | unimpaired.vim: Pairs of handy bracket mappings                                                             | http://github.com/tpope/vim-unimpaired                         |
| vinnymeller/swagger-preview.nvim             | Start/stop a live preview of Swagger files from Neovim                                                      | http://github.com/vinnymeller/swagger-preview.nvim             |
| zbirenbaum/copilot-cmp                       | Lua plugin to turn github copilot into a cmp source                                                         | http://github.com/zbirenbaum/copilot-cmp                       |
| zbirenbaum/copilot.lua                       | Fully featured & enhanced replacement for copilot.vim complete with API for interacting with Github Copilot | http://github.com/zbirenbaum/copilot.lua                       |

<!---ENDPLUGINS-->

### Notes

**This project is my personal vimrc**. Feel free to send me suggestions through
the [issues page](https://github.com/tecfu/.vim/issues/new) or to send me
improvements through the [pull requestspage](https://github.com/tecfu/.vim/pulls).

- If some characters do not render correctly

Make sure you install powerline fonts
