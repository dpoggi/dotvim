#!/bin/bash
#
# update_submodules.sh
# Updates Vim plugin submodules from their respective origins
#

cd "${HOME}/.vim"
printf >&2 "Fetching origin recursively (whole repo)...\n"
git fetch origin --recurse-submodules
printf >&2 "\n"

cd bundle
for submodule in *; do
  pushd "${submodule}" >/dev/null
  [[ "${submodule}" = "powerline" ]] && ref="origin/develop" || ref="origin/master"

  printf >&2 "Attempting to merge ${ref} for ${submodule}...\n"
  git merge --ff-only --no-edit "${ref}"
  printf >&2 "Updating submodules for ${submodule}, if any...\n"
  git submodule update --init --recursive
  printf >&2 "\n"

  popd >/dev/null
done
