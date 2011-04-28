require 'rubygems'
require 'bundler'
Bundler.require

require './mustachio'

map '/' do
  run Mustachio
end

map '/magickly' do
  run Magickly::App
end
