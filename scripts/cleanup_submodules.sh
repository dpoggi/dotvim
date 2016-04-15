#!/bin/bash
set -e

dir="${HOME}/.vim"
git_modules="${dir}/.gitmodules"
git_config="${dir}/.git/config"

for plugin_pair in \
  "clojure;VimClojure" \
  "cocoa;cocoa.vim" \
  "funcoo;funcoo.vim" \
  "haml;vim-haml" \
  "ios;vim-ios" \
  "mako;mako.vim" \
  "systemverilog;systemverilog.vim" \
  "ts;tsuquyomi"
do
  IFS=';' read -ra pair <<< "${plugin_pair}"

  bundle_dir="${dir}/bundle/${pair[0]}"
  if [[ -e "${bundle_dir}" ]]; then
    printf >&2 "Removing unused plugin bundle at ${bundle_dir}...\n"
    rm -rf "${bundle_dir}"
  fi

  module_dir="${dir}/.git/modules/bundle/${pair[0]}"
  if [[ -e "${module_dir}" ]]; then
    printf >&2 "Cleaning up orphaned Git module at ${module_dir}...\n"
    rm -rf "${module_dir}"
  fi

  if grep "bundle\/${pair[0]}" "${git_modules}" >/dev/null; then
    printf >&2 "Cleaning up .gitmodules for ${pair[1]}...\n"
    sed -i'' -e "s/^.*bundle\/${pair[0]}.*$//g" "${git_modules}"
    sed -i'' -e "/^.*\/${pair[1]}.*$/d" "${git_modules}"
  fi

  if grep "bundle\/${pair[0]}" "${git_config}" >/dev/null; then
    printf >&2 "Cleaning up .git/config for ${pair[1]}...\n"
    sed -i'' -e "/^.*bundle\/${pair[0]}.*$/d" "${git_config}"
    sed -i'' -e "/^.*\/${pair[1]}.*$/d" "${git_config}"
  fi
done
