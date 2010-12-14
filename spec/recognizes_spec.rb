require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe NamedParameters do
  it "doesn't complain if you pass it an optional parameter" do
    class Foo1
      recognizes :bar
      def initialize opts = {}; end
    end
    lambda { Foo1.new :bar => :bar }.should_not raise_error(ArgumentError)
  end

  it "doesn't complain if you don't pass it an optional parameter" do
    class Foo2
      recognizes :bar
      def initialize opts = {}; end
    end
    lambda { Foo2.new }.should_not raise_error(ArgumentError)
  end

  it "complains if you pass it an undeclared parameter" do
    class Foo3
      recognizes :bar
      def initialize opts = {}; end
    end
    lambda { Foo3.new :foo => :foo }.should raise_error(ArgumentError)
    lambda { Foo3.new :foo => :foo, :bar => :bar }.should raise_error(ArgumentError)
  end

  it "allows more than one optional parameters" do
    class Foo4
      recognizes :foo, :bar, :baz
      def initialize opts = {}; end
    end
    lambda { Foo4.new :foo => :foo }.should_not raise_error(ArgumentError)
    lambda { Foo4.new :bar => :bar }.should_not raise_error(ArgumentError)
    lambda { Foo4.new :baz => :baz }.should_not raise_error(ArgumentError)
    lambda { Foo4.new :foo => :foo, :bar => :bar }.should_not raise_error(ArgumentError)
    lambda { Foo4.new :bar => :bar, :baz => :baz }.should_not raise_error(ArgumentError)
    lambda { Foo4.new :foo => :foo, :bar => :bar, :baz => :baz }.should_not raise_error(ArgumentError)
  end
end
