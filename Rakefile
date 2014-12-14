# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

begin
  require 'jeweler'
rescue LoadError
else
  Jeweler::Tasks.new do |gem|
    # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
    gem.name = "mustachio"
    gem.homepage = "http://github.com/afeld/mustachio"
    gem.license = "MIT"
    gem.summary = %Q{automatic mustachifying of any image}
    gem.description = %Q{Adds a 'mustachify' shortcut to magickly.}
    gem.email = "aidan.feldman@gmail.com"
    gem.authors = ["Aidan Feldman"]
    # dependencies defined in Gemfile
  end
  Jeweler::RubygemsDotOrgTasks.new
end

begin
  require 'rspec/core'
  require 'rspec/core/rake_task'
rescue LoadError
else
  RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = FileList['spec/**/*_spec.rb']
  end

  RSpec::Core::RakeTask.new(:rcov) do |spec|
    spec.pattern = 'spec/**/*_spec.rb'
    spec.rcov = true
  end

  task :default => :spec
end
