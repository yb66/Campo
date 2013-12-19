# encoding: UTF-8

require 'spec_helper'
require_relative "../lib/campo/campo.rb"
require_relative "../lib/campo/plugins/partial.rb"
require_relative "../lib/campo/plugins/aria.rb"
require "rspec"


module Campo
  describe Campo do
  
    before(:all) do
      Campo.plugins.clear
      Campo.plugin :partial # this is normally done by lib/campo.rb
      Campo.plugin :Aria
    end      

    let(:top_bit) { s = <<-'STR'
- atts = {} if atts.nil?
- atts.default_proc = proc {|hash, key| hash[key] = {} } if atts.default_proc.nil?
- inners = {} if inners.nil?
- inners.default = "" if inners.default.nil?
- @campo_tabindex ||= 0 # for tabindex
STR
      s
    }

    describe :output do
      context "Given a form with no fields" do
        let(:expected) { 
          expected = top_bit + %q!%form{ atts[:myform], id: "myform", name: "myform", method: "POST", role: "form",  }!.strip + "\n"
        }

        subject{ Campo.output Campo::Form.new( "myform" ) }
        it { should_not be_nil }
        it { should == expected }
      end

      context "Given no form" do
        context "When given a select field with options" do
          let(:expected) { %q!
%label{ class: "list", for: "teas",  }
  Favourite tea:
  %select{ atts[:teas], tabindex: "#{@campo_tabindex += 1}", id: "teas", name: "teas",  }
    %option{ atts[:teas_default], id: "teas_default", name: "teas", value: "", disabled: "disabled",  }Choose one:
    %option{ atts[:teas_ceylon], id: "teas_ceylon", name: "teas", value: "ceylon",  }Ceylon
    %option{ atts[:teas_breakfast], id: "teas_breakfast", name: "teas", value: "breakfast",  }Breakfast
    %option{ atts[:teas_earl_grey], id: "teas_earl_grey", name: "teas", value: "earl grey",  }Earl grey
!.strip + "\n"
          }
          let(:tag) {
            select = Campo::Select.new( "teas" )
            tag = select.with_default.option("ceylon").option("breakfast").option("earl grey").labelled("Favourite tea:", class: "list") 
            tag
          }
          subject { Campo.output tag, :partial=>true }
          it { should_not be_nil }
          it { should == expected }

        end
      end
      
      describe "A realish form" do
        context "Given a form" do
          let(:expected) {
top_bit + %Q!%form{ atts[:personal_details], id: "personal_details", name: "personal_details", method: "POST", action: uri("/my/personal_details/update/"), role: "form",  }\n  %fieldset{  }\n    %legend{  }Your details\n    %label{ for: "full_name",  }\n      Full name: \n      %input{ atts[:full_name], tabindex: "\#{@campo_tabindex += 1}", id: "full_name", name: "full_name", type: "text", size: "60",  }\n    %label{ for: "dob",  }\n      Date of birth: \n      %input{ atts[:dob], tabindex: "\#{@campo_tabindex += 1}", id: "dob", name: "date_of_birth", type: "text", size: "10",  }\n    %fieldset{  }\n      %legend{  }Gender: \n      %label{ for: "gender_1",  }\n        Male\n        %input{ atts[:gender_1], tabindex: "\#{@campo_tabindex += 1}", id: "gender_1", name: "gender", type: "radio", value: "1",  }\n      %label{ for: "gender_2",  }\n        Female\n        %input{ atts[:gender_2], tabindex: "\#{@campo_tabindex += 1}", id: "gender_2", name: "gender", type: "radio", value: "2",  }\n    %label{ for: "ethnicorigin_id",  }\n      Ethnic-origin: \n      %select{ atts[:ethnicorigin_id], tabindex: "\#{@campo_tabindex += 1}", id: "ethnicorigin_id", name: "ethnicorigin_id",  }\n        %option{ atts[:ethnicorigin_id_default], id: "ethnicorigin_id_default", name: "ethnicorigin_id", value: "", disabled: "disabled",  }Choose one:\n        %option{ atts[:ethnicorigin_id_1], id: "ethnicorigin_id_1", name: "ethnicorigin_id", value: "1",  }White\n        %option{ atts[:ethnicorigin_id_2], id: "ethnicorigin_id_2", name: "ethnicorigin_id", value: "2",  }Asian\n        %option{ atts[:ethnicorigin_id_3], id: "ethnicorigin_id_3", name: "ethnicorigin_id", value: "3",  }Black\n        %option{ atts[:ethnicorigin_id_4], id: "ethnicorigin_id_4", name: "ethnicorigin_id", value: "4",  }Chinese and Other\n        %option{ atts[:ethnicorigin_id_5], id: "ethnicorigin_id_5", name: "ethnicorigin_id", value: "5",  }Mixed\n    %label{ for: "occupation",  }\n      Occupation: \n      %input{ atts[:occupation], tabindex: "\#{@campo_tabindex += 1}", id: "occupation", name: "occupation", type: "text", size: "60",  }\n    %label{ for: "phone_landline",  }\n      Phone (landline): \n      %input{ atts[:phone_landline], tabindex: "\#{@campo_tabindex += 1}", id: "phone_landline", name: "phone_landline", type: "text", size: "20",  }\n    %label{ for: "phone_mobile",  }\n      Phone (mobile): \n      %input{ atts[:phone_mobile], tabindex: "\#{@campo_tabindex += 1}", id: "phone_mobile", name: "phone_mobile", type: "text", size: "20",  }\n    %fieldset{  }\n      %legend{  }May we contact you...\n      %label{ for: "contactable_day",  }\n        In the day?\n        %input{ atts[:contactable_day], tabindex: "\#{@campo_tabindex += 1}", id: "contactable_day", name: "contactable", type: "checkbox", value: "day",  }\n      %label{ for: "contactable_evening",  }\n        In the evening?\n        %input{ atts[:contactable_evening], tabindex: "\#{@campo_tabindex += 1}", id: "contactable_evening", name: "contactable", type: "checkbox", value: "evening",  }\n    %input{ atts[:method], id: "method", name: "method", type: "hidden", value: "put",  }\n    %input{ atts[:Save], tabindex: "\#{@campo_tabindex += 1}", id: "Save", type: "submit", value: "Save",  }\n!
          } # let expected
          context "block with var style" do
            let(:form) do
              form = Campo::Form.new( "personal_details", action: %Q!"uri("/my/personal_details/update/")! )
              
              form.fieldset("Your details") do |f|
                
                f.text( "full_name", "Full name: ", size: 60 )
                f.text( "dob", "Date of birth: ", name: "date_of_birth", size: 10 )
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
                f.hidden "method", value: "put"
                f.submit("Save")
          
              end # form
              form
            end # let
      
            subject{ Campo.output form }
            it { should == expected }
                 
            context "With a div to wrap it in" do
              let(:doc) {
                doc = Campo.literal( ".centred.form" ) << form
              }
  let(:expected) {
    top_bit + %Q!.centred.form
  %form{ atts[:personal_details], id: "personal_details", name: "personal_details", method: "POST", action: uri("/my/personal_details/update/"), role: "form",  }
    %fieldset{  }
      %legend{  }Your details
      %label{ for: "full_name",  }
        Full name: 
        %input{ atts[:full_name], tabindex: "\#{@campo_tabindex += 1}", id: "full_name", name: "full_name", type: "text", size: "60",  }
      %label{ for: "dob",  }
        Date of birth: 
        %input{ atts[:dob], tabindex: "\#{@campo_tabindex += 1}", id: "dob", name: "date_of_birth", type: "text", size: "10",  }
      %fieldset{  }
        %legend{  }Gender: 
        %label{ for: "gender_1",  }
          Male
          %input{ atts[:gender_1], tabindex: "\#{@campo_tabindex += 1}", id: "gender_1", name: "gender", type: "radio", value: "1",  }
        %label{ for: "gender_2",  }
          Female
          %input{ atts[:gender_2], tabindex: "\#{@campo_tabindex += 1}", id: "gender_2", name: "gender", type: "radio", value: "2",  }
      %label{ for: "ethnicorigin_id",  }
        Ethnic-origin: 
        %select{ atts[:ethnicorigin_id], tabindex: "\#{@campo_tabindex += 1}", id: "ethnicorigin_id", name: "ethnicorigin_id",  }
          %option{ atts[:ethnicorigin_id_default], id: "ethnicorigin_id_default", name: "ethnicorigin_id", value: "", disabled: "disabled",  }Choose one:
          %option{ atts[:ethnicorigin_id_1], id: "ethnicorigin_id_1", name: "ethnicorigin_id", value: "1",  }White
          %option{ atts[:ethnicorigin_id_2], id: "ethnicorigin_id_2", name: "ethnicorigin_id", value: "2",  }Asian
          %option{ atts[:ethnicorigin_id_3], id: "ethnicorigin_id_3", name: "ethnicorigin_id", value: "3",  }Black
          %option{ atts[:ethnicorigin_id_4], id: "ethnicorigin_id_4", name: "ethnicorigin_id", value: "4",  }Chinese and Other
          %option{ atts[:ethnicorigin_id_5], id: "ethnicorigin_id_5", name: "ethnicorigin_id", value: "5",  }Mixed
      %label{ for: "occupation",  }
        Occupation: 
        %input{ atts[:occupation], tabindex: "\#{@campo_tabindex += 1}", id: "occupation", name: "occupation", type: "text", size: "60",  }
      %label{ for: "phone_landline",  }
        Phone (landline): 
        %input{ atts[:phone_landline], tabindex: "\#{@campo_tabindex += 1}", id: "phone_landline", name: "phone_landline", type: "text", size: "20",  }
      %label{ for: "phone_mobile",  }
        Phone (mobile): 
        %input{ atts[:phone_mobile], tabindex: "\#{@campo_tabindex += 1}", id: "phone_mobile", name: "phone_mobile", type: "text", size: "20",  }
      %fieldset{  }
        %legend{  }May we contact you...
        %label{ for: "contactable_day",  }
          In the day?
          %input{ atts[:contactable_day], tabindex: "\#{@campo_tabindex += 1}", id: "contactable_day", name: "contactable", type: "checkbox", value: "day",  }
        %label{ for: "contactable_evening",  }
          In the evening?
          %input{ atts[:contactable_evening], tabindex: "\#{@campo_tabindex += 1}", id: "contactable_evening", name: "contactable", type: "checkbox", value: "evening",  }
      %input{ atts[:method], id: "method", name: "method", type: "hidden", value: "put",  }
      %input{ atts[:Save], tabindex: "\#{@campo_tabindex += 1}", id: "Save", type: "submit", value: "Save",  }
!
            } # let expected
    
              subject{ Campo.output doc }
              it { should == expected }
            end # context
          end # context
          context "with no var for block" do           
            let(:form) do
              form = Campo.form "personal_details", action: %Q!"uri("/my/personal_details/update/")!  do
                fieldset("Your details") do              
                  text( "full_name", "Full name: ", size: 60 )
                  text( "dob", "Date of birth: ", name: "date_of_birth", size: 10 ) #TODO change this
                  fieldset( "Gender: " ) do
                    radio( "gender", "Male", value: 1 )
                    radio( "gender", "Female", value: 2 )
                  end
                  select( "ethnicorigin_id", {opts: [[1, "White"],[2,"Asian"],[3,"Black"],[4,"Chinese and Other"], [5,"Mixed"] ] }).with_default.labelled( "Ethnic-origin: " )
                  text( "occupation", "Occupation: ", size: 60 )
                  text( "phone_landline", "Phone (landline): ", size: 20 )
                  text( "phone_mobile", "Phone (mobile): ", size: 20 )
                  fieldset( "May we contact you..." ) do
                    checkbox( "contactable", "In the day?", value: "day" )
                    checkbox( "contactable",  "In the evening?", value: "evening" )
                  end
                  hidden "method", value: "put"
                  submit("Save")
                end
              end
            end # let      
            subject{ Campo.output form }
            it { should == expected }
          end
        end
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
%form{ atts[:myform], id: "myform", name: "myform", method: "POST", role: "form",  }
  %label{ for: "blah",  }
    Blahd
    %input{ atts[:blah], tabindex: "#{@campo_tabindex += 1}", id: "blah", name: "blah", type: "text", value: "blahdeblah",  }!.strip + "\n" }
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
%form{ atts[:myform], id: "myform", name: "myform", method: "POST", role: "form",  }
  %label{ for: "blah",  }
    Blah
    %input{ atts[:blah], tabindex: "#{@campo_tabindex += 1}", id: "blah", name: "blah", type: "text", value: "blahdeblah",  }!.strip + "\n" }
              
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
%form{ atts[:myform], id: "myform", name: "myform", method: "POST", role: "form",  }
  %label{ for: "blah_blahdeblah",  }
    Blahd
    %input{ atts[:blah_blahdeblah], tabindex: "#{@campo_tabindex += 1}", id: "blah_blahdeblah", name: "blah", type: "checkbox", value: "blahdeblah",  }!.strip + "\n" }
            
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
          it "should fail" do
            expect { form }.to raise_error
          end
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
            let(:expected) { %q!%form{ atts[:myform], id: "myform", name: "myform", method: "POST",  }! }
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
            let(:expected) { %q!%form{ atts[:myform], id: "myform", name: "myform", method: "POST", action: "/",  }! }
            subject { form.output }
            it { should == expected }
          end
        end
      end


      
      describe :fieldset do
        context "When given a form with only a name" do
          let(:form) { Campo::Form.new( "myform" ).fieldset("Do you like these colours? Tick for yes:") }
          let(:expected) { top_bit + %q!
%form{ atts[:myform], id: "myform", name: "myform", method: "POST", role: "form",  }
  %fieldset{  }
    %legend{  }Do you like these colours? Tick for yes:
                
!.strip + "\n" }
          subject { 
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
%form{ atts[:myform], id: "myform", name: "myform", method: "POST", role: "form",  }
  %label{ for: "teas",  }
    Favourite tea:
    %select{ atts[:teas], tabindex: "#{@campo_tabindex += 1}", id: "teas", name: "teas",  }
      %option{ atts[:teas_default], id: "teas_default", name: "teas", value: "", disabled: "disabled",  }Choose one:
      %option{ atts[:teas_ceylon], id: "teas_ceylon", name: "teas", value: "ceylon",  }Ceylon
      %option{ atts[:teas_breakfast], id: "teas_breakfast", name: "teas", value: "breakfast",  }Breakfast
      %option{ atts[:teas_earl_grey], id: "teas_earl_grey", name: "teas", value: "earl grey",  }Earl grey

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
%form{ atts[:myform], id: "myform", name: "myform", method: "POST", role: "form",  }
  %label{ for: "teas",  }
    Favourite tea:
    %select{ atts[:teas], tabindex: "#{@campo_tabindex += 1}", id: "teas", name: "teas",  }
      %option{ atts[:teas_default], id: "teas_default", name: "teas", value: "", disabled: "disabled",  }Choose one:
      %option{ atts[:teas_ceylon], id: "teas_ceylon", name: "teas", value: "ceylon",  }Ceylon
      %option{ atts[:teas_breakfast], id: "teas_breakfast", name: "teas", value: "breakfast",  }Breakfast
      %option{ atts[:teas_earl_grey], id: "teas_earl_grey", name: "teas", value: "earl grey",  }Earl grey
  %label{ for: "coffees",  }
    Favourite coffee:
    %select{ atts[:coffees], tabindex: "#{@campo_tabindex += 1}", id: "coffees", name: "coffees",  }
      %option{ atts[:coffees_default], id: "coffees_default", name: "coffees", value: "", disabled: "disabled",  }Choose one:
      %option{ atts[:coffees_blue_mountain], id: "coffees_blue_mountain", name: "coffees", value: "blue mountain",  }Blue mountain
      %option{ atts[:coffees_kenyan_peaberry], id: "coffees_kenyan_peaberry", name: "coffees", value: "kenyan peaberry",  }Kenyan peaberry
      %option{ atts[:coffees_colombian], id: "coffees_colombian", name: "coffees", value: "colombian",  }Colombian
      %option{ atts[:coffees_java], id: "coffees_java", name: "coffees", value: "java",  }Java

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
%form{ atts[:myform], id: "myform", name: "myform", method: "POST", role: "form",  }
  %input{ atts[:Submit], tabindex: "#{@campo_tabindex += 1}", id: "Submit", type: "submit", value: "Submit",  }

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
%form{ atts[:myform], id: "myform", name: "myform", method: "POST", role: "form",  }
  %input{ atts[:save], tabindex: "#{@campo_tabindex += 1}", id: "save", type: "submit", value: "Save",  }

!.strip + "\n" }
            
            subject { 
              form.submit( "save", value: "Save" )
              Campo.output form
            }
            
            it { should_not be_nil }
            it { should == expected }
          end
        end
      end
    end

    describe Span do
      let(:tag) { Span.new "my_id", "anything at all at all" }
      subject { tag }
      it { should_not be_nil }
      it { should be_a_kind_of( Span ) }

      describe :output do
        let(:expected) { %Q!%span{id: "my_id", }! }
        subject { tag.output }
        it { should == expected }
      end

      describe "Campo.output" do
        let(:expected) { %Q!%span{id: "my_id", }\n  anything at all at all\n! }
        subject { Campo.output tag, :partial=>true }
        it { should == expected }
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
        subject { Campo.output tag, :partial=>true }
        it { should == expected }
      end

      context "When using convenience method" do
        let(:form) { Campo::Form.new( "myform" ) }
        subject { form.literal( "Hello, World!" ) }
        it { should_not be_nil }
        it { should be_a_kind_of( Literal ) }

        describe "the full output" do
          let(:expected) { top_bit + %q$
%form{ atts[:myform], id: "myform", name: "myform", method: "POST", role: "form",  }
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
          let(:expected) {  top_bit + %q$%form{ atts[:myform], id: "myform", name: "myform", method: "POST", role: "form",  }
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
        subject { Campo.output tag,:partial=>true }
        it { should == expected }
      end

      context "When using convenience method" do
        let(:form) { Campo::Form.new( "myform" ) }
        subject { form.bit_of_ruby( "= 5 + 1" ) }
        it { should_not be_nil }
        it { should be_a_kind_of( Haml_Ruby_Insert ) }

        describe "the full output" do
          let(:expected) { top_bit + %q!
%form{ atts[:myform], id: "myform", name: "myform", method: "POST", role: "form",  }
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
            let(:expected) {  top_bit + %q$%form{ atts[:myform], id: "myform", name: "myform", method: "POST", role: "form",  }
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
            specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }! }

            context "Campo.output" do
              let(:expected) { %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }!.strip + "\n" }
              subject { Campo.output tag,:partial=>true }
              it { should_not be_nil }
              it { should == expected }
            end
            
            context "and a default" do
              context "With no arguments" do
              
                subject { tag.with_default }
                it { should_not be_nil }
                it { should be_a_kind_of(Select) }
                specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }! }
                
                context "Campo.output" do
                  let(:expected) { %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }
  %option{ atts[:pqr_default], id: "pqr_default", name: "pqr", value: "", disabled: "disabled",  }Choose one:!.strip + "\n"  }
                  subject { Campo.output tag.with_default, :partial=>true }
                  it { should == expected }
                end
              end
              context "Given an inner text" do
                context "And no other args" do
                  subject { tag.with_default("Choose wisely!") }
                  it { should_not be_nil }
                  it { should be_a_kind_of(Select) }
                  specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }! }
                  
                  context "Campo.output" do
                    let(:expected) { %q<%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }
  %option{ atts[:pqr_default], id: "pqr_default", name: "pqr", value: "", disabled: "disabled",  }Choose wisely!>.strip + "\n"  }
                    subject { Campo.output tag.with_default("Choose wisely!"), :partial=>true }
                    it { should == expected }
                  end
                end
                context "And an empty hash" do
                  subject { tag.with_default("Choose wisely!",{}) }
                  it { should_not be_nil }
                  it { should be_a_kind_of(Select) }
                  specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }! }
                  
                  context "Campo.output" do
                    let(:expected) { %q<%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }
  %option{ atts[:pqr_default], id: "pqr_default", name: "pqr", value: "",  }Choose wisely!>.strip + "\n"  }
                    subject { Campo.output tag.with_default("Choose wisely!",{}), :partial=>true }
                    it { should == expected }
                  end
                end
                context "And an empty hash" do
                  subject { tag.with_default("Choose wisely!",{class: "default"}) }
                  it { should_not be_nil }
                  it { should be_a_kind_of(Select) }
                  specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }! }
                  
                  context "Campo.output" do
                    let(:expected) { %q<%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }
  %option{ atts[:pqr_default], id: "pqr_default", name: "pqr", value: "", class: "default",  }Choose wisely!>.strip + "\n"  }
                    subject { Campo.output tag.with_default("Choose wisely!",{class: "default"}), :partial=>true }
                    it { should == expected }
                  end
                end

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
            specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }! }
            
            context "Campo.output" do
              let(:expected) { %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }
  %option{ atts[:pqr_volvo], id: "pqr_volvo", name: "pqr", value: "volvo",  }Volvo
  %option{ atts[:pqr_saab], id: "pqr_saab", name: "pqr", value: "saab",  }Saab
  %option{ atts[:pqr_audi], id: "pqr_audi", name: "pqr", value: "audi",  }Audi
