# -*- encoding: utf-8 -*-
lib = File.expand_path('./lib')
$:.unshift lib unless $:.include?(lib)
require './lib/campo/version.rb'

Gem::Specification.new do |s|
  s.name           = "campo"
  s.summary        = "Form builder for Haml"
  s.description = <<-EOF
    Form builder for Haml
  EOF
  s.version        = Campo::VERSION
  s.platform       = Gem::Platform::RUBY
  s.require_path   = "lib"
  s.required_ruby_version    = ">= 1.9.2"
  s.authors        = ["Iain Barnett"]
  s.files          = `git ls-files`.split("\n")
  s.add_development_dependency("haml", "~> 4.0.0")
  s.add_development_dependency("yard")
  s.add_development_dependency("rake")
  s.homepage       = "https://github.com/yb66/Campo"
  s.email          = "iainspeed @nospam@ gmail.com"
  s.test_files     = `git ls-files -- {test,spec,features}`.split("\n")
end
