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
`Hash` argument that should be treated like named-parameters.

For example:

    class GoogleStorage
      has_named_parameters :initialize, :required => [ :'access-key', :'secret-key' ]
      def initialize opts = { }
        # ...
      end
      
      has_named_parameters :request, :optional => :timeout
      def request path, opts = { }
        # ...
      end
    end

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
