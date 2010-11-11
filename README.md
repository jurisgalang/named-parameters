NamedParameters Gem
===================
This gem enables/simulates named-parameters in Ruby.

Installation
------------

    gem install named-parameters

Usage
-----    
To enable it everywhere (recommended):

    require 'named-parameters'

And all your classes should be able to declare:

    has_named_parameters :method, :optional => [ ... ], :required => [ ... ]

If you want to be selective about which classes will use it, do:

    require 'named-parameters/module'

-- then mix-in the `NamedParameters` module into the class of your choice, for
example:

    class FooBar
      include NamedParameters
      # ...
    end

Using the has_named_parameters Method
-------------------------------------
The `has_named_parameters` method is used to declare that a method accepts a
`Hash` argument that should be treated like named-parameters:

    class GoogleStorage
      has_named_parameters :initialize, 
        :required => [ :'access-key', :'secret-key' ]
      def initialize opts = { }
        # ...
      end
      
      has_named_parameters :request, :optional => :timeout
      def request path, opts = { }
        # ...
      end
    end
    
Since the `GoogleStorage` class above declares that its initializer requires
`:'access-key'` and  `:'secret-key'` to be specified, the following
invocation will (correctly) raise an `ArgumentError` 

    GoogleStorage.new   # ArgumentError, GoogleStorage#initialize requires: access-key, secret-key

On the other-hand, it declares that the `request` method may accept a parameter
named `timeout`; so the following invocations will not raise error:

    gs = GoogleStorage.new :'access-key' => '...', :'secret-key' => '...'
    gs.request '/some/path'
    gs.request '/some/path', :timeout => '500ms'

But specifiying an unrecognized parameter, will raise an error:

    gs.request '/some/path', :ssl => true # ArgumentError, GoogleStorage#request unrecognized parameter: ssl

Optional and Required Parameters
--------------------------------
Optional and required parameters may be declared in a single 
`has_named_parameters` declaration:

    has_named_parameters :request, :required => :path, :optional => :timeout

To specify more than one optional or required parameter, use an `Array`:

    has_named_parameters :request, :required => :path, :optional => [ :timeout, :ssl ]

How It Works
------------
The `has_named_parameters` declaration simply looks for the first `Hash` 
argument when a method that has been declared with `has_named_parameters` is 
called.

It does not know the name of the `Hash` parameter for the method.

Limitation
----------
Currently, `has_named_parameters` may only be used with instance methods.

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

== Copyright

Copyright (c) 2010 Juris Galang. See MIT-LICENSE and GPL-LICENSE for details.
