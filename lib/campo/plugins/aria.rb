# encoding: UTF-8

require_relative "../plugins.rb"

module Campo
  module Plugins
  
    # For more accessible forms
    # http://www.w3.org/WAI/intro/aria
    module Aria 
    
      # @private
      def self.new( options={} )
        Klass.new options
      end
      
      module InstanceMethods
        module Convenience
          
          # Adds aria-describedby along with a span.
          # @param [String] message The text for the aria-describedby attribute.
          # @param [optional,Hash] options Any attributes for the span.
          # @example
          #   text("postcode").describe("All in caps", class: "description")
          # @return [String] A span with an id (and any options passed in as attributes) as Haml.
          # @see http://www.w3.org/TR/WCAG20-TECHS/ARIA1.html
          def describe( message, opts={} )
            label, field = if self.kind_of? Campo::Label
              [self,self.fields.first]       
            elsif self.parent.kind_of? Campo::Label
              [self.parent, self]
            end
            
            span_id = "#{label.attributes[:for]}_description"
            label.fields.push Campo::Span.new( span_id, message, opts )
            
            field.attributes[:"aria-describedby"] = span_id
            self
          end # def
        end # Convenience 
      end # InstanceMethods
    
      class Klass < Plugin
    
        def initialize( opts={} )
          
          # adds `describe` to Convenience, it's an easy way to get it where it needs to be
          # @private
          on_plugin do
              Campo::Base.send(:include, Campo::Plugins::Aria::InstanceMethods::Convenience)
          end
          
          # Adds the form role attribute to all fields before output.
          # @private
          before_output do |fields,options|
            fields.find_all{|x| x.kind_of? Campo::Form }.each do |form|
              if form.attributes[:role].nil? || form.attributes[:role].empty?
                form.attributes[:role] = "form"
              end
            end
          end
        end
    
      end # Klass
    end # Aria
  
  
  end # Plugins
end # Campo
