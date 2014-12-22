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
end
