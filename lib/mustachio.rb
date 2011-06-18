require 'magickly'
require 'image_size'
require File.join(File.dirname(__FILE__), 'mustachio', 'shortcuts')

module Mustachio
  FACE_POS_ATTRS = ['center', 'eye_left', 'eye_right', 'mouth_left', 'mouth_center', 'mouth_right', 'nose']
  
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
        stache['vert_offset'] ||= 0
        stache['mouth_overlap'] ||= 0
        
        stache['file_path'] = File.expand_path(File.join(File.dirname(__FILE__), '..', 'public', 'images', 'staches', stache['filename']))
        unless stache['width'] && stache['height']
          stache['width'], stache['height'] = ImageSize.new(File.new(stache['file_path'])).get_size
        end
        stache
      end
      @@mustaches = staches
    end
  end
  
  
  self.setup
end
