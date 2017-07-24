#!/usr/bin/env bash
#
# update_submodules.sh - Updates Vim plugin submodules from their respective
# origins
#

set -eo pipefail

__logfln() {
  local lvl="$1"; shift
  local lvl_clr="$1"; shift
  local fmt="$1"; shift

  printf "\033[2;39;49m%s ${lvl_clr}${lvl}\033[2;39;49m : \033[0m${fmt}\n" \
         "$(date "+%Y-%m-%d %H:%M:%S")" \
         "$@"
}

infofln() { __logfln " INFO" "\033[0;34m" "$@"; }
errorfln() { __logfln "ERROR" "\033[0;31m" "$@"; }

update_submodule() {
  local submodule="$1"

  local plugin="$(basename "${submodule}")"

  pushd "${submodule}" >/dev/null

  local symbolic_ref

  # The JavaScript plugin's master branch is a little... behind
  if [[ "${plugin}" = "javascript" ]]; then
    symbolic_ref="refs/remotes/origin/develop"
  else
    symbolic_ref="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null)"
  fi

  if [[ -z "${symbolic_ref}" ]]; then
    errorfln "Unable to establish remote branch for %s, skipping..." "${plugin}"

    popd >/dev/null

    continue
  fi

  infofln "Attempting to checkout %s for %s..." "${symbolic_ref}" "${plugin}"

  git checkout --force "${symbolic_ref}"

  infofln "Updating submodules for %s, if any..." "${plugin}"

  git submodule update --init --recursive

  printf "\n"

  popd >/dev/null
}

main() {
  cd "$(dirname "${BASH_SOURCE[0]}")/.."

  infofln "Fetching origin recursively..."

  git fetch origin --recurse-submodules

  printf "\n"

  local submodule

  while IFS='' read -d '' -r submodule; do
    update_submodule "${submodule}"
  done < <(find ./bundle -mindepth 1 -maxdepth 1 -type d -print0)
}

main "$@"
