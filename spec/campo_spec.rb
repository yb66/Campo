# encoding: UTF-8

require_relative "../lib/campo/campo.rb"


form = Campo::Form.new( "myform" )
form << Campo::Input.new( "abc", :text ).labelled("abc")
form << Campo::Input.new( "def", :text ).labelled("def")
form << Campo::Input.new( "ghi", :text ).labelled("ghi")
form << Campo::Textarea.new( "jkl", "= inners[:jkl]" ).labelled("jkl")
form << Campo::Input.new("mno", :checkbox ).labelled( "mno" )
form << Campo::Select.new( "pqr" ) do |s|
  s << Campo::Option.new( "volvo", "Volvo" )
  s << Campo::Option.new( "saab", "Saab" )
  s << Campo::Option.new( "audi", "Audi" )
end.labelled("pqr")
opts = [["ford", "Ford"], ["bmw", "BMW"], ["ferrari", "Ferrari", "checked"]]
form << Campo::Select.new("stu", opts, ).labelled( "stu" )

form << Campo::Select.new( "vwx" ) do |s|
  s.option "volvo", "Volvo"
  s.option "saab", "Saab"
  s.option "audi", "Audi"
end.labelled("vwx")

form << Campo::Select.new( "yz", opts ) do |s|
  s.option "volvo", "Volvo"
  s.option "saab", "Saab"
  s.option "audi", "Audi"
end.labelled("yz")

puts Campo.output( form )

require "haml"

puts Haml::Engine.new( Campo.output form ).render