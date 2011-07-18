# encoding: UTF-8

require_relative "../lib/campo/campo.rb"


form = Campo::Form.new( "myform" )
form << Campo::Input.new( "abc", :text ).labelled("abc")
form << Campo::Input.new( "def", :text ).labelled("def")
form << Campo::Input.new( "ghi", :text ).labelled("ghi")
form << Campo::Textarea.new( "jkl", "= inners[:jkl]" ).labelled("jkl")
check_colours = form.fieldset( "Do you like these colours? Tick for yes:" )
Campo::Input.new("mno", :checkbox, value: "blue" ).labelled( "blue" ).fieldset( check_colours )
Campo::Input.new("mno", :checkbox, value: "red" ).labelled( "red" ).fieldset( check_colours )

sel_colours = form.fieldset( "Select the colour you like most:" )
Campo::Input.new("radio1", :radio, value: "green" ).labelled( "green" ).fieldset( sel_colours )
Campo::Input.new("radio1", :radio, value: "yellow" ).labelled( "yellow" ).fieldset( sel_colours )
Campo::Input.new("radio1", :radio, value: "red" ).labelled( "red" ).fieldset( sel_colours )
Campo::Input.new("radio1", :radio, value: "blue" ).labelled( "blue" ).fieldset( sel_colours )
Campo::Input.new("radio1", :radio, value: "purple" ).labelled( "purple" ).fieldset( sel_colours )

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