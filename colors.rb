#!/usr/bin/env ruby
# colors.rb - download/update the Vim colorschemes

[
  'https://raw.github.com/tomasr/dotfiles/master/.vim/colors/molokai.vim'
].each do |url|
  `curl -o colors/#{url.split('/').last} #{url}`
end
