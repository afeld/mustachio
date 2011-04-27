require 'rubygems'
require 'bundler'
Bundler.require

require './mustachio'
run Sinatra::Application