!.strip + "\n" }
              subject { Campo.output tag, :partial=>true }
              it { should_not be_nil }
              it { should == expected }
            end
            
            
            context "and a default" do

              subject { tag.with_default }
              it { should_not be_nil }
              it { should be_a_kind_of(Select) }
              specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }! }

              context "Campo.output" do
                let(:expected) { %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }
  %option{ atts[:pqr_default], id: "pqr_default", name: "pqr", value: "", disabled: "disabled",  }Choose one:
  %option{ atts[:pqr_volvo], id: "pqr_volvo", name: "pqr", value: "volvo",  }Volvo
  %option{ atts[:pqr_saab], id: "pqr_saab", name: "pqr", value: "saab",  }Saab
  %option{ atts[:pqr_audi], id: "pqr_audi", name: "pqr", value: "audi",  }Audi
!.strip + "\n"  }
                subject { Campo.output tag.with_default, :partial=>true }
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
              specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }! }
              
              context "Campo.output" do
                let(:expected) { %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }
  %option{ atts[:pqr_volvo], id: "pqr_volvo", name: "pqr", value: "volvo",  }Volvo
  %option{ atts[:pqr_saab], id: "pqr_saab", name: "pqr", value: "saab",  }Saab
  %option{ atts[:pqr_audi], id: "pqr_audi", name: "pqr", value: "audi",  }Audi
  = opts!.strip + "\n" }
                subject { 
                  Campo.output tag, :partial=>true 
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
              specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }! }
              context "Campo.output" do
                let(:tag){ 
                  Campo::Select.new( "pqr", {opts: opts} )
                }
                let(:expected) { 
%q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }
  %option{ atts[:pqr_ford], id: "pqr_ford", name: "pqr", value: "ford",  }Ford
  %option{ atts[:pqr_bmw], id: "pqr_bmw", name: "pqr", value: "bmw",  }Bmw
  %option{ atts[:pqr_ferrari], id: "pqr_ferrari", name: "pqr", value: "ferrari", selected: "selected",  }Ferrari!.strip + "\n" }
                subject { Campo.output tag, :partial=>true }
                it { should_not be_nil }
                it { should == expected }
              end
            
            end
            context "of type [String, String]" do
              let(:opts) { [["ford", "ford"], ["bmw", "BMW"], ["ferrari", "Ferrari", "checked"]] }
              subject { Campo::Select.new( "pqr", {opts: opts} ) }
  
              it { should_not be_nil }
              it { should be_a_kind_of(Select) }
              specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }! }
  
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
                specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }! }
                
                context "Campo.output" do
                  let(:expected) { %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }
  %option{ atts[:pqr_volvo], id: "pqr_volvo", name: "pqr", value: "volvo",  }Volvo
  %option{ atts[:pqr_saab], id: "pqr_saab", name: "pqr", value: "saab",  }Saab
  %option{ atts[:pqr_audi], id: "pqr_audi", name: "pqr", value: "audi",  }Audi
  %option{ atts[:pqr_ford], id: "pqr_ford", name: "pqr", value: "ford",  }Ford
  %option{ atts[:pqr_bmw], id: "pqr_bmw", name: "pqr", value: "bmw",  }BMW
  %option{ atts[:pqr_ferrari], id: "pqr_ferrari", name: "pqr", value: "ferrari", selected: "selected",  }Ferrari!.strip + "\n" }
                  subject { Campo.output tag, :partial=>true }
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
                    let(:expected) { %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }
  %option{ atts[:pqr_volvo], id: "pqr_volvo", name: "pqr", value: "volvo",  }Volvo
  %option{ atts[:pqr_saab], id: "pqr_saab", name: "pqr", value: "saab",  }Saab
  %option{ atts[:pqr_audi], id: "pqr_audi", name: "pqr", value: "audi",  }Audi
  %option{ atts[:pqr_ford], id: "pqr_ford", name: "pqr", value: "ford", class: "blue",  }Ford
  %option{ atts[:pqr_bmw], id: "pqr_bmw", name: "pqr", value: "bmw",  }BMW
  %option{ atts[:pqr_ferrari], id: "pqr_ferrari", name: "pqr", value: "ferrari", selected: "selected", class: "green",  }Ferrari!.strip + "\n" }
                    subject { Campo.output tag, :partial=>true }
                    it { should_not be_nil }
                    it { should == expected }
                  end
                end
              
                context "and a default" do
  
                  subject { tag.with_default }
                  it { should_not be_nil }
                  it { should be_a_kind_of(Select) }
                  specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }! }
  
                  context "Campo.output" do
                    let(:expected) { %q!%select{ atts[:pqr], tabindex: "#{@campo_tabindex += 1}", id: "pqr", name: "pqr",  }
  %option{ atts[:pqr_default], id: "pqr_default", name: "pqr", value: "", disabled: "disabled",  }Choose one:
  %option{ atts[:pqr_volvo], id: "pqr_volvo", name: "pqr", value: "volvo",  }Volvo
  %option{ atts[:pqr_saab], id: "pqr_saab", name: "pqr", value: "saab",  }Saab
  %option{ atts[:pqr_audi], id: "pqr_audi", name: "pqr", value: "audi",  }Audi
  %option{ atts[:pqr_ford], id: "pqr_ford", name: "pqr", value: "ford",  }Ford
  %option{ atts[:pqr_bmw], id: "pqr_bmw", name: "pqr", value: "bmw",  }BMW
  %option{ atts[:pqr_ferrari], id: "pqr_ferrari", name: "pqr", value: "ferrari", selected: "selected",  }Ferrari!.strip + "\n"  }
                    subject { Campo.output tag.with_default, :partial=>true }
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
                specify { Campo.output( subject, :partial=>true ).should == %Q!%select{ atts[:tea], tabindex: "\#{@campo_tabindex += 1}", id: "tea", name: "tea",  }\n  %option{ atts[:tea_ceylon], id: "tea_ceylon", name: "tea", value: "ceylon",  }Ceylon\n  %option{ atts[:tea_english_breakfast], id: "tea_english_breakfast", name: "tea", value: "english_breakfast",  }English breakfast\n  %option{ atts[:tea_earl_grey], id: "tea_earl_grey", name: "tea", value: "earl_grey",  }Earl grey\n! }
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
                specify { Campo.output( subject, :partial=>true ).should == %Q!%select{ atts[:tea], tabindex: "\#{@campo_tabindex += 1}", id: "tea", name: "tea",  }\n  %option{ atts[:tea_ceylon], id: "tea_ceylon", name: "tea", value: "ceylon",  }Ceylon\n  %option{ atts[:tea_english_breakfast], id: "tea_english_breakfast", name: "tea", value: "english_breakfast",  }English Breakfast\n  %option{ atts[:tea_earl_grey], id: "tea_earl_grey", name: "tea", value: "earl_grey",  }Earl Grey\n! }
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
                specify { Campo.output( subject, :partial=>true ).should == %Q!%select{ atts[:tea], tabindex: "\#{@campo_tabindex += 1}", id: "tea", name: "tea",  }\n  %option{ atts[:tea_ceylon], id: "tea_ceylon", name: "tea", value: "ceylon",  }Ceylon\n  %option{ atts[:tea_english_breakfast], id: "tea_english_breakfast", name: "tea", value: "english_breakfast", selected: "selected",  }English Breakfast\n  %option{ atts[:tea_earl_grey], id: "tea_earl_grey", name: "tea", value: "earl_grey",  }Earl Grey\n! }
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
            let(:output) { %q!%input{ atts[:abc], tabindex: "#{@campo_tabindex += 1}", id: "abc", name: "abc", type: "text",  }! }
            subject { tag }
            it { should_not be_nil }
            it { should be_a_kind_of(Input) }
            specify { subject.attributes[:type].should == "text" }
            specify { subject.output.should == output }
            context "Campo.output" do
              let(:expected) { output + "\n" }
              subject { Campo.output tag, :partial=>true }
              it { should_not be_nil }
              it { should == expected }
            end
          end
          
          context "and a type" do
            context "of text" do
              let(:tag) { Campo::Input.new( "abc", :text ) }
              let(:output) { %q!%input{ atts[:abc], tabindex: "#{@campo_tabindex += 1}", id: "abc", name: "abc", type: "text",  }! }
              subject { tag }
              it { should_not be_nil }
              it { should be_a_kind_of(Input) }
              specify { subject.attributes[:type].should == "text" }
              specify { subject.output.should == output }
              context "Campo.output" do
                let(:expected) { output + "\n" }
                subject { Campo.output tag, :partial=>true }
                it { should_not be_nil }
                it { should == expected }
              end
            end
            context "of password" do
              let(:tag) { Campo::Input.new( "abc", :password ) }
              let(:output) { %q!%input{ atts[:abc], tabindex: "#{@campo_tabindex += 1}", id: "abc", name: "abc", type: "password",  }! }
              subject { tag }
              it { should_not be_nil }
              it { should be_a_kind_of(Input) }
              specify { subject.attributes[:type].should == "password" }
              specify { subject.output.should == output }
              
              context "Campo.output" do
                let(:expected) { output + "\n" }
                subject { Campo.output tag, :partial=>true }
                it { should_not be_nil }
                it { should == expected }
              end
            end
          end  
          context "of checkbox" do
            let(:tag) { Campo::Input.new( "abc", :checkbox ) }
            let(:output) { %q!%input{ atts[:abc], tabindex: "#{@campo_tabindex += 1}", id: "abc", name: "abc", type: "checkbox",  }! }
            subject { tag }
            it { should_not be_nil }
            it { should be_a_kind_of(Input) }
            specify { subject.attributes[:type].should == "checkbox" }
            specify { subject.output.should == output }
            
            context "Campo.output" do
              let(:expected) { output + "\n" }
              subject { Campo.output tag, :partial=>true }
              it { should_not be_nil }
              it { should == expected }
            end
            
          end  

          context "Given an input with a [] to notify it's an array" do
            let(:tag) { Campo::Input.new( "abc[]", :checkbox, value: "many" ) }
            let(:output) { %q!%input{ atts[:abc_many], tabindex: "#{@campo_tabindex += 1}", id: "abc_many", name: "abc[]", type: "checkbox", value: "many",  }! }
            subject { tag }
            it { should_not be_nil }
            it { should be_a_kind_of(Input) }
            specify { subject.attributes[:type].should == "checkbox" }
            specify { subject.output.should == output }
            
            context "Campo.output" do
              let(:expected) { output + "\n" }
              subject { Campo.output tag, :partial=>true }
              it { should_not be_nil }
              it { should == expected }
            end
            context "Given several inputs, some grouped, some not" do
              let(:expected) { %q!- atts = {} if atts.nil?
- atts.default_proc = proc {|hash, key| hash[key] = {} } if atts.default_proc.nil?
- inners = {} if inners.nil?
- inners.default = "" if inners.default.nil?
- @campo_tabindex ||= 0 # for tabindex
%form{ atts[:example], id: "example", name: "example", method: "POST", role: "form",  }
  %label{ for: "a",  }
    A
    %input{ atts[:a], tabindex: "#{@campo_tabindex += 1}", id: "a", name: "a", type: "text",  }
  %label{ for: "b",  }
    B
    %input{ atts[:b], tabindex: "#{@campo_tabindex += 1}", id: "b", name: "b", type: "text",  }
  %fieldset{  }
    %legend{  }Which C?
    %label{ for: "c_grouped",  }
      Grouped
      %input{ atts[:c_grouped], tabindex: "#{@campo_tabindex += 1}", id: "c_grouped", name: "c", type: "checkbox", value: "grouped",  }
    %label{ for: "c",  }
      Also grouped
      %input{ atts[:c], tabindex: "#{@campo_tabindex += 1}", id: "c", name: "c", type: "checkbox", valued: "also grouped",  }
  %fieldset{  }
    %legend{  }Which D?
    %label{ for: "d_grouped",  }
      Grouped
      %input{ atts[:d_grouped], tabindex: "#{@campo_tabindex += 1}", id: "d_grouped", name: "d[]", type: "checkbox", value: "grouped",  }
    %label{ for: "d_also_grouped",  }
      Also grouped
      %input{ atts[:d_also_grouped], tabindex: "#{@campo_tabindex += 1}", id: "d_also_grouped", name: "d[]", type: "checkbox", value: "also grouped",  }
  %input{ atts[:Submit], tabindex: "#{@campo_tabindex += 1}", id: "Submit", type: "submit", value: "Submit",  }
!
              }
              let(:form) {  
                form = Campo.form "example" do
                  text "a"
                  text "b"
                  fieldset "Which C?" do
                    checkbox "c", "Grouped", value: "grouped"
                    checkbox "c", "Also grouped", valued: "also grouped"
                  end
                  fieldset "Which D?" do
                    checkbox "d[]", "Grouped", value: "grouped"
                    checkbox "d[]", "Also grouped", value: "also grouped"
                  end
                  submit
                end
                form
              }
                            
              subject { Campo.output form }
              it { should_not be_nil }
              it { should == expected }
            end
          end
          
          context "of radio" do
            let(:tag) { Campo::Input.new( "abc", :radio ) }
            let(:output) { %q!%input{ atts[:abc], tabindex: "#{@campo_tabindex += 1}", id: "abc", name: "abc", type: "radio",  }! }
            subject { tag }
            it { should_not be_nil }
            it { should be_a_kind_of(Input) }
            specify { subject.attributes[:type].should == "radio" }
            specify { subject.output.should == output }
            
            context "Campo.output" do
              let(:expected) { output + "\n" }
              subject { Campo.output tag, :partial=>true }
              it { should_not be_nil }
              it { should == expected }
            end
          end

        end # context
      end # initialisation

      context "Labelling" do
        let(:expected) { 
          top_bit + %q!
%form{ atts[:myform], id: "myform", name: "myform", method: "POST", role: "form",  }
  %label{ for: "abc",  }
    abc
    %input{ atts[:abc], tabindex: "#{@campo_tabindex += 1}", id: "abc", name: "abc", type: "text",  }
  %label{ for: "deff",  }
    deff
    %input{ atts[:deff], tabindex: "#{@campo_tabindex += 1}", id: "deff", name: "deff", type: "text",  }
  %label{ for: "ghi",  }
    ghi
    %input{ atts[:ghi], tabindex: "#{@campo_tabindex += 1}", id: "ghi", name: "ghi", type: "text",  }

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
%form{ atts[:myform], id: "myform", name: "myform", method: "POST", role: "form",  }
  %fieldset{  }
    %legend{  }Alphabetty spaghetti
    %label{ for: "abc",  }
      Abc
      %input{ atts[:abc], tabindex: "#{@campo_tabindex += 1}", id: "abc", name: "abc", type: "text",  }
    %label{ for: "def",  }
      Def
      %input{ atts[:def], tabindex: "#{@campo_tabindex += 1}", id: "def", name: "def", type: "text",  }
    %label{ for: "ghi",  }
      Ghi
      %input{ atts[:ghi], tabindex: "#{@campo_tabindex += 1}", id: "ghi", name: "ghi", type: "text",  }

!.strip + "\n"
          }
          let(:form) {
            form = Campo::Form.new( "myform" ) do
              fieldset( "Alphabetty spaghetti" ) do
                text( "abc" )
                text( "def" )
                text( "ghi" )
              end
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
%form{ atts[:myform], id: "myform", name: "myform", method: "POST", role: "form",  }
  %fieldset{  }
    %legend{  }Select the colour you like most:
    %label{ for: "radio1_green",  }
      green
      %input{ atts[:radio1_green], tabindex: "#{@campo_tabindex += 1}", id: "radio1_green", name: "radio1", type: "radio", value: "green",  }
    %label{ for: "radio1_yellow",  }
      yellow
      %input{ atts[:radio1_yellow], tabindex: "#{@campo_tabindex += 1}", id: "radio1_yellow", name: "radio1", type: "radio", value: "yellow",  }
    %label{ for: "radio1_red",  }
      red
      %input{ atts[:radio1_red], tabindex: "#{@campo_tabindex += 1}", id: "radio1_red", name: "radio1", type: "radio", value: "red",  }
    %label{ for: "radio1_blue",  }
      blue
      %input{ atts[:radio1_blue], tabindex: "#{@campo_tabindex += 1}", id: "radio1_blue", name: "radio1", type: "radio", value: "blue",  }
    %label{ for: "radio1_purple",  }
      purple
      %input{ atts[:radio1_purple], tabindex: "#{@campo_tabindex += 1}", id: "radio1_purple", name: "radio1", type: "radio", value: "purple",  }

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
        subject { Textarea.new }
        it "should fail" do
          expect { subject }.should raise_error
        end
      end
      context "Given a name" do
        subject { Textarea.new( "textie" ) }
        it { should_not be_nil }
        it { should be_a_kind_of(Textarea) }
        
        context "and using convenience method" do
          let(:form) { Campo::Form.new( "myform" ) }
          context "Without an explicit label parameter" do
            subject { form.textarea( "textie" ) }
            it { should_not be_nil }
            it { should be_a_kind_of(Label) }
            it { should contain_a_kind_of(Textarea) }
            
            describe "the full output" do
              let(:expected) { top_bit + %q!
%form{ atts[:myform], id: "myform", name: "myform", method: "POST", role: "form",  }
  %label{ for: "textie",  }
    Textie
    %textarea{ atts[:textie], tabindex: "#{@campo_tabindex += 1}", id: "textie", name: "textie", cols: "40", rows: "10",  }= inners[:textie] !.strip + " \n"}
              let(:form){ 
                form = Campo::Form.new( "myform" )
                form.textarea( "textie" ) 
                form
              }
              subject { Campo.output form }
              it { should == expected }
            end    
          end
          context "With an explicit label parameter" do
            subject { form.textarea( "textie", label: "Textie labelled" ) }
            it { should_not be_nil }
            it { should be_a_kind_of(Label) }
            it { should contain_a_kind_of(Textarea) }
            
            describe "the full output" do
              let(:expected) { top_bit + %q!
%form{ atts[:myform], id: "myform", name: "myform", method: "POST", role: "form",  }
  %label{ for: "textie",  }
    Textie labelled
    %textarea{ atts[:textie], tabindex: "#{@campo_tabindex += 1}", id: "textie", name: "textie", cols: "40", rows: "10",  }= inners[:textie] !.strip + " \n"}
              let(:form){ 
                form = Campo::Form.new( "myform" )
                form.textarea( "textie", labelled: "Textie labelled") 
                form
              }
              subject { Campo.output form }
              it { should == expected }
            end 
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
            it { should be_a_kind_of(Label) }
            it { should contain_a_kind_of(Textarea) }

            describe "the full output" do
              let(:expected) { top_bit + %q!
%form{ atts[:myform], id: "myform", name: "myform", method: "POST", role: "form",  }
  %label{ for: "textie",  }
    Textie
    %textarea{ atts[:textie], tabindex: "#{@campo_tabindex += 1}", id: "textie", name: "textie", cols: "60", rows: "10",  }= inners[:textie] 
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
