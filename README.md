# vimrc

Configuration for Vim > 8

## Installation

### Making sure you are using a compatible version of vim:

- Vim 8 on Ubuntu 20.04:

```bash
sudo apt-get install vim -y
```

- Vim 8.2 on Ubuntu 18.04/20.04:


```bash
sudo add-apt-repository ppa:jonathonf/vim
sudo apt-get update
sudo apt install vim
```

### Clone this repository and its submodules into your home directory.

```sh
git clone --recurse-submodules git://github.com/tecfu/.vim ~/.vim
```

### Run Install Script

```sh
$ . ~/.vim/INSTALL.sh
```

### coc.nvim 

> Why use coc.nvim?
> 
> - coc-snippets allows you to use VSCode snippets with vim

> coc.nvim tips

- List all installed extensions
```
:CocList extensions
```

- Access coc-settings.json
```
:CocConfig 
```

## Optional


### Configure your terminal to use a powerline font
- i.e.: Ubuntu Mono derivative Powerline

```sh
sudo apt-get install fonts-powerline
```

### [Optional/Recommended] Install Silver Searcher

```sh
sudo -S apt-get install silversearcher-ag'
```

## Adding your own plugins

- This .vimrc uses junegunn/vim-plug to manage plugin installation.  You can add
  new plugins by appending them to the file: .vimrc.plugins .

- Once you have added a new plugin, you can auto-generate a tabular brief
  summary in the README.md file by running a npm script that does this for you:

```sh
$ npm run update-plugin-list
```

## Troubleshooting

- CoC can't install plugins because npm registry is private
    ```
    npm config set registry https://registry.npmjs.org 
    ```

### Color Scheme

mango   https://github.com/goatslacker/mango.vim


## Plugin List 

