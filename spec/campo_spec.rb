# encoding: UTF-8

require 'spec_helper'
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
- @campo_tabindex ||= 0 # for tabindex

STR
            s
          }
          

    describe :output do
      context "Given a form with no fields" do
        let(:expected) { 
          expected = top_bit + %q!%form{ atts[:myform], method: "POST", id: "myform", name: "myform",  }!.strip + "\n"
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
  %select{ atts[:teas], tabindex: "#{@campo_tabindex += 1}", name: "teas",  }
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
          subject { Campo.output :partial, tag }
          it { should_not be_nil }
          it { should == expected }

        end
      end
      
      describe "A realish form" do
        context "Given a form" do
          let(:form) do
            form = Campo::Form.new( "personal_details", action: %Q!"uri("/my/personal_details/update/")! )
            
            form.fieldset("Your details") do |f|
              
              f.text( "full_name", "Full name: ", size: 60 )
              f.text( "dob", "Date of birth: ", size: 10 ) #TODO change this
              f.fieldset( "Gender: " ) do |genders|
                genders.radio( "gender", "Male", value: 1 )
                genders.radio( "gender", "Female", value: 2 )
              end
              f.select( "ethnicorigin_id", {opts: [[1, "White"],[2,"Asian"],[3,"Black"],[4,"Chinese and Other"], [5,"Mixed"] ] }).with_default.labelled( "Ethnic-origin: " )
              f.text( "occupation", "Occupation: ", size: 60 )
              f.text( "phone_landline", "Phone (landline): ", size: 20 )
              f.text( "phone_mobile", "Phone (mobile): ", size: 20 )
              f.fieldset( "May we contact you..." ) do |c|
                c.checkbox( "contactable", "In the day?", value: "day" )
                c.checkbox( "contactable",  "In the evening?", value: "evening" )
              end
              f.submit("Save")
        
            end # form
            form
          end # let

            
          let(:expected) {
          %Q!- atts = {} if atts.nil?\n- atts.default = {} if atts.default.nil?\n- inners = {} if inners.nil?\n- inners.default = "" if inners.default.nil?\n- @campo_tabindex ||= 0 # for tabindex\n\n%form{ atts[:personal_details], method: "POST", action: uri("/my/personal_details/update/"), id: "personal_details", name: "personal_details",  }\n  %fieldset{  }\n    %legend{  }Your details\n    %label{ for: "full_name",  }\n      Full name: \n      %input{ atts[:full_name], tabindex: "\#{@campo_tabindex += 1}", type: "text", id: "full_name", size: "60", name: "full_name",  }\n    %label{ for: "dob",  }\n      Date of birth: \n      %input{ atts[:dob], tabindex: "\#{@campo_tabindex += 1}", type: "text", id: "dob", size: "10", name: "dob",  }\n    %fieldset{  }\n      %legend{  }Gender: \n      %label{ for: "gender_1",  }\n        Male\n        %input{ atts[:gender_1], tabindex: "\#{@campo_tabindex += 1}", type: "radio", id: "gender_1", value: "1", name: "gender",  }\n      %label{ for: "gender_2",  }\n        Female\n        %input{ atts[:gender_2], tabindex: "\#{@campo_tabindex += 1}", type: "radio", id: "gender_2", value: "2", name: "gender",  }\n    %label{ for: "ethnicorigin_id",  }\n      Ethnic-origin: \n      %select{ atts[:ethnicorigin_id], tabindex: "\#{@campo_tabindex += 1}", name: "ethnicorigin_id",  }\n        %option{  value: "", disabled: "disabled", name: "ethnicorigin_id",  }Choose one:\n        %option{ atts[:ethnicorigin_id_1], value: "1", id: "ethnicorigin_id_1", name: "ethnicorigin_id",  }White\n        %option{ atts[:ethnicorigin_id_2], value: "2", id: "ethnicorigin_id_2", name: "ethnicorigin_id",  }Asian\n        %option{ atts[:ethnicorigin_id_3], value: "3", id: "ethnicorigin_id_3", name: "ethnicorigin_id",  }Black\n        %option{ atts[:ethnicorigin_id_4], value: "4", id: "ethnicorigin_id_4", name: "ethnicorigin_id",  }Chinese and Other\n        %option{ atts[:ethnicorigin_id_5], value: "5", id: "ethnicorigin_id_5", name: "ethnicorigin_id",  }Mixed\n    %label{ for: "occupation",  }\n      Occupation: \n      %input{ atts[:occupation], tabindex: "\#{@campo_tabindex += 1}", type: "text", id: "occupation", size: "60", name: "occupation",  }\n    %label{ for: "phone_landline",  }\n      Phone (landline): \n      %input{ atts[:phone_landline], tabindex: "\#{@campo_tabindex += 1}", type: "text", id: "phone_landline", size: "20", name: "phone_landline",  }\n    %label{ for: "phone_mobile",  }\n      Phone (mobile): \n      %input{ atts[:phone_mobile], tabindex: "\#{@campo_tabindex += 1}", type: "text", id: "phone_mobile", size: "20", name: "phone_mobile",  }\n    %fieldset{  }\n      %legend{  }May we contact you...\n      %label{ for: "contactable_day",  }\n        In the day?\n        %input{ atts[:contactable_day], tabindex: "\#{@campo_tabindex += 1}", type: "checkbox", id: "contactable_day", value: "day", name: "contactable",  }\n      %label{ for: "contactable_evening",  }\n        In the evening?\n        %input{ atts[:contactable_evening], tabindex: "\#{@campo_tabindex += 1}", type: "checkbox", id: "contactable_evening", value: "evening", name: "contactable",  }\n    %input{ atts[:Save_Save], tabindex: "\#{@campo_tabindex += 1}", type: "submit", id: "Save_Save", value: "Save",  }\n!
          } # let expected
  
          subject{ Campo.output form }
          it { should == expected }
          
      
          context "With a div to wrap it in" do
            let(:doc) {
              doc = Campo.literal( ".centred.form" ) << form
            }
let(:expected) {
          %Q!- atts = {} if atts.nil?\n- atts.default = {} if atts.default.nil?\n- inners = {} if inners.nil?\n- inners.default = "" if inners.default.nil?\n- @campo_tabindex ||= 0 # for tabindex\n\n.centred.form\n  %form{ atts[:personal_details], method: "POST", action: uri("/my/personal_details/update/"), id: "personal_details", name: "personal_details",  }\n    %fieldset{  }\n      %legend{  }Your details\n      %label{ for: "full_name",  }\n        Full name: \n        %input{ atts[:full_name], tabindex: "\#{@campo_tabindex += 1}", type: "text", id: "full_name", size: "60", name: "full_name",  }\n      %label{ for: "dob",  }\n        Date of birth: \n        %input{ atts[:dob], tabindex: "\#{@campo_tabindex += 1}", type: "text", id: "dob", size: "10", name: "dob",  }\n      %fieldset{  }\n        %legend{  }Gender: \n        %label{ for: "gender_1",  }\n          Male\n          %input{ atts[:gender_1], tabindex: "\#{@campo_tabindex += 1}", type: "radio", id: "gender_1", value: "1", name: "gender",  }\n        %label{ for: "gender_2",  }\n          Female\n          %input{ atts[:gender_2], tabindex: "\#{@campo_tabindex += 1}", type: "radio", id: "gender_2", value: "2", name: "gender",  }\n      %label{ for: "ethnicorigin_id",  }\n        Ethnic-origin: \n        %select{ atts[:ethnicorigin_id], tabindex: "\#{@campo_tabindex += 1}", name: "ethnicorigin_id",  }\n          %option{  value: "", disabled: "disabled", name: "ethnicorigin_id",  }Choose one:\n          %option{ atts[:ethnicorigin_id_1], value: "1", id: "ethnicorigin_id_1", name: "ethnicorigin_id",  }White\n          %option{ atts[:ethnicorigin_id_2], value: "2", id: "ethnicorigin_id_2", name: "ethnicorigin_id",  }Asian\n          %option{ atts[:ethnicorigin_id_3], value: "3", id: "ethnicorigin_id_3", name: "ethnicorigin_id",  }Black\n          %option{ atts[:ethnicorigin_id_4], value: "4", id: "ethnicorigin_id_4", name: "ethnicorigin_id",  }Chinese and Other\n          %option{ atts[:ethnicorigin_id_5], value: "5", id: "ethnicorigin_id_5", name: "ethnicorigin_id",  }Mixed\n      %label{ for: "occupation",  }\n        Occupation: \n        %input{ atts[:occupation], tabindex: "\#{@campo_tabindex += 1}", type: "text", id: "occupation", size: "60", name: "occupation",  }\n      %label{ for: "phone_landline",  }\n        Phone (landline): \n        %input{ atts[:phone_landline], tabindex: "\#{@campo_tabindex += 1}", type: "text", id: "phone_landline", size: "20", name: "phone_landline",  }\n      %label{ for: "phone_mobile",  }\n        Phone (mobile): \n        %input{ atts[:phone_mobile], tabindex: "\#{@campo_tabindex += 1}", type: "text", id: "phone_mobile", size: "20", name: "phone_mobile",  }\n      %fieldset{  }\n        %legend{  }May we contact you...\n        %label{ for: "contactable_day",  }\n          In the day?\n          %input{ atts[:contactable_day], tabindex: "\#{@campo_tabindex += 1}", type: "checkbox", id: "contactable_day", value: "day", name: "contactable",  }\n        %label{ for: "contactable_evening",  }\n          In the evening?\n          %input{ atts[:contactable_evening], tabindex: "\#{@campo_tabindex += 1}", type: "checkbox", id: "contactable_evening", value: "evening", name: "contactable",  }\n      %input{ atts[:Save_Save], tabindex: "\#{@campo_tabindex += 1}", type: "submit", id: "Save_Save", value: "Save",  }\n!
          } # let expected
  
            subject{ Campo.output doc }
            it { should == expected }
          end # context
        end # context
      end # describe a form
    end
    
    describe Convenience do
      let(:obj) { 
        class Fakeclass  
          include Convenience
          include Childish
        end
        Fakeclass.new  
      }
      let(:form) { Campo::Form.new( "myform" ) }
      
      describe "input" do
        context "When given type" do
          context "of text" do
            context "with a label" do
              let(:expected) { top_bit +  %q!
%form{ atts[:myform], method: "POST", id: "myform", name: "myform",  }
  %label{ for: "blah_blahdeblah",  }
    Blahd
    %input{ atts[:blah_blahdeblah], tabindex: "#{@campo_tabindex += 1}", type: "text", id: "blah_blahdeblah", value: "blahdeblah", name: "blah",  }!.strip + "\n" }
              subject { 
                form.input( "blah", :text, "Blahd", value: "blahdeblah" )
                Campo.output form   
              }
              it { should_not be_nil }
              it { should == expected }
              context "via convenience method" do
                subject {
                  form.text( "blah", "Blahd", value: "blahdeblah" )
                  Campo.output form
                }
                it { should_not be_nil }
                it { should == expected }
              end
            end
            context "without a label" do
              let(:expected) { top_bit +  %q!
%form{ atts[:myform], method: "POST", id: "myform", name: "myform",  }
  %label{ for: "blah_blahdeblah",  }
    Blah
    %input{ atts[:blah_blahdeblah], tabindex: "#{@campo_tabindex += 1}", type: "text", id: "blah_blahdeblah", value: "blahdeblah", name: "blah",  }!.strip + "\n" }
              
              subject { 
                form.input( "blah", :text, value: "blahdeblah" )
                Campo.output form   
              }
              it { should_not be_nil }
              it { should == expected }
              context "via convenience method" do
                subject {
                  form.text( "blah", value: "blahdeblah" )
                  Campo.output form
                }
                it { should_not be_nil }
                it { should == expected }
              end
            end
            
          end # text
          context "of checkbox" do
            let(:expected) { top_bit +  %q!
%form{ atts[:myform], method: "POST", id: "myform", name: "myform",  }
  %label{ for: "blah_blahdeblah",  }
    Blahd
    %input{ atts[:blah_blahdeblah], tabindex: "#{@campo_tabindex += 1}", type: "checkbox", id: "blah_blahdeblah", value: "blahdeblah", name: "blah",  }!.strip + "\n" }
            
            subject { 
              form.input( "blah", :checkbox, "Blahd", value: "blahdeblah" )
              Campo.output form 
            }
            it { should_not be_nil }
            it { should == expected }

            context "via convenience method" do
              subject { 
                form.checkbox( "blah", "Blahd", value: "blahdeblah" ) 
                Campo.output form
              }
              it { should_not be_nil }
              it { should == expected }
            end # conveniece
          end # checkbox
        end
      end # describe input
        
    end # Convenience

    describe Helpers do
      describe "self.options_builder" do
        context "Given a name" do
          let(:name) { "teas" }
          context "and not given an options argument" do
            it "raises error because not given any options" do
              expect { Campo::Helpers.options_builder name }.to raise_error
            end
          end         
          context "and given a nil for the options" do
            let(:opts) { nil }
            subject { Campo::Helpers.options_builder name, opts }
            it { should_not be_nil }
            it { should be_a_kind_of Array }
          end 
          context "and given a hash" do
            context "that is empty" do
              subject { Campo::Helpers.options_builder name, Hash.new }
              it { should_not be_nil }
              it { should be_a_kind_of Array }
              it { should be_empty }
            end
            context "with keys" do
              context "only" do
                let(:opts) {
                  Hash[ ["ceylon", "english_breakfast", "earl_grey"].zip( Array.new(3, nil ) ) ]
                }
                subject { Campo::Helpers.options_builder name, opts }
                it { should_not be_nil }
                it { should be_a_kind_of Array }
                it { should be_full_of Campo::Option }
              end
              context "and a single string value" do
                let(:opts) {
                  Hash[ [ 
                    ["ceylon", "Ceylon"],
                    ["english_breakfast", "English Breakfast"],
                    ["earl_grey", "Earl Grey"],
                  ] ]
                }
                subject { Campo::Helpers.options_builder name, opts }
                it { should_not be_nil }
                it { should be_a_kind_of Array }
                it { should be_full_of Campo::Option }
              end
              context "and an array value" do
                let(:opts) {
                  {
                    "ceylon"=>["Ceylon"], 
                    "english_breakfast"=>["English Breakfast", :selected], 
                    "earl_grey"=>["Earl Grey"]
                  }
                }
                subject { Campo::Helpers.options_builder name, opts }
                it { should_not be_nil }
                it { should be_a_kind_of Array }
                it { should be_full_of Campo::Option }
                it { should satisfy {|ys|
                    y = ys.find do |y| 
                      y.attributes[:selected]
                    end
                    y.attributes[:value] == "english_breakfast" 
                  }
                }
              end
            end
          end
          
          context "and given an array" do
            context "that is empty" do
              let(:opts) { [] }
              subject { Campo::Helpers.options_builder name, opts }
              it { should_not be_nil }
              it { should be_a_kind_of Array }
              it { should be_empty }
            end
            context "that contain [String,String]" do
              let(:opts) {
                [ 
                  ["ceylon", "Ceylon"],
                  ["english_breakfast", "English Breakfast"],
                  ["earl_grey", "Earl Grey"],
                ] 
              }
              subject { Campo::Helpers.options_builder name, opts }
              it { should_not be_nil }
              it { should be_a_kind_of Array }
              it { should be_full_of Campo::Option }
              context "with a selected option" do
                let(:opts_selected) {
                  [["ceylon", "Ceylon"], ["english_breakfast", "English Breakfast", :selected], ["earl_grey", "Earl Grey"]]
                }
                subject { Campo::Helpers.options_builder name, opts_selected }
                it { should_not be_nil }
                it { should be_a_kind_of Array }
                it { should be_full_of Campo::Option }
                it { should satisfy {|ys|
                    ys.find do |y| 
                      y.attributes[:selected]
                    end.attributes[:value] == "english_breakfast" 
                  }
                }
                
              end
            end
            context "that contain [String]" do
              context "formatted for the name attribute (underscores for spaces, lowercase)" do
                let(:opts) {
                  [ 
                    ["ceylon"],
                    ["english_breakfast"],
                    ["earl_grey"],
                  ] 
                }
                subject { Campo::Helpers.options_builder name, opts }
                it { should_not be_nil }
                it { should be_a_kind_of Array }
                it { should be_full_of Campo::Option }
                context "with a selected option" do
                  let(:opts_selected) {
                    [["ceylon"], ["english_breakfast", :selected], ["earl_grey"]]
                  }
                  subject { Campo::Helpers.options_builder name, opts_selected }
                  it { should_not be_nil }
                  it { should be_a_kind_of Array }
                  it { should be_full_of Campo::Option }
                  it { should satisfy {|ys|
                      ys.find do |y| 
                        y.attributes[:selected]
                      end.attributes[:value] == "english_breakfast" 
                    }
                  }
                  
                end
              end
              context "formatted for display" do
                let(:opts) {
                  [ 
                    ["Ceylon"],
                    ["English Breakfast"],
                    ["Earl Grey"],
                  ] 
                }
                subject { Campo::Helpers.options_builder name, opts }
                it { should_not be_nil }
                it { should be_a_kind_of Array }
                it { should be_full_of Campo::Option }
                context "with a selected option" do
                  let(:opts_selected) {
                    [["Ceylon"], ["English Breakfast", :selected], ["Earl Grey"]]
                  }
                  subject { Campo::Helpers.options_builder name, opts_selected }
                  it { should_not be_nil }
                  it { should be_a_kind_of Array }
                  it { should be_full_of Campo::Option }
                  it { should satisfy {|ys|
                      ys.find do |y| 
                        y.attributes[:selected]
                      end.attributes[:value] == "English Breakfast" 
                    }
                  }
                  
                end
              end
            end
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
            let(:expected) { %q!%form{ atts[:myform], method: "POST", id: "myform", name: "myform",  }! }
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
            let(:expected) { %q!%form{ atts[:myform], method: "POST", action: "/", id: "myform", name: "myform",  }! }
            subject { form.output }
            it { should == expected }
          end
        end
      end


      
      describe :fieldset do
        context "When given a form with only a name" do
          let(:form) { Campo::Form.new( "myform" ) }
          let(:expected) { top_bit + %q!
%form{ atts[:myform], method: "POST", id: "myform", name: "myform",  }
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
%form{ atts[:myform], method: "POST", id: "myform", name: "myform",  }
  %label{ for: "teas",  }
    Favourite tea:
    %select{ atts[:teas], tabindex: "#{@campo_tabindex += 1}", name: "teas",  }
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
%form{ atts[:myform], method: "POST", id: "myform", name: "myform",  }
  %label{ for: "teas",  }
    Favourite tea:
    %select{ atts[:teas], tabindex: "#{@campo_tabindex += 1}", name: "teas",  }
      %option{  value: "", disabled: "disabled", name: "teas",  }Choose one:
      %option{ atts[:teas_ceylon], value: "ceylon", id: "teas_ceylon", name: "teas",  }Ceylon
      %option{ atts[:teas_breakfast], value: "breakfast", id: "teas_breakfast", name: "teas",  }Breakfast
      %option{ atts[:teas_earl_grey], value: "earl grey", id: "teas_earl_grey", name: "teas",  }Earl grey
  %label{ for: "coffees",  }
    Favourite coffee:
    %select{ atts[:coffees], tabindex: "#{@campo_tabindex += 1}", name: "coffees",  }
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
%form{ atts[:myform], method: "POST", id: "myform", name: "myform",  }
  %input{ atts[:Submit_Submit], tabindex: "#{@campo_tabindex += 1}", type: "submit", id: "Submit_Submit", value: "Submit",  }

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
%form{ atts[:myform], method: "POST", id: "myform", name: "myform",  }
  %input{ atts[:Save_Save], tabindex: "#{@campo_tabindex += 1}", type: "submit", id: "Save_Save", value: "Save",  }

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


    describe Literal do
      let(:tag) { Literal.new "anything at all at all" }
      subject { tag }
      it { should_not be_nil }
      it { should be_a_kind_of( Literal ) }

      describe :output do
        let(:expected) { "anything at all at all" }
        subject { tag.output }
        it { should == expected }
      end

      describe "Campo.output" do
        let(:expected) { "anything at all at all\n" }
        subject { Campo.output :partial, tag }
        it { should == expected }
      end

      context "When using convenience method" do
        let(:form) { Campo::Form.new( "myform" ) }
        subject { form.literal( "Hello, World!" ) }
        it { should_not be_nil }
        it { should be_a_kind_of( Literal ) }

        describe "the full output" do
          let(:expected) { top_bit + %q$
%form{ atts[:myform], method: "POST", id: "myform", name: "myform",  }
  Hello, World!$.strip + "\n"}
          let(:form){ 
            form = Campo::Form.new( "myform" )
            form.literal( "Hello, World!" ) 
            form
          }
          subject { Campo.output form }
          it { should == expected } 
        end
        
        context "With a block" do
          subject {
            form.literal "%p" do |para|
              para.literal "Whatever"
              para.literal "%br"
              para.literal "you"
              para.literal "%br"
              para.literal "think"
              para.literal "%br"
              para.literal "challenge"
              para.literal "%br"
              para.literal "it"
            end
            Campo.output form
          }
          let(:expected) {  top_bit + %q$%form{ atts[:myform], method: "POST", id: "myform", name: "myform",  }
  %p
    Whatever
    %br
    you
    %br
    think
    %br
    challenge
    %br
    it
$.strip + "\n" }
          it { should_not be_nil }
          it { should == expected } 
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
        subject { Campo.output :partial, tag }
        it { should == expected }
      end

      context "When using convenience method" do
        let(:form) { Campo::Form.new( "myform" ) }
        subject { form.bit_of_ruby( "= 5 + 1" ) }
        it { should_not be_nil }
        it { should be_a_kind_of( Haml_Ruby_Insert ) }

        describe "the full output" do
          let(:expected) { top_bit + %q!
%form{ atts[:myform], method: "POST", id: "myform", name: "myform",  }
  = 5 + 1!.strip + "\n"}
          let(:form){ 
            form = Campo::Form.new( "myform" )
            form.bit_of_ruby( "= 5 + 1" ) 
            form
          }
          subject { Campo.output form }
          it { should == expected } 
          
          context "With a block" do
            subject {
              form.bit_of_ruby %q!="%p"! do |para|
                para.literal "Whatever"
                para.literal "%br"
                para.literal "you"
                para.literal "%br"
                para.literal "think"
                para.literal "%br"
                para.literal "challenge"
                para.literal "%br"
                para.literal "it"
              end
              Campo.output form
            }
            let(:expected) {  top_bit + %q$%form{ atts[:myform], method: "POST", id: "myform", name: "myform",  }
  = 5 + 1
  ="%p"
    Whatever
    %br
    you
    %br
    think
    %br
    challenge
    %br
    it
  $.strip + "\n" }
            it { should_not be_nil }
            it { should == expected } 
          end
        end
      end
      
      context "When not given a string" do
        it "should raise" do
          expect {
            form = Campo.form "a" do |form|
              form.bit_of_ruby 2
            end
          }.to raise_error( ArgumentError )
        end
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
            specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", name: "pqr",  }! }

            context "Campo.output" do
              let(:expected) { %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", name: "pqr",  }!.strip + "\n" }
              subject { Campo.output :partial, tag }
              it { should_not be_nil }
              it { should == expected }
            end
            
            context "and a default" do
              
              subject { tag.with_default }
              it { should_not be_nil }
              it { should be_a_kind_of(Select) }
              specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", name: "pqr",  }! }
              
              context "Campo.output" do
                let(:expected) { %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", name: "pqr",  }
  %option{  value: "", disabled: "disabled", name: "pqr",  }Choose one:!.strip + "\n"  }
                subject { Campo.output :partial, tag.with_default }
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
            specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", name: "pqr",  }! }
            
            context "Campo.output" do
              let(:expected) { %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", name: "pqr",  }
  %option{ atts[:pqr_volvo], value: "volvo", id: "pqr_volvo", name: "pqr",  }Volvo
  %option{ atts[:pqr_saab], value: "saab", id: "pqr_saab", name: "pqr",  }Saab
  %option{ atts[:pqr_audi], value: "audi", id: "pqr_audi", name: "pqr",  }Audi
!.strip + "\n" }
              subject { Campo.output :partial, tag }
              it { should_not be_nil }
              it { should == expected }
            end
            
            
            context "and a default" do

              subject { tag.with_default }
              it { should_not be_nil }
              it { should be_a_kind_of(Select) }
              specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", name: "pqr",  }! }

              context "Campo.output" do
                let(:expected) { %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", name: "pqr",  }
  %option{  value: "", disabled: "disabled", name: "pqr",  }Choose one:
  %option{ atts[:pqr_volvo], value: "volvo", id: "pqr_volvo", name: "pqr",  }Volvo
  %option{ atts[:pqr_saab], value: "saab", id: "pqr_saab", name: "pqr",  }Saab
  %option{ atts[:pqr_audi], value: "audi", id: "pqr_audi", name: "pqr",  }Audi
!.strip + "\n"  }
                subject { Campo.output :partial, tag.with_default }
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
              specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", name: "pqr",  }! }
              
              context "Campo.output" do
                let(:expected) { %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", name: "pqr",  }
  %option{ atts[:pqr_volvo], value: "volvo", id: "pqr_volvo", name: "pqr",  }Volvo
  %option{ atts[:pqr_saab], value: "saab", id: "pqr_saab", name: "pqr",  }Saab
  %option{ atts[:pqr_audi], value: "audi", id: "pqr_audi", name: "pqr",  }Audi
  = opts!.strip + "\n" }
                subject { 
                  Campo.output :partial, tag 
                }
                it { should_not be_nil }
                it { should == expected }
              end
            end
          end

          context "and an array" do
            context "of type [String]" do
              let(:opts) { [["ford"], ["bmw"], ["ferrari", :selected]] }
              subject { Campo::Select.new( "pqr", {opts: opts} ) }
  
              it { should_not be_nil }
              it { should be_a_kind_of(Select) }
              specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", name: "pqr",  }! }
              context "Campo.output" do
                let(:tag){ 
                  Campo::Select.new( "pqr", {opts: opts} )
                }
                let(:expected) { 
%q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", name: "pqr",  }
  %option{ atts[:pqr_ford], value: "ford", id: "pqr_ford", name: "pqr",  }Ford
  %option{ atts[:pqr_bmw], value: "bmw", id: "pqr_bmw", name: "pqr",  }Bmw
  %option{ atts[:pqr_ferrari], value: "ferrari", selected: "selected", id: "pqr_ferrari", name: "pqr",  }Ferrari!.strip + "\n" }
                subject { Campo.output :partial, tag }
                it { should_not be_nil }
                it { should == expected }
              end
            
            end
            context "of type [String, String]" do
              let(:opts) { [["ford", "ford"], ["bmw", "BMW"], ["ferrari", "Ferrari", "checked"]] }
              subject { Campo::Select.new( "pqr", {opts: opts} ) }
  
              it { should_not be_nil }
              it { should be_a_kind_of(Select) }
              specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", name: "pqr",  }! }
  
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
                specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", name: "pqr",  }! }
                
                context "Campo.output" do
                  let(:expected) { %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", name: "pqr",  }
  %option{ atts[:pqr_volvo], value: "volvo", id: "pqr_volvo", name: "pqr",  }Volvo
  %option{ atts[:pqr_saab], value: "saab", id: "pqr_saab", name: "pqr",  }Saab
  %option{ atts[:pqr_audi], value: "audi", id: "pqr_audi", name: "pqr",  }Audi
  %option{ atts[:pqr_ford], value: "ford", id: "pqr_ford", name: "pqr",  }Ford
  %option{ atts[:pqr_bmw], value: "bmw", id: "pqr_bmw", name: "pqr",  }BMW
  %option{ atts[:pqr_ferrari], value: "ferrari", selected: "selected", id: "pqr_ferrari", name: "pqr",  }Ferrari!.strip + "\n" }
                  subject { Campo.output :partial, tag }
                  it { should_not be_nil }
                  it { should == expected }
                  
                  context "and some attributes" do
                    let(:opts) { [["ford", "Ford",{class: "blue"}], ["bmw", "BMW"], ["ferrari", "Ferrari", "checked", {class: "green"}]] }
                    let(:tag){ 
                      Campo::Select.new( "pqr", {opts: opts} ) do |s|
                        s.option "volvo", "Volvo"
                        s.option "saab", "Saab"
                        s.option "audi", "Audi"
                      end
                    }
                    let(:expected) { %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", name: "pqr",  }
  %option{ atts[:pqr_volvo], value: "volvo", id: "pqr_volvo", name: "pqr",  }Volvo
  %option{ atts[:pqr_saab], value: "saab", id: "pqr_saab", name: "pqr",  }Saab
  %option{ atts[:pqr_audi], value: "audi", id: "pqr_audi", name: "pqr",  }Audi
  %option{ atts[:pqr_ford], value: "ford", id: "pqr_ford", class: "blue", name: "pqr",  }Ford
  %option{ atts[:pqr_bmw], value: "bmw", id: "pqr_bmw", name: "pqr",  }BMW
  %option{ atts[:pqr_ferrari], value: "ferrari", selected: "selected", id: "pqr_ferrari", class: "green", name: "pqr",  }Ferrari!.strip + "\n" }
                    subject { Campo.output :partial, tag }
                    it { should_not be_nil }
                    it { should == expected }
                  end
                end
              
                context "and a default" do
  
                  subject { tag.with_default }
                  it { should_not be_nil }
                  it { should be_a_kind_of(Select) }
                  specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", name: "pqr",  }! }
  
                  context "Campo.output" do
                    let(:expected) { %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", name: "pqr",  }
  %option{  value: "", disabled: "disabled", name: "pqr",  }Choose one:
  %option{ atts[:pqr_volvo], value: "volvo", id: "pqr_volvo", name: "pqr",  }Volvo
  %option{ atts[:pqr_saab], value: "saab", id: "pqr_saab", name: "pqr",  }Saab
  %option{ atts[:pqr_audi], value: "audi", id: "pqr_audi", name: "pqr",  }Audi
  %option{ atts[:pqr_ford], value: "ford", id: "pqr_ford", name: "pqr",  }Ford
  %option{ atts[:pqr_bmw], value: "bmw", id: "pqr_bmw", name: "pqr",  }BMW
  %option{ atts[:pqr_ferrari], value: "ferrari", selected: "selected", id: "pqr_ferrari", name: "pqr",  }Ferrari!.strip + "\n"  }
                    subject { Campo.output :partial, tag.with_default }
                    it { should == expected }
                  end
                end
                
              end
            end
          end

          context "and a hash" do
            context "with keys" do
              context "only" do
                let(:opts) {
                  Hash[ ["ceylon", "english_breakfast", "earl_grey"].zip( Array.new(3, nil ) ) ]
                }
                let(:tag){ 
                  Campo::Select.new( "tea", {opts: opts} )
                }
                subject { tag }
  
                it { should_not be_nil }
                it { should be_a_kind_of(Select) }
                specify { Campo.output( :partial, subject ).should == %Q!%select{ atts[:tea], tabindex: "\#{@campo_tabindex += 1}", name: "tea",  }\n  %option{ atts[:tea_ceylon], value: "ceylon", id: "tea_ceylon", name: "tea",  }Ceylon\n  %option{ atts[:tea_english_breakfast], value: "english_breakfast", id: "tea_english_breakfast", name: "tea",  }English breakfast\n  %option{ atts[:tea_earl_grey], value: "earl_grey", id: "tea_earl_grey", name: "tea",  }Earl grey\n! }
              end
              context "and a single string value" do
                let(:opts) {
                  Hash[ [ 
                    ["ceylon", "Ceylon"],
                    ["english_breakfast", "English Breakfast"],
                    ["earl_grey", "Earl Grey"],
                  ] ]
                }
                let(:tag){ 
                  Campo::Select.new( "tea", {opts: opts} )
                }
                subject { tag }
  
                it { should_not be_nil }
                it { should be_a_kind_of(Select) }
                specify { Campo.output( :partial, subject ).should == %Q!%select{ atts[:tea], tabindex: "\#{@campo_tabindex += 1}", name: "tea",  }\n  %option{ atts[:tea_ceylon], value: "ceylon", id: "tea_ceylon", name: "tea",  }Ceylon\n  %option{ atts[:tea_english_breakfast], value: "english_breakfast", id: "tea_english_breakfast", name: "tea",  }English Breakfast\n  %option{ atts[:tea_earl_grey], value: "earl_grey", id: "tea_earl_grey", name: "tea",  }Earl Grey\n! }
              end
              context "and an array value" do
                let(:opts) {
                  {
                    "ceylon"=>["Ceylon"], 
                    "english_breakfast"=>["English Breakfast", :selected], 
                    "earl_grey"=>["Earl Grey"]
                  }
                }
                let(:tag){ 
                  Campo::Select.new( "tea", {opts: opts} )
                }
                subject { tag }
  
                it { should_not be_nil }
                it { should be_a_kind_of(Select) }
                specify { Campo.output( :partial, subject ).should == %Q!%select{ atts[:tea], tabindex: "\#{@campo_tabindex += 1}", name: "tea",  }\n  %option{ atts[:tea_ceylon], value: "ceylon", id: "tea_ceylon", name: "tea",  }Ceylon\n  %option{ atts[:tea_english_breakfast], value: "english_breakfast", selected: "selected", id: "tea_english_breakfast", name: "tea",  }English Breakfast\n  %option{ atts[:tea_earl_grey], value: "earl_grey", id: "tea_earl_grey", name: "tea",  }Earl Grey\n! }
              end
            end
          end
        end

      end # initialisation
      
      describe :mark_as_selected do
        pending "write a test for this soon please!"
      end
    end # Select

    describe Input do

      context "initialisation" do
        context "Given a name" do
          context "and nothing else" do
            let(:tag) { Campo::Input.new( "abc" ) }
            let(:output) { %q!%input{ atts[:abc], tabindex: "#{@campo_tabindex += 1}", type: "text", id: "abc", name: "abc",  }! }
            subject { tag }
            it { should_not be_nil }
            it { should be_a_kind_of(Input) }
            specify { subject.attributes[:type].should == "text" }
            specify { subject.output.should == output }
            context "Campo.output" do
              let(:expected) { output + "\n" }
              subject { Campo.output :partial, tag }
              it { should_not be_nil }
              it { should == expected }
            end
          end

          context "and a type" do
            context "of text" do
              let(:tag) { Campo::Input.new( "abc", :text ) }
              let(:output) { %q!%input{ atts[:abc], tabindex: "#{@campo_tabindex += 1}", type: "text", id: "abc", name: "abc",  }! }
              subject { tag }
              it { should_not be_nil }
              it { should be_a_kind_of(Input) }
              specify { subject.attributes[:type].should == "text" }
              specify { subject.output.should == output }
              context "Campo.output" do
                let(:expected) { output + "\n" }
                subject { Campo.output :partial, tag }
                it { should_not be_nil }
                it { should == expected }
              end
            end
            context "of password" do
              let(:tag) { Campo::Input.new( "abc", :password ) }
              let(:output) { %q!%input{ atts[:abc], tabindex: "#{@campo_tabindex += 1}", type: "password", id: "abc", name: "abc",  }! }
              subject { tag }
              it { should_not be_nil }
              it { should be_a_kind_of(Input) }
              specify { subject.attributes[:type].should == "password" }
              specify { subject.output.should == output }
              
              context "Campo.output" do
                let(:expected) { output + "\n" }
                subject { Campo.output :partial, tag }
                it { should_not be_nil }
                it { should == expected }
              end
            end
          end  
          context "of checkbox" do
            let(:tag) { Campo::Input.new( "abc", :checkbox ) }
            let(:output) { %q!%input{ atts[:abc], tabindex: "#{@campo_tabindex += 1}", type: "checkbox", id: "abc", name: "abc",  }! }
            subject { tag }
            it { should_not be_nil }
            it { should be_a_kind_of(Input) }
            specify { subject.attributes[:type].should == "checkbox" }
            specify { subject.output.should == output }
            
            context "Campo.output" do
              let(:expected) { output + "\n" }
              subject { Campo.output :partial, tag }
              it { should_not be_nil }
              it { should == expected }
            end
            
          end  
          context "of radio" do
            let(:tag) { Campo::Input.new( "abc", :radio ) }
            let(:output) { %q!%input{ atts[:abc], tabindex: "#{@campo_tabindex += 1}", type: "radio", id: "abc", name: "abc",  }! }
            subject { tag }
            it { should_not be_nil }
            it { should be_a_kind_of(Input) }
            specify { subject.attributes[:type].should == "radio" }
            specify { subject.output.should == output }
            
            context "Campo.output" do
              let(:expected) { output + "\n" }
              subject { Campo.output :partial, tag }
              it { should_not be_nil }
              it { should == expected }
            end
          end

        end # context
      end # initialisation

      context "Labelling" do
        let(:expected) { 
          top_bit + %q!
%form{ atts[:myform], method: "POST", id: "myform", name: "myform",  }
  %label{ for: "abc",  }
    abc
    %input{ atts[:abc], tabindex: "#{@campo_tabindex += 1}", type: "text", id: "abc", name: "abc",  }
  %label{ for: "deff",  }
    deff
    %input{ atts[:deff], tabindex: "#{@campo_tabindex += 1}", type: "text", id: "deff", name: "deff",  }
  %label{ for: "ghi",  }
    ghi
    %input{ atts[:ghi], tabindex: "#{@campo_tabindex += 1}", type: "text", id: "ghi", name: "ghi",  }

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
%form{ atts[:myform], method: "POST", id: "myform", name: "myform",  }
  %fieldset{  }
    %legend{  }Alphabetty spaghetti
    %label{ for: "abc",  }
      abc
      %input{ atts[:abc], tabindex: "#{@campo_tabindex += 1}", type: "text", id: "abc", name: "abc",  }
    %label{ for: "def",  }
      def
      %input{ atts[:def], tabindex: "#{@campo_tabindex += 1}", type: "text", id: "def", name: "def",  }
    %label{ for: "ghi",  }
      ghi
      %input{ atts[:ghi], tabindex: "#{@campo_tabindex += 1}", type: "text", id: "ghi", name: "ghi",  }

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
%form{ atts[:myform], method: "POST", id: "myform", name: "myform",  }
  %fieldset{  }
    %legend{  }Select the colour you like most:
    %label{ for: "radio1_green",  }
      green
      %input{ atts[:radio1_green], tabindex: "#{@campo_tabindex += 1}", type: "radio", id: "radio1_green", value: "green", name: "radio1",  }
    %label{ for: "radio1_yellow",  }
      yellow
      %input{ atts[:radio1_yellow], tabindex: "#{@campo_tabindex += 1}", type: "radio", id: "radio1_yellow", value: "yellow", name: "radio1",  }
    %label{ for: "radio1_red",  }
      red
      %input{ atts[:radio1_red], tabindex: "#{@campo_tabindex += 1}", type: "radio", id: "radio1_red", value: "red", name: "radio1",  }
    %label{ for: "radio1_blue",  }
      blue
      %input{ atts[:radio1_blue], tabindex: "#{@campo_tabindex += 1}", type: "radio", id: "radio1_blue", value: "blue", name: "radio1",  }
    %label{ for: "radio1_purple",  }
      purple
      %input{ atts[:radio1_purple], tabindex: "#{@campo_tabindex += 1}", type: "radio", id: "radio1_purple", value: "purple", name: "radio1",  }

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
%form{ atts[:myform], method: "POST", id: "myform", name: "myform",  }
  %textarea{ atts[:textie], tabindex: "#{@campo_tabindex += 1}", cols: "40", rows: "10", name: "textie",  }= inners[:textie] !.strip + " \n"}
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
%form{ atts[:myform], method: "POST", id: "myform", name: "myform",  }
  %textarea{ atts[:textie], tabindex: "#{@campo_tabindex += 1}", cols: "60", rows: "10", name: "textie",  }= inners[:textie] 
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

  end # describe Campo
end # Campo
