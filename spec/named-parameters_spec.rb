require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "NamedParameters" do
  before :all do
    class FooBar
      has_named_parameters :initialize, :required => :x, :optional => [ :y, :z ]
      def initialize(opts = {}); end
      
      has_named_parameters :method_one, :required => :x, :optional => [ :y, :z ]
      def method_one(x, y, opts = {}); end

      def method_two(x, y, opts = {}); end
      
      has_named_parameters :method_three, :required => :x, :optional => [ :y, :z ]
      def self.method_three(x, y, opts = {}); end

      def self.method_four(x, y, opts = {}); end
    end
  end
  
  it "should allow declaration of has_named_parameters" do
    FooBar.should respond_to :has_named_parameters
  end
  
  it "should enforce named parameters for constructor" do
    lambda{ FooBar.new }.should raise_error ArgumentError
    lambda{ FooBar.new :w => :w }.should raise_error ArgumentError
    lambda{ FooBar.new :x => :x }.should_not raise_error
    lambda{ FooBar.new :x => :x, :y => :y }.should_not raise_error
    lambda{ FooBar.new :x => :x, :y => :y, :z => :z }.should_not raise_error
  end

  it "should enforce named parameters for instrumented instance methods" do
    lambda{ @foobar = FooBar.new :x => :x, :y => :y, :z => :z }.should_not raise_error
    lambda{ @foobar.method_one :x }.should raise_error ArgumentError
    lambda{ @foobar.method_one :x, :y }.should raise_error ArgumentError
    lambda{ @foobar.method_one :x, :y, :x => :x, :y => :y, :z => :z, :w => :w }.should raise_error ArgumentError
    lambda{ @foobar.method_one :x => :x, :y => :y, :z => :z }.should raise_error ArgumentError
    lambda{ @foobar.method_one :x, :y, :w => :w }.should raise_error ArgumentError
    lambda{ @foobar.method_one :x, :y, :x => :x }.should_not raise_error
    lambda{ @foobar.method_one :x, :y, :x => :x, :y => :y }.should_not raise_error
    lambda{ @foobar.method_one :x, :y, :x => :x, :y => :y, :z => :z }.should_not raise_error
  end

  it "should not enforce named parameters for un-instrumented instance methods" do
    lambda{ @foobar = FooBar.new :x => :x, :y => :y, :z => :z }.should_not raise_error
    lambda{ @foobar.method_two :x }.should raise_error ArgumentError
    lambda{ @foobar.method_two :x, :y }.should_not raise_error ArgumentError
    lambda{ @foobar.method_two :x, :y, :w => :w }.should_not raise_error ArgumentError
  end

  it "should enforce named parameters for instrumented class methods" do
    lambda{ FooBar.method_three :x }.should raise_error ArgumentError
    lambda{ FooBar.method_three :x, :y }.should raise_error ArgumentError
    lambda{ FooBar.method_three :x, :y, :x => :x, :y => :y, :z => :z, :w => :w }.should raise_error ArgumentError
    lambda{ FooBar.method_three :x => :x, :y => :y, :z => :z }.should raise_error ArgumentError
    lambda{ FooBar.method_three :x, :y, :w => :w }.should raise_error ArgumentError
    lambda{ FooBar.method_three :x, :y, :x => :x }.should_not raise_error
    lambda{ FooBar.method_three :x, :y, :x => :x, :y => :y }.should_not raise_error
    lambda{ FooBar.method_three :x, :y, :x => :x, :y => :y, :z => :z }.should_not raise_error
  end

  it "should not enforce named parameters for un-instrumented class methods" do
    lambda{ FooBar.method_four :x }.should raise_error ArgumentError
    lambda{ FooBar.method_four :x, :y }.should_not raise_error ArgumentError
    lambda{ FooBar.method_four :x, :y, :w => :w }.should_not raise_error ArgumentError
  end
end
