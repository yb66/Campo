# encoding: UTF-8

module Campo
  module Childish
    def push=( child )
      @fields << child
      self
    end

    alias :<< :push=
  end

  class Base 
    include Childish
    DEFAULT = { tabindex: nil }

    attr_reader :attributes, :fields

    def initialize( name, attributes={} )
      @attributes = DEFAULT.merge( attributes.merge({name: name}) )
      @fields = []
    end

    def output
      # not implemented
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
    Base.output( *args )
  end

  # opt id
  class Form < Base

    def initialize(name,  attributes={} )
      super( name, DEFAULT.merge( attributes ) )
    end
    DEFAULT = { name: nil, method: "POST", action: nil }

    def output( n=0, tab=2 )
      %Q!#{" " * n * tab}- form_#{@attributes[:name]} = form_#{@attributes[:name]}.nil? ? {} : form_#{@attributes[:name]}\n\n#{" " * n * tab}%form{ form_#{@attributes[:name]}, #{Base.unhash( @attributes )} }! 
    end
  end

  # 
  class Input < Base
    DEFAULT = { type: nil, value: nil, name: nil }

    def initialize( name, attributes={} )
      super( name, DEFAULT.merge( attributes ) )
    end
  end

  class Text < Input
    DEFAULT = { size: nil, maxlength: nil, type: "text" }

    def initialize( name, attributes={} )
      super( name, DEFAULT.merge( attributes ) )
    end

    def output( n=0, tab=2 )
      %Q!#{" " * n * tab}%input{ #{Base.unhash( @attributes )} }! 
    end
  end
  
  class Submit < Input
    DEFAULT = { type: "submit" }

    def initialize( name="submit", attributes={} )
      super( name, DEFAULT.merge( attributes ) )
    end

    def output( n=0, tab=2 )
      %Q!#{" " * n * tab}%input{ #{Base.unhash( @attributes )} }! 
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
    end


    def output( n=0, tab=2 )
      %Q!#{" " * n * tab}%textarea{ #{Base.unhash( @attributes )} } #{@inner}!
    end
  end

end
# 
# 
# 
# 
# 
# class Checkbox < Input
#   DEFAULT = { checked: nil, type: "checkbox" }
# 
#   def initialize( name, attributes={} )
#     super( name, DEFAULT.merge( attributes ) )
#   end
# end
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