require 'sinatra/base'
require 'magickly'
require 'image_size'
require 'ruby-debug'

# thanks to http://therantsandraves.com/?p=602 for the 'staches
MUSTACHE_FILENAME = File.expand_path(File.join('public', 'images', 'mustache_03.png'))
MUSTACHE_WIDTH = ImageSize.new(File.new(MUSTACHE_FILENAME)).get_width

FACE_POS_ATTRS = ['center', 'eye_left', 'eye_right', 'mouth_left', 'mouth_center', 'mouth_right', 'nose']

Magickly.dragonfly.configure do |c|
  c.analyser.add :face_data do |temp_object|
    Mustachio.face_client.faces_detect(:file => temp_object.file)['photos'].first
  end
  
  c.analyser.add :face_data_as_px do |temp_object|
    data = Mustachio.face_client.faces_detect(:file => temp_object.file)['photos'].first # TODO use #face_data
    FACE_POS_ATTRS.each do |pos_attr|
      data['tags'].map! do |face|
        face[pos_attr]['x'] *= (data['width'] / 100.0)
        face[pos_attr]['y'] *= (data['height'] / 100.0)
        face
      end
    end
    
    data
  end
  
  c.job :mustachify do
    photo_data = @job.face_data_as_px
    width = photo_data['width']
    
    commands = []
    photo_data['tags'].each do |face|
      mouth_width = face['mouth_right']['x'] - face['mouth_left']['x']
      lip_height = face['mouth_center']['y'] - face['nose']['y']
      
      stache_width = mouth_width * (rand * 2 + 1.2)
      stache_scale = stache_width / MUSTACHE_WIDTH
      
      angle = Math.atan(
        (face['mouth_center']['x'] - face['nose']['x']) /
        (face['mouth_center']['y'] - face['nose']['y'])
      ) / Math::PI * -360
      
      x = face['nose']['x'] - (stache_width / 2)
      y = face['nose']['y'] #+ (lip_height * 0.2)
      
      commands << "\\( \\( #{MUSTACHE_FILENAME} -geometry +#{x.to_i}+#{y.to_i} \\) +distort SRT '0,0 #{stache_scale} #{angle}' \\) -composite"
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
