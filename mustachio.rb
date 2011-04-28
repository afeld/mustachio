require 'sinatra/base'
require 'magickly'

class Mustachio < Sinatra::Base
  get '/' do
    'Hello world!'
  end
end
