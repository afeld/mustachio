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
    
    
    # URLs are preferred, because the detection results can be cached by Face.com
    def face_data(file_or_job)
      if file_or_job.is_a? Dragonfly::Job
        uri = file_or_job.uid
        if Addressable::URI.parse(uri).absolute?
          self.face_data(uri)
        else
          self.face_data(file_or_job.temp_object)
        end
      elsif file_or_job.is_a? File
        Mustachio.face_client.faces_detect(:file => file_or_job, :attributes => 'none')['photos'].first
      elsif file_or_job.is_a? Dragonfly::TempObject
        self.face_data(file_or_job.file)
      elsif file_or_job.is_a? String
        Mustachio.face_client.faces_detect(:urls => [file_or_job], :attributes => 'none')['photos'].first
      else
        raise ArgumentError, "A #{file_or_job.class} is not a valid argument for #face_data.  Please provide a File or a Dragonfly::Job."
      end
    end
    
    def face_data_as_px(file_or_job)
      data = self.face_data(file_or_job)

      new_tags = []
      data['tags'].map do |face|
        has_all_attrs = FACE_POS_ATTRS.all? do |pos_attr|
          if face[pos_attr]
            face[pos_attr]['x'] *= (data['width'] / 100.0)
            face[pos_attr]['y'] *= (data['height'] / 100.0)
            true
          else # face attribute missing
            false
          end
        end

        new_tags << face if has_all_attrs
      end

      data['tags'] = new_tags
      data
    end
    
    def face_span(file_or_job)
      face_data = self.face_data_as_px(file_or_job)
      faces = face_data['tags']

      left_face, right_face = faces.minmax_by{|face| face['center']['x'] }
      top_face, bottom_face = faces.minmax_by{|face| face['center']['y'] }

      top = top_face['eye_left']['y']
      bottom = bottom_face['mouth_center']['y']
      right = right_face['eye_right']['x']
      left = left_face['eye_left']['x']
      width = right - left
      height = bottom - top

      # TODO it needs some padding
      {
        :top => top,
        :bottom => bottom,
        :right => right,
        :left => left,
        :width => width,
        :height => height,
        :center_x => (left + right) / 2,
        :center_y => (top + bottom) / 2
      }
    end
  end
  
  
  self.setup
end
