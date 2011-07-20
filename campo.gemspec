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
  s.add_dependency("haml", "~> 3.1.1")
  s.email          = ["iainspeed @nospam@ gmail.com"]
  s.test_files     = `git ls-files -- {test,spec,features}`.split("\n")
  s.signing_key    = ENV['HOME'] + '/.ssh/gem-private_key.pem'
  s.cert_chain     = [ENV['HOME'] + '/.ssh/gem-public_cert.pem']
end
