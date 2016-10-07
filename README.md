# dotvim

My .vim folder. It has a lot of submodules. Credits, of course, go to their respective authors.

## Installation

### Option A

Install my dotfiles (https://github.com/dpoggi/dcp).

### Option B

```sh
cd

git clone https://github.com/dpoggi/dotvim.git .vim
ln -s .vim/vimrc .vimrc
ln -s .vim/gvimrc .gvimrc

cd .vim
git submodule update --init
scripts/post_update.sh
```

## Customization

Both `vimrc.local` and `gvimrc.local` are gitignored and will be loaded by `.vimrc` and `.gvimrc` respectively at the end of their runs. `plugins.local` shares the same gitignored status but is loaded near the very beginning of `.vimrc`, and can be used as such to disable plugins:

```
let g:pathogen_disabled = ['plugin1', 'plugin2', 'etc']
```

Note that the plugins need to be named by their directory in `bundle/`, not their "official" repository name. Sorry for renaming everything in `bundle/`, the decision was made a long time ago and would be tricky to change now.

## Copyright

Copyright (C) 2011 Dan Poggi. MIT License, see LICENSE for details.
