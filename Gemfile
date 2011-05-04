source 'http://rubygems.org'

gem 'sinatra', '~> 1.2.3', :require => 'sinatra/base'
gem 'dragonfly', '~> 0.9.0'
gem 'magickly', '~> 1.1'

gem 'face', '0.0.4'

group :development, :test do
  gem 'ruby-debug19', :platforms => :ruby_19
  gem 'ruby-debug', :platforms => :ruby_18
end

group :production do
  gem 'newrelic_rpm', :require => false
end
