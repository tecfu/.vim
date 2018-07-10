# vimrc

Configuration files for the Vim editor.

- Setup for development in the following languages: 
	- go
	- nodejs / javascript
	- PHP / Hack

- It includes editor preferences, colorscheme, plugins, custom functions and more.

**This project is my personal vimrc**. Feel free to send me suggestions through
the [issues page](https://github.com/tecfu/.vim/issues/new) or to send me
improvements through the [pull requests
page](https://github.com/tecfu/.vim/pulls).


## Quick start

### Clone this repository into your home directory.

```
git clone git://github.com/tecfu/dotfiles ~/dotfiles
```

### Run Install Script

```
$ . ~/dotfiles/.vim/INSTALL.sh
```

### Run Vim

- To install plugins on your first run:

```
vim -c "PlugInstall"
```

## Optional

### Configure your terminal to use a powerline font
- i.e.: Ubuntu Mono derivative Powerline

### [Optional] Remap ESC to CAPS LOCK

- Linux ~/.xmodmap 
```
! Swap caps lock and escape
remove Lock = Caps_Lock
keysym Escape = Caps_Lock
keysym Caps_Lock = Escape
add Lock = Caps_Lock
```

### [Configure tern for vim to show argument hints (if your machine can handle it)]
```
g:tern_show_argument_hints="on_move"
```
Default is g:tern_show_argument_hints=0


### [Optional/Recommended] Install Silver Searcher

```
sudo -S apt-get install silversearcher-ag'
```

## Adding your own plugins

- This .vimrc uses junegunn/vim-plug to manage plugin installation.  You can add
  new plugins by appending them to the file: .vimrc.plugins .

- Once you have added a new plugin, you can auto-generate a tabular brief
  summary in the README.md file by running a grunt task that does this for you:

```
$ grunt
```

If you don't already have grunt installed you'll need to run the following
commands:

```
$ npm install grunt -g
$ npm install
$ grunt
```

For more information on grunt see gruntjs.com. 

## Plugin List 

<!---PLUGINS-->
| Name                                                                                                              | Description                                                                                                    | Website                                                    |
| ----------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| <a href="http://github.com/airblade/vim-gitgutter">airblade/vim-gitgutter</a>                                     | A Vim plugin which shows a git diff in the gutter (sign column) and stages/undoes hunks.                       | http://github.com/airblade/vim-gitgutter                   |
| <a href="http://github.com/aklt/plantuml-syntax">aklt/plantuml-syntax</a>                                         | vim syntax file for plantuml                                                                                   | http://github.com/aklt/plantuml-syntax                     |
| <a href="http://github.com/altercation/vim-colors-solarized">altercation/vim-colors-solarized</a>                 | precision colorscheme for the vim text editor                                                                  | http://github.com/altercation/vim-colors-solarized         |
| <a href="http://github.com/blindFS/vim-taskwarrior">blindFS/vim-taskwarrior</a>                                   | vim interface for taskwarrior                                                                                  | http://github.com/blindFS/vim-taskwarrior                  |
| <a href="http://github.com/bling/vim-airline">bling/vim-airline</a>                                               | lean & mean status/tabline for vim that's light as air                                                         | http://github.com/bling/vim-airline                        |
| <a href="http://github.com/bronson/vim-visual-star-search">bronson/vim-visual-star-search</a>                     | Start a * or # search from a visual block                                                                      | http://github.com/bronson/vim-visual-star-search           |
| <a href="http://github.com/brookhong/DBGPavim">brookhong/DBGPavim</a>                                             | This is a plugin to enable php debug in VIM with Xdebug, with a new debug engine.                              | http://github.com/brookhong/DBGPavim                       |
| <a href="http://github.com/Chiel92/vim-autoformat">Chiel92/vim-autoformat</a>                                     | Provide easy code formatting in Vim by integrating existing code formatters.                                   | http://github.com/Chiel92/vim-autoformat                   |
| <a href="http://github.com/ctrlpvim/ctrlp.vim">ctrlpvim/ctrlp.vim</a>                                             | Active fork of kien/ctrlp.vim—Fuzzy file, buffer, mru, tag, etc finder.                                        | http://github.com/ctrlpvim/ctrlp.vim                       |
| <a href="http://github.com/danro/rename.vim">danro/rename.vim</a>                                                 | Rename the current file in the vim buffer + retain relative path.                                              | http://github.com/danro/rename.vim                         |
| <a href="http://github.com/Dewdrops/SearchComplete">Dewdrops/SearchComplete</a>                                   | Tab completion of words inside of a search ('/')                                                               | http://github.com/Dewdrops/SearchComplete                  |
| <a href="http://github.com/dhruvasagar/vim-table-mode">dhruvasagar/vim-table-mode</a>                             | VIM Table Mode for instant table creation.                                                                     | http://github.com/dhruvasagar/vim-table-mode               |
| <a href="http://github.com/ervandew/supertab">ervandew/supertab</a>                                               | Perform all your vim insert mode completions with Tab                                                          | http://github.com/ervandew/supertab                        |
| <a href="http://github.com/fatih/vim-go">fatih/vim-go</a>                                                         | Go development plugin for Vim                                                                                  | http://github.com/fatih/vim-go                             |
| <a href="http://github.com/FooSoft/vim-argwrap">FooSoft/vim-argwrap</a>                                           | Wrap and unwrap function arguments, lists, and dictionaries in Vim                                             | http://github.com/FooSoft/vim-argwrap                      |
| <a href="http://github.com/fs111/pydoc.vim">fs111/pydoc.vim</a>                                                   | pydoc integration for the best text editor on earth                                                            | http://github.com/fs111/pydoc.vim                          |
| <a href="http://github.com/godlygeek/csapprox">godlygeek/csapprox</a>                                             | Make gvim-only colorschemes work transparently in terminal vim                                                 | http://github.com/godlygeek/csapprox                       |
| <a href="http://github.com/godlygeek/tabular">godlygeek/tabular</a>                                               | Vim script for text filtering and alignment                                                                    | http://github.com/godlygeek/tabular                        |
| <a href="http://github.com/gorkunov/smartpairs.vim">gorkunov/smartpairs.vim</a>                                   | Enchanted visual (selection) mode for Vim                                                                      | http://github.com/gorkunov/smartpairs.vim                  |
| <a href="http://github.com/gregsexton/gitv">gregsexton/gitv</a>                                                   | gitk for Vim.                                                                                                  | http://github.com/gregsexton/gitv                          |
| <a href="http://github.com/heavenshell/vim-jsdoc">heavenshell/vim-jsdoc</a>                                       | Generate JSDoc to your JavaScript code.                                                                        | http://github.com/heavenshell/vim-jsdoc                    |
| <a href="http://github.com/hhvm/vim-hack">hhvm/vim-hack</a>                                                       | Syntax highlighting and typechecker integration for Hack.                                                      | http://github.com/hhvm/vim-hack                            |
| <a href="http://github.com/int3/vim-extradite">int3/vim-extradite</a>                                             | A git commit browser for vim. Extends fugitive.vim.                                                            | http://github.com/int3/vim-extradite                       |
| <a href="http://github.com/itchyny/calendar.vim">itchyny/calendar.vim</a>                                         | A calendar application for Vim                                                                                 | http://github.com/itchyny/calendar.vim                     |
| <a href="http://github.com/kien/ctrlp.vim">kien/ctrlp.vim</a>                                                     | Fuzzy file, buffer, mru, tag, etc finder.                                                                      | http://github.com/kien/ctrlp.vim                           |
| <a href="http://github.com/kshenoy/vim-signature">kshenoy/vim-signature</a>                                       | Plugin to toggle, display and navigate marks                                                                   | http://github.com/kshenoy/vim-signature                    |
| <a href="http://github.com/Lokaltog/vim-easymotion">Lokaltog/vim-easymotion</a>                                   | Vim motions on speed!                                                                                          | http://github.com/Lokaltog/vim-easymotion                  |
| <a href="http://github.com/m2mdas/phpcomplete-extended">m2mdas/phpcomplete-extended</a>                           | A fast, extensible, context aware autocomplete plugin for PHP composer projects with code inspection features. | http://github.com/m2mdas/phpcomplete-extended              |
| <a href="http://github.com/majutsushi/tagbar">majutsushi/tagbar</a>                                               | Vim plugin that displays tags in a window, ordered by scope                                                    | http://github.com/majutsushi/tagbar                        |
| <a href="http://github.com/maksimr/vim-jsbeautify">maksimr/vim-jsbeautify</a>                                     | vim plugin which formated javascript files by js-beautify                                                      | http://github.com/maksimr/vim-jsbeautify                   |
| <a href="http://github.com/marijnh/tern_for_vim">marijnh/tern_for_vim</a>                                         | Tern plugin for Vim                                                                                            | http://github.com/marijnh/tern_for_vim                     |
| <a href="http://github.com/MattesGroeger/vim-bookmarks">MattesGroeger/vim-bookmarks</a>                           | Vim bookmark plugin                                                                                            | http://github.com/MattesGroeger/vim-bookmarks              |
| <a href="http://github.com/mattn/emmet-vim">mattn/emmet-vim</a>                                                   | emmet for vim: http://emmet.io/                                                                                | http://github.com/mattn/emmet-vim                          |
| <a href="http://github.com/matze/vim-move">matze/vim-move</a>                                                     | Plugin to move lines and selections up and down                                                                | http://github.com/matze/vim-move                           |
| <a href="http://github.com/mbbill/undotree">mbbill/undotree</a>                                                   | The ultimate undo history visualizer for VIM                                                                   | http://github.com/mbbill/undotree                          |
| <a href="http://github.com/mileszs/ack.vim">mileszs/ack.vim</a>                                                   | Vim plugin for the Perl module / CLI script 'ack'                                                              | http://github.com/mileszs/ack.vim                          |
| <a href="http://github.com/moll/vim-node">moll/vim-node</a>                                                       | Tools and environment to make Vim superb for developing with Node.js. Like Rails.vim for Node.                 | http://github.com/moll/vim-node                            |
| <a href="http://github.com/mustache/vim-mustache-handlebars">mustache/vim-mustache-handlebars</a>                 | mustache and handlebars mode for vim                                                                           | http://github.com/mustache/vim-mustache-handlebars         |
| <a href="http://github.com/mxw/vim-jsx">mxw/vim-jsx</a>                                                           | React JSX syntax highlighting and indenting for vim.                                                           | http://github.com/mxw/vim-jsx                              |
| <a href="http://github.com/nathanaelkane/vim-indent-guides">nathanaelkane/vim-indent-guides</a>                   | A Vim plugin for visually displaying indent levels in code                                                     | http://github.com/nathanaelkane/vim-indent-guides          |
| <a href="http://github.com/OrangeT/vim-csharp">OrangeT/vim-csharp</a>                                             | Enhancement's to Vim's C-Sharp Functionality                                                                   | http://github.com/OrangeT/vim-csharp                       |
| <a href="http://github.com/othree/eregex.vim">othree/eregex.vim</a>                                               | Perl/Ruby style regexp notation for Vim                                                                        | http://github.com/othree/eregex.vim                        |
| <a href="http://github.com/pangloss/vim-javascript">pangloss/vim-javascript</a>                                   | Vastly improved Javascript indentation and syntax support in Vim.                                              | http://github.com/pangloss/vim-javascript                  |
| <a href="http://github.com/Peeja/vim-cdo">Peeja/vim-cdo</a>                                                       | Vim commands to run a command over every entry in the quickfix list (:Cdo) or location list (:Ldo).            | http://github.com/Peeja/vim-cdo                            |
| <a href="http://github.com/posva/vim-vue">posva/vim-vue</a>                                                       | Syntax Highlight for Vue.js components                                                                         | http://github.com/posva/vim-vue                            |
| <a href="http://github.com/scrooloose/syntastic">scrooloose/syntastic</a>                                         | Syntax checking hacks for vim                                                                                  | http://github.com/scrooloose/syntastic                     |
| <a href="http://github.com/scrooloose/vim-slumlord">scrooloose/vim-slumlord</a>                                   | Inline previews for Plantuml sequence diagrams. OMG!                                                           | http://github.com/scrooloose/vim-slumlord                  |
| <a href="http://github.com/shawncplus/phpcomplete.vim">shawncplus/phpcomplete.vim</a>                             | Improved PHP omnicompletion                                                                                    | http://github.com/shawncplus/phpcomplete.vim               |
| <a href="http://github.com/Shougo/deoplete.nvim">Shougo/deoplete.nvim</a>                                         | 🌠 Dark powered asynchronous completion framework for neovim/Vim8                                              | http://github.com/Shougo/deoplete.nvim                     |
| <a href="http://github.com/Shougo/neocomplete">Shougo/neocomplete</a>                                             | Next generation completion framework after neocomplcache                                                       | http://github.com/Shougo/neocomplete                       |
| <a href="http://github.com/Shougo/neomru.vim">Shougo/neomru.vim</a>                                               | MRU plugin includes unite.vim/denite.nvim MRU sources                                                          | http://github.com/Shougo/neomru.vim                        |
| <a href="http://github.com/Shougo/neoyank.vim">Shougo/neoyank.vim</a>                                             | Saves yank history includes unite.vim history/yank source.                                                     | http://github.com/Shougo/neoyank.vim                       |
| <a href="http://github.com/Shougo/unite.vim">Shougo/unite.vim</a>                                                 | 🐉 Unite and create user interfaces                                                                            | http://github.com/Shougo/unite.vim                         |
| <a href="http://github.com/Shougo/vimproc">Shougo/vimproc</a>                                                     | Interactive command execution in Vim.                                                                          | http://github.com/Shougo/vimproc                           |
| <a href="http://github.com/Shougo/vimshell">Shougo/vimshell</a>                                                   | 🐚 Powerful shell implemented by vim.                                                                          | http://github.com/Shougo/vimshell                          |
| <a href="http://github.com/sickill/vim-pasta">sickill/vim-pasta</a>                                               | Pasting in Vim with indentation adjusted to destination context                                                | http://github.com/sickill/vim-pasta                        |
| <a href="http://github.com/sidorares/node-vim-debugger">sidorares/node-vim-debugger</a>                           | node.js step by step debugging from vim                                                                        | http://github.com/sidorares/node-vim-debugger              |
| <a href="http://github.com/StanAngeloff/php.vim">StanAngeloff/php.vim</a>                                         | An up-to-date Vim syntax for PHP (7.x supported)                                                               | http://github.com/StanAngeloff/php.vim                     |
| <a href="http://github.com/supermomonga/vimshell-inline-history.vim">supermomonga/vimshell-inline-history.vim</a> | Inline history completion for VimShell                                                                         | http://github.com/supermomonga/vimshell-inline-history.vim |
| <a href="http://github.com/tecfu/vimshell-inline-history.vim">tecfu/vimshell-inline-history.vim</a>               | Inline history completion for VimShell                                                                         | http://github.com/tecfu/vimshell-inline-history.vim        |
| <a href="http://github.com/tecfu/YankRing.vim">tecfu/YankRing.vim</a>                                             | Maintains a history of previous yanks, changes and deletes                                                     | http://github.com/tecfu/YankRing.vim                       |
| <a href="http://github.com/terryma/vim-multiple-cursors">terryma/vim-multiple-cursors</a>                         | True Sublime Text style multiple selections for Vim                                                            | http://github.com/terryma/vim-multiple-cursors             |
| <a href="http://github.com/tomtom/tcomment_vim">tomtom/tcomment_vim</a>                                           | An extensible & universal comment vim-plugin that also handles embedded filetypes                              | http://github.com/tomtom/tcomment_vim                      |
| <a href="http://github.com/tpope/vim-abolish">tpope/vim-abolish</a>                                               | abolish.vim: easily search for, substitute, and abbreviate multiple variants of a word                         | http://github.com/tpope/vim-abolish                        |
| <a href="http://github.com/tpope/vim-fugitive">tpope/vim-fugitive</a>                                             | fugitive.vim: A Git wrapper so awesome, it should be illegal                                                   | http://github.com/tpope/vim-fugitive                       |
| <a href="http://github.com/tpope/vim-obsession">tpope/vim-obsession</a>                                           | obsession.vim: continuously updated session files                                                              | http://github.com/tpope/vim-obsession                      |
| <a href="http://github.com/tpope/vim-surround">tpope/vim-surround</a>                                             | surround.vim: quoting/parenthesizing made simple                                                               | http://github.com/tpope/vim-surround                       |
| <a href="http://github.com/vim-scripts/SearchComplete">vim-scripts/SearchComplete</a>                             | Tab completion of words inside of a search ('/')                                                               | http://github.com/vim-scripts/SearchComplete               |
| <a href="http://github.com/vim-vdebug/vdebug">vim-vdebug/vdebug</a>                                               | Multi-language DBGP debugger client for Vim (PHP, Python, Perl, Ruby, etc.)                                    | http://github.com/vim-vdebug/vdebug                        |
| <a href="http://github.com/w0rp/ale">w0rp/ale</a>                                                                 | Asynchronous Lint Engine                                                                                       | http://github.com/w0rp/ale                                 |
<!---ENDPLUGINS-->

### Color Scheme

elrodeo		https://github.com/chmllr/elrodeo-colorscheme


### Notes
- Golang shortcuts

```
<leader>r <Plug>(go-run)
<leader>b <Plug>(go-build)
<leader>t <Plug>(go-test)
<leader>c <Plug>(go-coverage)
``` 

- Installing Vim 8 on Ubuntu 14.04:

```
sudo add-apt-repository ppa:pi-rho/dev
```

https://launchpad.net/~pi-rho/+archive/ubuntu/dev


## Todo

- When opened, make unite traverse up the directory structure incrementally with each "f" keypress.

