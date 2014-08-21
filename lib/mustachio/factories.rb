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
