require File.join(File.dirname(__FILE__), '..', 'mustachio')
require 'sinatra/base'

module Mustachio
  class App < Sinatra::Base
    DEMO_IMAGE = 'http://www.librarising.com/astrology/celebs/images2/QR/queenelizabethii.jpg'
    
    set :static, true
    
    configure :production do
      require 'newrelic_rpm' if ENV['NEW_RELIC_ID']
    end
    
    before do
      app_host = ENV['MUSTACHIO_APP_DOMAIN']
      if app_host && request.host != app_host
        request_host_with_port = request.env['HTTP_HOST']
        redirect request.url.sub(request_host_with_port, app_host), 301
      end
    end
    
    
    get %r{^/(\d+|rand)?$} do |stache_num|
      src = params[:src]
      if src
        if faceless?(src)
          redirect src, 301
        else
          # use the specified stache, otherwise fall back to random
          image = Magickly.process_src params[:src], :mustachify => (stache_num || true)
          image.to_response(env)
        end
      else
        @stache_num = stache_num
        @site = Addressable::URI.parse(request.url).site
        haml :index
      end
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

    helpers do
      def faceless?(url)
        face_data = Mustachio.face_client.faces_detect(:urls => [url], :attributes => 'none')

        face_data['photos'].first['tags'].empty?
      end
    end
  end
end
