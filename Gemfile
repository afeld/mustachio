source 'http://rubygems.org'

gem 'sinatra', '~> 1.2', :require => 'sinatra/base'
gem 'dragonfly', '~> 0.9'
gem('magickly',
    :git => 'git://github.com/afeld/magickly.git',
    :ref => 'cd17608a9c4468da1f738815a96dc2a9473fc029')
#gem 'magickly', :path => '../magickly'
gem 'activesupport', '< 4.0' # requires Ruby version >= 1.9.3

# v0.12.0 requires Ruby 1.9.3+
# https://github.com/jnunemaker/httparty/commit/aed9e0d21eecb25a4e9fb50df5c72ecc7f3ebb84
gem 'httparty', '< 0.12.0'

gem 'excon'
gem 'faraday'

gem 'addressable', :require => 'addressable/uri'
gem 'haml'

gem 'imagesize', :require => 'image_size'

group :development do
  gem 'jeweler'
end

group :development, :test do
  gem 'rack-test', :require => 'rack/test'
  gem 'rspec'
  
  gem 'debugger'
end

group :test do
  gem 'webmock', :require => 'webmock/rspec'
  gem 'vcr'
end

group :production do
  gem 'newrelic_rpm', :require => false
end
