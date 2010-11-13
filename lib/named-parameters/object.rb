# Do the eigenclass thingy
class Object
  protected
  def eigenclass # :nodoc:
    class << self; self; end  
  end  
end
