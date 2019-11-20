```
   ____  __ __  ____     ___  _      ____    ___  ____   __  _____
  /    ⎞⎟  ⎞  ⎞⎟    \   /  _]⎟ ⎞    l    ⎠  /  _]⎟    \ ⎛  ⎟/ ___/
 ⎛  A  ⎟⎟  ⎟  ⎟⎟  D  ) /  [_ ⎟ ⎟     ⎟  ⎛  /  [_ ⎟  _  ⎞⎩_ (   \_
 ⎟     ⎟⎟  ⎟  ⎟⎟    / ⎛    _]⎟ l___  ⎟  ⎟ ⎛    _]⎟  ⎟  ⎟  \⎠\__  ⎞
 ⎟  _  ⎟⎟  :  ⎟⎟    \ ⎟   [_ ⎟     ⎞ ⎟  ⎟ ⎟   [_ ⎟  ⎟  ⎟    /  \ ⎟
 ⎟  ⎟  ⎟⎟     ⎟⎟  .  ⎞⎟     ⎞⎟     ⎟_⎠  l ⎟     ⎞⎟  ⎟  ⎟    \    ⎟
 ⎩__⎠__⎠\__,__⎠⎩__⎠\_⎠⎩_____⎠⎩_____⎠⎩____⎠⎣_____⎠⎩__⎠__⎠     \___j
  ___     ___   ______  _____  ____  _        ___  _____
 ⎟   \   /   \ ⎟      ⎞⎟     ⎟l    ⎞⎟ ⎞      /  _]/ ___/
 ⎟    \ /     ⎞⎟      ⎟⎟   __⎠ ⎟  ⌠ ⎟ ⎟     /  [_(   \_ 
 ⎟  D  ⎞|  O  ⎟⎝_⌠  ⌡_⌡⎟  l_   ⎟  ⎟ ⎟ l___ ⎛    _]\__  ⎞
 ⎟     ⎟|     ⎟  ⎟  ⎟  ⎟   _]  ⎟  ⎟ ⎟     ⎞⎟   [_ /  \ ⎟
 ⎟     ⎟⎝     ⎠  ⎟  ⎟  ⎟  T    ⎠  ⎝ ⎟     ⎟⎟     T\    ⎟
 ⎩_____⎠ \___/   ⎩__⎠  ⎩__⎠   ⎟____⎠⎩_____⎠⎩_____⎠ \___⎠
```

   * [Download and Installation](#download-and-installation)
   * [Stow packages](#stow-packages)
     * [dev package](#dev-package)
     * [os package](#os-package)
     * [term package](#term-package)
     * [vim package](#vim-package)
   * [Disclaimer](#disclaimer)
   * [Credits and Thanks](#credits-and-thanks)
   * [<a href="LICENSE">LICENSE</a> ](#license)


# Welcome to my dotfiles!
-------------------------

This is my collection of dotfiles, I use it to manage my bash-vim-tmux
configuration.

Symlinks to `$HOME` directory are handled with the excellent [GNU
Stow](http://www.gnu.org/software/stow/), available by default on every NIX
system package manager, nothing else is needed.  Dot files and dot folders are
encapsulated into 4 main stow packages

 + No error-prone homemade install script
 + Home folder is not polluted with version control files
 + simplicity
 + sobriety
 + clean organization 


## Download and Installation

**Get The Code**

Clone this repository, or better, fork it and clone **yours**:

```sh
$ cd $HOME
$ git clone github.com/USERNAME/dotfiles
$ cd dotfiles
```

Two features of my configuration are provided by Github-hosted external projects:

 * [vim-plug](https://github.com/junegunn/vim-plug) Minimalist Vim Plugin Manager
 * [gitmux](https://github.com/arl/gitmux) Git in your tmux status bar


**Install the dotfiles**

If your dotfiles repository is located under your `$HOME`, you can simply do,
while you are in your `dotfiles` repository:

```sh
$ stow dev
```

This will create symlinks of everything located under the `dev` stow package
(i.e the `dev` folder) in your home.

By default stow assumes you want to place the symlinks in the parent of the
current working directory, if that's not the case, pass `-t/--target` to set the
target directory, as in `stow -t $HOME dev`


You can also install multiple packages at once. To install *everything*:

```sh
$ stow bash dev os term vim
```

## Stow packages
----------------
Stow packages are simple folders located under the repository root. They
represent and contain the 4 categories of dotfiles:
 
+ os: operating system global configuration files
+ vim: full vim configuration (plugins, colorschemes, etc.)
+ dev: software development tools config
+ term: terminal configuration


### dev package

Global configuration for development tools like pylint, gdb and git


### os package

 - *Consolas* font, patched for use with [Vim lightline](https://github.com/itchyny/lightline.vim)
 - `.profile`
 - a simple system that lets you have some *unversioned* machine-specific settings


### term package

Package aimed at improving your terminal and shell:

+ customized customized tmux config: status-bar, 256 colors, loads of bindings, 
+ a powerful inputrc (global readline configuration file) improving your 
  productivity with each of your tools internally relying on readline (so
virtually everywhere you can write!). Every feature is detailed in the
comments in [.inputrc](./term/.inputrc)
+ A clear and informative prompt with colorful .dircolors [github.com/trapd00r/LS_COLORS](https://github.com/trapd00r/LS_COLORS)
![terminal screenshot](./screenshot.png)


### bash package

bash-specific stuff
+ configuration files
+ aliases
+ functions
+ completion

All ordered in nice and tidy `.bashrc` files, under `.bashrc.d` directory.

### vim package

I use [vim-plug](https://github.com/junegunn/vim-plug) to manage my vim plugins.
Here are *some* of them:

 - [nerdtree](https://github.com/scrooloose/nerdtree)
 - [vim-go](https://github.com/fatih/vim-go)
 - [vim-fugitive](https://github.com/tpope/vim-fugitive)
 - [taglist](https://github.com/vim-scripts/taglist.vim)
 - [vim-repeat](https://github.com/tpope/vim-repeat)
 - [vim-surround](https://github.com/tpope/vim-surround)
 - [ctrlp](https://github.com/ctrlpvim/ctrlp.vim)
 - [lightline](https://github.com/itchyny/lightline.vim)
 - [deoplete](https://github.com/Shougo/deoplete.nvim)

My [`.vimrc`](./vim/.vimrc) is well categorized and commented so that you and I
can easily find and modify what we are looking for.  Loads of colorschemes, I
change them often but eventually come back to
[desert256](http://www.vim.org/scripts/script.php?script_id=1243)


## Disclaimer

I only use Linux (Debian-based) OSes so i can't guarantee those configurations
will work anywhere else, not even that you will like any of it ;-) That being
said, mostly everything should work out of the box or with some minor changes,
adaptations or renamings in order to make it work on other Linux distros or
OSX (A lot of good stuff comes from other dotfiles repos that targets OSX)

Keep in mind that these dotfiles have been slowly and carefully crafted to suit
MY needs. I update them regularly as my needs, habits or mood change.
Anyway, share, transform, use it as a source of inspiration. I'd love to hear
that you found something useful here.


## Credits and Thanks

+ [Paulirish's Dotfiles](https://github.com/paulirish/dotfiles).
+ I decided to use GNU stow to manage my dotfiles after reading [Using GNU Stow to manage your dotfiles](http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html).
+ Ascii art generated on [bigtext.org](http://bigtext.org/).
+ To everybody developing and maintaining the project, files and plugins found here.
+ TOC generated with [github-markdown-tow](https://github.com/ekalinin/github-markdown-toc)


## [LICENSE](LICENSE)
