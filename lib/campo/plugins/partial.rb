# encoding: UTF-8

require_relative "../plugins.rb"

module Campo
  module Plugins
  
    module Partial 
    
      def self.new
        Klass.new
      end
      
      module InstanceMethods
        attr_accessor :partial
        
        DECLARATIONS = <<STR
- atts = {} if atts.nil?
- atts.default_proc = proc {|hash, key| hash[key] = {} } if atts.default_proc.nil?
- inners = {} if inners.nil?
- inners.default = "" if inners.default.nil?
- @campo_tabindex ||= 0 # for tabindex
STR
        def declarations
          DECLARATIONS
        end
      end
    
      class Klass < Plugin
    
      def initialize
        after_output do |output,opts|
          opts[:partial] ? 
            output : # partial
            declarations + output # whole form
        end
        on_plugin do
          Campo::Outputter.send(:include, Campo::Plugins::Partial::InstanceMethods)
          Campo::Outputter::DEFAULT_OPTIONS.merge!({partial: false})
        end
      end
    
        DEFAULT_OPTIONS={partial: false}
      end # Klass
    end # Partial
  
  
  end # Plugins
end # Campo
