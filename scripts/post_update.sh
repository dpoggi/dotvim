#!/usr/bin/env bash
#
# post_update.sh - Post-update hook to ensure Vimproc is built, handle
# submodule removal, and regenerate helptags.
#

set -eo pipefail

readonly VIM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly EFFECTIVE_HOME="$(cd "${VIM_DIR}/.." && pwd -P)"
readonly GIT_MODULES="${VIM_DIR}/.gitmodules"
readonly GIT_CONFIG="${VIM_DIR}/.git/config"
readonly FINGERPRINT_PATH="${XDG_CONFIG_HOME:-${HOME}/.config}/dcp/brew_codesign.sha1"

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

__qfgrep() { grep -qF "$@" 2>/dev/null; }

__is_xcode_installed() { xcrun xcode-select --print-path >/dev/null 2>&1; }

assert_deps() {
  local dep
  for dep in "$@"; do
    if ! hash "${dep}" 2>/dev/null; then
      errorfln "${dep} not found"
      return 1
    fi
  done
}

__codesign() {
  if [[ ! -r "${FINGERPRINT_PATH}" ]]; then
    return
  fi

  local fingerprint
  fingerprint="$(<"${FINGERPRINT_PATH}")"

  infofln "Code signing vimproc..."
  xcrun codesign --force --sign "${fingerprint}" "$1" || :
}

build_vimproc() {
  # Don't try to build vimproc if it's being ignored in ~/.vim/plugins.local
  if __qfgrep 'vimproc' "${VIM_DIR}/plugins.local"; then
    return
  fi

  # Don't try to build vimproc if we're on macOS without Xcode or CLI tools
  # installed (/usr/bin/make will be present but trigger a GUI installer)
  if [[ "$(uname -s)" = "Darwin" ]] && ! __is_xcode_installed; then
    return
  fi

  infofln "(Re)building vimproc..."

  HOME="${EFFECTIVE_HOME}" vim -c 'silent VimProcInstall' -c 'qall!'

  # If possible, attempt to codesign for macOS Mojave.
  if [[ -r "${VIM_DIR}/bundle/vimproc/lib/vimproc_mac.so" ]]; then
    __codesign "${VIM_DIR}/bundle/vimproc/lib/vimproc_mac.so"
  fi
}

remove_dir() {
  local dir_path="$1"
  local dir_description="$2"
  local plugin_repo="$3"

  if [[ ! -d "${dir_path}" ]]; then
    return
  fi

  infofln "Removing %s for %s..." "${dir_description}" "${plugin_repo}"

  rm -rf "${dir_path}"
}

scrub_file() {
  local file_path="$1"
  local file_description="$2"
  local plugin_bundle="$3"
  local plugin_repo="$4"

  if ! __qfgrep "bundle/${plugin_bundle}" "${file_path}" \
     && ! __qfgrep "/${plugin_repo}.git" "${file_path}"; then
    return
  fi

  infofln "Scrubbing %s from %s..." "${plugin_repo}" "${file_description}"

  perl -i -ln \
       -e "print unless (/bundle\\/${plugin_bundle}/ || /\\/${plugin_repo}\\.git/)" \
       "${file_path}"
}

remove_submodule() {
  local bundle="$1"
  local repo="$2"

  remove_dir "${VIM_DIR}/bundle/${bundle}" \
             "plugin bundle" \
             "${repo}"

  remove_dir "${VIM_DIR}/.git/modules/bundle/${bundle}" \
             "orphaned submodule" \
             "${repo}"

  scrub_file "${GIT_MODULES}" \
             ".gitmodules" \
             "${bundle}" \
             "${repo}"

  scrub_file "${GIT_CONFIG}" \
             ".git/config" \
             "${bundle}" \
             "${repo}"
}

migrate_thrift() {
  if ! __qfgrep 'sprsquish' "${GIT_CONFIG}"; then
    return
  fi

  remove_dir "${VIM_DIR}/bundle/thrift" \
             "plugin bundle" \
             "thrift.vim"

  remove_dir "${VIM_DIR}/.git/modules/bundle/thrift" \
             "orphaned submodule" \
             "thrift.vim"

  perl -i -pn \
       -e 's/sprsquish/solarnz/' \
       "${GIT_CONFIG}"

  (cd "${VIM_DIR}" && git submodule update --init)
}

regenerate_helptags() {
  find "${VIM_DIR}/bundle" -mindepth 3 -maxdepth 3 -type f -name 'tags' -delete

  HOME="${EFFECTIVE_HOME}" vim -c 'call pathogen#helptags()' -c 'qall!'
}

main() {
  assert_deps vim perl

  build_vimproc

  local plugin bundle repo

  for plugin in \
    "batsh:vim-Batsh"                 \
    "CamelCaseMotion:CamelCaseMotion" \
    "clojure:VimClojure"              \
    "cocoa:cocoa.vim"                 \
    "command-t:Command-T"             \
    "elm:elm-vim"                     \
    "funcoo:funcoo.vim"               \
    "haml:vim-haml"                   \
    "ios:vim-ios"                     \
    "kiwi:kiwi.vim"                   \
    "mako:mako.vim"                   \
    "nginx:nginx.vim"                 \
    "powerline:powerline"             \
    "systemverilog:systemverilog.vim" \
    "ts:tsuquyomi"
  do
    IFS=':' read -r bundle repo <<< "${plugin}"
    remove_submodule "${bundle}" "${repo}"
  done

  migrate_thrift

  regenerate_helptags
}

main "$@"
