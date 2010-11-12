require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "NamedParameters" do
  before :all do
    class Foo
      has_named_parameters :initialize, :required => :x, :optional => [ :y, :z ]
      def initialize opts = {}; end
      
      has_named_parameters :method_one, :required => :x, :optional => [ :y, :z ]
      def method_one x, y, opts = {}; end

      def method_two x, y, opts = {}; end
      
      has_named_parameters :method_three, :required => :x, :optional => [ :y, :z ]
      def self.method_three x, y, opts = {}; end

      def self.method_four x, y, opts = {}; end
    end
    
    class Bar
      has_named_parameters :method_with_one_required, :required => :x
      def method_with_one_required opts = {}; end
      
      has_named_parameters :method_with_many_required, :required => [ :x, :y ]
      def method_with_many_required opts = {}; end
      
      has_named_parameters :method_with_one_oneof, :oneof => :x
      def method_with_one_oneof opts = {}; end
      
      has_named_parameters :method_with_many_oneof, :oneof => [ :x, :y ]
      def method_with_many_oneof opts = {}; end
      
      has_named_parameters :method_with_one_optional, :optional => :x
      def method_with_one_optional opts = {}; end
      
      has_named_parameters :method_with_many_optional, :optional => [ :x, :y ]
      def method_with_many_optional opts = {}; end

      has_named_parameters :method_with_one_of_each_requirement, :required => :w, :oneof => [ :x, :y ], :optional => :z
      def method_with_one_of_each_requirement opts = {}; end
    end
    @bar = Bar.new
  end
  
  it "should allow declaration of has_named_parameters" do
    Foo.should respond_to :has_named_parameters
  end
  
  it "should enforce named parameters for constructor" do
    lambda{ Foo.new }.should raise_error ArgumentError
    lambda{ Foo.new :w => :w }.should raise_error ArgumentError
    lambda{ Foo.new :x => :x }.should_not raise_error
    lambda{ Foo.new :x => :x, :y => :y }.should_not raise_error
    lambda{ Foo.new :x => :x, :y => :y, :z => :z }.should_not raise_error
  end

  it "should enforce named parameters for instrumented instance methods" do
    lambda{ @foo = Foo.new :x => :x, :y => :y, :z => :z }.should_not raise_error
    lambda{ @foo.method_one :x }.should raise_error ArgumentError
    lambda{ @foo.method_one :x, :y }.should raise_error ArgumentError
    lambda{ @foo.method_one :x, :y, :x => :x, :y => :y, :z => :z, :w => :w }.should raise_error ArgumentError
    lambda{ @foo.method_one :x => :x, :y => :y, :z => :z }.should raise_error ArgumentError
    lambda{ @foo.method_one :x, :y, :w => :w }.should raise_error ArgumentError
    lambda{ @foo.method_one :x, :y, :x => :x }.should_not raise_error
    lambda{ @foo.method_one :x, :y, :x => :x, :y => :y }.should_not raise_error
    lambda{ @foo.method_one :x, :y, :x => :x, :y => :y, :z => :z }.should_not raise_error
  end

  it "should not enforce named parameters for un-instrumented instance methods" do
    lambda{ @foo = Foo.new :x => :x, :y => :y, :z => :z }.should_not raise_error
    lambda{ @foo.method_two :x }.should raise_error ArgumentError
    lambda{ @foo.method_two :x, :y }.should_not raise_error ArgumentError
    lambda{ @foo.method_two :x, :y, :w => :w }.should_not raise_error ArgumentError
  end

  it "should enforce named parameters for instrumented class methods" do
    lambda{ Foo.method_three :x }.should raise_error ArgumentError
    lambda{ Foo.method_three :x, :y }.should raise_error ArgumentError
    lambda{ Foo.method_three :x, :y, :x => :x, :y => :y, :z => :z, :w => :w }.should raise_error ArgumentError
    lambda{ Foo.method_three :x => :x, :y => :y, :z => :z }.should raise_error ArgumentError
    lambda{ Foo.method_three :x, :y, :w => :w }.should raise_error ArgumentError
    lambda{ Foo.method_three :x, :y, :x => :x }.should_not raise_error
    lambda{ Foo.method_three :x, :y, :x => :x, :y => :y }.should_not raise_error
    lambda{ Foo.method_three :x, :y, :x => :x, :y => :y, :z => :z }.should_not raise_error
  end

  it "should not enforce named parameters for un-instrumented class methods" do
    lambda{ Foo.method_four :x }.should raise_error ArgumentError
    lambda{ Foo.method_four :x, :y }.should_not raise_error ArgumentError
    lambda{ Foo.method_four :x, :y, :w => :w }.should_not raise_error ArgumentError
  end
  
  it "should require all :required parameters" do
    lambda{ @bar.method_with_one_required }.should raise_error ArgumentError
    lambda{ @bar.method_with_one_required :a => :a }.should raise_error ArgumentError
    lambda{ @bar.method_with_one_required :x => :x }.should_not raise_error
            
    lambda{ @bar.method_with_many_required }.should raise_error ArgumentError
    lambda{ @bar.method_with_many_required :x => :x }.should raise_error ArgumentError
    lambda{ @bar.method_with_many_required :x => :x, :y => :y }.should_not raise_error
  end
  
  it "should require one and only one of :oneof parameters" do
    lambda{ @bar.method_with_one_oneof }.should raise_error ArgumentError
    lambda{ @bar.method_with_one_oneof :a => :a }.should raise_error ArgumentError
    lambda{ @bar.method_with_one_oneof :x => :x }.should_not raise_error

    lambda{ @bar.method_with_many_oneof }.should raise_error ArgumentError
    lambda{ @bar.method_with_many_oneof :a => :a }.should raise_error ArgumentError
    lambda{ @bar.method_with_many_oneof :x => :x }.should_not raise_error
    lambda{ @bar.method_with_many_oneof :y => :y }.should_not raise_error
    lambda{ @bar.method_with_many_oneof :x => :x, :y => :y }.should raise_error ArgumentError
  end
  
  it "should reject parameters not declred in :required, :optional, or :oneof" do
    lambda{ @bar.method_with_one_optional }.should_not raise_error
    lambda{ @bar.method_with_one_optional :x => :x }.should_not raise_error
    lambda{ @bar.method_with_one_optional :a => :a }.should raise_error ArgumentError
    lambda{ @bar.method_with_one_optional :x => :x, :y => :y }.should raise_error ArgumentError

    lambda{ @bar.method_with_many_optional }.should_not raise_error
    lambda{ @bar.method_with_many_optional :x => :x }.should_not raise_error
    lambda{ @bar.method_with_many_optional :y => :y }.should_not raise_error
    lambda{ @bar.method_with_many_optional :x => :x, :y => :y }.should_not raise_error
    lambda{ @bar.method_with_many_optional :x => :x, :y => :y, :z => :z }.should raise_error ArgumentError

    lambda{ @bar.method_with_one_of_each_requirement }.should raise_error ArgumentError
    lambda{ @bar.method_with_one_of_each_requirement :w => :w }.should raise_error ArgumentError
    lambda{ @bar.method_with_one_of_each_requirement :w => :w, :x => :x }.should_not raise_error
    lambda{ @bar.method_with_one_of_each_requirement :w => :w, :y => :y }.should_not raise_error
    lambda{ @bar.method_with_one_of_each_requirement :w => :w, :x => :x, :y => :y }.should raise_error ArgumentError
    lambda{ @bar.method_with_one_of_each_requirement :w => :w, :x => :x, :z => :z }.should_not raise_error
    lambda{ @bar.method_with_one_of_each_requirement :w => :w, :y => :y, :z => :z }.should_not raise_error
    lambda{ @bar.method_with_one_of_each_requirement :w => :w, :x => :x, :z => :z, :a => :a }.should raise_error ArgumentError
  end
end
