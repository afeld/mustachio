require 'spec_helper'

describe Mustachio::Rekognition do
  describe '.face_detection' do
    it "handles API errors" do
      # they still return status 200 :(
      stub_request(:post, 'https://rekognition.com/func/api/').to_return(body: {
        url: 'http://example.com/dubya.jpeg',
        usage: {
          quota: '0',
          status: "ERROR! Image is corrupted!",
          api_id: '123'
        }
      }.to_json)

      expect {
        Mustachio::Rekognition.face_detection(image_file('dubya.jpeg'))
      }.to raise_error(Mustachio::Rekognition::Error)
    end
  end
end
