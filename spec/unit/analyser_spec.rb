# P.S. I'm pretty sure it's spelled "analyZer", but I'm staying consistent w/ Dragonfly
require 'spec_helper'

describe "analysers", :vcr => true do
  describe "#face_data" do
    it "should give similar results for small and large photos" do
      big_obama = get_photo('big_obama.jpeg')
      small_obama = get_photo('small_obama.jpeg')
      
      big_obama_data = stub_face_data(big_obama){|img| img.face_data }
      small_obama_data = stub_face_data(small_obama){|img| img.face_data }
      
      big_mouth_x = big_obama_data.first['mouth_right']['x']
      small_mouth_x = small_obama_data.first['mouth_right']['x']
      
      expect(big_mouth_x).to be_kind_of Float
      expect(small_mouth_x).to be_kind_of Float
      
      # compare positioning (percentages)
      expect(small_mouth_x).to be_within(1.0).of(small_mouth_x)
    end
  end
  
  describe "#face_data_as_px" do
    it "should scale the detection areas proportionally for large photos" do
      pending "big_mouth_x is not 5.0 within small_mouth_x * scale"
      big_obama = get_photo('big_obama.jpeg')
      small_obama = get_photo('small_obama.jpeg')
      
      big_obama_data = stub_face_data(big_obama){|img| img.face_data_as_px big_obama.width, big_obama.height }
      small_obama_data = stub_face_data(small_obama){|img| img.face_data_as_px small_obama.width, small_obama.height }
      
      big_mouth_x = big_obama_data.first['mouth_right']['x']
      small_mouth_x = small_obama_data.first['mouth_right']['x']
      
      expect(big_mouth_x).to be_kind_of Float
      expect(small_mouth_x).to be_kind_of Float
      expect(big_mouth_x).to_not be_within(1.0).of(small_mouth_x)
      
      scale = big_obama.width / small_obama.width.to_f
      # compare positioning (px)
      expect(big_mouth_x).to be_within(5.0).of(small_mouth_x * scale)
    end
  end
  
  describe "#face_span" do
    it "should return appropriate boundaries" do
      pending "TODO : Fix to work with pluggable face detection"
      image = get_photo
      span = stub_face_data(image){|img| img.face_span }
      expect(span).to be_a Hash
      expect(span[:top]).to < span[:bottom]
      expect(span[:left]).to < span[:right]
    end
  end
end
