#!/usr/bin/env bash
#
# update_submodules.sh
# Updates Vim plugin submodules from their respective origins
#

cd "$(dirname "${BASH_SOURCE[0]}")/.."

printf >&2 "Fetching origin recursively...\n"
git fetch origin --recurse-submodules
printf >&2 "\n"

# Pathogen is deliberately excluded as its updates are sometimes more involved.
for submodule in bundle/*; do
  plugin="$(basename "${submodule}")"
  pushd "${submodule}" > /dev/null

  # The JavaScript plugin's master branch is a little... behind.
  if [[ "${plugin}" = "javascript" ]]; then
    symbolic_ref="refs/remotes/origin/develop"
  else
    symbolic_ref="$(git symbolic-ref refs/remotes/origin/HEAD 2> /dev/null)"
  fi

  # refs/remotes/origin/branch -> sha1
  if [[ -n "${symbolic_ref}" ]]; then
    ref="$(git show-ref --hash --verify "${symbolic_ref}" 2> /dev/null)"
  fi

  if [[ -z "${symbolic_ref}" || -z "${ref}" ]]; then
    printf >&2 "Error: unable to establish remote branch for ${plugin}, skipping...\n"
    popd > /dev/null
    continue
  fi

  printf >&2 "Attempting to checkout ${symbolic_ref} for ${plugin}...\n"
  git checkout --force "${ref}"
  printf >&2 "Updating submodules for ${plugin}, if any...\n"
  git submodule update --init --recursive
  printf >&2 "\n"

  popd > /dev/null
done
