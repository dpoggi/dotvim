#!/bin/sh
# Fetch ze colorschemes, for they are nowhere on Github :(

for file in \
  https://raw.github.com/vim-scripts/molokai/master/colors/molokai.vim \
  http://blog.toddwerth.com/entry_files/8/ir_black.vim
do
  echo "Updating $(basename $file)..."
  curl -kL -o "$HOME/.vim/colors/$(basename $file)" "$file"
  echo
done
