# encoding: UTF-8

require_relative "./spec_helper.rb"
require_relative "../lib/campo/campo.rb"
require_relative "../lib/campo/plugins/partial.rb"


describe :"Campo::Plugins::Partial" do
  before(:all) do
    Campo.plugins.clear
    Campo.plugin :partial # this is normally done by lib/campo.rb
  end
  describe :"Campo::Plugins::Partial::Klass" do
    context "Initialisation" do
      subject { Campo::Plugins::Partial::Klass.new }
      it { should_not be_nil }
      it { should be_a_kind_of Campo::Plugins::Partial::Klass }
    end

    context "After initialisation" do
      subject { Campo::Plugins::Partial::Klass.new }
      it { should respond_to(:befores, :afters, :before_output, :after_output, :on_plugin, :extras, :plugged_in) }
    end
  end

  describe :"Campo::Plugins::Partial.new" do
    subject { Campo::Plugins::Partial.new }
    it { should_not be_nil }
    it { should be_a_kind_of Campo::Plugins::Partial::Klass }
  end

  context "Plugging in the Partial plugin" do
    before(:each) { Campo.plugin :partial }
    after(:each) { Campo.plugins.clear }
    context "ancestors" do
      subject { Campo::Outputter.ancestors }
      it { should include( Campo::Plugins::Partial::InstanceMethods ) }
    end
    context "included methods" do
      subject { Campo::Outputter.new }
      it { should respond_to( :partial, :declarations, :options, :befores ) }
      describe :partial do
        subject { Campo::Outputter.new.partial }
        it { should be_nil }
      end
      describe :declarations do
        subject { Campo::Outputter.new.declarations }
        it { should_not be_nil }
        it { should be_a_kind_of String }
        it { should include("- atts = {} if atts.nil?") }
        it { should include("# for tabindex\n") }
      end
      describe :options do
        subject { Campo::Outputter.new.options }
        it { should_not be_nil }
        it { should be_a_kind_of Hash }
        it { should include(n: 0, tab: 2, partial: false) }
      end
      describe :befores do
        subject { Campo::Outputter.new.befores }
        it { should_not be_nil }
        it { should be_a_kind_of Array }
        it { should be_empty }
        describe "What befores is holding" do
          subject { Campo::Outputter.new.befores.first }
          it { should be_nil }
        end
      end
      describe :afters do
        subject { Campo::Outputter.new.afters }
        it { should_not be_nil }
        it { should be_a_kind_of Array }
        it { should have(1).items }
      end
    end
  end
end # partial