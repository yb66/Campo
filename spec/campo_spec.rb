# encoding: UTF-8

require_relative "../lib/campo.rb"
require "rspec"
require "logger"


module Campo
  describe Campo do
    
    let(:logger){
      require 'logger'
      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG
      logger
    }

    let(:top_bit) { s = <<-'STR'
- atts = {} if atts.nil?
- atts.default = {} if atts.default.nil?
- inners = {} if inners.nil?
- inners.default = "" if inners.default.nil?
- i = 0 # for tabindex

STR
            s
          }
          

    describe :output do
      context "Given a form with no fields" do
        let(:expected) { 
          expected = top_bit + %q!%form{ atts[:myform], method: "POST", name: "myform",  }!.strip + "\n"
        }

        subject{ Campo.output Campo::Form.new( "myform" ) }
        it { should_not be_nil }
        it { should == expected }
      end

      context "Given no form" do
        context "When given a select field with options" do
          let(:expected) { %q!
%label{ for: "teas",  }
  Favourite tea:
  %select{ atts[:teas], tabindex: "#{i += 1}", name: "teas",  }
    %option{  value: "", disabled: "disabled", name: "teas",  }Choose one:
    %option{ atts[:teas_ceylon], value: "ceylon", id: "teas_ceylon", name: "teas",  }Ceylon
    %option{ atts[:teas_breakfast], value: "breakfast", id: "teas_breakfast", name: "teas",  }Breakfast
    %option{ atts[:teas_earl_grey], value: "earl grey", id: "teas_earl_grey", name: "teas",  }Earl grey
!.strip + "\n"
          }
          let(:tag) {
            select = Campo::Select.new( "teas" )
            tag = select.with_default.option("ceylon").option("breakfast").option("earl grey").labelled("Favourite tea:") 
            tag
          }
          subject { Campo.output tag }
          it { should_not be_nil }
          it { should == expected }

        end
      end
    end
    
    describe Grouping do
      let(:obj) { 
        class Fakeclass  
          include Grouping
          include Childish
        end
        Fakeclass.new  
      }
      let(:form) { Campo::Form.new( "myform" ) }
      
      describe "input" do
        context "When given type" do
          context "of text" do
            let(:expected) { top_bit +  %q!
%form{ atts[:myform], method: "POST", name: "myform",  }
  %label{ for: "blah_blahdeblah",  }
    Blahd
    %input{ atts[:blah_blahdeblah], tabindex: "#{i += 1}", type: "text", id: "blah_blahdeblah", value: "blahdeblah", name: "blah",  }!.strip + "\n" }
            before { form.input( "blah", :text, "Blahd", value: "blahdeblah" ) }
            subject { Campo.output form }
            it { should_not be_nil }
            it { should == expected }
          end
            context "of checkbox" do
              let(:expected) { top_bit +  %q!
%form{ atts[:myform], method: "POST", name: "myform",  }
  %label{ for: "blah_blahdeblah",  }
    Blahd
    %input{ atts[:blah_blahdeblah], tabindex: "#{i += 1}", type: "checkbox", id: "blah_blahdeblah", value: "blahdeblah", name: "blah",  }!.strip + "\n" }
              before { form.input( "blah", :checkbox, "Blahd", value: "blahdeblah" ) }
              subject { Campo.output form }
              it { should_not be_nil }
              it { should == expected }
            end
        end
      end
        
    end
    
    
    describe Label do
      let(:tag) { Label.new( "abc", "A, B, or C?" ) }
      subject { tag }
      it { should_not be_nil }
      it { should be_a_kind_of(Label) }
      
      describe :output do
        let(:expected) { s =<<'STR'
%label{ for: "abc",  }
  A, B, or C?
STR
s.chomp
}
        subject { tag.output }
        it { should == expected }
      end
    end

    describe Form do
      
      describe "initialisation" do
        context "When given no args" do
          let(:form) { Campo::Form.new }
          it { should_not be_nil }
          it { should raise_error }
        end
        context "When given a name" do
          let(:form) { Campo::Form.new( "myform" ) }
          subject { form }
          it { should_not be_nil }
          it { should be_a_kind_of(Form) }
          
          context "via convenience method" do
            let(:form) { Campo.form( "myform" ) }
            subject { form }
            it { should_not be_nil }
            it { should be_a_kind_of(Form) }
          end
            
          
          context "simple output" do
            let(:expected) { %q!%form{ atts[:myform], method: "POST", name: "myform",  }! }
            subject { form.output }
            it { should == expected }
          end
        end
        context "When given a name and a hash of haml attributes" do
          let(:form) { Campo::Form.new( "myform", action: "/" ) }
          subject { form }
          it { should_not be_nil }
          it { should be_a_kind_of(Form) }
          
          context "simple output" do
            let(:expected) { %q!%form{ atts[:myform], method: "POST", action: "/", name: "myform",  }! }
            subject { form.output }
            it { should == expected }
          end
        end
      end


      
      describe :fieldset do
        context "When given a form with only a name" do
          let(:form) { Campo::Form.new( "myform" ) }
          let(:expected) { top_bit + %q!
%form{ atts[:myform], method: "POST", name: "myform",  }
  %fieldset{  }
    %legend{  }Do you like these colours? Tick for yes:
                
!.strip + "\n" }
          subject { form.fieldset("Do you like these colours? Tick for yes:") 
            Campo.output form
          }
          it { should_not be_nil }
          it { should == expected }
        end
        context "When given a form with a mix of fields" do
          let(:form) { Campo::Form.new( "myform" ) }
        end
      end
        
      context :select do
        let(:form) { Campo::Form.new( "myform" ) }
        context "Given one select tag" do
          let(:expected) { top_bit + %q!
%form{ atts[:myform], method: "POST", name: "myform",  }
  %label{ for: "teas",  }
    Favourite tea:
    %select{ atts[:teas], tabindex: "#{i += 1}", name: "teas",  }
      %option{  value: "", disabled: "disabled", name: "teas",  }Choose one:
      %option{ atts[:teas_ceylon], value: "ceylon", id: "teas_ceylon", name: "teas",  }Ceylon
      %option{ atts[:teas_breakfast], value: "breakfast", id: "teas_breakfast", name: "teas",  }Breakfast
      %option{ atts[:teas_earl_grey], value: "earl grey", id: "teas_earl_grey", name: "teas",  }Earl grey

!.strip + "\n"
          }
                            
          subject {
            form.select("teas").with_default.option("ceylon").option("breakfast").option("earl grey").labelled("Favourite tea:") 
            Campo.output form
          }
          it { should_not be_nil }
          it { should == expected }
        end
        context "Given several select tags" do
          let(:expected) {  top_bit + %q!
%form{ atts[:myform], method: "POST", name: "myform",  }
  %label{ for: "teas",  }
    Favourite tea:
    %select{ atts[:teas], tabindex: "#{i += 1}", name: "teas",  }
      %option{  value: "", disabled: "disabled", name: "teas",  }Choose one:
      %option{ atts[:teas_ceylon], value: "ceylon", id: "teas_ceylon", name: "teas",  }Ceylon
      %option{ atts[:teas_breakfast], value: "breakfast", id: "teas_breakfast", name: "teas",  }Breakfast
      %option{ atts[:teas_earl_grey], value: "earl grey", id: "teas_earl_grey", name: "teas",  }Earl grey
  %label{ for: "coffees",  }
    Favourite coffee:
    %select{ atts[:coffees], tabindex: "#{i += 1}", name: "coffees",  }
      %option{  value: "", disabled: "disabled", name: "coffees",  }Choose one:
      %option{ atts[:coffees_blue_mountain], value: "blue mountain", id: "coffees_blue_mountain", name: "coffees",  }Blue mountain
      %option{ atts[:coffees_kenyan_peaberry], value: "kenyan peaberry", id: "coffees_kenyan_peaberry", name: "coffees",  }Kenyan peaberry
      %option{ atts[:coffees_colombian], value: "colombian", id: "coffees_colombian", name: "coffees",  }Colombian
      %option{ atts[:coffees_java], value: "java", id: "coffees_java", name: "coffees",  }Java

!.strip + "\n" }
          before {
            form.select("teas").with_default.option("ceylon").option("breakfast").option("earl grey").labelled("Favourite tea:")
            form.select("coffees").with_default.option("blue mountain").option("kenyan peaberry").option("colombian").option("java").labelled("Favourite coffee:")
          }
          
          subject{ Campo.output form }
          it { should_not be_nil }
          it { should == expected }
        end
      end
      
      describe :submit do
        let(:form) { Campo::Form.new( "myform" ) }
        context "Given a submit button" do
          context "With no arguments" do
            let(:expected) { top_bit + %q!
%form{ atts[:myform], method: "POST", name: "myform",  }
  %input{ atts[:Submit_Submit], tabindex: "#{i += 1}", type: "submit", id: "Submit_Submit", value: "Submit",  }

!.strip + "\n" }
            
            subject { 
              form.submit
              Campo.output form
            }
            
            it { should_not be_nil }
            it { should == expected }
          end
          context "With a name" do
            let(:expected) { top_bit + %q!
%form{ atts[:myform], method: "POST", name: "myform",  }
  %input{ atts[:Save_Save], tabindex: "#{i += 1}", type: "submit", id: "Save_Save", value: "Save",  }

!.strip + "\n" }
            
            subject { 
              form.submit( "Save" )
              Campo.output form
            }
            
            it { should_not be_nil }
            it { should == expected }
          end
        end
      end
    end

    describe Haml_Ruby_Insert do
      let(:tag) { Haml_Ruby_Insert.new "= sel_opts" }
      subject { tag }
      it { should_not be_nil }
      it { should be_a_kind_of(Haml_Ruby_Insert) }
      
      describe :output do
        let(:expected) { "= sel_opts" }
        subject { tag.output }
        it { should == expected }
      end
      
      describe "Campo.output" do
        let(:expected) { %Q!= sel_opts\n! }
        subject { Campo.output tag }
        it { should == expected }
      end
    end
    
    describe Select do
      context "initialisation" do
        context "Given a name" do
          context "and nothing else" do
            let(:tag) { Campo::Select.new( "pqr" ) }
            subject { tag  }
            it { should_not be_nil }
            it { should be_a_kind_of(Select) }
            specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{i += 1}", name: "pqr",  }! }

            context "Campo.output" do
              let(:expected) { %q!%select{ atts[:pqr], tabindex: "#{i += 1}", name: "pqr",  }!.strip + "\n" }
              subject { Campo.output tag }
              it { should_not be_nil }
              it { should == expected }
            end
            
            context "and a default" do
              
              subject { tag.with_default }
              it { should_not be_nil }
              it { should be_a_kind_of(Select) }
              specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{i += 1}", name: "pqr",  }! }
              
              context "Campo.output" do
                let(:expected) { %q!%select{ atts[:pqr], tabindex: "#{i += 1}", name: "pqr",  }
  %option{  value: "", disabled: "disabled", name: "pqr",  }Choose one:!.strip + "\n"  }
                subject { Campo.output tag.with_default }
                it { should == expected }
              end
            end
          end

          context "and a block with options" do
            let(:tag) {  
              Campo::Select.new( "pqr" ) do |s|
                s.option "volvo", "Volvo"
                s.option "saab", "Saab"
                s.option "audi", "Audi"
              end
            }

            subject { tag }

            it { should_not be_nil }
            it { should be_a_kind_of(Select) }
            specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{i += 1}", name: "pqr",  }! }
            
            context "Campo.output" do
              let(:expected) { %q!%select{ atts[:pqr], tabindex: "#{i += 1}", name: "pqr",  }
  %option{ atts[:pqr_volvo], value: "volvo", id: "pqr_volvo", name: "pqr",  }Volvo
  %option{ atts[:pqr_saab], value: "saab", id: "pqr_saab", name: "pqr",  }Saab
  %option{ atts[:pqr_audi], value: "audi", id: "pqr_audi", name: "pqr",  }Audi
!.strip + "\n" }
              subject { Campo.output tag }
              it { should_not be_nil }
              it { should == expected }
            end
            
            
            context "and a default" do

              subject { tag.with_default }
              it { should_not be_nil }
              it { should be_a_kind_of(Select) }
              specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{i += 1}", name: "pqr",  }! }

              context "Campo.output" do
                let(:expected) { %q!%select{ atts[:pqr], tabindex: "#{i += 1}", name: "pqr",  }
  %option{  value: "", disabled: "disabled", name: "pqr",  }Choose one:
  %option{ atts[:pqr_volvo], value: "volvo", id: "pqr_volvo", name: "pqr",  }Volvo
  %option{ atts[:pqr_saab], value: "saab", id: "pqr_saab", name: "pqr",  }Saab
  %option{ atts[:pqr_audi], value: "audi", id: "pqr_audi", name: "pqr",  }Audi
!.strip + "\n"  }
                subject { Campo.output tag.with_default }
                it { should == expected }
              end
            end
            
            
            context "and a haml ruby insert" do
              let(:tag) {  
                Campo::Select.new( "pqr", {haml_insert: "= opts"} ) do |s|
                  s.option "volvo"
                  s.option "saab", "Saab"
                  s.option "audi", "Audi"
                end
              }
              subject { tag }
              specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{i += 1}", name: "pqr",  }! }
              
              context "Campo.output" do
                let(:expected) { %q!%select{ atts[:pqr], tabindex: "#{i += 1}", name: "pqr",  }
  = opts
  %option{ atts[:pqr_volvo], value: "volvo", id: "pqr_volvo", name: "pqr",  }Volvo
  %option{ atts[:pqr_saab], value: "saab", id: "pqr_saab", name: "pqr",  }Saab
  %option{ atts[:pqr_audi], value: "audi", id: "pqr_audi", name: "pqr",  }Audi!.strip + "\n" }
                subject { 
                  Campo.output tag }
                it { should_not be_nil }
                it { should == expected }
              end
            end
          end

          context "and an array" do
            let(:opts) { [["ford", "ford"], ["bmw", "BMW"], ["ferrari", "Ferrari", "checked"]] }
            subject { Campo::Select.new( "pqr", {opts: opts} ) }

            it { should_not be_nil }
            it { should be_a_kind_of(Select) }
            specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{i += 1}", name: "pqr",  }! }

            context "with a block with options" do
              let(:opts) { [["ford", "Ford"], ["bmw", "BMW"], ["ferrari", "Ferrari", "checked"]] }
              let(:tag){ 
                Campo::Select.new( "pqr", {opts: opts} ) do |s|
                  s.option "volvo", "Volvo"
                  s.option "saab", "Saab"
                  s.option "audi", "Audi"
                end
              }
              subject { tag }

              it { should_not be_nil }
              it { should be_a_kind_of(Select) }
              specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{i += 1}", name: "pqr",  }! }
              
              context "Campo.output" do
                let(:expected) { %q!%select{ atts[:pqr], tabindex: "#{i += 1}", name: "pqr",  }
  %option{ atts[:pqr_ford], value: "ford", id: "pqr_ford", name: "pqr",  }Ford
  %option{ atts[:pqr_bmw], value: "bmw", id: "pqr_bmw", name: "pqr",  }BMW
  %option{ atts[:pqr_ferrari], value: "ferrari", selected: "selected", id: "pqr_ferrari", name: "pqr",  }Ferrari
  %option{ atts[:pqr_volvo], value: "volvo", id: "pqr_volvo", name: "pqr",  }Volvo
  %option{ atts[:pqr_saab], value: "saab", id: "pqr_saab", name: "pqr",  }Saab
  %option{ atts[:pqr_audi], value: "audi", id: "pqr_audi", name: "pqr",  }Audi!.strip + "\n" }
                subject { Campo.output tag }
                it { should_not be_nil }
                it { should == expected }
              end
            
              context "and a default" do

                subject { tag.with_default }
                it { should_not be_nil }
                it { should be_a_kind_of(Select) }
                specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{i += 1}", name: "pqr",  }! }

                context "Campo.output" do
                  let(:expected) { %q!%select{ atts[:pqr], tabindex: "#{i += 1}", name: "pqr",  }
  %option{  value: "", disabled: "disabled", name: "pqr",  }Choose one:
  %option{ atts[:pqr_ford], value: "ford", id: "pqr_ford", name: "pqr",  }Ford
  %option{ atts[:pqr_bmw], value: "bmw", id: "pqr_bmw", name: "pqr",  }BMW
  %option{ atts[:pqr_ferrari], value: "ferrari", selected: "selected", id: "pqr_ferrari", name: "pqr",  }Ferrari
  %option{ atts[:pqr_volvo], value: "volvo", id: "pqr_volvo", name: "pqr",  }Volvo
  %option{ atts[:pqr_saab], value: "saab", id: "pqr_saab", name: "pqr",  }Saab
  %option{ atts[:pqr_audi], value: "audi", id: "pqr_audi", name: "pqr",  }Audi!.strip + "\n"  }
                  subject { Campo.output tag.with_default }
                  it { should == expected }
                end
              end
              
            end
          end

        end

      end # initialisation
    end # Select

    describe Input do

      context "initialisation" do
        context "Given a name" do
          context "and nothing else" do
            let(:tag) { Campo::Input.new( "abc" ) }
            let(:output) { %q!%input{ atts[:abc], tabindex: "#{i += 1}", type: "text", id: "abc", name: "abc",  }! }
            subject { tag }
            it { should_not be_nil }
            it { should be_a_kind_of(Input) }
            specify { subject.attributes[:type].should == "text" }
            specify { subject.output.should == output }
            context "Campo.output" do
              let(:expected) { output + "\n" }
              subject { Campo.output tag }
              it { should_not be_nil }
              it { should == expected }
            end
          end

          context "and a type" do
            context "of text" do
              let(:tag) { Campo::Input.new( "abc", :text ) }
              let(:output) { %q!%input{ atts[:abc], tabindex: "#{i += 1}", type: "text", id: "abc", name: "abc",  }! }
              subject { tag }
              it { should_not be_nil }
              it { should be_a_kind_of(Input) }
              specify { subject.attributes[:type].should == "text" }
              specify { subject.output.should == output }
              context "Campo.output" do
                let(:expected) { output + "\n" }
                subject { Campo.output tag }
                it { should_not be_nil }
                it { should == expected }
              end
            end
            context "of password" do
              let(:tag) { Campo::Input.new( "abc", :password ) }
              let(:output) { %q!%input{ atts[:abc], tabindex: "#{i += 1}", type: "password", id: "abc", name: "abc",  }! }
              subject { tag }
              it { should_not be_nil }
              it { should be_a_kind_of(Input) }
              specify { subject.attributes[:type].should == "password" }
              specify { subject.output.should == output }
              
              context "Campo.output" do
                let(:expected) { output + "\n" }
                subject { Campo.output tag }
                it { should_not be_nil }
                it { should == expected }
              end
            end
          end  
          context "of checkbox" do
            let(:tag) { Campo::Input.new( "abc", :checkbox ) }
            let(:output) { %q!%input{ atts[:abc], tabindex: "#{i += 1}", type: "checkbox", id: "abc", name: "abc",  }! }
            subject { tag }
            it { should_not be_nil }
            it { should be_a_kind_of(Input) }
            specify { subject.attributes[:type].should == "checkbox" }
            specify { subject.output.should == output }
            
            context "Campo.output" do
              let(:expected) { output + "\n" }
              subject { Campo.output tag }
              it { should_not be_nil }
              it { should == expected }
            end
            
          end  
          context "of radio" do
            let(:tag) { Campo::Input.new( "abc", :radio ) }
            let(:output) { %q!%input{ atts[:abc], tabindex: "#{i += 1}", type: "radio", id: "abc", name: "abc",  }! }
            subject { tag }
            it { should_not be_nil }
            it { should be_a_kind_of(Input) }
            specify { subject.attributes[:type].should == "radio" }
            specify { subject.output.should == output }
            
            context "Campo.output" do
              let(:expected) { output + "\n" }
              subject { Campo.output tag }
              it { should_not be_nil }
              it { should == expected }
            end
          end

        end # context
      end # initialisation

      context "Labelling" do
        let(:expected) { 
          top_bit + %q!
%form{ atts[:myform], method: "POST", name: "myform",  }
  %label{ for: "abc",  }
    abc
    %input{ atts[:abc], tabindex: "#{i += 1}", type: "text", id: "abc", name: "abc",  }
  %label{ for: "deff",  }
    deff
    %input{ atts[:deff], tabindex: "#{i += 1}", type: "text", id: "deff", name: "deff",  }
  %label{ for: "ghi",  }
    ghi
    %input{ atts[:ghi], tabindex: "#{i += 1}", type: "text", id: "ghi", name: "ghi",  }

!.strip + "\n"
        }
        let(:form) {
          form = Campo::Form.new( "myform" )
          form << Campo::Input.new( "abc", :text ).labelled("abc")
          form << Campo::Input.new( "deff", :text ).labelled("deff")
          form << Campo::Input.new( "ghi", :text ).labelled("ghi")
          form
        }
        subject { Campo.output form }
        it { should_not be_nil }
        it { should == expected }
        
        context "Within a fieldset" do
          let(:expected) { 
            top_bit + %q!
%form{ atts[:myform], method: "POST", name: "myform",  }
  %fieldset{  }
    %legend{  }Alphabetty spaghetti
    %label{ for: "abc",  }
      abc
      %input{ atts[:abc], tabindex: "#{i += 1}", type: "text", id: "abc", name: "abc",  }
    %label{ for: "def",  }
      def
      %input{ atts[:def], tabindex: "#{i += 1}", type: "text", id: "def", name: "def",  }
    %label{ for: "ghi",  }
      ghi
      %input{ atts[:ghi], tabindex: "#{i += 1}", type: "text", id: "ghi", name: "ghi",  }

!.strip + "\n"
          }
          let(:form) {
            form = Campo::Form.new( "myform" )
              myfieldset = form.fieldset( "Alphabetty spaghetti" ) do |f|
              f << Campo::Input.new( "abc", :text ).labelled("abc")
              f << Campo::Input.new( "def", :text ).labelled("def")
              f << Campo::Input.new( "ghi", :text ).labelled("ghi")
            end
            form
          }
          subject { Campo.output form }
          it { should_not be_nil }
          it { should == expected }          
        end
      end
        
        
      describe "A form with a group of radio buttons" do
        let(:expected) { 
          top_bit +  %q!
%form{ atts[:myform], method: "POST", name: "myform",  }
  %fieldset{  }
    %legend{  }Select the colour you like most:
    %label{ for: "radio1_green",  }
      green
      %input{ atts[:radio1_green], tabindex: "#{i += 1}", type: "radio", id: "radio1_green", value: "green", name: "radio1",  }
    %label{ for: "radio1_yellow",  }
      yellow
      %input{ atts[:radio1_yellow], tabindex: "#{i += 1}", type: "radio", id: "radio1_yellow", value: "yellow", name: "radio1",  }
    %label{ for: "radio1_red",  }
      red
      %input{ atts[:radio1_red], tabindex: "#{i += 1}", type: "radio", id: "radio1_red", value: "red", name: "radio1",  }
    %label{ for: "radio1_blue",  }
      blue
      %input{ atts[:radio1_blue], tabindex: "#{i += 1}", type: "radio", id: "radio1_blue", value: "blue", name: "radio1",  }
    %label{ for: "radio1_purple",  }
      purple
      %input{ atts[:radio1_purple], tabindex: "#{i += 1}", type: "radio", id: "radio1_purple", value: "purple", name: "radio1",  }

!.strip + "\n"
        }
      
        let(:radios) {
          form = Campo::Form.new( "myform" )
          form.fieldset( "Select the colour you like most:" ) do |f|
            f << Campo::Input.new("radio1", :radio, value: "green" ).labelled( "green" )
            f << Campo::Input.new("radio1", :radio, value: "yellow" ).labelled( "yellow" )
            f << Campo::Input.new("radio1", :radio, value: "red" ).labelled( "red" )
            f << Campo::Input.new("radio1", :radio, value: "blue" ).labelled( "blue" )
            f << Campo::Input.new("radio1", :radio, value: "purple" ).labelled( "purple" )
          end
          form
        }
        subject { Campo.output radios }
        it { should_not be_nil }
        it { should == expected }
      end # a group of radio buttons
    end # Input
    
    describe Textarea do
      context "Given no arguments" do
        it { should_not be_nil }
        it { should raise_error }
      end
      context "Given a name" do
        subject { Textarea.new( "textie" ) }
        it { should_not be_nil }
        it { should be_a_kind_of(Textarea) }
        
        context "and using convenience method" do
          let(:form) { Campo::Form.new( "myform" ) }
          subject { form.textarea( "textie" ) }
          it { should_not be_nil }
          it { should be_a_kind_of(Textarea) }
          
          describe "the full output" do
            let(:expected) { top_bit + %q!
%form{ atts[:myform], method: "POST", name: "myform",  }
  %textarea{ atts[:textie], tabindex: "#{i += 1}", cols: "40", rows: "10", name: "textie",  }= inners[:textie] !.strip + " \n"}
            let(:form){ 
              form = Campo::Form.new( "myform" )
              form.textarea( "textie" ) 
              form
            }
            subject { Campo.output form }
            it { should == expected }
          end    
        end      
      
        context "and an attribute" do
          subject { Textarea.new( "textie", cols: 60 ) }
          it { should_not be_nil }
          it { should be_a_kind_of(Textarea) }
          
          context "When using convenience method" do
            let(:form) { Campo::Form.new( "myform" ) }
            subject { form.textarea( "textie" ) }
            it { should_not be_nil }
            it { should be_a_kind_of(Textarea) }

            describe "the full output" do
              let(:expected) { top_bit + %q!
%form{ atts[:myform], method: "POST", name: "myform",  }
  %textarea{ atts[:textie], tabindex: "#{i += 1}", cols: "60", rows: "10", name: "textie",  }= inners[:textie] 
  !.strip + " \n"}
              let(:form){ 
                form = Campo::Form.new( "myform" )
                form.textarea( "textie", cols: 60 ) 
                form
              }
              subject { Campo.output form }
              it { should == expected }
            end
          end
        end

      end
    end


    # describe "A form" do
    #   context "Given a form" do
    #     let(:form) { Campo::Form.new("myform") }
    #     
    #     context "

    # form = Campo::Form.new( "myform" )
    # form << Campo::Input.new( "abc", :text ).labelled("abc")
    # form << Campo::Input.new( "def", :text ).labelled("def")
    # form << Campo::Input.new( "ghi", :text ).labelled("ghi")
    # form << Campo::Textarea.new( "jkl", "= inners[:jkl]" ).labelled("jkl")
    # check_colours = form.fieldset( "Do you like these colours? Tick for yes:" )
    # Campo::Input.new("mno", :checkbox, value: "blue" ).labelled( "blue" ).fieldset( check_colours )
    # Campo::Input.new("mno", :checkbox, value: "red" ).labelled( "red" ).fieldset( check_colours )
    # 
    # sel_colours = form.fieldset( "Select the colour you like most:" )
    # Campo::Input.new("radio1", :radio, value: "green" ).labelled( "green" ).fieldset( sel_colours )
    # Campo::Input.new("radio1", :radio, value: "yellow" ).labelled( "yellow" ).fieldset( sel_colours )
    # Campo::Input.new("radio1", :radio, value: "red" ).labelled( "red" ).fieldset( sel_colours )
    # Campo::Input.new("radio1", :radio, value: "blue" ).labelled( "blue" ).fieldset( sel_colours )
    # Campo::Input.new("radio1", :radio, value: "purple" ).labelled( "purple" ).fieldset( sel_colours )
    # 
    # form << Campo::Select.new( "pqr" ) do |s|
    #   s << Campo::Option.new( "pqr", "", "Please choose one option", nil, {disabled: "disabled" } )
    #   s << Campo::Option.new( "pqr", "volvo", "Volvo" )
    #   s << Campo::Option.new( "pqr", "saab", "Saab" )
    #   s << Campo::Option.new( "pqr", "audi", "Audi" )
    # end.labelled("pqr")
    # opts = [["ford", "Ford"], ["bmw", "BMW"], ["ferrari", "Ferrari", "checked"]]
    # form << Campo::Select.new("stu", opts, ).labelled( "stu" )
    # 
    # form << Campo::Select.new( "vwx" ) do |s|
    #   s.option "volvo", "Volvo"
    #   s.option "saab", "Saab"
    #   s.option "audi", "Audi"
    # end.labelled("vwx")
    # 
    # form << Campo::Select.new( "yz", opts ) do |s|
    #   s.option "volvo", "Volvo"
    #   s.option "saab", "Saab"
    #   s.option "audi", "Audi"
    # end.labelled("yz")
    # 
    # form << Campo::Select.new( "bands" ).with_default.option("Suede").option("Blur").option("Oasis").option("Echobelly").option("Pulp").option("Supergrass").labelled("Bands")
    # 
    # form << Campo::Input.new( "blah", :text ).labelled
    # form << Campo::Input.new( "deblah", :text ).labelled
    # form.text( "age", "How old are you?" )
    # form.text( "cuppa", "What's your favourite tea?", class: "drink" )
    # 
    # form.select("teas").with_default.option("Ceylon").option("Breakfast").option("Earl grey").labelled("Favourite tea:")
    # 
    # puts Campo.output( form )
    # 
    # require "haml"
    # 
    # puts Haml::Engine.new( Campo.output form ).render
  end # describe Campo
end # Campo
