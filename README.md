This gem simulates named-parameters in Ruby. It's a complement to the common 
Ruby idiom of using `Hash` args to emulate the use of named parameters. 

It does this by extending the language with a `has_named_parameters` clause 
that allows a class to declare the parameters that are acceptable to a method.

The `has_named_parameters` dictates how the presence of these parameters are
enforced and raises an `ArgumentError` when a method invocation is made that
violates the rules for those parameters.

See: the [Named Parameter](http://en.wikipedia.org/wiki/named_parameter) 
article from Wikipedia for more information.

Get It
------
You know you want it:

    gem install named-parameters

Use It
------
Make it available everywhere:

    require 'named-parameters'   
    
But if you want to be selective, do:
    
    require 'named-parameters/module'

Then include the `NamedParameters` module into your class:

    class YourClass
      include NamedParameters
    end
    
Either way, you would now be able to  use the  `has_named_parameters` clause 
as needed:

    class YourClass
      has_named_parameters :your_method, :require => :param
      def your_method options
        puts options.inspect
      end
    end

So when you invoke `your_method`, its parameter requirements will now be
enforced:

    obj = YourClass.new
    obj.your_method :param => 'Et tu, Babe?'  # will spit out: 'Et tu, Babe?'
    obj.your_method                           # will raise an ArgumentError because the required :param was not specified
        
Abuse It
--------
Declare required parameters:

    has_named_parameters :send_mail, :required => :to
    has_named_parameters :send_mail, :required => [ :to, :subject ]
    
Declare optional parameters:

    has_named_parameters :send_mail, :optional => :subject
    has_named_parameters :send_mail, :optional => [ :subject, :bcc, :from ]
    
Declare one of a set of parameters as required (ie: require one and only
one from a list):

    has_named_parameters :send_mail, :oneof => [ :signature, :alias ]
    
Declare default values for optional parameters:
    
    has_named_parameters :send_mail, :optional => [ :subject, :bcc, { :from => 'yourself@example.org' } ]
    has_named_parameters :send_mail, :optional => [ :subject, :bcc, [ :from, 'yourself@example.org' ] ]

You can also declare default values for `:required` and `:oneof` parameters, 
but really, that's just silly.

With `has_named_parameters` you can mix-and-match parameter requirements:

    has_named_parameters :send_mail, 
      :required => [ :to, :subject, ],
      :oneof    => [ :signature, :alias ],
      :optional => [ :subject, :bcc, [ :from, 'yourself@example.org' ] ]

And is applicable to both class and instance methods:

    require 'named-parameters'
    
    class Mailer
      has_named_parameters :send_mail, 
        :required => [ :to, :subject, ],
        :oneof    => [ :signature, :alias ],
        :optional => [ :subject, :bcc, [ :from, 'yourself@example.org' ] ]
      def send_mail options
        # ... do send mail stuff here ...
      end
      
      has_named_parameters :archive, :optional => [ :method => 'zip' ]
      def self.archive options = { }
        # ... do mail archiving stuff here ...
      end
    end

Gotchas
-------
When `has_named_parameters` is declared in a class, it instruments the class
so that when the method in the declaration is invoked, a validation is 
performed on the first `Hash` argument that was received by the method.

It really has no idea about the position of the argument that is supposed
to carry the named parameters.

So you can mix-and-match argument types in a method, and still declare that
it `has_named_parameters`:

    has_named_parameters :request, :required => :accesskey
    def request path, options
      "path: #{path}, options: #{options.inspect}"
    end
    
    # invocation:
    request "/xxx", :accesskey => '0925'  
    
    # result:
    # => path: /xxx, options: {:accesskey => '0925'}
    
But be careful when you have something like the following:

    has_named_parameters :request, :required => :accesskey
    def request path, options = { }
      "path: #{path}, options: #{options.inspect}"
    end

    # invocation:
    request :accesskey => '0925'  
    
    # result isn't what's expected:
    # => path: {:accesskey => '0925'}, options: {}

The next release of the gem will adopt the convention of having the `Hash` 
argument as the last argument passed to the method.

Dependencies
------------
Development:

* `yard >= 0`
* `rspec >= 1.2.9`

Download
--------
You can download this project in either
[zip](http://github.com/jurisgalang/named-parameters/zipball/master) or
[tar](http://github.com/jurisgalang/named-parameters/tarball/master") formats.

You can also clone the project with [Git](http://git-scm.com)
by running: 

    git clone git://github.com/jurisgalang/named-parameters

Note on Patches/Pull Requests
-----------------------------
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version 
  unintentionally.
* Commit, do not mess with rakefile, version, or history. (if you want to have 
  your own version, that is fine but bump version in a commit by itself I can 
  ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Releases
--------
Please read the `RELEASENOTES` file for the details of each release. 

In general: patch releases will not include breaking changes while releases 
that bumps the major or minor components of the version string may or may not 
include breaking changes.

Author
------
[Juris Galang](http://github.com/jurisgalang/)

License
-------
Dual licensed under the MIT or GPL Version 2 licenses.  
See the MIT-LICENSE and GPL-LICENSE files for details.

Copyright (c) 2010 Juris Galang. All Rights Reserved.
