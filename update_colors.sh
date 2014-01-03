#!/usr/bin/env bash
# update_colors.sh
# Fetches Vim color schemes from the web, since they can't be found in Git
# submodule form on a consistent basis.

hash wget 2>&- && get="wget --no-check-certificate --content-disposition"
hash curl 2>&- && get="curl --location --remote-name --remote-header-name"
test "${get}" || { echo >&2 "Error! Couldn't find cURL or Wget!"; exit 1; }

cd "${HOME}/.vim/colors"
rm -f *.vim

for url in \
  "http://www.vim.org/scripts/download_script.php?src_id=9750" \
  "http://blog.toddwerth.com/entry_files/8/ir_black.vim" \
  "http://www.vim.org/scripts/download_script.php?src_id=11225" \
  "https://raw.github.com/altercation/solarized/master/vim-colors-solarized/colors/solarized.vim" \
  "https://raw.github.com/vim-scripts/Zenburn/master/colors/zenburn.vim"
do
  ${get} "${url}"
  echo
done

unset url
unset get
