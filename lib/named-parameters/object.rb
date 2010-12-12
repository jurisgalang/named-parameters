#
# metaclass helpers from _why...
#
# See: http://www.ruby-forum.com/topic/77046
# See: https://github.com/dannytatom/metaid
# See: http://dannytatom.github.com/metaid/
#
class Object
  def metaclass # :nodoc:
    class << self; self; end  
  end
  
  def meta_eval(&block)
    metaclass.instance_eval(&block)
  end
  
  # adds methods to a metaclass
  def meta_def(name, &block)
    meta_eval { define_method name, &block }
  end
  
  # defines an instance method within a class
  def class_def(name, &block)
    class_eval { define_method name, &block }
  end
end
