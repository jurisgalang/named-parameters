require 'named-parameters/object'
require 'named-parameters/module'

# Extend object to automatically make it available for all
# user defined classes...
class Object 
  include NamedParameters
end
