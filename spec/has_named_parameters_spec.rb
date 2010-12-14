require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "NamedParameters::has_named_parameters" do
  it "shouldn't complain if there are not declared parameters" do
    class HasNamedParameters
      def initialize opts = { }; end
      def method1 opts = { }; end
      def self.method1 opts = { }; end
    end
    lambda { HasNamedParameters.method1 }.should_not raise_error
    lambda { @hasnamedparameters = HasNamedParameters.new }.should_not raise_error
    lambda { @hasnamedparameters.method1 }.should_not raise_error
  end
end
