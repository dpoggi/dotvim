# dotvim

`~/.vim` directory: there are many like it, but this one is mine.

## Installation

### Option I

Install my [dotfiles](https://github.com/dpoggi/dcp) using the provided
installation script.

### Option II

```bash
git clone https://github.com/dpoggi/dotvim.git ~/.vim

pushd ~/.vim

git submodule update --init
scripts/post_update.sh

popd

ln -s ~/.vim/vimrc ~/.vimrc

# These are optional, depending whether you use gVim or any Vim-alikes
ln -s ~/.vim/gvimrc ~/.gvimrc
ln -s ~/.vim/ideavimrc ~/.ideavimrc
ln -s ~/.vim/xvimrc ~/.xvimrc
```

### Windows

Installation in Windows environments (except for WSL) is broken-ish because
`autoload` is symlinked into the `pathogen` submodule. Workaround hacks:

* Replace the non-working "symlink" with a real NT symlink (`mklink`), then run
  `git update-index --assume-unchanged`. `mklink` will require administrator
  privileges, unless you're running the Windows 10 Creators Update with
  Developer Mode enabled.
* Delete the symlink, copy `pathogen/autoload` to `autoload` (easy mode).

## Customization

Both `vimrc.local` and `gvimrc.local` are gitignored and will be loaded by
`.vimrc` and `.gvimrc` respectively at the end of their runs. `plugins.local`
shares the same gitignored status but is loaded near the very beginning of
`.vimrc`, and can be used as follows to disable plugins:

```vim
let g:pathogen_disabled = ['plugin1', 'plugin2', 'etc']
```

Note that the plugins need to be named by their directory in `bundle/`,
not their "official" repository name. Sorry for renaming everything in
`bundle/`, the decision was made a long time ago and would be tricky to
change now.

## Copyright

Copyright (C) 2011 Dan Poggi. MIT License, see LICENSE for details.
