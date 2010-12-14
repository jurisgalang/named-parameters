require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "NamedParameters::recognizes" do
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
    recognizes.instance_variable_get(:@foo).should eql :foo
  end

  it "allows you to override default values for optional parameters" do
    class Recognizes6
      recognizes :foo => :foo
      def initialize opts = {}
        @foo = opts[:foo]
      end
    end
    recognizes = Recognizes6.new :foo => :bar
    recognizes.instance_variable_get(:@foo).should eql :bar
  end
end
