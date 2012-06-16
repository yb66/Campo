# encoding: UTF-8


require_relative "./campo/plugins.rb"
require_relative "./campo/plugins/partial.rb"
require_relative "./campo/plugins/jqueryvalidation.rb"
require_relative "./campo/plugins/aria.rb"

require_relative "./campo/campo.rb"

Campo.plugin :partial
Campo.plugin :Aria
