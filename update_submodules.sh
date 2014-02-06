#!/bin/bash

# update_submodules.sh
# Updates Vim plugin submodules from their respective origins

cd "${HOME}/.vim"
git fetch origin --recurse-submodules

cd bundle
for submodule in *; do
  cd "${submodule}"

  if [[ "${submodule}" = "powerline" ]]; then
    git rebase refs/remotes/origin/develop
  elif [[ "${submodule}" != "go" ]]; then
    git rebase refs/remotes/origin/master
  fi

  cd ..
done
