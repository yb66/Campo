# encoding: UTF-8


require_relative "./campo/plugins.rb"
require_relative "./campo/plugins/partial.rb"
require_relative "./campo/plugins/jqueryvalidation.rb"

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
  
  def self.constantize(camel_cased_word)
    names = camel_cased_word.split('::')
    names.shift if names.empty? || names.first.empty?

    constant = Object
    names.each do |name|
      constant = constant.const_defined?(name) ? constant.const_get(name,false) : constant.const_missing(name)
    end
    constant
  end
  
    
  # keeps track of the current plugins
  def self.plugins
    @plugins ||= {}
  end
  
  
  def self.plugin( name )
    unless plugins.include? name
      modname = (str = name.to_s) && (str[0,1].upcase + str[1..-1])
      plugins[name] = constantize("Campo::Plugins::#{modname}").new
      plugins[name].plugged_in
    end
  end
  
    
  module Convenience  
    
    # @param [optional, Hash] attributes Any attributes you wish to add to the haml element.
    # @example Fieldset as a block is easiest to read
    #   form.fieldset("Your details") do |f|
    #     f.text( "full_name",  size: 60 )
    #     f.text( "dob", "Date of birth: ", size: 8 )
    #   end
    def fieldset( text, attributes={}, &block )
      self << Fieldset.new( text, attributes, &block )
    end
    
    # @example Add a bit of code to the markup
    #   form.bit_of_ruby( "= 5 + 1" ) }
    def bit_of_ruby( *args, &block  )
      tag = Campo::Haml_Ruby_Insert.new( *args, &block  )
      self << tag
      tag
    end

    alias :haml_ruby_insert :bit_of_ruby

    # @example Output a literal string
    #   form.literal %Q!%p= "This is a paragraph "!
    def literal( *args, &block  )
      tag = Campo::Literal.new( *args, &block  )
      self << tag
      tag
    end

    # @example 
    #     # Select with a block of options
    #     f.select("teas") do |s|
    #       s.with_default
    #       s.option("ceylon")
    #       s.option("breakfast")
    #       s.option("earl grey")
    #       s.option("oolong")
    #       s.option("sencha")
    #     end.labelled("Favourite tea:")
    #
    #     # Select using chain of options
    #     form.select("bands").option("Suede").option("Blur").option("Oasis").option("Echobelly").option("Pulp").option("Supergrass").with_default.labelled("Favourite band:")
    #
    # @see Select
    def select( *args, &block )
      select = Campo::Select.new( *args, &block )
      self << select
      select
    end
    
    # Add an input with type of text
    # @param [String] name The name html attribute.
    # @param [optional, String, nil] label Give the label a name. Defaults to a capitalised name with _ replaced by spaces.
    # @param [optional, Hash] attributes Any attributes you wish to add to the haml element.
    # @example
    #     f.text "full_name",  size: 60 
    #     f.text "dob", "Date of birth: ", size: 8
    # @return [Input] 
    #   With the attribute `type=text`
    def text( name, label=nil, attributes={}  )
      input( name, :text, label, attributes  )
    end
    
    def hidden( name, attributes={}  )
      self << Campo::Input.new( name, :hidden, attributes )
    end
    
    
    # @param (see #text)
    def password( name, label=nil, attributes={}  )
      input( name, :password, label, attributes  )
    end
    
    
    # @param (see #text)
    def radio( name, label=nil, attributes={} )
      input( name, :radio, label, attributes )
    end
    
    # @param (see #text)
    def checkbox( name, label=nil, attributes={} )
      input( name, :checkbox, label, attributes )
    end
    
    
    # @param (see #text)
    # @param [:symbol] type The type html attribute.
    def input( name, type, label=nil, attributes={} ) 
      if label.kind_of? Hash
        attributes = label
        label = nil
      end

      field = Campo::Input.new( name, type, attributes ).labelled( label )
      self << field
      field
    end
    
    # @param [optional,String] name
    # @param [optional, Hash] attributes Any attributes you wish to add to the haml element.
    def submit( name="Submit", label_inner=nil, attributes={} )
      submit = Campo::Input.new( name, :submit, {value: name}.merge(attributes) )
      self << submit
      submit
    end
    
    
    def textarea( *args, &block  )
      textarea = Campo::Textarea.new( *args )
      self << textarea
      textarea
    end
  end # Convenience
  
  module Helpers
  
  
    # [ [id, lookup, selected || false], ... ]
    def self.options_builder( name, opts )
      return [] if opts.nil? || opts.empty?
      
      if opts.respond_to? :each_pair
        opts.map do |id, (inner, selected, atts)|
          Campo::Option.new( name, id, inner, selected, atts )
        end
      else
        opts.map do |id, inner, selected, atts|
          Campo::Option.new( name, id, inner, selected, atts )
        end
      end
    end # def
    
    
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
    include Enumerable 
    alias_method :enumerable_select, :select
    include Convenience
    
    DEFAULT = { tabindex: nil }

    attr_accessor :attributes, :fields

    def initialize( name, attributes={}, &block )
      @attributes = DEFAULT.merge( {id: name}.merge(attributes.merge({name: name})) ).reject{|k,v| v.nil? }
      @fields = []
      
      instance_eval( &block ) if block
    end
    
    def each(&block)
      block.call self if block
      if respond_to?(:fields) &! fields.empty?
        fields.each{|field| field.each &block }
      end
    end
    
    
    def on_output( &block )
      @output_listener = block
    end

    def output( n=0, tab=2 )
      n ||= 0
      tab ||= 2
      @output_listener.call n, tab
    end

    def labelled( inner=nil )
      inner ||= self.attributes[:name].gsub("_"," ").capitalize
      parent = self.parent
      label = Label.new( %Q!#{@attributes[:id]}!, inner ) << self
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
    
    # if the string provided begins with a double quote but does not end in one, make it an unquoted string on output
    # else, wrap it in quotes
    def self.quotable( s )
      retval = if s.respond_to?(:start_with?) && s.start_with?( %Q!"! ) &! s.end_with?( %Q!"! )
        s[1.. -1] # chop the first character
      else
        %Q!"#{s}"! # wrap
      end 
    end


    def self.output( top, so_far="", count=0, tab=2)
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
  
  # @see Convenience#literal
  def self.literal( *args, &block )
    Campo::Literal.new( *args, &block )
	end
	
  # Pass anything but the form for the first argument to *not* have the local variable defaults added to the top
  # @example 
  #     Campo.output form # would add the default locals
  #     # these won't
  #     Campo.output :partial, input_field
  #     Campo.output false, label
  #     Campo.output true, fieldset
  def self.output( fields, options={} )
    Outputter.new( options.delete(:tab)  ).run( fields, options )
  end # self.output

# end Campo methods

  class Outputter  
    
    def before_output( &block )
      befores << block
    end
    
    def after_output( &block )
      afters << block
    end
    
    def befores
      @befores ||= check_for_plugins :befores
    end   
    
    def afters
      @afters ||= check_for_plugins :afters
    end
    
    def check_for_plugins( type )
      Campo.plugins.reduce [] do |mem, (_,plugin)|
        mem + plugin.send(:"#{type}" )
      end
    end
    
    def initialize( tab=nil, &block )
      options[:tab] = tab unless tab.nil? 
      instance_eval( &block ) if block
    end
    
    attr_accessor :output
    
    DEFAULT_OPTIONS={n: 0, tab: 2}
    
    def options
      @options ||= DEFAULT_OPTIONS
    end
    
    def run( fields, opts={} )
      opts = options.merge opts
      tab = opts.delete(:tab) || @tab
      
      output = ""
      befores.each{|f| instance_exec( fields, options, &f ) } 
      output = Base.output( fields, output, options[:n], tab )
      output = afters.reduce(output){|mem,obj| instance_exec mem, opts, &obj }
      output
    end
  end


  
  class Form < Base
    DEFAULT = { method: "POST" }

    # @param [String] name The form's name (html) attribute.
    # @param [optional, Hash] attributes Html attributes. They can be anything you like. Defaults follow:
    # @option attributes [String] :method ("POST")
    # @example
    #     form = Campo::Form.new "example", "/path/to/post/to/" do |form|
    #       form.text "first_field"
    #       #... more fields follow
    #     end
    def initialize(name,  attributes={} )
      super( name, DEFAULT.merge( attributes ) )
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%form{ atts[:#{name.gsub(/\W/, "_").downcase}], #{Base.unhash( @attributes )} }!
      end
    end
    

  end # Form
  
  # Generally, the first method you'll call.
  # @example 
  #     # Form with a block
  #     form = Campo.form "form1", action: "/go/for/it/" do |f|
  #       f.text "Hello"
  #       #... more fields follow
  #     end
  #
  # @param [String] name The form's name (html) attribute.  
  # @param [optional, Hash] attributes Html attributes. They can be anything you like. Defaults follow:
  # @option attributes [String] :method ("POST") The method attribute for the form.
  # @see Form#initialize
  def self.form( name, attributes={}, &block )
    Form.new( name, attributes, &block )
  end
  
  
  class Haml_Ruby_Insert < Base
    def initialize( s )
      raise ArgumentError, "you may only pass a string to Haml_Ruby_Insert/bit_of_ruby" unless s.kind_of?( String )
      super( nil ) # no name needed
      @s = s.start_with?( '=' ) ? s : "= " + s.to_s
    
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
      self
    end
  end # Literal
  
  class Select < Base
    def initialize( name, params={} )
      opts = params[:opts] || []
      attributes = params[:attributes] || {}
      haml_insert = params[:haml_insert] || nil
      
      super( name, { tabindex: %q!#{@campo_tabindex += 1}! }.merge(attributes) )
      
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%select{ atts[:#{name.gsub(/\W/, "_").downcase}], #{Base.unhash( @attributes )} }! 
      end
      
      self.fields += Helpers.options_builder( name, opts ) unless opts.nil? || opts.empty?
      
      self.fields << Haml_Ruby_Insert.new( haml_insert ) unless haml_insert.nil?
      
      
      self
    end # initialize
      
    # @example (see Convenience#select)  
    def option( *args )
      value = args.shift
      inner = args.shift 
      selected, attributes = *args
      inner = value.capitalize if inner.nil?
      self << Campo::Option.new( @attributes[:name], value, inner, selected, attributes )
      self
    end
    
    
    # @example 
    #     As a default:
    #     form.select("teas").with_default.option("ceylon")
    #     # output:
    #       %select{ atts[:teas], tabindex: "#{@campo_tabindex += 1}", name: "teas",  }
    #          %option{  value: "", disabled: "disabled", name: "teas",  }Choose one:
    #          %option{ atts[:teas_ceylon], value: "ceylon", id: "teas_ceylon", name: "teas",  }Ceylon
    #
    #     form.select("teas").with_default("My fave tea is:").option("ceylon")
    #     # output:
    #       %select{ atts[:teas], tabindex: "#{@campo_tabindex += 1}", name: "teas",  }
    #       %option{  value: "", disabled: "disabled", name: "teas",  }My fave tea is:
    #       %option{ atts[:teas_ceylon], value: "ceylon", id: "teas_ceylon", name: "teas",  }Ceylon
    def with_default( inner="Choose one:" )
      self.fields.unshift Campo::Option.new( @attributes[:name], "", inner , nil, {disabled: "disabled" } )
      self
    end
    
    # def mark_as_selected( val )
    #   fields.find {|field| field.value == val }.selected = {selected: "selected"}
    # end
  end # Select
  
  
  class Option < Base
    
    # @param [String] name
    # @param [String] value
    def initialize( name, value, inner=nil, selected=nil, attributes={} )
      unless inner.nil? || inner.kind_of?( String )
        attributes = selected
        selected = inner
        inner = nil
      end
      
      unless selected.nil? || selected.kind_of?( TrueClass )
        if selected.respond_to? :each_pair
          attributes = selected
          selected = nil   
        else
          selected = true  
          @selected = true   
        end
      end
      
      attributes ||= {}
      
      @inner = (inner || value.gsub("_"," ").capitalize)
      
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
      id_tag = id_tag(
        [:text,:hidden,:submit,:password].include?(type) ? 
          nil : 
          attributes[:value]
      ).gsub(/\W/, "_")
      
      atts_name = "#{name.gsub(/\W/, "_")}#{id_tag}"
      
      puts "id_tag: #{id_tag}"
      
      super( name, 
            { type: type.to_s, 
              id: "#{name}#{id_tag}",
              tabindex: %q!#{@campo_tabindex += 1}!, 
            }.merge( attributes ) )
            
               
      @attributes.delete(:name) if type == :submit
      @attributes.delete(:tabindex) if type == :hidden
            
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%input{ atts[:#{atts_name}], #{Base.unhash( @attributes )} }! 
      end
    end
  end

  class Fieldset < Base

    # @params [String,nil] text Text for the legend tag
    # @params [Hash] attributes Hash of html attributes
    def initialize( text=nil, attributes={} )
      if text.kind_of? Hash
        attributes = text
        text = nil
      end
      super( nil, attributes )
      @attributes.delete(:name)
      
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%fieldset{ #{Base.unhash( @attributes )} }! 
      end
      @fields.unshift Legend.new( text ) unless text.nil?
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

    def initialize( for_element, inner=nil, attributes={} )
      if inner.kind_of? Hash
        attributes = inner
        inner = nil
      end
      super( nil, attributes.merge(for: for_element) )

      @inner = inner
    
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%label{ #{Base.unhash( @attributes )} }\n#{" " * (n + 1) * tab}#{@inner}! 
      end
    end

  end # Label


  class Textarea < Base
    DEFAULT = { cols: 40, rows: 10, tabindex: %q!#{@campo_tabindex += 1}! }

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

Campo.plugin :partial