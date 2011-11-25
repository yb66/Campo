# encoding: UTF-8

module Campo
  module Childish
    def push=( child )
      @fields << child
      child.parent = self
      self
    end

    alias :<< :push=
    
    attr_accessor :parent
  end # Childish
  
  module Iding
    def id_tag( val )
      val.nil? ? "" : "_#{val}"
    end
  end # Iding
  
  module Convenience
    
    def fieldset( text, attributes={}, &block )
      fieldset = (Fieldset.new(attributes) << Legend.new( text ))
      block.call( fieldset ) if block
      self << fieldset 
      fieldset
    end
    
    def bit_of_ruby( *args )
      tag = Campo::Haml_Ruby_Insert.new( *args )
      self << tag
      tag
    end

    alias :haml_ruby_insert :bit_of_ruby

    def literal( *args )
      tag = Campo::Literal.new( *args )
      self << tag
      tag
    end

    def select( *args, &block )
      select = Campo::Select.new( *args, &block )
      self << select
      select
    end
    
    def text( name, label=nil, attributes={} )
      input( name, :text, label, attributes )
    end
    
    def radio( name, label=nil, attributes={} )
      input( name, :radio, label, attributes )
    end
    
    def checkbox( name, label=nil, attributes={} )
      input( name, :checkbox, label, attributes )
    end
    
    def input( name, type, label=nil, attributes={} ) 
      if label.kind_of? Hash
        attributes = label
        label = nil
      end

      field = Campo::Input.new( name, type, attributes ).labelled( label )
      self << field
      field
    end
    
    def submit( name="Submit", label_inner=nil, attributes={} )
      submit = Campo::Input.new( name, :submit, {value: name}.merge(attributes) )
      self << submit
      submit
    end
    
    
    def textarea( *args )
      textarea = Campo::Textarea.new( *args )
      self << textarea
      textarea
    end
  end # Convenience
  
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
  end # Helpers

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
      @attributes = DEFAULT.merge( attributes.merge({name: name}) ).reject{|k,v| v.nil? }
      @fields = []
    end
    
    def on_output( &block )
      @output_listener = block
    end

    def output( n=0, tab=2 )
      @output_listener.call n, tab
    end

    def labelled( inner=nil )
      inner ||= self.attributes[:name].gsub("_"," ").capitalize
      parent = self.parent
      label = Label.new( %Q!#{@attributes[:name] + id_tag(@attributes[:value]).gsub(/\W/, "_")}!, inner ) << self
      retval = if parent.nil?
        label
      else
        parent.fields.delete self
        parent << label
        label
      end
      
      retval
    end # labelled

    def self.unhash( hash, skip=nil )
      hash.reject{|k,v| v.nil?  }.reject{|k,v| k.to_sym == skip.to_sym unless skip.nil? }.reduce(""){|mem, (k,v)| mem + %Q!#{k}: #{Base.quotable(v)}, !}
    end
    
    # if the string provided begins with one quote but does not end in one, make it an unquoted string on output
    # else, wrap it in quotes
    def self.quotable( s )
      retval = if s.respond_to?(:start_with?) && s.start_with?( %Q!"! ) &! s.end_with?( %Q!"! )
        s[1.. -1] # chop the first character
      else
        %Q!"#{s}"! # wrap
      end 
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

  end # Base
  
	
# Campo methods

  # pass anything but the form for the first argument to *not* have the local variable defaults added to the top
  # i.e. Campo.output :partial, input_field
  # i.e. Campo.output false, label
  # i.e. Campo.output true, fieldset
  def self.output( *args )
    s = <<STR
- atts = {} if atts.nil?
- atts.default = {} if atts.default.nil?
- inners = {} if inners.nil?
- inners.default = "" if inners.default.nil?
- i = 0 # for tabindex

STR


    # default to true
    whole_form = if args.first.kind_of? Campo::Form 
      true
    else 
      args.shift
      false
    end
    
    output = Base.output( *args )
    output = s + output if whole_form
    output
  end # self.output

# end Campo methods


  # opt id
  class Form < Base
    include Convenience
    DEFAULT = { method: "POST" }

    def initialize(name,  attributes={}, &block )
      super( name, DEFAULT.merge( attributes ) )
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%form{ atts[:#{name.gsub(/\W/, "_").downcase}], #{Base.unhash( @attributes )} }!
      end
      
      block.call( self ) if block
      self
    end
    

  end # Form
  
  
  def self.form( name, *args )
    Form.new( name, *args )
  end
  
  
  class Haml_Ruby_Insert < Base
    def initialize( s )
      super( nil ) # no name needed
      @s = s.start_with?( '=' ) ? s : "= #{s}"
    
      self.on_output do |n=0, tab=2|
        (" " * n * tab) + @s
      end
    end
  end # Haml_Ruby_Insert
  

  # add whatever you need to with a literal
  class Literal < Base
    def initialize( s )
      super( nil ) # no name needed
      @s = s

      self.on_output do |n=0, tab=2|
        (" " * n * tab) + @s
      end
    end
  end # Literal
  
  class Select < Base
    def initialize( name, params={}, &block )
      opts = params[:opts] || []
      attributes = params[:attributes] || {}
      haml_insert = params[:haml_insert] || nil
      
      super( name, { tabindex: %q!#{i += 1}! }.merge(attributes) )
      
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%select{ atts[:#{name.gsub(/\W/, "_").downcase}], #{Base.unhash( @attributes )} }! 
      end
      
      self.fields += Helpers.options_builder( name, opts ) unless opts.nil? || opts.empty?
      
      self.fields << Haml_Ruby_Insert.new( haml_insert ) unless haml_insert.nil?
      
      block.call( self ) if block
      self
    end # initialize
      
    def option( *args )
      value = args.shift
      inner = args.shift 
      selected, attributes = *args
      inner = value.capitalize if inner.nil?
      self << Campo::Option.new( @attributes[:name], value, inner, selected, attributes )
      self
    end
    
    def with_default( inner="Choose one:" )
      self.fields.unshift Campo::Option.new( @attributes[:name], "", inner , nil, {disabled: "disabled" } )
      self
    end
    
    # def mark_as_selected( val )
    #   fields.find {|field| field.value == val }.selected = {selected: "selected"}
    # end
  end # Select
  
  
  class Option < Base
    attr_accessor :value, :checked
    
    def initialize( name, value, inner=nil, selected=nil, attributes={} )
      attributes ||= {}
      if inner.kind_of? TrueClass
        selected = attributes
        inner = nil
      end
      
      @inner = inner || value
      
      if selected.kind_of? Hash
        attributes = selected 
        selected = {}
      end 
      
      attributes = { id: "#{(name.gsub(/\W/, "_") + id_tag(value).gsub(/\W/, "_")).downcase}" }.merge(attributes) unless value.nil? || value.to_s.empty?
      
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
            
               
      @attributes.delete(:name) if type == :submit
            
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%input{ atts[:#{name.gsub(/\W/, "_")}#{id_tag(attributes[:value]).gsub(/\W/, "_")}], #{Base.unhash( @attributes )} }! 
      end
    end
  end

  class Fieldset < Base
    include Convenience
    
    def initialize( attributes={} )
      super( nil, attributes )
      @attributes.delete(:name)
      
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%fieldset{ #{Base.unhash( @attributes )} }! 
      end
    end # initialize
  end # Fieldset
  
  
  class Legend < Base
    
    def initialize( inner, attributes={} )
      super( nil, attributes )
      @attributes.delete(:name)
      @inner = inner
      
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%legend{ #{Base.unhash( @attributes )} }#{@inner}! 
      end
    end # initialize
  end # Fieldset
      

  class Label < Base
    
    DEFAULT = { for: nil }

    attr_reader :attributes, :fields

    def initialize( name, inner=nil, attributes={} )
      if inner.kind_of? Hash
        attributes = inner
        inner = nil
      end
      super( name, attributes )

      @inner = inner
    
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%label{ for: "#{@attributes[:name]}", #{Base.unhash( @attributes, :name )} }\n#{" " * (n + 1) * tab}#{@inner}! 
      end
    end

  end # Label


  class Textarea < Base
    DEFAULT = { cols: 40, rows: 10, tabindex: %q!#{i += 1}! }

    def initialize( name,  inner=nil, attributes={} )
      if inner.kind_of? Hash
        attributes = inner
        inner = nil
      end
      super( name, DEFAULT.merge( attributes ) )
      @inner = inner
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%textarea{ atts[:#{name.gsub(/\W/, "_")}], #{Base.unhash( @attributes )} }= inners[:#{name.gsub(/\W/, "_")}] !
      end
    end
  end # Textarea

end
