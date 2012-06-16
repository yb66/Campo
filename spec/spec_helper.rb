# encoding: UTF-8

require 'rspec'
Spec_dir = File.expand_path( File.dirname __FILE__ )

# code coverage
require 'simplecov'
SimpleCov.start


Dir[ File.join( Spec_dir, "/support/**/*.rb")].each do |f| 
  puts "requiring #{f}"
  require f
end