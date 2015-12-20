```
   ____  __ __  ____     ___  _      ____    ___  ____   __  _____
  /    ⎞⎟  ⎞  ⎞⎟    \   /  _]⎟ ⎞    l    j  /  _]⎟    \ ⎛  ⎟/ ___/
 ⎛  A  ⎟⎟  ⎟  ⎟⎟  D  ) /  [_ ⎟ ⎟     ⎟  T  /  [_ ⎟  _  ⎞l_ (   \_
 ⎟     ⎟⎟  ⎟  ⎟⎟    / ⎛    _]⎟ l___  ⎟  ⎟ ⎛    _]⎟  ⎟  ⎟  \⎠\__  ⎞
 ⎟  _  ⎟⎟  :  ⎟⎟    \ ⎟   [_ ⎟     ⎞ ⎟  ⎟ ⎟   [_ ⎟  ⎟  ⎟    /  \ ⎟
 ⎟  ⎟  ⎟l     ⎟⎟  .  ⎞⎟     ⎞⎟     ⎟_j  l ⎟     ⎞⎟  ⎟  ⎟    \    ⎟
 ⎩__⎠__⎠\__,__⎠⎩__⎠\_⎠⎩_____⎠⎩_____⎠⎩____⎠⎣_____⎠⎩__⎠__⎠     \___j
  ___     ___   ______  _____  ____  _        ___  _____
 ⎟   \   /   \ ⎟      ⎞⎟     ⎟l    ⎞⎟ ⎞      /  _]/ ___/
 ⎟    \ /     ⎞⎟      ⎟⎟   __j ⎟  ⌠ ⎟ ⎟     /  [_(   \_ 
 ⎟  D  ⎞⎟  O  ⎟⎝_⌠  ⌡_⌡⎟  l_   ⎟  ⎟ ⎟ l___ ⎛    _]\__  ⎞
 ⎟     ⎟⎟     ⎟  ⎟  ⎟  ⎟   _]  ⎟  ⎟ ⎟     T⎟   [_ /  \ ⎟
 ⎟     ⎟\     !  ⎟  ⎟  ⎟  T    ⎠  ⎝ ⎟     ⎟⎟     T\    ⎟
 ⎩_____⎠ \___/   ⎩__⎠  ⎩__⎠   ⎟____⎠⎩_____⎠⎩_____⎠ \___⎠
 ```

# Welcome to my dotfiles configuration

This repository represents my collection of dotfiles, I use it on all
my boxes, at home and at work.

Feel free to use, fork, clone, improve!

Dotfiles are handled with the excellent [http://www.gnu.org/software/stow/](GNU Stow),
available by default on every NIX system package manager, nothing else is needed
to install the dotfiles

 - No error-prone homemade install script
 - Home folder is not polluted with version control files
 - simplicity
 - sobriety
 - clean organization 


## Stow packages

 Stow packages are simple folders located under the repository root. They represent the 4
 categories of dotfiles
  - os: operating system global configuration files
  - vim: full vim configuration (plugins, colorschemes, etc.)
  - dev: software development tools config
  - term: terminal configuration

### How To Use?

Let's call `dotfiles` the root folder of this repository.
`dotfiles` should be, for sake of simplicity, a child folder
of your home directory (where all the dotfiles link go)

So, once your current directory is `$HOME/dotfiles`, simply do:
```
stow PACKAGENAME
```
For example, to install dotfiles contained in the dev folder/package, do:
```
stow dev
```

You can also install more than one package at once, so that this will install everything:
```stow dev os term vim```

### dev package

Global configuration for development tools like pylint, gdb and git

### os package

 - *Consolas* font (patched for use with [https://github.com/itchyny/lightline.vim](vim lightline))
 - .profile, with a possibility to use some machine specific settings

### term package

 Though this package contains some of shell-agnostic utilities,  shell
 package 
 - highly customized tmux config: status-bar, 256 colors, loads of bindings, tmux-git and more.
 - a powerful inputrc (global readline configuration file) improving your productivity with each of
 your tools internally relying on readline (so virtually everywhere you can write!). Every feature
 is detailed in the comments in [./term/.inputrc](.inputrc) // TODO: check link to .inputrc
 - typing `git_prompt` in the shell brings you [https://github.com/magicmonty/bash-git-prompt](git-prompt)
 - a colorful .dircolors [from FIND THE LINK.com](findme.com)
[screenshot.png](terminal screenshot)
 -bash config files

### vim package

I use to manage my plugins, the main ones are:
 - nerdtree (TODO links)
 - vim-go (TODO more links)
 - fugitive
 - taglist
 - repeat
 - surround
 - ctrlp
 - lightline
 - you-complete-me

My vimrc is well categorized and commented so you and I could find what we are looking for

There are a lot of colorschemes, I change them often bu eventually come back to desert256 (TODO link)


## Disclaimer

I only use Linux (Debian-based) OSes so i can't guarantee those configurations
will work anywhere else, not even that you will like any of it ;-)
That being said, mostly everything should work out of the box or with some minor
changes, adaptations or renamings in order to make it work on other Linux
distros and OSX (I integrated a lot of tricks shown on other dotfiles repos that
were targeting OSX)

But keep in mind that these dotfiles have been slowly and carefully crafted and
are regularly updated to suit MY needs and follow their evolution.
Anyway, share, transform, use it as a source of inspiration. I'd happy to hear from you
if that was useful


### Credits and Thanks
add thanks for :
- tutorial of using gnu sow to manage dotfiles
- where i found .dircolors and .inputrc
ascii art generated on [http://bigtext.org/](bigtext.org)


- add a lot of things here (look for TODO in this file)
- every external link should correspond to one thankx/credits

### [LICENSE](LICENSE)


