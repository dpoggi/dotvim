#!/usr/bin/env bash
set -e

dir="$(cd "$(dirname "${BASH_SOURCE}")/.." && pwd -P)"
fake_home="$(cd "${dir}/.." && pwd -P)"
gitmodules="${dir}/.gitmodules"
git_config="${dir}/.git/config"

os="$(uname -s)"
if [[ "${os}" = "Darwin" ]]; then
  xcode-select --print-path >/dev/null && should_make="true" || true
else
  should_make="true"
fi
grep -Fq "vimproc" "${dir}/plugins.local" 2>/dev/null || vimproc="true"

if [[ "${should_make}" = "true" && "${vimproc}" = "true" ]]; then
  printf >&2 "Rebuilding vimproc...\n"
  HOME="${fake_home}" vim -c "silent VimProcInstall" -c "qall!"
fi

for plugin in \
  "clojure:VimClojure" \
  "cocoa:cocoa.vim" \
  "command-t:Command-T" \
  "funcoo:funcoo.vim" \
  "haml:vim-haml" \
  "ios:vim-ios" \
  "kiwi:kiwi.vim" \
  "mako:mako.vim" \
  "systemverilog:systemverilog.vim" \
  "ts:tsuquyomi"
do
  IFS=':' read -r bundle repo <<< "${plugin}"
  bundle_fgrep="bundle/${bundle}"
  bundle_sed="/^.*bundle\/${bundle}.*$/d"
  repo_sed="/^.*\/${repo}.*$/d"

  bundle_dir="${dir}/bundle/${bundle}"
  if [[ -e "${bundle_dir}" ]]; then
    printf >&2 "Removing plugin bundle for ${repo}...\n"
    rm -rf "${bundle_dir}"
  fi

  module_dir="${dir}/.git/modules/bundle/${bundle}"
  if [[ -e "${module_dir}" ]]; then
    printf >&2 "Removing orphaned Git module for ${repo}...\n"
    rm -rf "${module_dir}"
  fi

  if grep -F "${bundle_fgrep}" "${gitmodules}" >/dev/null; then
    printf >&2 "Cleaning up .gitmodules for ${repo}...\n"
    sed -i.bak \
      -e "${bundle_sed}" \
      -e "${repo_sed}" \
      "${gitmodules}" &&
      rm -f "${gitmodules}.bak"
  fi

  if grep -F "${bundle_fgrep}" "${git_config}" >/dev/null; then
    printf >&2 "Cleaning up .git/config for ${repo}...\n"
    sed -i.bak \
      -e "${bundle_sed}" \
      -e "${repo_sed}" \
      "${git_config}" &&
      rm -f "${git_config}.bak"
  fi
done

find "${dir}/bundle" -name "tags" -delete
HOME="${fake_home}" vim -c "call pathogen#helptags()" -c "qall!"
