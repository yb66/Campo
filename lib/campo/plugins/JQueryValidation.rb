# encoding: UTF-8

require_relative "../plugins.rb"

module Campo
  module Plugins

    # using the lib from http://docs.jquery.com/Plugins/Validation
    module JQueryValidation  
    
      def self.new
        Klass.new
      end
      
      module Rules  
        def self.render
          return "" if Rules.rules.empty?
          output = @jqv_rules.map do |(field,rs)| 
            "#{field}: { " << 
            rs.map{|k,v| "#{k}: #{v}" }.join(", ") <<
            " }"
          end.join(",\n" + "  " * 4)
          output = <<STR
rules: {
        #{output}
      }
STR
   
          output.chomp
        end
        def self.rules
          if @jqv_rules.nil?
              @jqv_rules = {}
              @jqv_rules.default_proc = proc {|hash, key| hash[key] = {} }
            end
          @jqv_rules
        end
          
        def self.[](key)
          Rules.rules[key]
        end
        def self.[]=( key,value )
          value = {value => true} unless value.kind_of? Hash
          Rules.rules[key].merge! value
          Rules.rules
        end
        def self.reset
          @jqv_rules = nil
        end
      end 
        
      module InstanceMethods
        # the simplest validation possible
        module Convenience
          def validate( *args )
          
            label, field = if self.kind_of? Campo::Label
              [self,self.fields.first] # for the key            
            elsif self.parent.kind_of? Campo::Label
              [self.parent, self]  # for the key
            end
            
            key = field.attributes[:id] || field.attributes[:name]
            
            # required
            if args.empty? || args.include?( :required )
              [label, field].each do |elem|
                elem.attributes.merge!({ :class => "required" } )
              end
              Rules[key] = :required
            end
            
            unless args.empty?  
              if args.include?( :maxlength )          
                if field.attributes.include? :size
                  Rules[key] = {maxlength: field.attributes[:size]}
                end
              end
              # http://docs.jquery.com/Plugins/Validation/Methods/digits
              Rules[key] = :digits if args.include? :digits
            end
            
            self
          end # def
        end
        module Outputter        
          
          # holds the names of form(s)
          attr_accessor :jqv_form_names
          
          # builds the declaration for the top of the output
          def jquery_script_declaration
            unless jqv_form_names.nil? || jqv_form_names.empty?
              @jqv_form_names.reduce(":javascript\n") do |mem,name|
                 mem + <<STR
  $().ready(function(){
    $("##{name}").validate({
      #{JQueryValidation::Rules.render}
    });
  });
STR
              end
            else
              "" # just in case there are no forms for some reason
            end
          end
        end
      end # instance methods
      
      class Klass < Plugin
        def initialize
          before_output do |fields,options|
            #find the form name(s)
            @jqv_form_names = fields.find_all{|x| x.kind_of? Campo::Form }.map{|x| x.attributes[:name]}
          end
          after_output do |output,options|
            # concat to the current output
            out = jquery_script_declaration + output
            Rules.reset
            out
          end
          on_plugin do
            # adds `validate` to Convenience, it's an easy way to get it where it needs to be
            Campo::Base.send(:include, Campo::Plugins::JQueryValidation::InstanceMethods::Convenience)
            # only for the outputter
            Campo::Outputter.send(:include, Campo::Plugins::JQueryValidation::InstanceMethods::Outputter)
          end
        end
      end # klass
    end # jqueryvalidation
  
  end # Plugins
end # Campo