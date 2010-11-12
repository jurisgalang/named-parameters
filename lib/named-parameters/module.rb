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
# @author Juris Galang
#
class Object
  protected
  def eigenclass # :nodoc:
    class << self; self; end  
  end  
end

module NamedParameters
  protected
  def self.included base # :nodoc:
    base.extend ClassMethods
  end

  private
  # this is the method used to validate the name of the received parameters 
  # (based on the defined spec) when an instrumented method is invoked.
  #
  def self.validate name, params, spec  # :nodoc:
    [ :required, :optional, :oneof ].each{ |k| spec[k] ||= [] }
    
    spec = Hash[ spec.map{ |k, v| 
      v = [ v ] unless v.instance_of? Array
      [ k, v ]
    } ]
    
    sorter  = lambda{ |x, y| x.to_s <=> y.to_s }
    allowed = (spec[:optional] + spec[:required] + spec[:oneof]).sort &sorter
    keys    = params.keys.map{ |k| k.to_sym }
    
    keys.sort! &sorter
    spec[:required].sort! &sorter
    
    list = lambda{ |params| params.join(", ") }
    
    # require that all of :required parameters are specified
    unless spec[:required].empty? 
      k = spec[:required] & keys
      raise ArgumentError, \
        "#{name} requires the following parameters: #{list[spec[:required] - k]}" \
        unless k == spec[:required]
    end
    
    # require that one (and only one) of :oneof parameters is specified
    unless spec[:oneof].empty?
      k = spec[:oneof] & keys
      raise ArgumentError, \
        "#{name} requires at least one of the following parameters: #{list[spec[:oneof]]}" \
        unless k.length == 1 
    end
    
    # enforce that only declared parameters (:required, :optional, and :oneof)
    # may be specified
    k = keys - allowed    
    raise ArgumentError, \
      "Unrecognized parameter specified on call to #{name}: #{list[k]}" \
      unless k.empty?
  end
  
  module ClassMethods
    # Declares that `method` will enforce named parameters behavior as 
    # described in `spec`; a method declared with `:required` and/or 
    # `:optional` parameters will raise an `ArgumentError` if it is invoked 
    # without its required parameters or receives an unrecognized parameter.
    #
    # Sample usage:
    #
    #     has_named_parameters :point, :required => [ :x, :y ], :optional => :color
    #
    # @param [Symbol] method the name of the method that is supposed to 
    #   enforce named parameters behavior.
    #
    # @param [Hash] spec a `Hash` to specify the list of required and optional 
    #   parameters for the method. Use either the `:required` or `:optional` 
    #   key to specify required and optional lists of parameters. The list is
    #   expected to be an `Array` of symbols matching the names of the 
    #   expected and optional parameters.
    #
    def has_named_parameters method, spec = { }
      specs[method] = spec
    end
    
    protected
    # add instrumentation for class methods
    def singleton_method_added name  # :nodoc:
      instrument name do
        method = self.eigenclass.instance_method name
        spec   = specs.delete name
        owner  = "#{self.name}::"
        eigenclass.instance_eval do
          intercept method, owner, name, spec
        end
      end
      super
    end
    
    # add instrumentation for instance methods
    def method_added name  # :nodoc:
      instrument name do
        method = instance_method name
        spec   = specs.delete name
        owner  = "#{self.name}#"
        intercept method, owner, name, spec
      end
      super
    end

    private
    # apply instrumentation to method
    def instrument method  # :nodoc:
      if specs.include? method and !instrumenting?
        @instrumenting = true
        yield method
        @instrumenting = false
      end
    end
    
    # insert parameter validation prior to executing the instrumented method
    def intercept method, owner, name, spec  # :nodoc:
      define_method name do |*args, &block|
        params   = args.find{ |arg| arg.instance_of? Hash }
        fullname = "#{owner}#{name}"
        NamedParameters::validate fullname, params || {}, spec
        method.bind(self).call(*args, &block)
      end
    end
    
    # initialize specs table as needed 
    def specs  # :nodoc:
      @specs ||= { }
    end
    
    # check if in the process of instrumenting a method
    def instrumenting?  # :nodoc:
      @instrumenting
    end
    
    # initialize the @instrumenting instance variable (housekeeping)
    def self.extended base  # :nodoc:
      base.instance_variable_set :@instrumenting , false
    end
  end
end
