#!/usr/bin/env bash
#
# update_submodules.sh
# Updates Vim plugin submodules from their respective origins
#

set -e

log_info() {
  printf "\033[0;34m[%s]:\033[0m %s\n" \
         "$(date "+%Y-%m-%d %H:%M:%S")" \
         "$*"
}

log_error() {
  printf >&2 "\033[1;37;41m[%s]:\033[0m %s\n" \
             "$(date "+%Y-%m-%d %H:%M:%S")" \
             "$*"
}

main() {
  cd "$(dirname "${BASH_SOURCE[0]}")/.."

  log_info "Fetching origin recursively..."

  git fetch origin --recurse-submodules

  printf >&2 "\n"

  local submodule plugin symbolic_ref ref

  for submodule in bundle/*; do
    plugin="$(basename "${submodule}")"

    pushd "${submodule}" > /dev/null

    # The JavaScript plugin's master branch is a little... behind
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
      log_error "Error: unable to establish remote branch for ${plugin}, skipping..."

      popd > /dev/null

      continue
    fi

    log_info "Attempting to checkout ${symbolic_ref} for ${plugin}..."

    git checkout --force "${ref}"

    log_info "Updating submodules for ${plugin}, if any..."

    git submodule update --init --recursive

    printf >&2 "\n"

    popd > /dev/null
  done
}

main "$@"
