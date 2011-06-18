require 'spec_helper'

describe Magickly do
  before do
    @image_path = File.join(File.dirname(__FILE__), '..', 'support', 'dubya.jpeg')
  end
  
  describe ".face_data" do
    use_vcr_cassette 'dubya'
    
    def check_face_data(file_or_job)
      data = Mustachio.face_data(file_or_job)
      
      data.should be_a Hash
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
