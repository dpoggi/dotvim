#!/bin/sh
# Fetch ze colorschemes, for they are nowhere on Github :(

hash curl 2>&- && GET="curl -kLJO"
hash wget 2>&- && GET="wget --no-check-certificate --content-disposition"
test "$GET" || { echo >&2 "Error! Couldn't find cURL or Wget!"; exit 1; }

cd "$HOME/.vim/colors"
rm -f *.vim

for URL in \
  "http://www.vim.org/scripts/download_script.php?src_id=9750" \
  "http://blog.toddwerth.com/entry_files/8/ir_black.vim" \
  "http://www.vim.org/scripts/download_script.php?src_id=11225" \
  "https://raw.github.com/altercation/solarized/master/vim-colors-solarized/colors/solarized.vim"
do
  $GET "$URL"
  echo
done
