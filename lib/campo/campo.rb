# encoding: UTF-8

module Campo

  # Deals with adding children and tracking parents.
  module Childish
  
    # Push something onto the end of the fields array.
    # @param [Object] child The object to push.
    # @return [Object] self
    def push=( child )
      @fields << child
      child.parent = self
      self
    end

    # @see #push=
    alias :<< :push=
    
    attr_accessor :parent
  end # Childish
  
  # Helpers for id'ing fields.
  module Iding
    
    # Helps to create a unique id tag.
    # @param [String,nil] val
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
  
  
  def self.plugin( name, options={} )
    unless plugins.include? name
      modname = (str = name.to_s) && (str[0,1].upcase + str[1..-1])
      plugins[name] = constantize("Campo::Plugins::#{modname}").new options
      plugins[name].plugged_in
    end
  end
  
  # Here to make life a bit easier and cut down on RSI.
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
    # @see Campo::Literal#initialize
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
    #     select( "breads", {opts: [[1, "White"],[2,"Malted"],[3,"Black"],[4,"Wholemeal"], [5,"Rye"] ] })
    #
    # @see Select#initialize
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
    def submit( name="Submit", attributes={} )
      submit = Campo::Input.new( name, :submit, {value: name}.merge(attributes) )
      self << submit
      submit
    end
    
    
    # There is no easy way to give this convenience method in the same convention as the other methods, so this uses a hash argument for the label
    # @example
    #   textarea "name", "The text wrapped inside", label: "Example textarea"
    def textarea( name,  inner=nil, attributes={}, &block  ) 
      if inner.kind_of? Hash
        attributes = inner
        inner = nil
      end
      label = attributes.delete(:label) || attributes.delete(:labelled)
      textarea = Campo::Textarea.new( name, inner, attributes ).labelled( label )
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
  
  
  # Almost every Campo class inherits from this.
  # @abstract Not entirely abstract, but should always be subclassed.
  class Base 
    include Childish
    include Iding
    include Enumerable 
    alias_method :enumerable_select, :select
    include Convenience
    
    # Default attributes.
    DEFAULT = { tabindex: nil }

    # @!attribute [r] attributes The element's html attributes.
    # @return [Hash]
    
    # @!attribute [r] fields The element's child elements.
    # @return [Array<Base>]
    
    attr_accessor :attributes, :fields

    # @param [String] name The value of the element's name attribute.
    # @param [Hash,optional] attributes Any attributes for the element. Defaults to a generated tabindex (dependent on the order of form elements).
    # @yield Any fields defined in the passed block become children of this element.
    def initialize( name, attributes={}, &block )
      @attributes = DEFAULT.merge( {id: name}.merge(attributes.merge({name: name})) ).reject{|k,v| v.nil? }
      @fields = []
      
      instance_eval( &block ) if block
    end
    
    
    # Iterates over the fields array.
    def each(&block)
      block.call self if block
      if respond_to?(:fields) &! fields.empty?
        fields.each{|field| field.each &block }
      end
    end
    
    
    # Takes a block that handles the rendering.
    def on_output( &block )
      @output_listener = block
    end


    # Render to Haml
    # @param [Integer] n
    # @param [Integer] tab
    def output( n=0, tab=2 )
      n ||= 0
      tab ||= 2
      @output_listener.call n, tab
    end


    # Bit of a convenience method for adding a label around any element.
    # @param [String] inner The text for the label.
    # @return [Base]
    def labelled( inner=nil )
      inner ||= self.attributes[:name].gsub(/\[\]/, "").gsub("_"," ").capitalize
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


    # Takes a hash and transforms the key value pairs into a stringified version that Haml can consume.
    # @param [Hash] hash The hash to stringify.
    # @param [Array<#to_s>] skips Keys to skip.
    # @todo Make an Attributes class < Hash that deals with this.
    # @api private
    def self.unhash( hash, skips=nil )
      skips = skips.nil? ? [] : skips.map(&:to_sym) # all keys are symbols
      hash.reject{|k,v| v.nil?  }.reject{|k,v| skips.include? k.to_sym }.reduce(""){|mem, (k,v)| mem + %Q!#{k.to_s.include?("-") ? ":\"#{k}\" =>" : "#{k}:"} #{Base.quotable(v)}, !}
    end
    
    
    # @api private
    # if the string provided begins with a double quote but does not end in one, make it an unquoted string on output
    # else, wrap it in quotes
    # @param [String] s
    def self.quotable( s )
      retval = if s.respond_to?(:start_with?) && s.start_with?( %Q!"! ) &! s.end_with?( %Q!"! )
        s[1.. -1] # chop the first character
      else
        %Q!"#{s}"! # wrap
      end 
    end


    # Where the magic of output happens.
    # @param [Base] top
    # @param [String] so_far
    # @param [Integer] depth
    # @param [Integer] tab Number of spaces for a tab.
    def self.output( top, so_far="", depth=0, tab=2)
      so_far << "#{top.output( depth, tab )}\n"
      depth += 1
      if top.respond_to?( :fields ) && top.fields.length >= 1
        top.fields.each do |field|
          so_far = Base.output( field, so_far, depth, tab ) 
        end
      end

      so_far
    end
    
    alias :render :output

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
  
  
  # Probably, the first method you'll call.
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
      fail ArgumentError, "you may only pass a string to Haml_Ruby_Insert/bit_of_ruby" unless s.kind_of?( String )
      super( nil ) # no name needed
      
      # @todo Don't enforce the equals sign, as a hyphen is also valid for adding a bit of ruby. Raise an exception
      @s = s.start_with?( '=' ) ? s : "= " + s.to_s
    
      self.on_output do |n=0, tab=2|
        (" " * n * tab) + @s
      end
    end
  end # Haml_Ruby_Insert
  

  # Add whatever you need to with a literal.
  class Literal < Base
  
    # @param [String] s The literal string.
    # @param [Hash,optional] attributes Any html attributes you wish the literal to have. 
    def initialize( s, attributes={} )
      super( nil, attributes ) # no name needed
      @s = s

      self.on_output do |n=0, tab=2|
        left,right = if @attributes.empty?
          ['','']
        else
          ['{ ', '}']
        end
        %Q!#{" " * n * tab}#{@s}! + left + Base.unhash( @attributes ) + right
      end
      self
    end
  end # Literal
  

  # For building 'select' tags.
  class Select < Base

    # @param [String] :name
    # @param [Hash] :params
    # option params [Hash] :attributes
    # option params [#to_s] :haml_insert
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


    # @param [#to_s] value The value for attribute 'value'.
    # @param [#to_s] inner The display text.
    # @param [true,false,nil] selected Whether the field is selected. Defaults to false.
    # @param [Hash] attributes Hash of attributes. They'll get added to the element.
    # @example (see Convenience#select)  
    def option( *args )
      value = args.shift
      inner = args.shift 
      selected, attributes = *args
      inner = value.capitalize if inner.nil?
      self << Campo::Option.new( @attributes[:name], value, inner, selected, attributes )
      self
    end
    
    
    # Adds a default selection to a select list. By default it is disabled.
    # @param [String,nil] The display string for the option. Default is "Choose one:".
    # @param [Hash,nil] attributes Attributes for the option. Defaults to {disabled: "disabled"}, pass in an empty hash to override (or a filled one), or nil for the default.
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
    def with_default( inner="Choose one:", attributes={disabled: "disabled"} )
      unless inner.nil? || inner.kind_of?( String )
        attributes = inner
        inner = nil
      end
      
      inner ||="Choose one:"
      attributes ||= {disabled: "disabled"}
      attributes = {id: "#{@attributes[:name]}_default" }.merge! attributes
      self.fields.unshift Campo::Option.new( @attributes[:name], "", inner , nil, attributes )
      self
    end
    
  end # Select
  
  
  # Options for your Selectas!
  class Option < Base
    
    # @param [String] name
    # @param [String] value
    # @param [String] inner
    # @param [true,false,nil] selected
    # @param [Hash] attributes
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
    
    # @param [String] name
    # @param [Symbol] type
    # @param [Hash] attributes
    # @example
    #    Campo::Input.new( "abc", :text, maxlength: 50 )
    #    # => %input{ atts[:abc], tabindex: "#{@campo_tabindex += 1}", id: "abc", type: "text", maxlength: "50", name: "abc",  }
    def initialize( name, type=:text, attributes={} )
      id_tag = id_tag(
        [:text,:hidden,:submit,:password].include?(type) ? 
          nil : 
          attributes[:value]
      ).gsub(/\W/, "_")
      
      name2 = name.gsub(/\[\]/, "") # remove any [] that may have been used for an array like / grouped object
      
      atts_name = "#{name2.gsub(/\W/, "_")}#{id_tag}"
      
      super( name, 
            { type: type.to_s, 
              id: "#{name2}#{id_tag}",
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

    # @param [String,nil] text Text for the legend tag
    # @param [Hash] attributes Hash of html attributes
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
  
  # add whatever you need to with a literal
  class Span < Base
  
    def initialize( id, inner, attributes={} )
      if inner.kind_of? Hash
        attributes = inner
        inner = nil
      end
      super( id, attributes )
      @attributes.delete(:name) # only id for this element
      @inner = inner
      
      unless @inner.nil? or @inner.empty?
        self.fields.push Campo.literal(@inner)
      end
      
      self.on_output do |n=0, tab=2|
        %Q!#{" " * n * tab}%span{#{Base.unhash( @attributes )}}!
      end
      self
    end
  end # Literal

end