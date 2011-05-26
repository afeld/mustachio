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

VCR.config do |c|
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures', 'vcr_cassettes')
  c.stub_with :webmock # or :fakeweb
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
end
