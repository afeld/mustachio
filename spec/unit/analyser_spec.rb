# P.S. I'm pretty sure it's spelled "analyZer", but I'm staying consistent w/ Dragonfly
require 'spec_helper'

describe "retrieving face data" do
  def get_photo(filename='dubya.jpeg')
    image_url = "http://www.foo.com/#{filename}"
    image_path = File.join(File.dirname(__FILE__), '..', 'support', filename)
    stub_request(:get, image_url).to_return(:body => File.new(image_path))
    
    Magickly.dragonfly.fetch(image_url)
  end
  
  describe "#face_data" do
    it "should give similar results for small and large photos" do
      big_obama = get_photo('big_obama.jpeg')
      big_obama_data = nil
      VCR.use_cassette('big_obama') do
        big_obama_data = big_obama.face_data['tags'].first
      end
      
      small_obama = get_photo('small_obama.jpeg')
      small_obama_data = nil
      VCR.use_cassette('small_obama') do
        small_obama_data = small_obama.face_data['tags'].first
      end
      
      big_obama_data['eye_right']['x'].should be_kind_of Float
      small_obama_data['eye_right']['x'].should be_kind_of Float
      big_obama_data['eye_right']['x'].should be_within(5.0).of(small_obama_data['eye_right']['x'])
    end
  end
  
  describe "#face_data_as_px" do
    it "should not scale a photo smaller than 900px" do
      image = get_photo
      image.height.should eq 300
      
      VCR.use_cassette('dubya') do
        image.face_data_as_px['height'].should eq 300
      end
    end
    
    it "should scale the detection areas proportionally for large photos" do
      big_obama = get_photo('big_obama.jpeg')
      big_obama_data = nil
      VCR.use_cassette('big_obama') do
        big_obama_data = big_obama.face_data_as_px['tags'].first
      end
      
      small_obama = get_photo('small_obama.jpeg')
      small_obama_data = nil
      VCR.use_cassette('small_obama') do
        small_obama_data = small_obama.face_data_as_px['tags'].first
      end
      
      big_obama_data['eye_right']['x'].should be_kind_of Float
      small_obama_data['eye_right']['x'].should be_kind_of Float
      big_obama_data['eye_right']['x'].should_not be_within(1.0).of(small_obama_data['eye_right']['x'])
      
      scale = big_obama.width / small_obama.width.to_f
      big_obama_data['eye_right']['x'].should be_within(5.0).of(small_obama_data['eye_right']['x'] * scale)
    end
  end
end
