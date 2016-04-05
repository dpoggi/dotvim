#!/bin/bash
#
# update_submodules.sh
# Updates Vim plugin submodules from their respective origins
#

pushd "${HOME}/.vim" >/dev/null

printf >&2 "Fetching origin recursively...\n"
git fetch origin --recurse-submodules
printf >&2 "\n"

# Pathogen is deliberately excluded as its updates are sometimes more involved.
for submodule in "${HOME}/.vim/bundle"/*; do
  pushd "${submodule}" >/dev/null

  ref="$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)"
  if [[ -z "${ref}" ]]; then
    printf >&2 "Error: unable to establish remote ref for ${submodule}, skipping...\n"
    popd >/dev/null
    continue
  fi

  printf >&2 "Attempting to merge ${ref} for ${submodule}...\n"
  git merge --ff-only --no-edit "${ref}"
  printf >&2 "Updating submodules for ${submodule}, if any...\n"
  git submodule update --init --recursive
  printf >&2 "\n"

  popd >/dev/null
done

popd >/dev/null
