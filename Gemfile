source 'http://rubygems.org'

gem 'sinatra', '~> 1.2', :require => 'sinatra/base'
gem 'dragonfly', '~> 0.9.0'
#gem 'magickly', '~> 1.2'
gem('magickly',
    :git => 'git://github.com/afeld/magickly.git',
    :ref => 'ffeed110561d3441b4cd52128ecb83c2f7d7e94b')
#gem 'magickly', :path => '../magickly'

gem 'rest-client', '~> 1.6', :require => 'rest_client'

gem 'addressable', '~> 2.2', :require => 'addressable/uri'
gem 'haml', '~> 3.0'

gem 'imagesize', '~> 0.1', :require => 'image_size'

group :development do
  gem 'jeweler', '~> 1.6'
end

group :development, :test do
  gem 'rack-test', :require => 'rack/test'
  gem 'rspec', '~> 2.5'
  
  gem 'debugger'
end

group :test do
  gem 'webmock', '~> 1.6', :require => 'webmock/rspec'
  gem 'vcr', '~> 2.2'
end

group :production do
  gem 'newrelic_rpm', :require => false
end
