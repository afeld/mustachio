require 'rubygems'
require 'bundler'
Bundler.require

require File.join(File.dirname(__FILE__), 'lib', 'mustachio')

map '/' do
  run Mustachio
end

map '/magickly' do
  run Magickly::App
end
