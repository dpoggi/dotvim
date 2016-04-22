# dotvim

My .vim folder. It has a lot of submodules. Credits, of course, go to their respective authors.

## Installation

Either clone the repository as your .vim folder and run `git submodule update --init`, or install my dotfiles (https://github.com/dpoggi/dcp).

## Powerline

If you want to use Powerline (and have the appropriate fonts installed to do so), add this to `~/.vim/vimrc.local`:

```
set rtp+=~/.vim/bundle/powerline/powerline/bindings/vim
```

## Customization

Both `vimrc.local` and `gvimrc.local` are gitignored and will be loaded by `.vimrc` and `.gvimrc` respectively at the end of their runs. `plugins.local` shares the same gitignored status but is loaded near the very beginning of `.vimrc`, and can be used as such:

```
let g:pathogen_disabled = ['plugin1', 'plugin2', 'etc']
```

Note that the plugins need to be named by their directory in `bundle/`, not their "official" repository name. Sorry for renaming everything in `bundle/`, the decision was made a long time ago and would be tricky to change now.

## Copyright

Copyright (C) 2011 Dan Poggi. MIT License, see LICENSE for details.
