
# encoding: UTF-8

require_relative "./spec_helper.rb"
require_relative "../lib/campo/campo.rb"
require_relative "../lib/campo/plugins/partial.rb"
require_relative "../lib/campo/plugins/aria.rb"
require_relative "../lib/campo/plugins/jqueryvalidation.rb"

describe :"Campo::Plugins::JQueryValidation" do
  before(:all) do
    Campo.plugins.clear
  end
  describe :"Campo::Plugins::JQueryValidation::Klass" do
    context "Initialisation" do
      subject { Campo::Plugins::JQueryValidation::Klass.new }
      it { should_not be_nil }
      it { should be_a_kind_of Campo::Plugins::JQueryValidation::Klass }
    end
    
    context "After initialisation" do
      subject { Campo::Plugins::JQueryValidation::Klass.new }
      it { should respond_to(:befores, :afters, :before_output, :after_output, :on_plugin, :extras, :plugged_in) }
    end
  end
  
  describe :"Campo::Plugins::JQueryValidation.new" do
    subject { Campo::Plugins::JQueryValidation.new }
    it { should_not be_nil }
    it { should be_a_kind_of Campo::Plugins::JQueryValidation::Klass }
  end
  
  context "Plugging in the JQueryValidation plugin" do
    before(:each) { 
      Campo.plugins.clear
      Campo.plugin :partial
      Campo.plugin :JQueryValidation 
    }
    after(:each) { Campo.plugins.clear }
    context "ancestors" do
      subject { Campo::Base.ancestors }
      it { should include( Campo::Plugins::JQueryValidation::InstanceMethods::Convenience ) }
    end
    context "included methods" do
      context "Convenience" do
        subject { Campo::Input.new "name"}
        it { should respond_to( :validate ) }
      end
      context "Outputter" do
        subject { Campo::Outputter.new }
        it { should respond_to( :jquery_script_declaration ) }
        it { should respond_to( :jqv_form_names ) }
      end
    end
  end


  describe "output" do
    context "Given a partial" do
      before { 
        Campo.plugins.clear          
        Campo.plugin :partial        
        Campo.plugin :Aria
        Campo.plugin :JQueryValidation, form: "wrapper_form" }
      let(:form) {
        Campo.literal ".form" do
          text("a").validate
          text "c"
          text( "g", size: 3 ).validate( :digits, :maxlength, :required )
        end
      }
let(:expected) { 
<<'STR'
:javascript
  $().ready(function(){
    $("#wrapper_form").validate({
      rules: {
        a: { required: true },
        g: { required: true, maxlength: 3, digits: true }
      }
    });
  });
.form
  %label{ for: "a", class: "required",  }
    A
    %input{ atts[:a], tabindex: "#{@campo_tabindex += 1}", id: "a", type: "text", name: "a", class: "required",  }
  %label{ for: "c",  }
    C
    %input{ atts[:c], tabindex: "#{@campo_tabindex += 1}", id: "c", type: "text", name: "c",  }
  %label{ for: "g", class: "required",  }
    G
    %input{ atts[:g], tabindex: "#{@campo_tabindex += 1}", id: "g", type: "text", size: "3", name: "g", class: "required",  }
STR
}
      
      
      subject { Campo.output(form, :partial => true) }
      it { should_not be_nil }
      it { should be_a_kind_of String }
      it { should == expected }
      it { should include(%Q!class: "required"!)   }
    end
    
    
    
    context "Given a whole form" do
      before { 
        Campo.plugins.clear          
        Campo.plugin :partial        
        Campo.plugin :Aria
        Campo.plugin :JQueryValidation}
      let(:form) {
        Campo.form "exampleForm" do
          text("a").validate
          text( "b" ).validate
          text "c"
          text( "d", size: 2 ).validate( :maxlength )
          text( "e", size: 5 ).validate( :maxlength, :required )
          text( "f" ).validate( :digits )
          text( "g", size: 3 ).validate( :digits, :maxlength, :required )
        end
      }
      let(:expected) { <<'STR'
:javascript
  $().ready(function(){
    $("#exampleForm").validate({
      rules: {
        a: { required: true },
        b: { required: true },
        d: { maxlength: 2 },
        e: { required: true, maxlength: 5 },
        f: { digits: true },
        g: { required: true, maxlength: 3, digits: true }
      }
    });
  });
- atts = {} if atts.nil?
- atts.default_proc = proc {|hash, key| hash[key] = {} } if atts.default_proc.nil?
- inners = {} if inners.nil?
- inners.default = "" if inners.default.nil?
- @campo_tabindex ||= 0 # for tabindex
%form{ atts[:exampleform], id: "exampleForm", method: "POST", name: "exampleForm", role: "form",  }
  %label{ for: "a", class: "required",  }
    A
    %input{ atts[:a], tabindex: "#{@campo_tabindex += 1}", id: "a", type: "text", name: "a", class: "required",  }
  %label{ for: "b", class: "required",  }
    B
    %input{ atts[:b], tabindex: "#{@campo_tabindex += 1}", id: "b", type: "text", name: "b", class: "required",  }
  %label{ for: "c",  }
    C
    %input{ atts[:c], tabindex: "#{@campo_tabindex += 1}", id: "c", type: "text", name: "c",  }
  %label{ for: "d",  }
    D
    %input{ atts[:d], tabindex: "#{@campo_tabindex += 1}", id: "d", type: "text", size: "2", name: "d",  }
  %label{ for: "e", class: "required",  }
    E
    %input{ atts[:e], tabindex: "#{@campo_tabindex += 1}", id: "e", type: "text", size: "5", name: "e", class: "required",  }
  %label{ for: "f",  }
    F
    %input{ atts[:f], tabindex: "#{@campo_tabindex += 1}", id: "f", type: "text", name: "f",  }
  %label{ for: "g", class: "required",  }
    G
    %input{ atts[:g], tabindex: "#{@campo_tabindex += 1}", id: "g", type: "text", size: "3", name: "g", class: "required",  }
STR
}
      subject { Campo.output(form) }
      it { should_not be_nil }
      it { should be_a_kind_of String }
      it { should == expected }
      it { should include(%Q!class: "required"!)   }
    end
  end

end