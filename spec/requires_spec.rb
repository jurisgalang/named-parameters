require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "NamedParameters::requires" do
  it "complains if you don't pass it a required parameter" do
    class Requires1
      requires :bar
      def initialize opts = {}; end
    end
    lambda { Requires1.new }.should raise_error(ArgumentError)
  end

  it "doesn't complain if you pass it a required parameter" do
    class Requires2
      requires :bar
      def initialize opts = {}; end
    end
    lambda { Requires2.new :bar => :bar }.should_not raise_error(ArgumentError)
  end

  it "complains if you pass it an undeclared parameter" do
    class Requires3
      requires :bar
      def initialize opts = {}; end
    end
    lambda { Requires3.new :foo => :foo }.should raise_error(ArgumentError)
    lambda { Requires3.new :foo => :foo, :bar => :bar }.should raise_error(ArgumentError)
  end
  
  it "allows more than one required parameters" do
    class Requires4
      requires :foo, :bar, :baz
      def initialize opts = {}; end
    end
    lambda { Requires4.new :foo => :foo, :bar => :bar, :baz => :baz }.should_not raise_error(ArgumentError)
  end

  it "complains if not all of the required parameters was passed" do
    class Requires5
      requires :foo, :bar, :baz
      def initialize opts = {}; end
    end
    lambda { Requires5.new :foo => :foo }.should raise_error(ArgumentError)
    lambda { Requires5.new :foo => :foo, :bar => :bar }.should raise_error(ArgumentError)
    lambda { Requires5.new :bar => :bar, :baz => :baz }.should raise_error(ArgumentError)
  end

  # TODO: This feature is still not yet implemented; expect it to fail
  #it "allows you to declare multiple requires clause and treat it as one" do
  #  class Requires6
  #    requires :foo
  #    requires :bar
  #    requires :baz
  #    def initialize opts = {}; end
  #  end
  #  lambda { Requires6.new :foo => :foo, :bar => :bar, :baz => :baz }.should_not raise_error(ArgumentError)
  #  lambda { Requires6.new :foo => :foo }.should raise_error(ArgumentError)
  #  lambda { Requires6.new :foo => :foo, :bar => :bar }.should raise_error(ArgumentError)
  #  lambda { Requires6.new :bar => :bar, :baz => :baz }.should raise_error(ArgumentError)
  #end
end
