require 'sinatra/base'
require 'magickly'
require 'ruby-debug'

# thanks to http://therantsandraves.com/?p=602 for the 'staches
MUSTACHE_FILENAME = File.expand_path(File.join('public', 'images', 'mustache_03.png'))

Magickly.dragonfly.configure do |c|
  c.analyser.add :face_data do |temp_object|
    Mustachio.face_client.faces_detect(:file => temp_object.file, :detector => 'Aggressive')
  end
  
  c.job :mustachify do
    photo_data = @job.face_data['photos'].first
    width = photo_data['width']
    
    commands = []
    photo_data['tags'].each do |face|
      mouth_width = (face['mouth_right']['x'] - face['mouth_left']['x']) * photo_data['width'] / 100
      stache_width = mouth_width * 1.8
      lip_height = (face['mouth_center']['y'] - face['nose']['y']) * photo_data['height'] / 100
      x = (face['nose']['x'] * photo_data['width'] / 100) - (stache_width / 2)
      y = face['nose']['y'] * photo_data['height'] / 100 + (lip_height * 0.2)
      
      commands << "\\( #{MUSTACHE_FILENAME} -resize #{stache_width.to_i}x \\) -geometry +#{x.to_i}+#{y.to_i} -composite"
    end
    
    command_str = commands.join(' ')
    process :convert, command_str
  end
end

class Mustachio < Sinatra::Base
  @@face_client = Face.get_client(
    :api_key => (ENV['MUSTACHIO_FACE_API_KEY'] || raise("Please set MUSTACHIO_FACE_API_KEY.")),
    :api_secret => (ENV['MUSTACHIO_FACE_API_SECRET'] || raise("Please set MUSTACHIO_FACE_API_SECRET."))
  )
  
  class << self
    def face_client
      @@face_client
    end
  end
  
  get '/' do
    'Hello world!'
  end
end
