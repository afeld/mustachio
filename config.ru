require 'rubygems'
require 'bundler'
Bundler.require

require File.join(File.dirname(__FILE__), 'lib', 'mustachio', 'app')

map '/' do
  run Mustachio::App
end

map '/magickly' do
  run Magickly::App
end
