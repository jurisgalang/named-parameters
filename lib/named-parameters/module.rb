# When mixed-in, this module adds has_named_parameters class method, which
# can be used to declare methods that are supposed to accepts named-parameters.
# 
# Sample usage:
#
#   class FooBar
#     include NamedParameters
#
#     has_named_parameters :initialize, :required => [ :x ]
#     def initialize opts = { }
#       ...
#     end
#   end
#
#   FooBar.new :x => '...' # instantiates FooBar
#   FooBar.new :y => '...' # ArgumentError - since :x was not specified
#
module NamedParameters
  def self.included base
    base.extend ClassMethods
  end

  private
  def self.validate name, params, spec
    name = "#{self.class.name}##{name}"
    spec[:required] ||= []
    spec[:optional] ||= []
    
    sorter  = lambda{ |x, y| x.to_s <=> y.to_s }
    allowed = (spec[:optional] + spec[:required]).sort &sorter
    keys    = params.keys.map{ |k| k.to_sym }
    
    keys.sort! &sorter
    spec[:required].sort! &sorter
    
    list = lambda{ |params| params.join(", ") }
    
    unless spec[:required].empty? 
      k = spec[:required] & keys
      raise ArgumentError, \
        "#{name} requires arguments for parameters: #{list[spec[:required] - k]}" \
        unless k == spec[:required]
    end
    
    k = keys - allowed    
    raise ArgumentError, \
      "Unrecognized parameter specified on call to #{name}: #{list[k]}" \
      unless k.empty?
  end
  
  module ClassMethods
    def method_added name
      if specs.include?(name) && !instrumenting?
        @instrumenting = true
        method = instance_method(name)
        spec   = specs[name]
        define_method name do |*args, &block|
          params = args.find{ |arg| arg.instance_of? Hash }
          NamedParameters::validate name, params || {}, spec
          method.bind(self).call(*args, &block)
        end
        @instrumenting = false
      end
      super
    end

    def has_named_parameters method, spec = { }
      specs[method] = spec
    end
    
    private
    def specs
      @specs ||= { }
    end
    
    def instrumenting?
      @instrumenting
    end
    
    def self.extended base
      base.instance_variable_set :@instrumenting , false
    end
  end
end
