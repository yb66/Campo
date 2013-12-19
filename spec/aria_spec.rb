# encoding: UTF-8

require_relative "./spec_helper.rb"
require_relative "../lib/campo/campo.rb"
require_relative "../lib/campo/plugins/aria.rb"
require_relative "../lib/campo/plugins/partial.rb"

describe "Aria" do

  before(:all) {
    Campo.plugins.clear
    Campo.plugin :partial # this is normally done by lib/campo.rb
    Campo.plugin :Aria
  }
  let(:form) { 
    Campo.form "example" do
      text("a").describe("mm/yy")
      text("b").describe("All in caps", class: "description")
      text("c").describe([["Must be 8 characters at least.",class: "password validate", id: "password_length"], ["It's better to add some numbers/punctuation.", id: "password_not_email_address", class: "password validate"]], class: "description")
      text("d").describe([["You"], ["Me"], ["Them"]])
    end
  }
  
  let(:expected) { <<'STR'
- atts = {} if atts.nil?
- atts.default_proc = proc {|hash, key| hash[key] = {} } if atts.default_proc.nil?
- inners = {} if inners.nil?
- inners.default = "" if inners.default.nil?
- @campo_tabindex ||= 0 # for tabindex
%form{ atts[:example], id: "example", name: "example", method: "POST", role: "form",  }
  %label{ for: "a",  }
    A
    %span{id: "a_description", }
      mm/yy
    %input{ atts[:a], tabindex: "#{@campo_tabindex += 1}", id: "a", name: "a", type: "text", :"aria-describedby" => "a_description",  }
  %label{ for: "b",  }
    B
    %span{id: "b_description", class: "description", }
      All in caps
    %input{ atts[:b], tabindex: "#{@campo_tabindex += 1}", id: "b", name: "b", type: "text", :"aria-describedby" => "b_description",  }
  %label{ for: "c",  }
    C
    %span{id: "c_description", class: "description", }
      %ul
        %li{ id: "password_length", class: "password validate", }
          Must be 8 characters at least.
        %li{ id: "password_not_email_address", class: "password validate", }
          It's better to add some numbers/punctuation.
    %input{ atts[:c], tabindex: "#{@campo_tabindex += 1}", id: "c", name: "c", type: "text", :"aria-describedby" => "c_description",  }
  %label{ for: "d",  }
    D
    %span{id: "d_description", }
      %ul
        %li
          You
        %li
          Me
        %li
          Them
    %input{ atts[:d], tabindex: "#{@campo_tabindex += 1}", id: "d", name: "d", type: "text", :"aria-describedby" => "d_description",  }
STR
  }

  subject { Campo.output form }
  it { should == expected }

end