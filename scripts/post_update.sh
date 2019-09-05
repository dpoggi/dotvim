#!/usr/bin/env bash
#
# post_update.sh - Post-update hook to ensure Vimproc is built, handle
# submodule removal, and regenerate helptags.
#

set -eo pipefail

readonly VIM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly GIT_MODULES="${VIM_DIR}/.gitmodules"
readonly GIT_CONFIG="${VIM_DIR}/.git/config"

__logfln() {
  local level="$1"; shift
  local level_color="$1"; shift
  local format="$1"; shift
  printf \
    "\033[2;39;49m%s\033[0m ${level_color}${level}\033[0;35;49m %s\033[2;39m :\033[0m ${format}\\n" \
    "$(date '+%F %T')" \
    "$$" \
    "$@"
}

infofln() { __logfln " INFO" "\033[0;34m" "$@"; }
warnfln() { __logfln " WARN" "\033[0;33m" "$@"; }
errorfln() { __logfln "ERROR" "\033[1;31m" "$@"; }

qfgrep() {
  # FIXME: This is a function because we don't do existence checks before
  # searching files and need 2>/dev/null everywhere.
  grep -F -q "$@" 2>/dev/null
}

is_cmd() {
  command -v "$1" >/dev/null
}

check_cmds() {
  while (($# > 0)); do
    if ! is_cmd "$1"; then
      errorfln '%s not found' "$1"
      return 1
    fi
    shift
  done
}

rebuild_vimproc() {
  # Don't try to build vimproc if it's being ignored in ~/.vim/plugins.local
  if qfgrep 'vimproc' "${VIM_DIR}/plugins.local"; then
    return
  fi

  local darwin
  if [[ "$(uname -s)" = "Darwin" ]]; then
    darwin="true"
  else
    darwin="false"
  fi

  # Don't try to build vimproc if we're on macOS without Xcode or CLI tools
  # installed (/usr/bin/make will be present but trigger a GUI installer)
  if "${darwin}" && ! xcode-select --print-path >/dev/null 2>&1; then
    return
  fi

  local -a make_cmd
  if "${darwin}"; then
    make_cmd=(xcrun --sdk macosx make)
  else
    if is_cmd gmake; then
      make_cmd=(gmake)
    elif is_cmd make; then
      make_cmd=(make)
    elif is_cmd nmake; then
      make_cmd=(nmake -f "make_msvc.mak" nodebug=1)
    fi
  fi

  if ((${#make_cmd[@]} == 0)); then
    warnfln 'make not found, unable to rebuild vimproc'
    return
  fi

  infofln 'Rebuilding vimproc...'

  (
    cd "${VIM_DIR}/bundle/vimproc"
    "${make_cmd[@]}" clean
    "${make_cmd[@]}"
  )
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

  if ! qfgrep "bundle/${plugin_bundle}" "${file_path}" &&
     ! qfgrep "/${plugin_repo}.git" "${file_path}"; then
    return
  fi

  infofln "Scrubbing %s from %s..." "${plugin_repo}" "${file_description}"

  perl -ln -i \
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
  if ! qfgrep 'sprsquish' "${GIT_CONFIG}"; then
    return
  fi

  remove_dir "${VIM_DIR}/bundle/thrift" \
             "plugin bundle" \
             "thrift.vim"

  remove_dir "${VIM_DIR}/.git/modules/bundle/thrift" \
             "orphaned submodule" \
             "thrift.vim"

  perl -pn -i -e 's/sprsquish/solarnz/' "${GIT_CONFIG}"

  git -C "${VIM_DIR}" submodule update --init
}

regenerate_helptags() {
  find \
    "${VIM_DIR}/bundle" \
    -mindepth 3 \
    -maxdepth 3 \
    -type f \
    -name 'tags' \
    -delete

  # FIXME: This is a terrible hack to support bundling the whole distribution.
  # Figuring out what VIMRUNTIME should be to do this in a sane way appears
  # non-trivial, but I could be wrong.
  HOME="$(dirname "${VIM_DIR}")" \
    vim \
    -c 'call pathogen#helptags()' \
    -c 'qall!'
}

main() {
  check_cmds grep perl vim

  rebuild_vimproc

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
