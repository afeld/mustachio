source 'http://rubygems.org'

gem 'sinatra', '~> 1.2', :require => 'sinatra/base'
gem 'dragonfly', '~> 0.9.0'
#gem 'magickly', '~> 1.2'
gem('magickly',
    :git => 'git://github.com/tolsen/magickly.git',
    :ref => '0a960ceb30b96fcf42639247a341fd575e45a5ad')
#gem 'magickly', :path => '../magickly'

gem 'addressable', '~> 2.2.4', :require => 'addressable/uri'
gem 'haml', '~> 3.0'

gem 'imagesize', '~> 0.1', :require => 'image_size'

group :development do
  gem 'jeweler', '~> 1.6'
end

group :development, :test do
  gem 'rack-test', :require => 'rack/test'
  gem 'rspec', '~> 2.5'
  gem 'webmock', '~> 1.6', :require => 'webmock/rspec'
  gem 'vcr', '~> 1.9'
  
  gem 'ruby-debug19', :require => 'ruby-debug', :platforms => :ruby_19
  gem 'ruby-debug', :platforms => :ruby_18
end

group :production do
  gem 'newrelic_rpm', :require => false
end
