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
          expected = top_bit + %q!%form{ atts[:myform], method: "POST", name: "myform",  }

!
        }

        subject{ Campo.output Campo::Form.new( "myform" ) }
        it { should_not be_nil }
        it { should == expected }
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

      context "initialisation" do
        subject { Campo::Form.new( "myform" ) }
        it { should_not be_nil }
        it { should be_a_kind_of(Form) }
      end

      context "simple output" do
        let(:expected) { %q!%form{ atts[:myform], method: "POST", name: "myform",  }! }
        subject { Campo::Form.new( "myform" ).output }
        it { should == expected }
      end
      
      context :fieldset do
        let(:expected) { top_bit + "%fieldset{  }\n  %legend{  }Do you like these colours? Tick for yes:\n\n" }
        subject { Campo.output Campo::Form.new( "myform" ).fieldset("Do you like these colours? Tick for yes:") }
        it { should_not be_nil }
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
              let(:expected) { top_bit + %q!%select{ atts[:pqr], tabindex: "#{i += 1}", name: "pqr",  }

! }
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
                let(:expected) { top_bit + %q!%select{ atts[:pqr], tabindex: "#{i += 1}", name: "pqr",  }
  %option{  value: "", disabled: "disabled", name: "pqr",  }Choose one:

!  }
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
              let(:expected) { top_bit + %q!%select{ atts[:pqr], tabindex: "#{i += 1}", name: "pqr",  }
  %option{ atts[:pqr_volvo], value: "volvo", id: "pqr_volvo", name: "pqr",  }Volvo
  %option{ atts[:pqr_saab], value: "saab", id: "pqr_saab", name: "pqr",  }Saab
  %option{ atts[:pqr_audi], value: "audi", id: "pqr_audi", name: "pqr",  }Audi

! }
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
                let(:expected) { top_bit + %q!%select{ atts[:pqr], tabindex: "#{i += 1}", name: "pqr",  }
  %option{  value: "", disabled: "disabled", name: "pqr",  }Choose one:
  %option{ atts[:pqr_volvo], value: "volvo", id: "pqr_volvo", name: "pqr",  }Volvo
  %option{ atts[:pqr_saab], value: "saab", id: "pqr_saab", name: "pqr",  }Saab
  %option{ atts[:pqr_audi], value: "audi", id: "pqr_audi", name: "pqr",  }Audi

!  }
                subject { Campo.output tag.with_default }
                it { should == expected }
              end
            end
            
          end

          context "and an array" do
            let(:opts) { [["ford", "Ford"], ["bmw", "BMW"], ["ferrari", "Ferrari", "checked"]] }
            subject { Campo::Select.new( "pqr", opts ) }

            it { should_not be_nil }
            it { should be_a_kind_of(Select) }
            specify { subject.output.should == %q!%select{ atts[:pqr], tabindex: "#{i += 1}", name: "pqr",  }! }

            context "with a block with options" do
              let(:opts) { [["ford", "Ford"], ["bmw", "BMW"], ["ferrari", "Ferrari", "checked"]] }
              let(:tag){ 
                Campo::Select.new( "pqr", opts ) do |s|
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
                let(:expected) { top_bit + %q!%select{ atts[:pqr], tabindex: "#{i += 1}", name: "pqr",  }
  %option{ atts[:pqr_ford], value: "ford", id: "pqr_ford", name: "pqr",  }Ford
  %option{ atts[:pqr_bmw], value: "bmw", id: "pqr_bmw", name: "pqr",  }BMW
  %option{ atts[:pqr_ferrari], value: "ferrari", selected: "selected", id: "pqr_ferrari", name: "pqr",  }Ferrari
  %option{ atts[:pqr_volvo], value: "volvo", id: "pqr_volvo", name: "pqr",  }Volvo
  %option{ atts[:pqr_saab], value: "saab", id: "pqr_saab", name: "pqr",  }Saab
  %option{ atts[:pqr_audi], value: "audi", id: "pqr_audi", name: "pqr",  }Audi

! }
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
                  let(:expected) { top_bit + %q!%select{ atts[:pqr], tabindex: "#{i += 1}", name: "pqr",  }
  %option{  value: "", disabled: "disabled", name: "pqr",  }Choose one:
  %option{ atts[:pqr_ford], value: "ford", id: "pqr_ford", name: "pqr",  }Ford
  %option{ atts[:pqr_bmw], value: "bmw", id: "pqr_bmw", name: "pqr",  }BMW
  %option{ atts[:pqr_ferrari], value: "ferrari", selected: "selected", id: "pqr_ferrari", name: "pqr",  }Ferrari
  %option{ atts[:pqr_volvo], value: "volvo", id: "pqr_volvo", name: "pqr",  }Volvo
  %option{ atts[:pqr_saab], value: "saab", id: "pqr_saab", name: "pqr",  }Saab
  %option{ atts[:pqr_audi], value: "audi", id: "pqr_audi", name: "pqr",  }Audi

!  }
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
              let(:expected) { top_bit + output + "\n\n" }
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
                let(:expected) { top_bit + output + "\n\n" }
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
                let(:expected) { top_bit + output + "\n\n" }
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
              let(:expected) { top_bit + output + "\n\n" }
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
              let(:expected) { top_bit + output + "\n\n" }
              subject { Campo.output tag }
              it { should_not be_nil }
              it { should == expected }
            end
          end


        end # context
      end # initialisation

      context "Labelling" do
        let(:expected) { 
          s = <<STR
%form{ atts[:myform], method: "POST", name: "myform",  }
  %label{ for: "abc",  }
    abc
    %input{ atts[:abc], tabindex: "\#{i += 1}", type: "text", id: "abc", name: "abc",  }
  %label{ for: "def",  }
    def
    %input{ atts[:def], tabindex: "\#{i += 1}", type: "text", id: "def", name: "def",  }
  %label{ for: "ghi",  }
    ghi
    %input{ atts[:ghi], tabindex: "\#{i += 1}", type: "text", id: "ghi", name: "ghi",  }

STR
        top_bit + s
      }
        let(:form) {
          form = Campo::Form.new( "myform" )
          form << Campo::Input.new( "abc", :text ).labelled("abc")
          form << Campo::Input.new( "def", :text ).labelled("def")
          form << Campo::Input.new( "ghi", :text ).labelled("ghi")
          form
        }
        subject { Campo.output form }
        it { should_not be_nil }
        it { should == expected }
        
        context "Within a fieldset" do
          let(:expected) { 
            s = <<STR
%form{ atts[:myform], method: "POST", name: "myform",  }
  %fieldset{  }
    %legend{  }Alphabetty spaghetti
    %label{ for: "abc",  }
      abc
      %input{ atts[:abc], tabindex: "\#{i += 1}", type: "text", id: "abc", name: "abc",  }
    %label{ for: "def",  }
      def
      %input{ atts[:def], tabindex: "\#{i += 1}", type: "text", id: "def", name: "def",  }
    %label{ for: "ghi",  }
      ghi
      %input{ atts[:ghi], tabindex: "\#{i += 1}", type: "text", id: "ghi", name: "ghi",  }

STR
        top_bit + s
      }
          let(:form) {
            form = Campo::Form.new( "myform" )
            myfieldset = form.fieldset( "Alphabetty spaghetti" )
            Campo::Input.new( "abc", :text ).labelled("abc").fieldset(myfieldset)
            Campo::Input.new( "def", :text ).labelled("def").fieldset(myfieldset)
            Campo::Input.new( "ghi", :text ).labelled("ghi").fieldset(myfieldset)
            form
          }
          subject { Campo.output form }
          it { should_not be_nil }
          it { should == expected }          
        end
      end
        
        
      describe "A form with a group of radio buttons" do
        let(:expected) { 
          s = <<'STRI' 
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
STRI
          top_bit + s + "\n"
        }
        
        let(:radios) {
          form = Campo::Form.new( "myform" )
          sel_colours = form.fieldset( "Select the colour you like most:" )
          Campo::Input.new("radio1", :radio, value: "green" ).labelled( "green" ).fieldset( sel_colours )
          Campo::Input.new("radio1", :radio, value: "yellow" ).labelled( "yellow" ).fieldset( sel_colours )
          Campo::Input.new("radio1", :radio, value: "red" ).labelled( "red" ).fieldset( sel_colours )
          Campo::Input.new("radio1", :radio, value: "blue" ).labelled( "blue" ).fieldset( sel_colours )
          Campo::Input.new("radio1", :radio, value: "purple" ).labelled( "purple" ).fieldset( sel_colours )
          sel_colours
        }
        subject { Campo.output radios }
        it { should_not be_nil }
        it { should == expected }
      end # a group of radio buttons
    end # Input
    


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