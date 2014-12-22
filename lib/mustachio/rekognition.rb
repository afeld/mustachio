module Mustachio
  class Rekognition
    class Error < StandardError; end

    class << self
      REKOGNITION_KEY = ENV['MUSTACHIO_REKOGNITION_KEY'] || raise('please set MUSTACHIO_REKOGNITION_KEY')
      REKOGNITION_SECRET = ENV['MUSTACHIO_REKOGNITION_SECRET'] || raise('please set MUSTACHIO_REKOGNITION_SECRET')


      def get_response(file, jobs)
        conn = Faraday.new :url => 'https://rekognition.com' do |faraday|
          faraday.request :multipart
          faraday.request :url_encoded
          faraday.adapter :excon
        end

        payload = {
          :api_key       => REKOGNITION_KEY,
          :api_secret    => REKOGNITION_SECRET,
          :uploaded_file => Faraday::UploadIO.new(file, content_type(file)),
          :jobs          => jobs,
          :name_space    => '',
          :user_id       => ''
        }

        conn.post('/func/api/', payload)
      end

      def json file, jobs = 'face'
        response = self.get_response(file, jobs)
        JSON.parse response.body
      end

      def dims file
        `identify -format "%wx%h" #{file.path}`.strip.split('x').map(&:to_f)
      end

      def content_type file
        `file -b --mime #{file.path}`.strip.split(/[:;]\s+/)[0]
      end

      def validate_response(json)
        unless json['face_detection']
          usage = json['usage'] || {}
          msg = usage['status'] || 'failure.'
          raise Error.new("Rekognition API: #{msg}")
        end
      end

      def face_detection file
        json = self.json file, 'face_part'
        self.validate_response(json)
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
