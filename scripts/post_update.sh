#!/usr/bin/env bash
#
# post_update.sh
# Post-update hook to ensure Vimproc is built, handle submodule removal, and
# regenerate helptags.
#

set -e

readonly VIM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly EFFECTIVE_HOME="$(cd "${VIM_DIR}/.." && pwd -P)"
readonly GIT_MODULES="${VIM_DIR}/.gitmodules"
readonly GIT_CONFIG="${VIM_DIR}/.git/config"

log_info() {
  printf "\033[0;34m[%s]:\033[0m %s\n" \
         "$(date "+%Y-%m-%d %H:%M:%S")" \
         "$*"
}

build_vimproc() {
  # Don't try to build vimproc if it's being ignored in ~/.vim/plugins.local
  if grep -Fq 'vimproc' "${VIM_DIR}/plugins.local" 2> /dev/null; then
    return
  fi

  # Don't try to build vimproc if we're on macOS without Xcode or CLI tools
  # installed (/usr/bin/make will be present but trigger a GUI installer)
  if [[ "$(uname -s)" = "Darwin" ]] \
     && ! xcode-select --print-path &> /dev/null; then
    return
  fi

  log_info "(Re)building vimproc..."

  HOME="${EFFECTIVE_HOME}" vim -c 'silent VimProcInstall' -c 'qall!'
}

remove_dir() {
  local dir_path="$1"
  local dir_description="$2"
  local plugin_repo="$3"

  if [[ ! -d "${dir_path}" ]]; then
    return
  fi

  log_info "Removing ${dir_description} for ${plugin_repo}..."

  rm -rf "${dir_path}"
}

scrub_file() {
  local file_path="$1"
  local file_description="$2"
  local plugin_bundle="$3"
  local plugin_repo="$4"

  if ! grep -Fq "bundle/${plugin_bundle}" "${file_path}" \
     && ! grep -Fq "/${plugin_repo}.git" "${file_path}"; then
    return
  fi

  log_info "Scrubbing ${plugin_repo} from ${file_description}..."

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
  if ! grep -Fq 'sprsquish' "${GIT_CONFIG}"; then
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
  find "${VIM_DIR}/bundle" \
       -mindepth 3 \
       -maxdepth 3 \
       -type f \
       -name 'tags' \
       -delete

  HOME="${EFFECTIVE_HOME}" vim -c 'call pathogen#helptags()' -c 'qall!'
}

main() {
  build_vimproc

  local plugin bundle repo

  for plugin in \
    "CamelCaseMotion:CamelCaseMotion" \
    "clojure:VimClojure" \
    "cocoa:cocoa.vim" \
    "command-t:Command-T" \
    "elm:elm-vim" \
    "funcoo:funcoo.vim" \
    "haml:vim-haml" \
    "ios:vim-ios" \
    "kiwi:kiwi.vim" \
    "mako:mako.vim" \
    "nginx:nginx.vim" \
    "powerline:powerline" \
    "systemverilog:systemverilog.vim" \
    "ts:tsuquyomi"
  do
    IFS=$':' read -r bundle repo <<< "${plugin}"

    remove_submodule "${bundle}" "${repo}"
  done

  migrate_thrift

  regenerate_helptags
}

main "$@"
