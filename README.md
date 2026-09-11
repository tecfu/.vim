# vimrc

## Prerequisites

- Mac: You will to want to use a terminal that supports Truecolor, like:
  - Alacritty
  - Extraterm
- Ubuntu: `xsel` is installed by this setup (see INSTALL.sh) and is **required for clipboard support** (`"+y` / `"+p`). Neovim silently skips clipboard setup when it's missing, so yanking appears to do nothing. Restore it with:
  ```bash
  sudo apt-get install -y xsel
  ```
  Verify in nvim: `:echo provider#clipboard#Executable()` should print `xsel_override`.

## Installation for Vim

### Clone this repository and its submodules into your home directory

```sh
git clone --recurse-submodules https://github.com/tecfu/.vim ~/.vim
```

### Run Install Script

```sh
. ~/.vim/INSTALL.sh
```

The installer returns a nonzero status when required configuration links,
plugin installation, or attempted LSP/tool installations fail, and summarizes
the failed steps. Plugin output is retained in `.install-plugins.log` and is
printed on failure. Missing optional build tools, fonts, or Python/PyYAML
support are reported as warnings rather than hidden.

### Windows configuration and startup

Run the installer from Git Bash. It honors an existing `XDG_CONFIG_HOME`;
otherwise native Windows Neovim uses `%LOCALAPPDATA%\nvim`. The installer
does not change your persistent environment variables. Enable Windows
Developer Mode or use an elevated shell for real symlinks; the installer
warns when a destination is only a copy and will not track repository edits.
Existing files are backed up as `.saved`, `.saved.1`, and so on without
overwriting older backups. `UNINSTALL.sh` uses the same configuration paths,
removes only matching managed symlinks, and restores the latest backup.

Windows keeps its native default shell for plugin commands. Use `:Bash`
for an interactive Git Bash terminal, or `:Bash <command>` for a Bash command.
MSYS-style home paths are normalized when loading native Windows Neovim.

YankRing still tracks ordinary yanks, but automatic clipboard ingestion on
startup/focus is disabled. To restore it, set
`let g:yankring_clipboard_monitor = 1` before loading this configuration.
The default CoC profile displays diagnostic messages in floating windows.
`:StringifyJSON` and visual `<leader>s` use native JSON escaping rather than
a Unix shell pipeline, preserving the original numeric precision and JSON
layout inside the resulting string.

### Language-server and formatter installation

`INSTALL.sh` runs `scripts/install-lsp-tools.py` with a working Python 3
interpreter (`python3`, falling back to `python`). It reads shared LSP metadata,
EFM tool metadata, and runnable CoC profile `sources`, checks the declared
executables, and deduplicates install commands. Python CLI tools use `pipx`
to avoid system-Python restrictions on modern Ubuntu.
EFM metadata selects the `tecfu/efm-langserver` fork required for in-place
Markdown formatting and checks auxiliary formatters such as `prettierd`
independently of the EFM executable.

PyYAML is needed to read EFM metadata; if missing, the installer warns and
continues with LSP and CoC metadata. On Ubuntu, install it with
`sudo apt-get install python3-yaml`; elsewhere, install PyYAML in the Python
environment used for the script.

Preview missing tools without running installation commands:

```sh
python3 scripts/install-lsp-tools.py --dry-run
```

The root `install-lsp-tools.py` remains a compatibility entry point to the
same implementation. Missing tools with manual-only sources are reported
rather than guessed.

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

