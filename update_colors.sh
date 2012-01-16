#!/bin/sh
# Fetch ze colorschemes, for they are nowhere on Github :(

hash curl 2>&- && DCP_GET="curl -kLJO"
hash wget 2>&- && DCP_GET="wget --no-check-certificate --content-disposition"
test "$DCP_GET" || { echo >&2 "Error! Couldn't find cURL or Wget!"; exit 1; }

OLD_WD=`pwd`
cd "$HOME/.vim/colors"
rm -f *.vim

for URL in \
  "http://www.vim.org/scripts/download_script.php?src_id=9750" \
  "http://blog.toddwerth.com/entry_files/8/ir_black.vim" \
  "http://www.vim.org/scripts/download_script.php?src_id=11225"
do
  $DCP_GET "$URL"
  echo
done

cd "$OLD_WD"