<!---PLUGINS-->
| Name                              | Description                                                                                                      | Website                                             |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| airblade/vim-gitgutter            | A Vim plugin which shows git diff markers in the sign column and stages/previews/undoes hunks and partial hunks. | http://github.com/airblade/vim-gitgutter            |
| aklt/plantuml-syntax              | vim syntax file for plantuml                                                                                     | http://github.com/aklt/plantuml-syntax              |
| altercation/vim-colors-solarized  | precision colorscheme for the vim text editor                                                                    | http://github.com/altercation/vim-colors-solarized  |
| ap/vim-css-color                  | Preview colours in source code while editing                                                                     | http://github.com/ap/vim-css-color                  |
| bling/vim-airline                 | lean & mean status/tabline for vim that's light as air                                                           | http://github.com/bling/vim-airline                 |
| bronson/vim-visual-star-search    | Start a * or # search from a visual block                                                                        | http://github.com/bronson/vim-visual-star-search    |
| chr4/nginx.vim                    | Improved nginx vim plugin (incl. syntax highlighting)                                                            | http://github.com/chr4/nginx.vim                    |
| craigemery/vim-autotag            | Automatically discover and "properly" update ctags files on save                                                 | http://github.com/craigemery/vim-autotag            |
| danro/rename.vim                  | Rename the current file in the vim buffer + retain relative path.                                                | http://github.com/danro/rename.vim                  |
| easymotion/vim-easymotion         | Vim motions on speed!                                                                                            | http://github.com/easymotion/vim-easymotion         |
| FooSoft/vim-argwrap               | Wrap and unwrap function arguments, lists, and dictionaries in Vim                                               | http://github.com/FooSoft/vim-argwrap               |
| godlygeek/csapprox                | Make gvim-only colorschemes work transparently in terminal vim                                                   | http://github.com/godlygeek/csapprox                |
| godlygeek/tabular                 | Vim script for text filtering and alignment                                                                      | http://github.com/godlygeek/tabular                 |
| hashivim/vim-terraform            | basic vim/terraform integration                                                                                  | http://github.com/hashivim/vim-terraform            |
| heavenshell/vim-jsdoc             | Generate JSDoc to your JavaScript code.                                                                          | http://github.com/heavenshell/vim-jsdoc             |
| idanarye/vim-merginal             | Fugitive extension to manage and merge Git branches                                                              | http://github.com/idanarye/vim-merginal             |
| inkarkat/vim-ArgsAndMore          | Apply commands to multiple buffers and manage the argument list.                                                 | http://github.com/inkarkat/vim-ArgsAndMore          |
| itchyny/calendar.vim              | A calendar application for Vim                                                                                   | http://github.com/itchyny/calendar.vim              |
| jupyter-vim/jupyter-vim           | Make Vim talk to Jupyter kernels                                                                                 | http://github.com/jupyter-vim/jupyter-vim           |
| kshenoy/vim-signature             | Plugin to toggle, display and navigate marks                                                                     | http://github.com/kshenoy/vim-signature             |
| leafgarland/typescript-vim        | Typescript syntax files for Vim                                                                                  | http://github.com/leafgarland/typescript-vim        |
| luochen1990/rainbow               | Rainbow Parentheses Improved, shorter code, no level limit, smooth and fast, powerful configuration.             | http://github.com/luochen1990/rainbow               |
| maksimr/vim-jsbeautify            | vim plugin which formated javascript files by js-beautify                                                        | http://github.com/maksimr/vim-jsbeautify            |
| mattn/emmet-vim                   | emmet for vim: http://emmet.io/                                                                                  | http://github.com/mattn/emmet-vim                   |
| mbbill/undotree                   | The undo history visualizer for VIM                                                                              | http://github.com/mbbill/undotree                   |
| mechatroner/rainbow_csv           | 🌈Rainbow CSV - Vim plugin: Highlight columns in CSV and TSV files and run queries in SQL-like language          | http://github.com/mechatroner/rainbow_csv           |
| mileszs/ack.vim                   | Vim plugin for the Perl module / CLI script 'ack'                                                                | http://github.com/mileszs/ack.vim                   |
| moll/vim-node                     | Tools and environment to make Vim superb for developing with Node.js. Like Rails.vim for Node.                   | http://github.com/moll/vim-node                     |
| mustache/vim-mustache-handlebars  | mustache and handlebars mode for vim                                                                             | http://github.com/mustache/vim-mustache-handlebars  |
| mxw/vim-jsx                       | React JSX syntax highlighting and indenting for vim.                                                             | http://github.com/mxw/vim-jsx                       |
| nathanaelkane/vim-indent-guides   | A Vim plugin for visually displaying indent levels in code                                                       | http://github.com/nathanaelkane/vim-indent-guides   |
| neoclide/coc.nvim                 | Nodejs extension host for vim & neovim, load extensions like VSCode and host language servers.                   | http://github.com/neoclide/coc.nvim                 |
| othree/eregex.vim                 | Perl/Ruby style regexp notation for Vim                                                                          | http://github.com/othree/eregex.vim                 |
| pangloss/vim-javascript           | Vastly improved Javascript indentation and syntax support in Vim.                                                | http://github.com/pangloss/vim-javascript           |
| Peeja/vim-cdo                     | Vim commands to run a command over every entry in the quickfix list (:Cdo) or location list (:Ldo).              | http://github.com/Peeja/vim-cdo                     |
| posva/vim-vue                     | Syntax Highlight for Vue.js components                                                                           | http://github.com/posva/vim-vue                     |
| preservim/tagbar                  | Vim plugin that displays tags in a window, ordered by scope                                                      | http://github.com/preservim/tagbar                  |
| preservim/vim-markdown            | Markdown Vim Mode                                                                                                | http://github.com/preservim/vim-markdown            |
| puremourning/vimspector           | vimspector - A multi-language debugging system for Vim                                                           | http://github.com/puremourning/vimspector           |
| raghur/vim-ghost                  | Vim/Nvim client for GhostText - Edit browser text areas in Vim/Neovim                                            | http://github.com/raghur/vim-ghost                  |
| rbong/vim-flog                    | A fast, beautiful, and powerful git branch viewer for vim.                                                       | http://github.com/rbong/vim-flog                    |
| roxma/vim-hug-neovim-rpc          | EXPERIMENTAL                                                                                                     | http://github.com/roxma/vim-hug-neovim-rpc          |
| scrooloose/vim-slumlord           | Inline previews for Plantuml sequence diagrams. OMG!                                                             | http://github.com/scrooloose/vim-slumlord           |
| SpaceVim/nvim-yarp                | Yet Another Remote Plugin Framework for Neovim                                                                   | http://github.com/SpaceVim/nvim-yarp                |
| StanAngeloff/php.vim              | An up-to-date Vim syntax for PHP (7.x supported)                                                                 | http://github.com/StanAngeloff/php.vim              |
| stephpy/vim-yaml                  | Override vim syntax for yaml files                                                                               | http://github.com/stephpy/vim-yaml                  |
| tecfu/vim-move                    | Plugin to move lines and selections up and down                                                                  | http://github.com/tecfu/vim-move                    |
| tecfu/vimshell-inline-history.vim | Inline history completion for VimShell                                                                           | http://github.com/tecfu/vimshell-inline-history.vim |
| tecfu/YankRing.vim                | Maintains a history of previous yanks, changes and deletes                                                       | http://github.com/tecfu/YankRing.vim                |
| tomtom/tcomment_vim               | An extensible & universal comment vim-plugin that also handles embedded filetypes                                | http://github.com/tomtom/tcomment_vim               |
| tpope/vim-commentary              | commentary.vim: comment stuff out                                                                                | http://github.com/tpope/vim-commentary              |
| tpope/vim-fugitive                | fugitive.vim: A Git wrapper so awesome, it should be illegal                                                     | http://github.com/tpope/vim-fugitive                |
| tpope/vim-obsession               | obsession.vim: continuously updated session files                                                                | http://github.com/tpope/vim-obsession               |
| tpope/vim-surround                | surround.vim: Delete/change/add parentheses/quotes/XML-tags/much more with ease                                  | http://github.com/tpope/vim-surround                |
| tpope/vim-unimpaired              | unimpaired.vim: Pairs of handy bracket mappings                                                                  | http://github.com/tpope/vim-unimpaired              |
| valloric/MatchTagAlways           | A Vim plugin that always highlights the enclosing html/xml tags                                                  | http://github.com/valloric/MatchTagAlways           |
<!---ENDPLUGINS-->

### Notes

**This project is my personal vimrc**. Feel free to send me suggestions through
the [issues page](https://github.com/tecfu/.vim/issues/new) or to send me
improvements through the [pull requestspage](https://github.com/tecfu/.vim/pulls).


- If some characters dont render correctly

Make sure you install powerline fonts
