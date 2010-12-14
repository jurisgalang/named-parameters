require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe NamedParameters do
  it "complains if you don't pass it a required parameter" do
    class Foo1
      requires :bar
      def initialize opts = {}; end
    end
    lambda { Foo1.new }.should raise_error(ArgumentError)
  end

  it "doesn't complain if you pass it a required parameter" do
    class Foo2
      requires :bar
      def initialize opts = {}; end
    end
    lambda { Foo2.new :bar => :bar }.should_not raise_error(ArgumentError)
  end

  it "complains if you pass it an undeclared parameter" do
    class Foo3
      requires :bar
      def initialize opts = {}; end
    end
    lambda { Foo3.new :foo => :foo }.should raise_error(ArgumentError)
    lambda { Foo3.new :foo => :foo, :bar => :bar }.should raise_error(ArgumentError)
  end
  
  it "allows more than one required parameters" do
    class Foo4
      requires :foo, :bar, :baz
      def initialize opts = {}; end
    end
    lambda { Foo4.new :foo => :foo, :bar => :bar, :baz => :baz }.should_not raise_error(ArgumentError)
  end

  it "complains if not all of the required parameters was passed" do
    class Foo5
      requires :foo, :bar, :baz
      def initialize opts = {}; end
    end
    lambda { Foo5.new :foo => :foo }.should raise_error(ArgumentError)
    lambda { Foo5.new :foo => :foo, :bar => :bar }.should raise_error(ArgumentError)
    lambda { Foo5.new :bar => :bar, :baz => :baz }.should raise_error(ArgumentError)
  end
end
