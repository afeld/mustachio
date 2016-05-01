require 'spec_helper'

describe Magickly do
  before do
    @image_path = support_file_path('dubya.jpeg')

    # https://github.com/afeld/face_detect/issues/1
    data_path = File.join(__dir__, '..', 'support', 'dubya.json')
    body = File.read(data_path)
    stub_request(:post, %r{^https://vision.googleapis.com/}).to_return(
      headers: {
        'Content-Type' => 'application/json'
      },
      body: body
    )
  end

  describe '.face_data' do
    def check_face_data(file_or_job)
      data = Mustachio.face_data(file_or_job)
      expect(data).to be_a Array
    end

    it "should accept a File" do
      file = File.new(@image_path)
      check_face_data(file)
    end

    it "should accept a Dragonfly::Job" do
      job = get_photo
      check_face_data(job)
    end

    it "should accept a Dragonfly::TempObject" do
      job = get_photo
      job.apply
      check_face_data(job.temp_object)
    end
  end
end
