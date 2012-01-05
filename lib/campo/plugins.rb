# encoding: UTF-8

module Campo
  module Plugins
    
    module Pluggable      
      def before_output( &block )
        befores << block
      end
      
      def after_output( &block )
        afters << block
      end
      
      def on_plugin( &block )
        @extras = block
      end
      
      def extras
        @extras ||= proc {}
      end
    
      def plugged_in
        instance_exec &@extras
      end
    end
    
    class Plugin
      include Pluggable   
      def befores
        @befores ||= []
      end   
      
      def afters
        @afters ||= []
      end
    end
  
  end # Plugins
  
end # Campo