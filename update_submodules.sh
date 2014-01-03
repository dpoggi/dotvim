#!/usr/bin/env bash
# update_submodules.sh
# Updates Vim submodules from origin, with the exception of a few.

cd "${HOME}/.vim/bundle"

for submodule in *; do
  cd "${submodule}"
  git fetch origin

  if [[ "${submodule}" != "go" && "${submodule}" != "powerline" ]]; then
    git rebase origin/master
  fi

  cd ..
done

unset submodule
