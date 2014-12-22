require File.join(File.dirname(__FILE__), '..', 'mustachio')
require 'sinatra/base'

module Mustachio
  class App < Sinatra::Base
    DEMO_IMAGE = 'http://www.librarising.com/astrology/celebs/images2/QR/queenelizabethii.jpg'

    set :static, true

    configure :production do
      require 'newrelic_rpm' if ENV['NEW_RELIC_ID']
    end


    def redirect_to_canonical_host
      app_host = ENV['MUSTACHIO_APP_DOMAIN']
      if app_host && request.host != app_host
        request_host_with_port = request.env['HTTP_HOST']
        redirect request.url.sub(request_host_with_port, app_host), 301
      end
    end

    def valid_url?(url)
      url =~ /\A#{URI::regexp(['http', 'https'])}\z/
    end

    def serve_stache(src, stache_arg)
      if valid_url?(src)
        begin
          image = Magickly.process_src(src, mustachify: stache_arg)
          image.to_response(env)
        rescue ArgumentError => e
          if e.message == 'uncaught throw :unable_to_handle'
            status 415
            "Unsupported image format."
          else
            raise
          end
        rescue Dragonfly::DataStorage::DataNotFound, SocketError
          status 502
          "Image not found."
        rescue Mustachio::Rekognition::Error => e
          status 502
          e.message
        rescue Timeout::Error
          status 504
          "Image download timed out."
        end
      else
        status 415
        "Invalid src parameter."
      end
    end


    before do
      redirect_to_canonical_host
    end

    get %r{^/(\d+|rand)?$} do |stache_num|
      src = params[:src]
      if src
        stache_arg = stache_num || true
        serve_stache(src, stache_arg)
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
  end
end
