require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "NamedParameters::has_named_parameters" do
  it "should allow declaration of the has_named_parameters clause" do
    class Hnp0; end
    Hnp0.should respond_to(:has_named_parameters)
  end

  it "shouldn't complain if there are not declared parameters" do
    class Hnp1
      def initialize opts = { }; end
      def method1 opts = { }; end
      def self.method1 opts = { }; end
    end
    lambda { Hnp1.method1 }.should_not raise_error
    lambda { @hasnamedparameters = Hnp1.new }.should_not raise_error
    lambda { @hasnamedparameters.method1 }.should_not raise_error
  end
end
