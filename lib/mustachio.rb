require 'magickly'
require 'fastimage'
require File.join(File.dirname(__FILE__), 'mustachio', 'factories')
require File.join(File.dirname(__FILE__), 'mustachio', 'shortcuts')


module Mustachio
#  FACE_POS_ATTRS = ['center', 'eye_left', 'eye_right', 'mouth_left', 'mouth_center', 'mouth_right', 'nose']
  REQUIRED_FACE_ATTRS = %w(mouth_left mouth_right nose)
  FACE_SPAN_SCALE = 2.0
  
  class << self

    def mustaches
      @@mustaches
    end
    
    def setup
      staches = YAML.load(File.read(File.join(File.dirname(__FILE__), '..', 'config', 'staches.yml')))
      staches.map! do |stache|
        stache['vert_offset'] ||= 0
        stache['mouth_overlap'] ||= 0
        
        stache['file_path'] = File.expand_path(File.join(File.dirname(__FILE__), 'mustachio', 'public', 'images', 'staches', stache['filename']))
        unless stache['width'] && stache['height']
          stache['width'], stache['height'] = FastImage.size(File.new(stache['file_path']))
        end
        stache
      end
      @@mustaches = staches
    end

    # block should take |File|
    # and return hash with keys 'mouth_left', 'mouth_right', 'nose'  (and optionally 'mouth_center')
    # with values containing keys 'x' and 'y'
    # whose values are between 0 and 100
    def setup_face_detection &block
      @@face_detection_proc = block
    end

    def setup_rekognition
      require File.join(File.dirname(__FILE__), 'mustachio', 'rekognition')

      self.setup_face_detection do |file|
        Mustachio::Rekognition.face_detection file
      end
    end
    
    def face_data(file_or_job)
      file = case file_or_job
      when Dragonfly::Job
        file_or_job.apply if file_or_job.temp_object.nil?
        file_or_job.temp_object.file
      when Dragonfly::TempObject
        file_or_job.file
      when File
        file_or_job
      else
        raise ArgumentError, "A #{file_or_job.class} is not a valid argument for #face_data.  Please provide a File or a Dragonfly::Job."
      end

      # default to using Rekognition for face detection
      self.setup_rekognition unless defined? @@face_detection_proc

      @@face_detection_proc.call file
    end
    
    def face_data_as_px(file_or_job, width, height)
      faces = self.face_data file_or_job

      # TODO: make more robust by filtering out faces without all data
      new_faces = faces.map do |face|
        face_arr = face.map do |k, v|
          [k, { 'x' => (v['x'] * (width / 100.0)), 'y' => (v['y'] * (height / 100.0)) }]
        end
        Hash[face_arr]
      end
      new_faces
    end
    
    # TODO : Fix to work with pluggable face detection
    # def face_span(file_or_job)
    #   face_data = self.face_data_as_px(file_or_job)
    #   faces = face_data['tags']
      
    #   left_face, right_face = faces.minmax_by{|face| face['center']['x'] }
    #   top_face, bottom_face = faces.minmax_by{|face| face['center']['y'] }
      
    #   top = top_face['eye_left']['y']
    #   bottom = bottom_face['mouth_center']['y']
    #   right = right_face['eye_right']['x']
    #   left = left_face['eye_left']['x']
    #   width = right - left
    #   height = bottom - top
      
    #   # compute adjusted values for padding around face span
    #   adj_width = width * FACE_SPAN_SCALE
    #   adj_height = height * FACE_SPAN_SCALE
    #   adj_top = top - ((adj_height - height) / 2.0)
    #   adj_bottom = bottom + ((adj_height - height) / 2.0)
    #   adj_right = right + ((adj_width - width) / 2.0)
    #   adj_left = left - ((adj_width - width) / 2.0)
      
    #   {
    #     :top => adj_top,
    #     :bottom => adj_bottom,
    #     :right => adj_right,
    #     :left => adj_left,
    #     :width => adj_width,
    #     :height => adj_height,
    #     :center_x => (adj_left + adj_right) / 2,
    #     :center_y => (adj_top + adj_bottom) / 2
    #   }
    # end

    
  end
  
  
  self.setup
end
