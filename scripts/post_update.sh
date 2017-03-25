#!/usr/bin/env bash

set -e

readonly VIM_DIR="$(cd "$(dirname "${BASH_SOURCE}")/.." && pwd -P)"
readonly EFFECTIVE_HOME="$(cd "${VIM_DIR}/.." && pwd -P)"
readonly GIT_MODULES="${VIM_DIR}/.gitmodules"
readonly GIT_CONFIG="${VIM_DIR}/.git/config"

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

MAKE_VIMPROC="true"

# Don't try to make vimproc if it's being ignored.
if grep -Fq "vimproc" "${VIM_DIR}/plugins.local" &> /dev/null; then
  MAKE_VIMPROC="false"
fi

# Don't try to make vimproc if we're on a Mac without Xcode/CLI tools
# (/usr/bin/make will be present but trigger a GUI installer).
if [[ "$(uname -s)" = "Darwin" ]]; then
  if ! xcode-select --print-path &> /dev/null; then
    MAKE_VIMPROC="false"
  fi
fi

remove_dir() {
  if [[ ! -e "$1" ]]; then
    return
  fi

  log_info "Removing $2 for $3..."

  rm -rf "$1"
}

clean_up() {
  if ! grep -Fq "bundle/$3" "$1" &> /dev/null; then
    return
  fi

  log_info "Cleaning up $2 for $4..."

  perl -i -ln \
    -e "print unless (/bundle\/$3/ || /\/$4.git/)" \
    "$1"
}

remove_submodule() {
  remove_dir "${VIM_DIR}/bundle/$1" \
             "plugin bundle" \
             "$2"

  remove_dir "${VIM_DIR}/.git/modules/bundle/$1" \
             "orphaned submodule" \
             "$2"

  clean_up "${GIT_MODULES}" \
           ".gitmodules" \
           "$1" \
           "$2"

  clean_up "${GIT_CONFIG}" \
           ".git/config" \
           "$1" \
           "$2"
}

if [[ "${MAKE_VIMPROC}" = "true" ]]; then
  log_info "Rebuilding vimproc..."

  HOME="${EFFECTIVE_HOME}" vim -c "silent VimProcInstall" -c "qall!"
fi

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
  IFS=":" read -r bundle repo <<< "${plugin}"

  remove_submodule "${bundle}" "${repo}"
done

if grep -Fq "sprsquish" "${GIT_CONFIG}" &> /dev/null; then
  remove_dir "${VIM_DIR}/bundle/thrift" \
             "plugin bundle" \
             "thrift.vim"

  remove_dir "${VIM_DIR}/.git/modules/bundle/thrift" \
             "orphaned submodule" \
             "thrift.vim"

  perl -i -pn \
       -e "s/sprsquish/solarnz/" \
       "${GIT_CONFIG}"

  (cd "${VIM_DIR}" && git submodule update --init)
fi

find "${VIM_DIR}/bundle" \
     -mindepth 3 \
     -maxdepth 3 \
     -type f \
     -name "tags" \
     -delete

HOME="${EFFECTIVE_HOME}" vim -c "call pathogen#helptags()" -c "qall!"
