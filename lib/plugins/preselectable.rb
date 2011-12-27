module Campo
  module Plugins
    module Preselectable
      module InstanceMethods
        def output( already_done, n=0, tab=2 )
#           puts "@attributes[:name]: #{@attributes[:name]}"
#           puts "@attributes[:type]: #{@attributes[:type]}"
#           puts "self.class #{self.class}"
#           already_done
          done_here = if [Campo::Select, Campo::Input].include?( self.class ) && (x = Helpers.selected_based_on_value @attributes[:name], @attributes[:type] )
            "#{" " * n * tab}#{x}"  
          else
            nil
          end
            
          "#{done_here}#{already_done}"
        end
      end # instance methods
      
      # module ClassMethods
#       end
      
      
      
      module Helpers
        def self.memory
          puts "memory: #{@memory.inspect}"
          @memory ||= Hash.new(0)
        end
        
#         def self.clear_memory
#           @memory = nil
#         end
#         
#         def on_update( &block )
#           @on_update = if block
#             block
#           else
#             ->{ @memory = nil }
#           end
#         end
#         
#         def self.update
#           @on_update.call
#         end
        
        def self.selected_based_on_value( name, type )
          type = "select" if type.nil?
          hash = case type
            when "select" then %q!{selected: "selected"}!
            when "radio"
              Helpers.memory[name] += 1
              %q!{checked: "checked"}!
            when "checkbox" then %q!{checked: "checked"}!
            else nil
          end
          
          # if the radio button's name has already been seen too many times it won't run this again
          unless hash.nil? || (Helpers.memory[name] >= 2 )      
<<STR
- atts["#{name}_\#{atts[:#{name}][:value]}".to_sym ] = atts["#{name}_\#{atts[:#{name}][:value]}".to_sym].merge( #{hash} ) unless atts[:#{name}].empty?
STR
          end
        end # def
          
      
      end # Helpers
    end # Preselectable
  end # Plugins
end # Campo