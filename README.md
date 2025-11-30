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

The list of enabled language servers is defined in `~/.vim/lua/lsp_servers.lua`:

```lua
return {
  'ts_ls',    -- TypeScript/JavaScript
  'pyright',  -- Python
  'gopls',    -- Go
  -- Add more servers here
}
```

Server names must match those used by [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md).

**Installing language servers:**

You must install the actual language server binaries on your system:

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

**Common language servers:**

- JavaScript/TypeScript: `ts_ls`
- Python: `pyright` or `pylsp`
- Go: `gopls`
- Rust: `rust_analyzer`
- C/C++: `clangd`
- Lua: `lua_ls`

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

| Name                              | Description                                                                                                                                                                           | Website                                               |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| airblade/vim-gitgutter            | A Vim plugin which shows git diff markers in the sign column and stages/previews/undoes hunks and partial hunks.                                                                      | <http://github.com/airblade/vim-gitgutter>            |
| altercation/vim-colors-solarized  | precision colorscheme for the vim text editor                                                                                                                                         | <http://github.com/altercation/vim-colors-solarized>  |
| ap/vim-css-color                  | Preview colours in source code while editing                                                                                                                                          | <http://github.com/ap/vim-css-color>                  |
| bling/vim-airline                 | lean & mean status/tabline for vim that's light as air                                                                                                                                | <http://github.com/bling/vim-airline>                 |
| bronson/vim-visual-star-search    | Start a \* or # search from a visual block                                                                                                                                            | <http://github.com/bronson/vim-visual-star-search>    |
| chr4/nginx.vim                    | Improved nginx vim plugin (incl. syntax highlighting)                                                                                                                                 | <http://github.com/chr4/nginx.vim>                    |
| craigemery/vim-autotag            | Automatically discover and "properly" update ctags files on save                                                                                                                      | <http://github.com/craigemery/vim-autotag>            |
| danro/rename.vim                  | Rename the current file in the vim buffer + retain relative path.                                                                                                                     | <http://github.com/danro/rename.vim>                  |
| easymotion/vim-easymotion         | Vim motions on speed!                                                                                                                                                                 | <http://github.com/easymotion/vim-easymotion>         |
| FooSoft/vim-argwrap               | Wrap and unwrap function arguments, lists, and dictionaries in Vim                                                                                                                    | <http://github.com/FooSoft/vim-argwrap>               |
| goatslacker/mango.vim             | A color scheme for vim                                                                                                                                                                | <http://github.com/goatslacker/mango.vim>             |
| godlygeek/csapprox                | Make gvim-only colorschemes work transparently in terminal vim                                                                                                                        | <http://github.com/godlygeek/csapprox>                |
| godlygeek/tabular                 | Vim script for text filtering and alignment                                                                                                                                           | <http://github.com/godlygeek/tabular>                 |
| heavenshell/vim-jsdoc             | Generate JSDoc to your JavaScript code.                                                                                                                                               | <http://github.com/heavenshell/vim-jsdoc>             |
| idanarye/vim-merginal             | Fugitive extension to manage and merge Git branches                                                                                                                                   | <http://github.com/idanarye/vim-merginal>             |
| inkarkat/vim-ArgsAndMore          | Apply commands to multiple buffers and manage the argument list.                                                                                                                      | <http://github.com/inkarkat/vim-ArgsAndMore>          |
| itchyny/calendar.vim              | A calendar application for Vim                                                                                                                                                        | <http://github.com/itchyny/calendar.vim>              |
| jupyter-vim/jupyter-vim           | Make Vim talk to Jupyter kernels                                                                                                                                                      | <http://github.com/jupyter-vim/jupyter-vim>           |
| kshenoy/vim-signature             | Plugin to toggle, display and navigate marks                                                                                                                                          | <http://github.com/kshenoy/vim-signature>             |
| leafgarland/typescript-vim        | Typescript syntax files for Vim                                                                                                                                                       | <http://github.com/leafgarland/typescript-vim>        |
| luochen1990/rainbow               | Rainbow Parentheses Improved, shorter code, no level limit, smooth and fast, powerful configuration.                                                                                  | <http://github.com/luochen1990/rainbow>               |
| maksimr/vim-jsbeautify            | vim plugin which formated javascript files by js-beautify                                                                                                                             | <http://github.com/maksimr/vim-jsbeautify>            |
| mattn/emmet-vim                   | emmet for vim: <http://emmet.io/>                                                                                                                                                     | <http://github.com/mattn/emmet-vim>                   |
| mbbill/undotree                   | The undo history visualizer for VIM                                                                                                                                                   | <http://github.com/mbbill/undotree>                   |
| mechatroner/rainbow_csv           | 🌈Rainbow CSV - Vim plugin: Highlight columns in CSV and TSV files and run queries in SQL-like language                                                                               | <http://github.com/mechatroner/rainbow_csv>           |
| mileszs/ack.vim                   | Vim plugin for the Perl module / CLI script 'ack'                                                                                                                                     | <http://github.com/mileszs/ack.vim>                   |
| moll/vim-node                     | Tools and environment to make Vim superb for developing with Node.js. Like Rails.vim for Node.                                                                                        | <http://github.com/moll/vim-node>                     |
| mustache/vim-mustache-handlebars  | mustache and handlebars mode for vim                                                                                                                                                  | <http://github.com/mustache/vim-mustache-handlebars>  |
| mxw/vim-jsx                       | React JSX syntax highlighting and indenting for vim.                                                                                                                                  | <http://github.com/mxw/vim-jsx>                       |
| nathanaelkane/vim-indent-guides   | A Vim plugin for visually displaying indent levels in code                                                                                                                            | <http://github.com/nathanaelkane/vim-indent-guides>   |
| neoclide/coc.nvim                 | Nodejs extension host for vim & neovim, load extensions like VSCode and host language servers.                                                                                        | <http://github.com/neoclide/coc.nvim>                 |
| othree/eregex.vim                 | Perl/Ruby style regexp notation for Vim                                                                                                                                               | <http://github.com/othree/eregex.vim>                 |
| pangloss/vim-javascript           | Vastly improved Javascript indentation and syntax support in Vim.                                                                                                                     | <http://github.com/pangloss/vim-javascript>           |
| Peeja/vim-cdo                     | Vim commands to run a command over every entry in the quickfix list (:Cdo) or location list (:Ldo).                                                                                   | <http://github.com/Peeja/vim-cdo>                     |
| posva/vim-vue                     | Syntax Highlight for Vue.js components                                                                                                                                                | <http://github.com/posva/vim-vue>                     |
| preservim/tagbar                  | Vim plugin that displays tags in a window, ordered by scope                                                                                                                           | <http://github.com/preservim/tagbar>                  |
| preservim/vim-markdown            | Markdown Vim Mode                                                                                                                                                                     | <http://github.com/preservim/vim-markdown>            |
| puremourning/vimspector           | vimspector - A multi-language debugging system for Vim                                                                                                                                | <http://github.com/puremourning/vimspector>           |
| raghur/vim-ghost                  | Vim/Nvim client for GhostText - Edit browser text areas in Vim/Neovim                                                                                                                 | <http://github.com/raghur/vim-ghost>                  |
| rbong/vim-flog                    | A fast, beautiful, and powerful git branch viewer for vim.                                                                                                                            | <http://github.com/rbong/vim-flog>                    |
| roxma/vim-hug-neovim-rpc          | EXPERIMENTAL                                                                                                                                                                          | <http://github.com/roxma/vim-hug-neovim-rpc>          |
| scrooloose/vim-slumlord           | Inline previews for Plantuml sequence diagrams. OMG!                                                                                                                                  | <http://github.com/scrooloose/vim-slumlord>           |
| sheerun/vim-polyglot              | A solid language pack for Vim.                                                                                                                                                        | <http://github.com/sheerun/vim-polyglot>              |
| Shougo/vimproc                    | Interactive command execution in Vim.                                                                                                                                                 | <http://github.com/Shougo/vimproc>                    |
| Shougo/vimshell                   | 🐚 Powerful shell implemented by vim.                                                                                                                                                 | <http://github.com/Shougo/vimshell>                   |
| SpaceVim/nvim-yarp                | Yet Another Remote Plugin Framework for Neovim                                                                                                                                        | <http://github.com/SpaceVim/nvim-yarp>                |
| StanAngeloff/php.vim              | An up-to-date Vim syntax for PHP (7.x supported)                                                                                                                                      | <http://github.com/StanAngeloff/php.vim>              |
| stephpy/vim-yaml                  | Override vim syntax for yaml files                                                                                                                                                    | <http://github.com/stephpy/vim-yaml>                  |
| tecfu/tokyonight-vim              | A clean, dark vim colorscheme that celebrates the lights of downtown Tokyo at night, based on a VSCode theme by @enkia with the same name [Archived because I'm no longer using this] | <http://github.com/tecfu/tokyonight-vim>              |
| tecfu/vim-move                    | Plugin to move lines and selections up and down                                                                                                                                       | <http://github.com/tecfu/vim-move>                    |
| tecfu/vimshell-inline-history.vim | Inline history completion for VimShell                                                                                                                                                | <http://github.com/tecfu/vimshell-inline-history.vim> |
| tecfu/YankRing.vim                | Maintains a history of previous yanks, changes and deletes                                                                                                                            | <http://github.com/tecfu/YankRing.vim>                |
| tomtom/tcomment_vim               | An extensible & universal comment vim-plugin that also handles embedded filetypes                                                                                                     | <http://github.com/tomtom/tcomment_vim>               |
| tpope/vim-commentary              | commentary.vim: comment stuff out                                                                                                                                                     | <http://github.com/tpope/vim-commentary>              |
| tpope/vim-fugitive                | fugitive.vim: A Git wrapper so awesome, it should be illegal                                                                                                                          | <http://github.com/tpope/vim-fugitive>                |
| tpope/vim-obsession               | obsession.vim: continuously updated session files                                                                                                                                     | <http://github.com/tpope/vim-obsession>               |
| tpope/vim-surround                | surround.vim: Delete/change/add parentheses/quotes/XML-tags/much more with ease                                                                                                       | <http://github.com/tpope/vim-surround>                |
| tpope/vim-unimpaired              | unimpaired.vim: Pairs of handy bracket mappings                                                                                                                                       | <http://github.com/tpope/vim-unimpaired>              |
| valloric/MatchTagAlways           | A Vim plugin that always highlights the enclosing html/xml tags                                                                                                                       | <http://github.com/valloric/MatchTagAlways>           |

<!---ENDPLUGINS-->

### Notes

**This project is my personal vimrc**. Feel free to send me suggestions through
the [issues page](https://github.com/tecfu/.vim/issues/new) or to send me
improvements through the [pull requestspage](https://github.com/tecfu/.vim/pulls).

- If some characters do not render correctly

Make sure you install powerline fonts
