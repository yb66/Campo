# encoding: UTF-8

require_relative "./spec_helper.rb"
require_relative "../lib/campo.rb"

describe :"Campo::plugins" do
  context "before plugging anything in" do
    subject { Campo.plugins }
    it { should be_a_kind_of Hash }
    it { should be_empty }
    context "Outputter" do
     # subject { Campo::Outputter.new }
      describe "befores" do
        subject { Campo::Outputter.new.befores }
        it { should_not be_nil }
        it { should be_a_kind_of Array }
        it { should be_empty }   
      end
      describe "afters" do
        subject { Campo::Outputter.new.afters }
        it { should_not be_nil }
        it { should be_a_kind_of Array }
        it { should be_empty }   
      end     
      context "check_for_plugins" do
        context "Given type of 'befores'" do
          subject { Campo::Outputter.new.check_for_plugins :befores }
          it { should_not be_nil }
          it { should be_a_kind_of Array }
          it { should be_empty }   
        end
        context "Given type of 'afters'" do
          subject { Campo::Outputter.new.check_for_plugins :afters }
          it { should_not be_nil }
          it { should be_a_kind_of Array }
          it { should be_empty }
        end
      end
                    
    end
  end
  context "after plugging something in" do
    before(:each) { Campo.plugin :partial }
    
    subject { Campo.plugins }
    it { should be_a_kind_of Hash }
    it { should_not be_empty }
    it { should include( :partial ) }
    
    describe "the value" do
      subject { Campo.plugins[:partial] }
      it { should_not be_nil }
      it { be_a_kind_of Campo::Plugins::Partial::Klass }
    end
    
    context "and then clearing the plugins" do
      subject { Campo.plugins.clear }
      it { should be_empty }
    end
  end
end
