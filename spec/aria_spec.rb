# encoding: UTF-8

require_relative "./spec_helper.rb"
require_relative "../lib/campo.rb"

describe "Aria" do

  before {
    Campo.plugin :Aria
  }
  let(:form) { 
    Campo.form "example" do
      text("a").describe("mm/yy")
      text("b").describe("All in caps", class: "description")
    end
  }
  
  let(:expected) { <<'STR'
- atts = {} if atts.nil?
- atts.default_proc = proc {|hash, key| hash[key] = {} } if atts.default_proc.nil?
- inners = {} if inners.nil?
- inners.default = "" if inners.default.nil?
- @campo_tabindex ||= 0 # for tabindex
%form{ atts[:example], id: "example", method: "POST", name: "example", role: "form",  }
  %label{ for: "a",  }
    A
    %input{ atts[:a], tabindex: "#{@campo_tabindex += 1}", id: "a", type: "text", name: "a", :"aria-describedby" => "a_description",  }
    %span{id: "a_description", }
      mm/yy
  %label{ for: "b",  }
    B
    %input{ atts[:b], tabindex: "#{@campo_tabindex += 1}", id: "b", type: "text", name: "b", :"aria-describedby" => "b_description",  }
    %span{id: "b_description", class: "description", }
      All in caps
STR
  }

  subject { Campo.output form }
  it { should == expected }

end