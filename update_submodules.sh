#!/bin/bash

# update_submodules.sh
# Updates Vim plugin submodules from their respective origins

cd "${HOME}/.vim"
git fetch origin --recurse-submodules

cd bundle
for submodule in *; do
  pushd "${submodule}" >/dev/null
  git rebase refs/remotes/origin/master
  popd >/dev/null
done
