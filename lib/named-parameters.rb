require "rubygems"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib')) if RUBY_VERSION =~ /^(1\.8\.6)/
require 'named-parameters/module'

# Extend object to automatically make it available for all
# user defined classes...
class Object
  include NamedParameters
end
