# TODO : Fix to work with pluggable face detection
# Magickly.add_convert_factory :crop_to_faces do |c|
#   c.convert_args do |geometry, convert|
#     width, height = convert.pre_identify.values_at :width, :height

#     thumb_width, thumb_height = geometry.split('x')
#     # raise ArgumentError
#     thumb_width = thumb_width.to_f
#     thumb_height = thumb_height.to_f
    
#     span = Mustachio.face_span(convert.image)
#     scale_x = thumb_width / span[:width]
#     scale_y = thumb_height / span[:height]
    
#     # TODO
#     # if thumb larger than span
#     # center span and crop
#     # else
#     # resize image so span is smaller than thumb, then crop

#     scale = offset_x = offset_y = nil
    
#     # center the span in the dimension with the smaller scale
#     if scale_x < scale_y
#       # check if image is tall enough for this scaling
#       if height * scale_x >= thumb_height
#         scale = scale_x
#         offset_x = span[:left] * scale
#       else
#         # image is too short - increase scale to fit height
#         scale = thumb_height / height.to_f
#         offset_x = span[:left] * scale + ((scale - scale_x) * width / 2.0)
#       end
      
#       offset_y = (span[:center_y] * scale) - (thumb_height / 2)
#     else
#       # check if image is wide enough for this scaling
#       if width * scale_y >= thumb_width
#         scale = scale_y
#         offset_y = span[:top] * scale
#       else
#         # image is too narrow - increase scale to fit width
#         scale = thumb_width / width.to_f
#         offset_y = span[:top] * scale + ((scale - scale_y) * height / 2.0)
#       end
      
#       offset_x = (span[:center_x] * scale) - (thumb_width / 2)
#     end
    
#     # round up, to ensure the scaled image fills the thumb area
#     percentage = (scale * 100).ceil

#     "-resize #{percentage}% -extent #{geometry}+#{offset_x.to_i}+#{offset_y.to_i}"
#   end

#   c.identity do |geometry, convert|
#     width, height = geometry.split 'x'
#     convert.pre_identify.merge :width => width, :height => height
#   end
# end

Magickly.add_convert_factory :mustachify do |c|
  c.convert_args do |stache_num_param, convert|
    identity = convert.pre_identify
    width = identity[:width]
    height = identity[:height]
    # resize to smaller than 900px, because Face.com downsizes the image to this anyway
    # TODO move resize inside of Mustachio.face_data
    faces = convert.image.thumb('900x900>').face_data_as_px(width, height)

    commands = ['-alpha Background -background Transparent']
    faces.each do |face|
      stache_num = case stache_num_param
                   when true
                     0
                   when 'true'
                     0
                   when 'rand'
                     rand(Mustachio.mustaches.size)
                   else
                     stache_num_param.to_i
                   end
      
      mustache = Mustachio.mustaches[stache_num]

      face['mouth_center'] ||= {
        'x' => ((face['mouth_left']['x'] + face['mouth_right']['x']) / 2.0),
        'y' => ((face['mouth_left']['y'] + face['mouth_right']['y']) / 2.0)
      }
      
      # perform transform such that the mustache is the height
      # of the upper lip, and the bottom-center of the stache
      # is mapped to the center of the mouth

      rotation = Math.atan(( face['mouth_right']['y'] - face['mouth_left']['y'] ).to_f / ( face['mouth_right']['x'] - face['mouth_left']['x'] ).to_f ) / Math::PI * 180.0
      desired_height = Math.sqrt(
                                 ( face['nose']['x'] - face['mouth_center']['x'] ).to_f**2 +
                                 ( face['nose']['y'] - face['mouth_center']['y'] ).to_f**2
                                 )
      mouth_intersect = mustache['height'] - mustache['mouth_overlap']
      scale = desired_height / mouth_intersect
      
      srt_params = [
                    [ mustache['width'] / 2.0, mouth_intersect - mustache['vert_offset'] ].map{|e| e.to_i }.join(','), # bottom-center of stache
                    scale, # scale
                    rotation, # rotate
                    [ face['mouth_center']['x'], face['mouth_center']['y'] ].map{|e| e.to_i }.join(',') # middle of mouth
                   ]
      srt_params_str = srt_params.join(' ')
      
      commands << "\\( #{mustache['file_path']} +distort SRT '#{srt_params_str}' \\)"
    end
    commands << "-flatten"
    
    commands.join(' ')
  end
end
