#!/usr/bin/env ruby
require 'fileutils'

['vimrc', 'gvimrc'].each do |file|
  original = File.expand_path file
  link = File.join File.expand_path('~'), ".#{File.basename file}"
  puts "#{link} => #{original}"
  if not File.exists? link
    FileUtils.ln_s original, link
  end
end
