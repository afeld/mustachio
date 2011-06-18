require 'face'

Magickly.dragonfly.configure do |c|
  c.log_commands = true
  
  c.analyser.add :face_data do |temp_object|
    Mustachio.face_client.faces_detect(:file => temp_object.file, :attributes => 'none')['photos'].first
  end
  
  c.analyser.add :face_data_as_px do |temp_object|
    data = Magickly.dragonfly.analyser.functions[:face_data].first.call(temp_object)
    
    new_tags = []
    data['tags'].map do |face|
      has_all_attrs = Mustachio::FACE_POS_ATTRS.all? do |pos_attr|
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
  
  c.analyser.add :face_span do |temp_object|
    face_data = Magickly.dragonfly.analyser.functions[:face_data_as_px].first.call(temp_object)
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
  
  
  
  c.job :mustachify do |stache_num_param|
    photo_data = @job.face_data_as_px
    width = photo_data['width']
    
    commands = ['-virtual-pixel transparent']
    photo_data['tags'].each do |face|
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
      
      # perform transform such that the mustache is the height
      # of the upper lip, and the bottom-center of the stache
      # is mapped to the center of the mouth
      rotation = Math.atan(
        ( face['mouth_right']['y'] - face['mouth_left']['y'] ).to_f /
        ( face['mouth_right']['x'] - face['mouth_left']['x'] ).to_f
      ) / Math::PI * 180.0
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
    
    command_str = commands.join(' ')
    process :convert, command_str
  end
  
  c.job :crop_to_faces do |geometry|
    thumb_width, thumb_height = geometry.split('x')
    # raise ArgumentError
    thumb_width = thumb_width.to_f
    thumb_height = thumb_height.to_f
    
    span = @job.face_span
    puts span.inspect
    scale_x = thumb_width / span[:width]
    scale_y = thumb_height / span[:height]
    
    # if thumb larger than span
    # center span and crop
    # else
    # resize image so span is smaller than thumb, then crop
    
    # center the span in the dimension with the smaller scale
    if scale_x < scale_y
      scale = scale_x
      offset_x = span[:left] * scale
      offset_y = (span[:center_y] * scale) - (thumb_height / 2)
    else
      scale = scale_y
      offset_x = (span[:center_x] * scale) - (thumb_width / 2)
      offset_y = span[:top] * scale
    end
    
    process :convert, "-resize #{(scale * 100).to_i}% -extent #{geometry}+#{offset_x.to_i}+#{offset_y.to_i}"
  end
end