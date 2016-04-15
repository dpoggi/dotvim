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

  modules_line="$(grep -n "\/${pair[1]}" "${git_modules}" | cut -d ':' -f 1)"
  if [[ -n "${modules_line}" ]]; then
    printf >&2 "Cleaning up .gitmodules for ${pair[1]}...\n"
    prev_line="$(expr ${modules_line} - 2)"
    sed -i '' -e "${prev_line},${modules_line}d" "${git_modules}"
  fi

  config_line="$(grep -n "\/${pair[1]}" "${git_config}" | cut -d ':' -f 1)"
  if [[ -n "${config_line}" ]]; then
    printf >&2 "Cleaning up .git/config for ${pair[1]}...\n"
    prev_line="$(expr ${config_line} - 1)"
    sed -i '' -e "${prev_line},${config_line}d" "${git_config}"
  fi
done
