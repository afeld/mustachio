require 'spec_helper'

describe "jobs" do
  describe "#crop_to_faces" do
    it "should return a cropped image of the desired size" do
      pending "TODO : Fix to work with pluggable face detection"
      original = get_photo
      cropped = stub_face_data(original){|img| Magickly.process_image img, crop_to_faces: '100x200' }
      original.width.should_not eq cropped.width
      cropped.width.should eq 100
      cropped.height.should eq 200
    end
  end
end
