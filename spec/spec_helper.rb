ENV['RACK_ENV'] ||= 'test'

require 'rubygems'
require 'bundler'
Bundler.require

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mustachio/app'
require 'webmock/rspec'

Mustachio::App.set :environment, :test

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join('spec', 'support', '**', '*.rb')].each {|f| require f }

RSpec.configure do |config|
  config.mock_with :rspec

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    Rack::Attack.cache.store.clear

    # https://github.com/afeld/face_detect/issues/1
    authorization = instance_double(Google::Auth::ServiceAccountCredentials)
    allow_any_instance_of(FaceDetect::Adapter::Google).to receive(:authorization).and_return(authorization)
  end
end


def support_file_path(filename)
  File.join(File.dirname(__FILE__), 'support', filename)
end

def support_file(filename)
  path = support_file_path(filename)
  File.new(path)
end

def get_photo(filename='dubya.jpeg')
  image_url = "http://www.foo.com/#{filename}"
  stub_request(:get, image_url).to_return(body: support_file(filename))

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

  # https://github.com/afeld/face_detect/issues/1
  body = support_file('dubya.json').read
  stub_request(:post, %r{^https://vision.googleapis.com/}).to_return(
    headers: {
      'Content-Type' => 'application/json'
    },
    body: body
  )

  yield(file_or_job)
end
