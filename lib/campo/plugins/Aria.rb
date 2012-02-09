# encoding: UTF-8

require_relative "../plugins.rb"

module Campo
  module Plugins
  
    # For more accessible forms
    # http://www.w3.org/WAI/intro/aria
    module Aria 
    
      def self.new( options={} )
        Klass.new options
      end
      
      module InstanceMethods
        module Convenience
          def describe( message )
            label, field = if self.kind_of? Campo::Label
              [self,self.fields.first]       
            elsif self.parent.kind_of? Campo::Label
              [self.parent, self]
            end
            
            span_id = "#{label.attributes[:for]}_description"
            label.fields.push Campo::Span.new( span_id, message )
            
            field.attributes[:"aria-describedby"] = span_id
            
          end # def
        end # Convenience 
      end # InstanceMethods
    
      class Klass < Plugin
    
      def initialize( opts={} )
        on_plugin do
            # adds `describe` to Convenience, it's an easy way to get it where it needs to be
            Campo::Base.send(:include, Campo::Plugins::Aria::InstanceMethods::Convenience)
        end
      end
    
      end # Klass
    end # Aria
  
  
  end # Plugins
end # Campo
