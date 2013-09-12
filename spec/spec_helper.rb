ENV['RACK_ENV'] ||= 'test'

require 'rubygems'
require 'bundler'
Bundler.require

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mustachio/app'
require 'webmock/rspec'
require 'vcr'

Mustachio::App.set :environment, :test

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join('spec', 'support', '**', '*.rb')].each {|f| require f}

VCR.configure do |c|
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures', 'vcr_cassettes')
  c.hook_into :faraday
  c.default_cassette_options = {
    :record => :new_episodes
  }
  
  # VCR doesn't recognize when requests are explicitly mocked - this is a workaround
  # https://github.com/myronmarston/vcr/issues/146
  c.allow_http_connections_when_no_cassette = true

  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec
  
  ENV['MUSTACHIO_REKOGNITION_KEY'] = '123'
  ENV['MUSTACHIO_REKOGNITION_SECRET'] = '456'
end


def get_photo(filename='dubya.jpeg')
  image_url = "http://www.foo.com/#{filename}"
  image_path = File.join(File.dirname(__FILE__), 'support', filename)
  stub_request(:get, image_url).to_return(:body => File.new(image_path))
  
  Magickly.dragonfly.fetch(image_url)
end

def stub_face_data(file_or_job)
  if file_or_job.is_a? File
    basename = File.basename(file_or_job.path)
  elsif file_or_job.is_a? Dragonfly::TempObject
    basename = File.basename(file_or_job.file.path)
  elsif file_or_job.is_a? Dragonfly::Job
    path = Addressable::URI.parse(file_or_job.uid)
    basename = path.basename
  else
    raise ArgumentError, "A #{file_or_job.class} is not a vaild type for #stub_face_data."
  end

  result = nil
  VCR.use_cassette( basename.chomp(File.extname(basename)) ) do
    result = yield(file_or_job)
  end
  result
end
