# encoding: UTF-8

require_relative "../plugins.rb"

module Campo
  module Plugins

    # using the lib from http://docs.jquery.com/Plugins/Validation
    module JQueryValidation  
    
      def self.new
        Klass.new
      end
        
      module InstanceMethods
        # the simplest validation possible
        module Convenience
          def validate
            field = self.class == Campo::Label ?
              self.fields.first :
              self
              
            field.attributes.merge!({ :class => "required" } )
            self
          end
        end
        module Outputter        
          
          # holds the names of form(s)
          attr_accessor :jqv_form_names
          
          # builds the declaration for the top of the output
          def jquery_script_declaration
            unless jqv_form_names.nil? || jqv_form_names.empty?
              @jqv_form_names.reduce(":javascript\n") do |mem,name|
                 mem + %Q!  $("##{name}").validate();\n!
              end + "\n"
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
            jquery_script_declaration + output
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