| `NVIM_CONFIG` value | Mode | Description |
| --- | --- | --- |
| `coc` | [CoC](#mode-1-coc-coc) | Uses `coc.nvim` for completion and language server support |
| `cmp-efm` | [nvim-cmp + EFM](#mode-2-nvim-cmp--efm-cmp-efm) | EFM-only lint/format mode; does not start the shared real language servers |
| `cmp-builtin` | [nvim-cmp + Builtin](#mode-3-nvim-cmp--builtin-cmp-builtin---default) (Default) | Uses `nvim-cmp` for completion with native Neovim LSP and no `efm-langserver` dependency |

If `NVIM_CONFIG` is unset, empty, or set to any value other than `coc`/`cmp-efm`, it falls back to `cmp-builtin`.

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

- Most language servers are configured via CoC extensions in `~/.vim/coc-profiles/<profile>/extensions.json`
- Settings are in `~/.vim/coc-profiles/<profile>/coc-settings.json`
- See the [CoC Profiles](#coc-profiles) section above for managing multiple profiles
- Servers listed in `~/.vim/lsp-servers.json` (shared with `cmp-builtin`, see [Mode 3](#mode-3-nvim-cmp--builtin-cmp-builtin---default)) are registered automatically as generic `languageserver.*` entries at startup — you don't need a CoC extension or a `coc-settings.json` entry for those (e.g. Python's `basedpyright`/`ruff` diagnostics work in `coc` mode without installing `coc-pyright`/`coc-pylsp`)

**Installing language servers:**

```vim
:CocInstall coc-tsserver coc-go
```

#### Mode 2: nvim-cmp + EFM (`cmp-efm`)

**What it is:** Uses `nvim-cmp` as the completion UI and `efm-langserver` to wrap linters and formatters. This mode is intentionally **EFM-only**: it does not load the real language servers from `lsp-servers.json`.

**When to use:** If you want a single language server that can handle multiple tools (ESLint, Prettier, etc.) with project-specific configurations. Requires `efm-langserver` to be installed and runnable on your machine.

Switching from `cmp-builtin` to `cmp-efm` stops configuring servers such as
`basedpyright`, `gopls`, and `typescript-language-server`. EFM does not replace
their semantic completion, go-to-definition, references, or rename support.
Buffer/path completion remains available through `nvim-cmp`; linting and
formatting depend on the tools declared in the EFM configuration.

| Capability | `coc` | `cmp-builtin` | `cmp-efm` |
| --- | --- | --- | --- |
| Shared real language servers | Yes | Yes | No |
| Semantic navigation/completion | From configured servers/extensions | From configured servers | Not supplied by EFM |
| EFM lint/format tools | With an EFM-enabled CoC profile | No | Yes |

**Configuration:**

- EFM configuration is in `~/.vim/efm-langserver-config.yaml`
- The wrapper script at `~/.vim/efm-langserver-linter-wrapper.sh` intelligently uses project-local configs when available
- See [Advanced Linting with EFM-Langserver](#advanced-linting-with-efm-langserver) section for details

**Installing language servers:**

- EFM-langserver itself: Install from [github.com/mattn/efm-langserver](https://github.com/mattn/efm-langserver)
- Individual tools (ESLint, Prettier, etc.): Install via npm/pip as needed

#### Mode 3: nvim-cmp + Builtin (`cmp-builtin`) - Default

**What it is:** Uses `nvim-cmp` for completion and native Neovim LSP (`vim.lsp`), with each language server's `cmd`/`filetypes`/`settings` configured explicitly — no `efm-langserver` required.

**When to use:** For a modern, lightweight setup with direct LSP integration and no external universal-linter dependency. Recommended for most users, and required if you can't run `efm-langserver` on your machine.

**Configuration:**

Language servers are loaded from `~/.vim/lsp-servers.json`. This is a single, plain-JSON source of truth shared by both `cmp-builtin` and `coc` mode (see [Mode 1](#mode-1-coc-coc)), so a server only needs to be defined once to work in either mode. Pure lint/format-only tools that require `efm-langserver` (e.g. `flake8`, `markdownlint`) stay defined separately in `efm-langserver-config.yaml`, since that file is specific to [`cmp-efm` mode](#mode-2-nvim-cmp--efm-cmp-efm).

**Adding a Language Server:**

To add a new LSP, edit `~/.vim/lsp-servers.json` and add an entry to the `servers` array:

```json
{
  "name": "pyright",
  "filetypes": ["python"],
  "cmd": ["pyright-langserver", "--stdio"],
  "root_patterns": [".git", "requirements.txt"],
  "install": "pip install pyright"
}
```

**Configuration Fields:**

- `name`: (Required) A unique identifier for the server (used as the CoC `languageserver.<name>` key and the Neovim LSP client name).
- `filetypes`: (Required) Array of filetypes the server should attach to.
- `cmd`: (Required) Array — the command and arguments used to launch the server.
- `root_patterns`: Array of files/directories that indicate the project root (optional, defaults to `[".git"]`).
- `settings`: Object passed through as LSP `initializationOptions`/`workspace/didChangeConfiguration` settings (optional).
- `install`: Shell command to install the server binary (optional). Used by `INSTALL.sh` (via `jq`), and by both `coc` and `cmp-builtin` themselves at startup, to auto-install missing servers; also documents how to install it manually.

**Installing language servers:**

Installation is automatic in both `coc` and `cmp-builtin` mode: on startup, each server in `lsp-servers.json` is checked with `executable()`, and if missing, its `install` command runs in the background (a message is echoed when the install starts/finishes). Restart nvim once it completes so the new binary is picked up.

You can also install everything up front by running `INSTALL.sh` (requires `jq`), or install a server manually using its `install` command, e.g.:

```sh
# TypeScript/JavaScript
npm install -g typescript-language-server typescript

# Python
pip install basedpyright ruff

# Go
go install golang.org/x/tools/gopls@latest
```

**Windows: "Installed" but the binary still isn't found (stale `PATH`)**

On Windows, if an install places a new binary in a directory that was just added to `PATH` (e.g. `pip install --user` adding to `%APPDATA%\Python\Python3xx\Scripts`), an already-running terminal/app (and any nvim/VS Code instance spawned from it) **will not see the update** — child processes only inherit `PATH` from their parent at the moment they were spawned, and Windows env var changes are only picked up by processes started fresh after the change (or after a full logoff/logon). Simply opening a new tab in an already-running terminal app does **not** help, since the new tab is a child of that already-running (stale) process.

To confirm this is what's happening, check whether the new directory is missing from the current session:

```powershell
$env:Path -split ';' | Select-String Python
```

To fix it without restarting anything, reload `PATH` from the registry into the current session:

```powershell
$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
```

Otherwise, fully quit (not just close a tab of) the terminal/app that will launch nvim, or log off and back on.

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

**Servers currently defined in `lsp-servers.json`:**

- Python: `basedpyright` (type-checking), `ruff` (linting)
- JavaScript/TypeScript: `ts_ls`
- Go: `gopls`
- SQL: `sqlls`

See the [full list of available servers in nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md) for reference `cmd`/`filetypes` values when adding new entries (note: `cmp-builtin` mode no longer depends on nvim-lspconfig's own server definitions — `lsp-servers.json` is self-contained).

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
