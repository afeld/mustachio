require 'spec_helper'
require 'rack/test'

describe Mustachio::App do
  include Rack::Test::Methods

  def app
    subject
  end

  describe "GET /" do
    it "shows the homepage" do
      get '/'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Created by')
    end
  end

  describe "GET /?src=..." do
    it "gives a 502 for a missing image" do
      stub_request(:get, 'http://existentsite.com/foo.png').to_return(status: 404)
      get '/?src=http://existentsite.com/foo.png'
      expect(last_response.status).to eq(502)
    end
  end
end
