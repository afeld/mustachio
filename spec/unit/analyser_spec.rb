# P.S. I'm pretty sure it's spelled "analyZer", but I'm staying consistent w/ Dragonfly
require 'spec_helper'

describe "analysers" do
  def face_data(filename='dubya.jpeg')
    photo = get_photo(filename)
    data = nil
    VCR.use_cassette( filename.chomp(File.extname(filename)) ) do
      data = photo.face_data
    end
    
    data
  end
  
  def face_data_as_px(filename='dubya.jpeg')
    photo = get_photo(filename)
    data = nil
    VCR.use_cassette( filename.chomp(File.extname(filename)) ) do
      data = photo.face_data_as_px
    end
    
    data
  end
  
  describe "#face_data" do
    it "should give similar results for small and large photos" do
      big_obama_data = face_data('big_obama.jpeg')
      small_obama_data = face_data('small_obama.jpeg')
      
      big_eye_x = big_obama_data['tags'].first['eye_right']['x']
      small_eye_x = small_obama_data['tags'].first['eye_right']['x']
      
      big_eye_x.should be_kind_of Float
      small_eye_x.should be_kind_of Float
      
      # compare positioning (percentages)
      small_eye_x.should be_within(1.0).of(small_eye_x)
    end
  end
  
  describe "#face_data_as_px" do
    it "should not scale a photo smaller than 900px" do
      image = get_photo
      image.height.should eq 300
      
      face_data_as_px['height'].should eq 300
    end
    
    it "should scale the detection areas proportionally for large photos" do
      big_obama_data = face_data_as_px('big_obama.jpeg')
      small_obama_data = face_data_as_px('small_obama.jpeg')
      
      big_eye_x = big_obama_data['tags'].first['eye_right']['x']
      small_eye_x = small_obama_data['tags'].first['eye_right']['x']
      
      big_eye_x.should be_kind_of Float
      small_eye_x.should be_kind_of Float
      big_eye_x.should_not be_within(1.0).of(small_eye_x)
      
      scale = big_obama_data['width'] / small_obama_data['width'].to_f
      # compare positioning (px)
      big_eye_x.should be_within(5.0).of(small_eye_x * scale)
    end
  end
end
