require 'sinatra/base'
require 'magickly'

# thanks to http://therantsandraves.com/?p=602 for the 'staches
MUSTACHE_FILENAME = File.expand_path(File.join('public', 'images', 'mustache_03.png'))

Magickly.dragonfly.configure do |c|
  c.analyser.add :face_data do |temp_object|
    Mustachio.face_client.faces_detect(:file => temp_object.file, :detector => 'Aggressive')
  end
  
  c.job :mustachify do
    data = @job.face_data
    
    commands = []
    data['photos'].first['tags'].each do |face|
      commands << "-page +#{face['nose']['x'].to_i}+#{face['nose']['y'].to_i} \\( #{MUSTACHE_FILENAME} -resize 100x \\)"
    end
    
    command_str = commands.join(' ')
    process :convert, command_str
    encode :jpg
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
