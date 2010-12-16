require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "NamedParameters::recognizes" do
  it "should allow declaration of the recognizes clause" do
    class Recognizes; end
    Recognizes.should respond_to(:recognizes)
  end
  
  it "complains if you don't declare a parameter when using the clause" do
    lambda { 
      class Recognizes0
        recognizes
        def initialize opts = {}; end
      end
    }.should raise_error(ArgumentError)
  end
  
  it "doesn't complain if you pass it an optional parameter" do
    class Recognizes1
      recognizes :bar
      def initialize opts = {}; end
    end
    lambda { Recognizes1.new :bar => :bar }.should_not raise_error(ArgumentError)
  end

  it "doesn't complain if you don't pass it an optional parameter" do
    class Recognizes2
      recognizes :bar
      def initialize opts = {}; end
    end
    lambda { Recognizes2.new }.should_not raise_error(ArgumentError)
  end

  it "complains if you pass it an undeclared parameter" do
    class Recognizes3
      recognizes :bar
      def initialize opts = {}; end
    end
    lambda { Recognizes3.new :foo => :foo }.should raise_error(ArgumentError)
    lambda { Recognizes3.new :foo => :foo, :bar => :bar }.should raise_error(ArgumentError)
  end

  it "allows more than one optional parameters" do
    class Recognizes4
      recognizes :foo, :bar, :baz
      def initialize opts = {}; end
    end
    lambda { Recognizes4.new :foo => :foo }.should_not raise_error(ArgumentError)
    lambda { Recognizes4.new :bar => :bar }.should_not raise_error(ArgumentError)
    lambda { Recognizes4.new :baz => :baz }.should_not raise_error(ArgumentError)
    lambda { Recognizes4.new :foo => :foo, :bar => :bar }.should_not raise_error(ArgumentError)
    lambda { Recognizes4.new :bar => :bar, :baz => :baz }.should_not raise_error(ArgumentError)
    lambda { Recognizes4.new :foo => :foo, :bar => :bar, :baz => :baz }.should_not raise_error(ArgumentError)
  end

  it "allows you to specify default values for optional parameters" do
    class Recognizes5
      recognizes :foo => :foo
      def initialize opts = {}
        @foo = opts[:foo]
      end
    end
    recognizes = Recognizes5.new
    recognizes.instance_variable_get(:@foo).should eql(:foo)
  end

  it "allows you to override default values for optional parameters" do
    class Recognizes6
      recognizes :foo => :foo
      def initialize opts = {}
        @foo = opts[:foo]
      end
    end
    recognizes = Recognizes6.new :foo => :bar
    recognizes.instance_variable_get(:@foo).should eql(:bar)
  end
  
  it "allows you to declare parameters and default values as Array pairs" do
    class Recognizes7
      recognizes [ :foo, :foo ], [ :bar, :bar ]
      def initialize opts = {}
        @foo = opts[:foo]
        @bar = opts[:bar]
      end
    end
    recognizes = Recognizes7.new
    recognizes.instance_variable_get(:@foo).should eql(:foo)
    recognizes.instance_variable_get(:@bar).should eql(:bar)
  end

  it "allows you to declare parameters and default values as KV pairs" do
    class Recognizes8
      recognizes :xen => :xen, :bar => :bar
      def initialize opts = {}
        @xen = opts[:xen]
        @bar = opts[:bar]
      end
    end
    recognizes = Recognizes8.new
    recognizes.instance_variable_get(:@xen).should eql(:xen)
    recognizes.instance_variable_get(:@bar).should eql(:bar)
  end

  it "allows you to declare parameters and default values as Array and KV pairs" do
    class Recognizes9
      recognizes [ :foo, :foo ], { :bar => :bar }
      def initialize opts = {}
        @foo = opts[:foo]
        @bar = opts[:bar]
      end
    end
    recognizes = Recognizes9.new
    recognizes.instance_variable_get(:@foo).should eql(:foo)
    recognizes.instance_variable_get(:@bar).should eql(:bar)
  end

  it "allows you to declare parameters with and without default values" do
    class Recognizes10
      recognizes :foo, [ :bar, :bar ], :zoo, { :baz => :baz }, :quux
      def initialize opts = {}
        @foo  = opts[:foo]
        @bar  = opts[:bar]
        @baz  = opts[:baz]
        @zoo  = opts[:zoo]
        @quux = opts[:quux]
      end
    end
    recognizes = Recognizes10.new(:foo => :foo, :zoo => :zoo, :quux => :quux)
    recognizes.instance_variable_get(:@foo).should  eql(:foo)
    recognizes.instance_variable_get(:@bar).should  eql(:bar)
    recognizes.instance_variable_get(:@baz).should  eql(:baz)
    recognizes.instance_variable_get(:@zoo).should  eql(:zoo)
    recognizes.instance_variable_get(:@quux).should eql(:quux)
  end
end
