require 'rubygems'
require 'bundler'
Bundler.require

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))
require 'mustachio'

Mustachio.set :environment, :test

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join('spec', 'support', '**', '*.rb')].each {|f| require f}

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
