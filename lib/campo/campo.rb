# encoding: UTF-8

module Campo
  module Childish
    def push=( child )
      @fields << child
      self
    end

    alias :<< :push=
  end

    @atts = {}

    class << self
      attr_accessor :atts
    end
  
  class Base 
    include Childish
    DEFAULT = { tabindex: nil }

    attr_reader :attributes, :fields

    def initialize( name, attributes={} )
      @attributes = DEFAULT.merge( attributes.merge({name: name}) )
      @fields = []
    end
    
    def on_output( &block )
      @output_listener = block
    end

    def output( n=0, tab=2 )
      @output_listener.call n, tab
    end

    def labelled( inner=nil )
      Label.new( @attributes[:name], inner ) << self
    end

    def self.unhash( hash )
      hash.reject{|k,v| v.nil? }.reduce(""){|mem, (k,v)| mem + %Q!#{k}: "#{v}", !}
    end


    def self.output( top, so_far="", count=0, tab=2 )
      so_far << "#{top.output( count, tab )}\n"
      count += 1
      unless top.fields.length == 0
        top.fields.each do |field|
          so_far = Base.output( field, so_far, count, tab ) 
        end
      end

      so_far
    end

  end
  
  def self.output( *args )
    s = <<STR
- atts = {} if atts.nil?
- atts.default = {} if atts.default.nil?
- inners = {} if inners.nil?
- inners.default = "" if inners.default.nil?

#{Base.output( *args )}
STR
  end

  # opt id
  class Form < Base
    DEFAULT = { name: nil, method: "POST", action: nil }

    def initialize(name,  attributes={} )
      super( name, DEFAULT.merge( attributes ) )
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%form{ atts[:#{name}], #{Base.unhash( @attributes )} }!
      end
    end
    
  end

  # 
  # form = Campo::Form.new( "myform" )
  # form << Campo::Input.new( "abc", :text ).labelled("abc")
  # form << Campo::Input.new( "def", :text ).labelled("def")
  # form << Campo::Input.new( "ghi", :text ).labelled("ghi")
  # form << Campo::Textarea.new( "jkl", "= inners[:jkl]" ).labelled("jkl")
  # form << Campo::Input.new("mno", :checkbox ).labelled( "mno" )
  # form << Campo::Input.new( "submit", :submit )
  class Input < Base  

    #{ type: nil, value: nil, name: nil }
    #{ size: nil, maxlength: nil, type: "text" }
    #{ size: nil, maxlength: nil, type: "hidden" }
    #{ type: "submit" }
    def initialize( name, type=:text, attributes={} )
      super( name, {type: type.to_s}.merge( attributes ) )
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%input{ atts[:#{name}], #{Base.unhash( @attributes )} }! 
      end
    end
  end


  class Label
    include Childish
    DEFAULT = { for: nil }

    attr_reader :attributes, :fields

    def initialize( name, inner=nil, attributes={} )
      (attributes = inner && inner = nil) if inner.kind_of? Hash
      @name = name
      @attributes = attributes || {}
      @fields = []
      @inner = inner
    end
    
    def output( n=0, tab=2 )
      %Q!#{" " * n * tab}%label{ for: "#{@name}", #{Base.unhash( @attributes )} }\n#{" " * (n + 1) * tab}#{@inner}! 
    end

  end


  class Textarea < Base
    DEFAULT = { cols: 40, rows: 10 }

    def initialize( name,  inner=nil, attributes={} )
      (attributes = inner && inner = nil) if inner.kind_of? Hash
      super( name, DEFAULT.merge( attributes ) )
      @inner = inner
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%textarea{ atts[:#{name}], #{Base.unhash( @attributes )} }#{@inner}!
      end
    end
  end

end

# 
# class Radio < Input
#   DEFAULT = { checked: nil, type: "radio" }
# 
#   def initialize( name, attributes={} )
#     super( name, DEFAULT.merge( attributes ) )
#   end
# end
# 
# class Password < Input
#   DEFAULT = { type: "password" }
# 
#   def initialize( name, attributes={} )
#     super( name, DEFAULT.merge( attributes ) )
#   end
# end