module Mustachio
  class Rekognition
    class << self

      REKOGNITION_KEY = ENV['MUSTACHIO_REKOGNITION_KEY'] || raise('please set MUSTACHIO_REKOGNITION_KEY')
      REKOGNITION_SECRET = ENV['MUSTACHIO_REKOGNITION_SECRET'] || raise('please set MUSTACHIO_REKOGNITION_SECRET')

      # return tuple [rekognition_json, rekognition_width, rekognition_height]
      def data file
        json = self.json file
        width, height = self.dims file
        [json, width, height]
      end

      def json file, jobs = 'face'
        response = RestClient.post('http://rekognition.com/func/api/',
                                   api_key: REKOGNITION_KEY,
                                   api_secret: REKOGNITION_SECRET,
                                   jobs: jobs,
                                   uploaded_file: file,
                                   name_space: '',
                                   user_id: '')
        JSON.parse response
      end

      def dims file
        `identify -format "%wx%h" #{file.path}`.strip.split('x').map(&:to_f)
      end

      def face_detection file
        json = self.json file, 'face_part'
        width, height = self.dims file

        json['face_detection'].map do |entry|
          mouth_left, mouth_right, nose = entry.values_at('mouth_l', 'mouth_r', 'nose').map do |dims|
            {
              'x' => ((dims['x'].to_f / width) * 100.0),
              'y' => ((dims['y'].to_f / height) * 100.0)
            }
          end

          { 'mouth_left' => mouth_left, 'mouth_right' => mouth_right, 'nose' => nose }
        end
      end
      
    end
  end
end
