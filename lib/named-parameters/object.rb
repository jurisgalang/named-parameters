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
  
  def meta_eval &blk
    metaclass.instance_eval &blk
  end
  
  # adds methods to a metaclass
  def meta_def name, &blk
    meta_eval { define_method name, &blk }
  end
  
  # defines an instance method within a class
  def class_def name, &blk
    class_eval { define_method name, &blk }
  end
end
