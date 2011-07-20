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
  
  module Grouping
    
    def fieldset( fieldset )
      fieldset << self
    end
  end
  
  module Helpers
    # [ [id, lookup, selected || false], ... ]
    def self.options_builder( name, opts )
      return [] if opts.nil? || opts.empty?

      opts.map do |opt|
        id, lookup, selected, atts = opt
        selected = selected ? true : false
        atts = atts.nil? ? { } : atts

        Campo::Option.new( name, id, lookup, selected, atts )
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
    include Grouping
    
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
      inner ||= self.attributes[:name]
      Label.new( %Q!#{@attributes[:name]}#{id_tag(@attributes[:value]).gsub(/\W/, "_")}!, inner ) << self
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
- i = 0 # for tabindex

#{Base.output( *args )}
STR
  end

  # opt id
  class Form < Base
    DEFAULT = { method: "POST" }

    def initialize(name,  attributes={} )
      super( name, DEFAULT.merge( attributes ) )
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%form{ atts[:#{name.gsub(/\W/, "_")}], #{Base.unhash( @attributes )} }!
      end
    end
    
    def fieldset( text )
      fieldset = (Fieldset.new() << Legend.new( text ))
      @fields << fieldset
      fieldset
    end
    
    def text( name, label_inner=nil, attributes={} )
      (attributes = label_inner && label_inner = nil) if label_inner.kind_of? Hash
      text = Campo::Input.new( name, :text, attributes ).labelled( label_inner )
      @fields << text
      text
    end
    
    def select( name, opts=[], attributes={}, &block )
      select = Campo::Select.new( name, opts, attributes, &block )
      @fields << select
      select
    end
  end

  
  class Select < Base
    def initialize( name, opts=[], attributes={}, &block )
      (attributes = opts && opts = []) if opts.kind_of? Hash
      
      super( name, { tabindex: %q!#{i += 1}! }.merge(attributes) )
      
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%select{ atts[:#{name.gsub(/\W/, "_")}], #{Base.unhash( @attributes )} }! 
      end
      
      self.fields += Helpers.options_builder( name, opts ) unless opts.nil? || opts.empty?
      
      block.call( self ) if block
    end # initialize
      
    def option( *args )
      self << Campo::Option.new( @attributes[:name], *args )
      self
    end
    
    def with_default( inner="Choose one:" )
      self << Campo::Option.new( @attributes[:name], "", inner , nil, {disabled: "disabled" } )
      self
    end
    
    def mark_as_selected( val )
      fields.find {|field| field.value == val }.selected = {selected: "selected"}
    end
  end # Select
  
  
  class Option < Base
    attr_accessor :value, :checked
    
    def initialize( name, value, inner=nil, selected=nil, attributes={} )
      
      (selected = attributes && inner = nil) if inner.kind_of? TrueClass
      
      @inner = inner || value
      
      (attributes = selected && selected = {}) if selected.kind_of? Hash
      
      attributes = { id: "#{name.gsub(/\W/, "_")}#{id_tag(value).gsub(/\W/, "_")}" }.merge(attributes) unless value.nil? || value.empty?
      
      super( name, {
        value: value,
        selected: (selected ? "selected" : nil)
      }.merge( attributes ) )
      
      atts_string = "atts[:#{@attributes[:id]}]," unless @attributes[:id].nil?
      
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%option{ #{atts_string} #{Base.unhash( @attributes )} }#{@inner}!
      end

    end #initialize
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
              id: "#{name}#{id_tag(attributes[:value]).gsub(/\W/, "_")}",
              tabindex: %q!#{i += 1}!, 
            }.merge( attributes ) )
            
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%input{ atts[:#{name.gsub(/\W/, "_")}#{id_tag(attributes[:value]).gsub(/\W/, "_")}], #{Base.unhash( @attributes )} }! 
      end
    end
  end

  class Fieldset < Base
    include Childish
    
    def initialize( attributes={} )
      super( "", attributes )
      @attributes.delete(:name)
      
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%fieldset{ #{Base.unhash( @attributes )} }! 
      end
    end # initialize
  end # Fieldset
  
  
  class Legend < Base
    include Childish
    
    def initialize( inner, attributes={} )
      super( "", attributes )
      @attributes.delete(:name)
      @inner = inner
      
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%legend{ #{Base.unhash( @attributes )} }#{@inner}! 
      end
    end # initialize
  end # Fieldset
      

  class Label
    include Childish
    include Grouping
    
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
    DEFAULT = { cols: 40, rows: 10, tabindex: %q!#{i += 1}! }

    def initialize( name,  inner=nil, attributes={} )
      (attributes = inner && inner = nil) if inner.kind_of? Hash
      super( name, DEFAULT.merge( attributes ) )
      @inner = inner
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%textarea{ atts[:#{name.gsub(/\W/, "_")}], #{Base.unhash( @attributes )} }#{@inner}!
      end
    end
  end

end
