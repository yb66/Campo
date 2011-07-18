# encoding: UTF-8

module Campo
  module Childish
    def push=( child )
      @fields << child
      self
    end

    alias :<< :push=
  end
  
  module Iding
    def id_tag( val )
      val.nil? ? "" : "_#{val}"
    end
  end
  
  module Helpers
    # [ [id, lookup, selected || false], ... ]
    def self.options_builder( opts )
      return [] if opts.nil? || opts.empty?

      opts.map do |opt|
        id, lookup, selected, atts = opt
        selected = false if selected.nil?
        atts = atts.nil? ? { } : atts

        Campo::Option.new( id, lookup, selected, atts )
      end
    end
    
    def self.options_outputter( opts=[] )
      return "" if opts.nil? || opts.empty?
      opts.map{|o| "#{o.output}\n" }.reduce(:+)
    end
  end

    @atts = {}

    class << self
      attr_accessor :atts
    end
  
  class Base 
    include Childish
    include Iding
    
    DEFAULT = { tabindex: nil }

    attr_accessor :attributes, :fields

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
      Label.new( %Q!#{@attributes[:name]}#{id_tag(@attributes[:value])}!, inner ) << self
    end

    def self.unhash( hash )
      hash.reject{|k,v| v.nil? }.reduce(""){|mem, (k,v)| mem + %Q!#{k}: "#{v}", !}
    end


    def self.output( top, so_far="", count=0, tab=2 )
      so_far << "#{top.output( count, tab )}\n"
      count += 1
      if top.respond_to?( :fields ) && top.fields.length >= 1
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
    DEFAULT = { method: "POST" }

    def initialize(name,  attributes={} )
      super( name, DEFAULT.merge( attributes ) )
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%form{ atts[:#{name}], #{Base.unhash( @attributes )} }!
      end
    end
    
  end

  
  class Select < Base
    def initialize( name, opts=[], attributes={} )
      (attributes = opts && opts = []) if opts.kind_of? Hash
      
      super( name, attributes )
      
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%select{ atts[:#{name}], #{Base.unhash( @attributes )} }! 
      end
      
      self.fields += Helpers.options_builder( opts ) unless opts.nil? || opts.empty?
      
      yield( self ) if block_given?
    end # initialize
      
    def option( *args )
      self << Campo::Option.new( *args )
    end
    
    def mark_as_selected( val )
      fields.find {|field| field.value == val }.selected = {selected: "selected"}
    end
  end # Select
  
  class Option
    attr_accessor :value, :checked
    def initialize( value, inner, selected=false, attributes={} )
      @value = value
      @inner = inner
      (attributes = selected && selected = {}) if selected.kind_of? Hash
      @selected = selected ? {selected: "selected"} : {}
      @attributes = attributes
    end
    
    def output(n=0, tab=2)
      %Q!#{" " * n * tab}%option{ #{@selected}, value: "#{@value}", #{Base.unhash( @attributes )} }#{@inner}!
    end
  end # Option
  
  
  # form << Campo::Input.new( "submit", :submit )
  class Input < Base  
    
    #{ type: nil, value: nil, name: nil }
    #{ size: nil, maxlength: nil, type: "text" }
    #{ size: nil, maxlength: nil, type: "hidden" }
    #{ type: "submit" }
    def initialize( name, type=:text, attributes={} )
      super( name, 
            { type: type.to_s, 
              id: "#{name}#{id_tag(attributes[:value])}" 
            }.merge( attributes ) )
            
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
