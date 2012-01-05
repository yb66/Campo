
# encoding: UTF-8

require_relative "./spec_helper.rb"
require_relative "../lib/campo.rb"

describe :"Campo::Plugins::JQueryValidation" do
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
    before(:each) { Campo.plugin :JQueryValidation }
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
    describe "output" do
      let(:form) {
        Campo.form "exampleForm" do
          text("a").validate
          text "b"
          text "c"
        end
      }
      subject { Campo.output(form) }
      it { should_not be_nil }
      it { should be_a_kind_of String }
      it { should include(%Q!:javascript\n  $("#exampleForm").validate();\n!)   }
      it { should include(%Q!class: "required"!)   }
    end
  end
end