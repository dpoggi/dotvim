#!/usr/bin/env bash
set -e

dir="$(cd "$(dirname "${BASH_SOURCE}")/.." && pwd -P)"
fake_home="$(cd "${dir}/.." && pwd -P)"
gitmodules="${dir}/.gitmodules"
git_config="${dir}/.git/config"
vimproc="true"

# Don't try to make vimproc if it's being ignored.
if grep -Fq "vimproc" "${dir}/plugins.local" &> /dev/null; then
  vimproc="false"
fi
# Don't try to make vimproc if we're on a Mac without Xcode/CLI tools
# (/usr/bin/make will be present but trigger a GUI installer).
if [[ "$(uname -s)" = "Darwin" ]]; then
  xcode-select --print-path &> /dev/null || vimproc="false"
fi

remove_dir() {
  if [[ ! -e "$1" ]]; then
    return
  fi

  printf >&2 "Removing %s for %s...\n" "$2" "$3"
  rm -rf "$1"
}

clean_up() {
  if ! grep -Fq "bundle/$3" "$1" &> /dev/null; then
    return
  fi

  printf >&2 "Cleaning up %s for %s...\n" "$2" "$4"
  perl -i -ln \
    -e "print unless (/bundle\/$3/ || /\/$4.git/)" \
    "$1"
}

remove_submodule() {
  remove_dir "${dir}/bundle/$1" \
    "plugin bundle" "$2"
  remove_dir "${dir}/.git/modules/bundle/$1" \
    "orphaned submodule" "$2"

  clean_up "${gitmodules}" ".gitmodules" "$1" "$2"
  clean_up "${git_config}" ".git/config" "$1" "$2"
}

if [[ "${vimproc}" = "true" ]]; then
  printf >&2 "Rebuilding vimproc...\n"
  HOME="${fake_home}" vim -c "silent VimProcInstall" -c "qall!"
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

if grep -Fq "sprsquish" "${git_config}" &> /dev/null; then
  remove_dir "${dir}/bundle/thrift" \
    "plugin bundle" "thrift.vim"
  remove_dir "${dir}/.git/modules/bundle/thrift" \
    "orphaned submodule" "thrift.vim"
  perl -i -pn \
    -e "s/sprsquish/solarnz/" \
    "${git_config}"
  (cd "${dir}" && git submodule update --init)
fi

find "${dir}/bundle" -name "tags" -delete
HOME="${fake_home}" vim -c "call pathogen#helptags()" -c "qall!"
