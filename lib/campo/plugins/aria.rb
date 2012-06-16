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
          # @overload text(message, opts)
          #   @param [String] message The text for the aria-describedby attribute.
          #   @param [optional,Hash] options Any attributes for the span.
          #   @example
          #     text("postcode").describe("All in caps", class: "description")
          #   @return [String] A span with an id (and any options passed in as attributes) as Haml.
          # @overload text(message-tuples, opts)
          #   @param [Array<Array<String,Hash>>] message-tuples An array of tuples, each tuple containing the message string and an options hash for attributes.
          #   @param [optional,Hash] options Any attributes for the span.
          #   @example
          #     text("Address").describe([["postcode",{class: "British"}],["zipcode", {class: "American"}]], class: "description")
          #   @return [String] A span with an id (and any options passed in as attributes) as Haml, wrapped around an unordered list with a list-item for each message, each list-item receiving the attributes passed in the tuple for it.
          # @overload text(messages,opts)
          #   @param [Array<Array<String>>] messages An array of single valued arrays containing a string, the message.
          #   @example
          #     text("Address").describe([["A valid address"],["Don't forget the postcode!"]])
          #   @return [String] A span with an id (and any options passed in as attributes) as Haml, wrapped around an unordered list with a list-item for each message.
          # @see http://www.w3.org/TR/WCAG20-TECHS/ARIA1.html
          def describe( message, opts={} )
            label, field = if self.kind_of? Campo::Label
              [self,self.fields.first]       
            elsif (parent = self.parent).kind_of? Campo::Label
              [parent, self]
            end
            
            span_id = "#{label.attributes[:for]}_description"
            
            if message.respond_to? :map
              # array
              span = Campo::Span.new( span_id, "%ul", opts )
              message.each do |(x,o)|
                o ||= {}     
                li = Campo.literal("%li",o) << Campo.literal(x)
                span.fields.first << li
              end
            else              
              span = Campo::Span.new( span_id, message, opts )
            end
              
            label.fields.unshift span 
            
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
              form.attributes[:role] = "form" if form.attributes[:role].nil? || form.attributes[:role].empty?
            end
          end
        end
    
      end # Klass
    end # Aria
  
  
  end # Plugins
end # Campo
