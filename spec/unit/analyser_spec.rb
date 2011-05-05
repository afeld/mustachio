# P.S. I'm pretty sure it's spelled "analyZer", but I'm staying consistent w/ Dragonfly
require 'spec_helper'

describe "#face_data_as_px" do
  def dubya_photo
    image_url = "http://www.foo.com/imagemagick.png"
    image_path = File.join(File.dirname(__FILE__), '..', 'support', 'dubya.jpeg')
    stub_request(:get, image_url).to_return(:body => File.new(image_path))
    
    Magickly.dragonfly.fetch(image_url)
  end
  
  it "should return a hash" do
    image = dubya_photo
    
    VCR.use_cassette('dubya') do
      image.face_data_as_px.should be_kind_of Hash
    end
  end
end
