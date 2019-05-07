#!/usr/bin/env bash
#
# update_submodules.sh - Updates Vim plugin submodules from their respective
# origins
#

set -eo pipefail

readonly VIM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

infofln() { __logfln " INFO" "\033[0;34m" "$@"; }
errorfln() { __logfln "ERROR" "\033[0;31m" "$@"; }

__logfln() {
  local level="$1"; shift
  local level_color="$1"; shift
  local format="$1"; shift
  printf \
    "\033[2;39;49m%s ${level_color}${level}\033[2;39;49m : \033[0m${format}\\n" \
    "$(date "+%Y-%m-%d %H:%M:%S")" "$@"
}

find_submodules() {
  git -C "$1" submodule status 2>/dev/null | awk '$2 ~ /^bundle\// { print $2 }'
}

git_symbolic_ref() {
  git -C "$1" symbolic-ref --quiet "refs/remotes/origin/HEAD"
}

update_submodule() {
  local dir name symbolic_ref

  dir="$1"
  name="$(basename "${dir}")"

  symbolic_ref="$(git_symbolic_ref "${dir}")"
  if [[ -z "${symbolic_ref}" ]]; then
    return 1
  fi

  infofln "Attempting to checkout %s for %s..." "${symbolic_ref}" "${name}"
  git -C "${dir}" checkout --quiet --force "${symbolic_ref}"

  infofln "Updating submodules for %s, if any..." "${name}"
  git -C "${dir}" submodule --quiet update --init --recursive

  printf '\n'
}

main() {
  local submodule_dir

  infofln "Fetching origin recursively..."
  git -C "${VIM_DIR}" fetch --quiet --recurse-submodules origin 2>/dev/null

  printf '\n'

  while IFS='' read -r submodule_dir; do
    if ! update_submodule "${VIM_DIR}/${submodule_dir}" 2>/dev/null; then
      errorfln "Unable to establish remote branch for %s, skipping..." "${submodule_dir}"
    fi
  done < <(
    find_submodules "${VIM_DIR}" 2>/dev/null
  )
}

main "$@"
