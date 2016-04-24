#!/bin/bash
#
# update_colorschemes.sh
# Fetches the specific colorschemes which can't be found in submodule form on a
# consistent basis.

if ! hash curl 2>/dev/null; then
  printf >&2 "Couldn't find cURL!\n"
  exit 1
fi

pushd "${HOME}/.vim/colors" >/dev/null

gh_base="https://raw.githubusercontent.com"
for url in \
  "${gh_base}/vim-scripts/blackboard.vim/master/colors/blackboard.vim" \
  "${gh_base}/chrishunt/color-schemes/master/railscasts/base16-railscasts.vim"
do
  name="$(basename "${url}")"
  printf >&2 "Deleting old ${name}...\n"
  rm -f "${name}"
  printf >&2 "Downloading fresh ${name}...\n"
  curl --silent --location --remote-name --remote-header-name "${url}"
  printf >&2 "\n"
done

popd >/dev/null
