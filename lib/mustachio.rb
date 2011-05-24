require 'sinatra/base'
require 'magickly'
require 'image_size'
require 'face'

# thanks to http://therantsandraves.com/?p=602 for the 'staches

Magickly.dragonfly.configure do |c|
  c.log_commands = true
  
  c.analyser.add :face_data do |temp_object|
    Mustachio.face_client.faces_detect(:file => temp_object.file, :attributes => 'none')['photos'].first
  end
  
  c.analyser.add :face_data_as_px do |temp_object|
    data = Mustachio.face_client.faces_detect(:file => temp_object.file, :attributes => 'none')['photos'].first # TODO use #face_data
    
    data['tags'].map! do |face|
      Mustachio::FACE_POS_ATTRS.each do |pos_attr|
        if face[pos_attr].nil?
          puts "WARN: missing position attribute '#{pos_attr}'"
        else
          face[pos_attr]['x'] *= (data['width'] / 100.0)
          face[pos_attr]['y'] *= (data['height'] / 100.0)
        end
      end
      
      face
    end
    
    data
  end
  
  c.job :mustachify do
    photo_data = @job.face_data_as_px
    width = photo_data['width']
    
    commands = []
    photo_data['tags'].each do |face|
      stache_num = 0 # TODO make this random
      mustache = Mustachio.mustaches[stache_num]
      
      # perform affine transform, such that the top-center
      # of the mustache is mapped to the nose, and the bottom-center
      # of the stache is mapped to the center of the mouth
      rotation = Math.atan(
        ( face['mouth_right']['y'] - face['mouth_left']['y'] ).to_f /
        ( face['mouth_right']['x'] - face['mouth_left']['x'] ).to_f
      ) / Math::PI * 180.0
      
      desired_height = Math.sqrt(
        ( face['nose']['x'] - face['mouth_center']['x'] ).to_f**2 +
        ( face['nose']['y'] - face['mouth_center']['y'] ).to_f**2
      )
      scale = desired_height / mustache['height']
      
      srt_params = [
        [ mustache['width']/2.0, mustache['height'] ].map{|e| e.to_i }.join(','), # old position
        scale, # scale
        rotation, # rotate
        [ face['mouth_center']['x'], face['mouth_center']['y'] ].map{|e| e.to_i }.join(',') # now position
      ]
      srt_params_str = srt_params.join(' ')
      
      commands << "\\( #{mustache['file_path']} +distort SRT '#{srt_params_str}' \\)"
    end
    commands << "-flatten"
    
    command_str = commands.join(' ')
    process :convert, command_str
  end
end

class Mustachio < Sinatra::Base
  FACE_POS_ATTRS = ['center', 'eye_left', 'eye_right', 'mouth_left', 'mouth_center', 'mouth_right', 'nose']
  
  set :static, true
  set :public, 'public'
  
  configure :production do
    require 'newrelic_rpm' if ENV['NEW_RELIC_ID']
  end
  
  class << self
    def face_client
      @@face_client
    end
    
    def mustaches
      @@mustaches
    end
    
    def setup
      @@face_client = Face.get_client(
        :api_key => (ENV['MUSTACHIO_FACE_API_KEY'] || raise("Please set MUSTACHIO_FACE_API_KEY.")),
        :api_secret => (ENV['MUSTACHIO_FACE_API_SECRET'] || raise("Please set MUSTACHIO_FACE_API_SECRET."))
      )
      
      staches = YAML.load(File.read(File.join(File.dirname(__FILE__), '..', 'config', 'staches.yml')))
      staches.map! do |stache|
        stache['file_path'] = File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'staches', stache['filename']))
        stache['width'], stache['height'] = ImageSize.new(File.new(stache['file_path'])).get_size
        stache
      end
      @@mustaches = staches
    end
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
  
  get '/test' do
    haml :test
  end
  
  get '/face_api_dev_challenge' do
    haml :face_api_dev_challenge
  end
  
  
  self.setup
end
