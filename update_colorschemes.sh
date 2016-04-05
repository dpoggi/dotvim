#!/bin/bash
#
# update_colorschemes.sh
# Fetches Vim colorschemes from the web, since they can't be found in Git
# submodule form on a consistent basis
#

hash curl 2>/dev/null || { printf >&2 "Fatal: unable to find cURL.\n"; exit 1; }

pushd "${HOME}/.vim/colors" >/dev/null

for colorscheme in *.vim; do
  [[ "${colorscheme}" = "ir_black.vim" ]] || rm -f "${colorscheme}"
done

for url in \
  "http://www.vim.org/scripts/download_script.php?src_id=9750" \
  "http://www.vim.org/scripts/download_script.php?src_id=11225" \
  "https://raw.githubusercontent.com/altercation/solarized/master/vim-colors-solarized/colors/solarized.vim" \
  "https://raw.githubusercontent.com/vim-scripts/Zenburn/master/colors/zenburn.vim" \
  "https://raw.githubusercontent.com/chriskempson/base16-vim/master/colors/base16-railscasts.vim"
do
  curl --remote-header-name --location --remote-name "${url}"
  printf >&2 "\n"
done

popd >/dev/null
