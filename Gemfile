source 'http://rubygems.org'
ruby '2.3.1'

gem 'sinatra', '~> 1.2', :require => 'sinatra/base'
gem 'dragonfly', '~> 0.9'
gem('magickly',
    :git => 'git://github.com/afeld/magickly.git',
    :ref => 'cd17608a9c4468da1f738815a96dc2a9473fc029')
#gem 'magickly', :path => '../magickly'

gem 'face_detect'
gem 'googleauth'
gem 'google-api-client'

gem 'addressable', :require => 'addressable/uri'
gem 'haml'

gem 'fastimage', :require => 'fastimage'

gem 'unicorn'
gem 'rack-attack'

group :development do
  gem 'jeweler'
end

group :development, :test do
  gem 'rack-test', :require => 'rack/test'
  gem 'rspec'

  gem 'debugger', platforms: :mri_19
  gem 'byebug', platforms: :mri_20
end

group :test do
  gem 'webmock', :require => 'webmock/rspec'
end

group :production do
  gem 'newrelic_rpm', :require => false
end
