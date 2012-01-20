# encoding: UTF-8

RSpec::Matchers.define :be_full_of do |klass|
  match do |items|
    items.all?{|x| x.kind_of? klass }
  end
end

# encoding: UTF-8

RSpec::Matchers.define :contain_a_kind_of do |klass|
  match do |items|
    items.any?{|x| x.kind_of? klass }
  end
end