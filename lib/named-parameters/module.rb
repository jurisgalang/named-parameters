# named-parameters.rb
# 
# When mixed-in, the `NamedParameters` module adds has_named_parameters class 
# method, which can be used to declare methods that are supposed to accepts 
# named-parameters.
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
# @copyright 2010 Juris Galang. All Rights Reserved
#
require 'named-parameters/object'

module NamedParameters
  # Returns the list of declared parameters for the calling method, ie: the 
  # concatenation of `:required`, `:optional`, and `:oneof` parameter list as 
  # declared in the the `has_named_parameters` clause, or the list specified 
  # in either the `requires` and `recognizes` clause.
  #   
  #     has_named_parameters :foo, :required => [ :x ], :optional => [ :y ]
  #     def foo options = { }
  #       puts declared_parameters.inspect
  #     end
  #
  #     foo :x => 1, :y => 2   # => [ :x, :y ]
  #
  # @param [Array<Symbol>] type limits the list of parameters returned to the
  #   parameter types specified.
  #
  # @return [Array<Symbol>] the list of symbols representing the name of the 
  #   declared parameters.
  #
  def declared_parameters type = [ :required, :optional, :oneof ]
    klazz  = self.instance_of?(Class) ? self : self.class
    specs  = klazz.send :method_specs
    method = if block_given?
      yield # insane-fucker! :-)
    else
      caller = calling_method
      self.instance_of?(Class) ? :"self.#{caller}" : caller
    end

    return [] unless spec = specs[klazz.send(:key_for, method)]

    mapper = lambda{ |entry| entry.instance_of?(Hash) ? entry.keys.first : entry }
    sorter = lambda{ |x, y| x.to_s <=> y.to_s }
    Array(type).map{ |k| spec[k].map(&mapper) }.flatten.sort(&sorter)
  end
  
  # Returns the list of declared parameters for a specific method, ie: the 
  # concatenation of `:required`, `:optional`, and `:oneof` parameter list as 
  # declared in the the {#has_named_parameters} clause, or the list specified 
  # in either the `requires` and `recognizes` clause.
  #   
  #     has_named_parameters :foo, :required => [ :x ], :optional => [ :y ]
  #     def foo options = { }
  #       # ...
  #     end
  #
  #     def bar
  #       puts declared_parameters_for(:foo).inspect
  #     end
  #
  #     bar   # => [ :x, :y ]
  #
  # @param [Symbol] method the name of the method in question.
  #
  # @param [Array<Symbol>] type limits the list of parameters returned to the
  #   parameter types specified.
  #
  # @return [Array<Symbol>] the list of symbols representing the name of the 
  #   declared parameters.
  #
  def declared_parameters_for method, type = [ :required, :optional, :oneof ]
    declared_parameters(type) { method }
  end
  
  # Filter out keys from `options` that are not declared as parameter to the
  # method:
  #   
  #     has_named_parameters :foo, :required => :x
  #     def foo options = { }
  #       options.inspect
  #     end
  #
  #     # the following will fail because :y and :z is not recognized/declared
  #     options = { :x => 1, :y => 2, :z => 3 } 
  #     foo options   # => ArgumentError! 
  #
  #     # the following will not fail because we've applied the filter
  #     foo filter_parameters(options)   # => [ :x ]
  #
  # @param [Hash] options the options argument to the method.
  #
  # @param [Array<Symbol>] filter the list of symbols representing the declared
  #   parameters used to filter `options`. If not specified then the list 
  #   returned by {#declared_parameters} is used by default.
  #
  # @return [Hash] a `Hash` whose keys are limited to what's declared as
  #   as parameter to the method.
  #
  def filter_parameters options, filter = nil
    caller = calling_method
    method = self.instance_of?(Class) ? :"self.#{caller}" : caller
    filter ||= declared_parameters { method } 
    options.reject{ |key, value| !filter.include?(key) }
  end
  
  protected
  def self.included base # :nodoc:
    base.extend ClassMethods
  end

  private
  # returns the name of the current method
  def current_method # :nodoc:
    caller[0][/`([^']*)'/, 1].to_sym
  end

  # returns the name of the calling method
  def calling_method # :nodoc:
    caller[1][/`([^']*)'/, 1].to_sym
  end
    
  # this is the method used to validate the name of the received parameters 
  # (based on the defined spec) when an instrumented method is invoked.
  #
  def self.validate_method_specs name, params, spec  # :nodoc:
    mapper   = lambda{ |n| n.instance_of?(Hash) ? n.keys : n }
    optional = spec[:optional].map(&mapper).flatten
    required = spec[:required].map(&mapper).flatten
    oneof    = spec[:oneof].map(&mapper).flatten
    
    # determine what keys are allowed, unless mode is :permissive
    # in which case we don't care unless its listed as required or oneof
    sorter  = lambda{ |x, y| x.to_s <=> y.to_s }
    allowed = spec[:mode] == :permissive ? [] : (optional + required + oneof).sort(&sorter)
    
    # determine what keys were passed;
    # also, plugin the names of parameters assigned with default values
    keys = params.keys.map{ |k| k.to_sym }
    keys.sort! &sorter
    required.sort! &sorter
    
    # this lambda is used to present the list of parameters as a string
    list = lambda{ |params| params.join(", ") }
        
    # require that all of :required parameters are specified
    unless required.empty? 
      k = required & keys
      raise ArgumentError, \
        "#{name} requires the following parameters: #{list[required - k]}" \
        unless k == required
    end
    
    # require that one (and only one) of :oneof parameters is specified
    unless oneof.empty?
      k = oneof & keys
      raise ArgumentError, \
        "#{name} requires at least one of the following parameters: #{list[oneof]}" \
        if k.empty?
      raise ArgumentError, \
        "#{name} may specify only one of the following parameters: #{list[oneof]}" \
        if k.length > 1
    end
    
    # enforce that only declared parameters (:required, :optional, and :oneof)
    # may be specified
    k = keys - allowed    
    raise ArgumentError, \
      "Unrecognized parameter specified on call to #{name}: #{list[k]}" \
      unless k.empty?
  end

  module ClassMethods
    ALIAS_PREFIX = :__intercepted__

    def aliased name # :nodoc:
      :"#{ALIAS_PREFIX}#{name}"
    end
    
    def unaliased name  # :nodoc:
      name.gsub(/^#{ALIAS_PREFIX}/, '')
    end
    
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
    #   parameters for the method. Use either the `:required`, `:optional`, or
    #   `:oneof` key to specify the lists of parameters. The list is expected 
    #   to be an `Array` of symbols matching the names of the expected and 
    #   optional parameters.
    #
    #   Parameters are evaluated according their classification:
    #
    #   * `:required` means that all of these parameters must be specified.
    #   * `:optional` means that all or none of these parameters may be used.
    #   * `:oneof` means that one of these parameters must be specified.
    #
    # @param [Symbol] mode enforces that only parameters that were named in
    #   either the `:required`, `:optional`, and `:oneof` list may be allowed.
    #   Set it to `:permissive` to relax the requirement - `:required` and `:oneof`
    #   parameters will still be expected.
    #
    def has_named_parameters method, spec, mode = :strict
      # ensure spec entries are initialized and the proper types
      [ :required, :optional, :oneof ].each{ |k| spec[k] ||= [] }
      
      # assemble/normalize method spec; the following code should 
      # just be:
      # 
      #   spec = Hash[ spec.map{ |k, v| 
      #     v = [ v ] unless v.instance_of? Array
      #     v.map!{ |entry| entry.instance_of?(Array) ? Hash[*entry] : entry }
      #     [ k, v ] 
      #   } ] 
      #
      # but we have to play nice with ruby 1.8.6, so we'll have to be content
      # with the ugliness for now...
      #
      pairs = spec.map{ |k, v| 
        v = [ v ] unless v.instance_of? Array
        v.map!{ |entry| entry.instance_of?(Array) ? Hash[*entry] : entry  }
        [ k, v ]
      }

      spec = { }
      pairs.each{ |x| spec[x[0]] = x[1] }
      spec = Hash[ spec ] 

      spec[:mode] = mode
      method_specs[key_for(method)] = spec
      yield spec if block_given?
    end
    
    # Convenience method, equivalent to declaring:
    #
    #     has_named_parameters :'self.new', :required => params, :strict
    #     has_named_parameters :initialize, :required => params, :strict
    # 
    # @param [Array<Symbol>] params the lists of parameters. The list is expected 
    #   to be an `Array` of symbols matching the names of the required 
    #   parameters.
    #
    def requires *params, &block
      raise ArgumentError, "You must specify at least one parameter when declaring a requiring clause" if params.empty?
      [ :'self.new', :initialize ].each do |method|
        spec = method_specs[key_for(method)] || { }
        spec.merge!(:required => params)
        has_named_parameters method, spec, :strict, &block
      end
    end
    
    # Convenience method, equivalent to declaring:
    #
    #     has_named_parameters :'self.new', :optional => params, :strict
    #     has_named_parameters :initialize, :optional => params, :strict
    # 
    # @param [Array<Symbol>] params the lists of parameters. The list is expected 
    #   to be an `Array` of symbols matching the names of the optional
    #   parameters.
    #
    def recognizes *params, &block
      raise ArgumentError, "You must specify at least one parameter when declaring a recognizes clause" if params.empty?
      [ :'self.new', :initialize ].each do |method|
        spec = method_specs[key_for(method)] || { }
        spec.merge!(:optional => params)
        has_named_parameters method, spec, :strict, &block
      end
    end
    
    protected
    # Attach a validation block for a specific parameter that will be invoked 
    # before the actual `method` call.
    #
    # @param [Symbol] method the name of the method.
    #
    # @param [Symbol] param the name of the parameter whose value is to be
    #   validated.
    #
    # @param [lambda, Proc] &block the chunk of code that will perform the 
    #   actual validation. It is expected to raise an error or return false
    #   if the validation fails. It receives argument for `param` on 
    #   invocation.
    # 
    #   If `&block` is not specified then it assumes that an implicit 
    #   validation method is defined. It calculates the name of this method
    #   by concatenating the values supplied for `method` and `param`, 
    #   suffixed with the word `validation`, eg:
    #
    #     validates_arguments_for :request, :timeout
    #     def request, opts = { }
    #       ...
    #     end
    #    
    #     private
    #     def request_timeout_validation value
    #       ...
    #     end
    #
    #def validates_arguments method, param, &block
    #  # TODO: IMPLEMENT
    #end
    
    # add instrumentation for class methods
    def singleton_method_added name  # :nodoc:
      apply_method_spec :"self.#{name}" do
        self.metaclass.send :alias_method, aliased(name), name
        owner = "#{self}::"
        spec  = method_specs[key_for(:"self.#{name}")]
        metaclass.instance_eval do
          intercept owner, name, spec
        end
      end
      super
    end
    
    # add instrumentation for instance methods
    def method_added name  # :nodoc:
      apply_method_spec name do
        alias_method aliased(name), name
        owner = "#{self}#"
        spec  = method_specs[key_for(name)]
        intercept owner, name, spec
      end
      super
    end

    private
    # apply instrumentation to method
    def apply_method_spec method  # :nodoc:
      if method_specs.include? key_for(method) and !instrumenting?
        @instrumenting = true
        yield method
        @instrumenting = false
      end
    end

    # insert parameter validation prior to executing the instrumented method
    def intercept owner, name, spec  # :nodoc:
      class_eval(<<-CODE, __FILE__, __LINE__)
        def #{name}(*args, &block)
          # compute the fully-qualified name of the method
          # this is used when reporting argument errors
          fullname = "#{owner}#{name}"

          # locate the argument representing the named parameters value
          # for the method invocation
          params = args.last
          args << (params = { }) unless params.instance_of? Hash
          
          # merge the declared default values for params into the arguments
          # used when the method is invoked
          spec     = #{spec.inspect}
          defaults = { }
          spec.each do |k, v|
            next if k == :mode
            v.each{ |entry| entry.instance_of?(Hash) ? defaults.merge!(entry) : entry }
          end
          params = defaults.merge(params)
          
          # validate the parameters against the spec
          NamedParameters::validate_method_specs fullname, params, spec

          # inject the updated argument values for params into the arguments
          # before actually making method invocation
          args[args.length - 1] = params
          method = :"#{ALIAS_PREFIX}#{name}"
          send method, *args, &block
        end
      CODE
    end
    
    # initialize specs table as needed 
    def method_specs  # :nodoc:
      @method_specs ||= { }
    end
    
    def key_for method
      type = method.to_s =~ /^self\./ ? :singleton : :instance
      name = method.to_s.sub(/^self\./, '')
      :"#{self}::#{type}.#{unaliased name}"
    end
    
    # check if in the process of instrumenting a method
    def instrumenting?  # :nodoc:
      @instrumenting
    end
    
    # initialize the @instrumenting instance variable (housekeeping)
    def self.extended base  # :nodoc:
      base.instance_variable_set(:@instrumenting, false)
    end
  end
end
