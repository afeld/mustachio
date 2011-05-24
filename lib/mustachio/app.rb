require File.join(File.dirname(__FILE__), '..', 'mustachio')
require 'sinatra/base'

module Mustachio
  class App < Sinatra::Base
    set :static, true
    set :public, 'public'
    
    configure :production do
      require 'newrelic_rpm' if ENV['NEW_RELIC_ID']
    end
    
    
    get '/' do
      src = params[:src]
      if src
        image = Magickly.process_src params[:src], :mustachify => true
        image.to_response(env)
      else
        @site = Addressable::URI.parse(request.url).site
        haml :index
      end
    end
    
    get %r{/(\d+)} do |stache_num|
      image = Magickly.process_src params[:src], :mustachify => stache_num
      image.to_response(env)
    end
    
    get '/gallery' do
      haml :gallery
    end
    
    get '/test' do
      haml :test
    end
    
    get '/face_api_dev_challenge' do
      haml :face_api_dev_challenge
    end
    
  end
end
