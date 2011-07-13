#!/usr/bin/env ruby
# colors.rb - download/update the Vim colorschemes

[
  'https://raw.github.com/tomasr/dotfiles/master/.vim/colors/molokai.vim',
  'http://blog.toddwerth.com/entry_files/8/ir_black.vim'
].each do |url|
  file = url.split('/').last
  puts "Downloading #{file}..."
  `curl -s -k -o colors/#{file} #{url}`
end
