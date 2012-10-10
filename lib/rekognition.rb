class Rekognition
  class << self

    REKOGNITION_KEY = ENV['MUSTACHIO_REKOGNITION_KEY'] || raise('please set MUSTACHIO_REKOGNITION_KEY')
    REKOGNITION_SECRET = ENV['MUSTACHIO_REKOGNITION_SECRET'] || raise('please set MUSTACHIO_REKOGNITION_SECRET')

    # return tuple [rekognition_json, rekognition_width, rekognition_height]
    def data file
      json = rekognition_json file
      width, height = dims file
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
    
  end
end
