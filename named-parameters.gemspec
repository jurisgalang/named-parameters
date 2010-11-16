# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{named-parameters}
  s.version = "0.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Juris Galang"]
  s.date = %q{2010-11-16}
  s.description = %q{This gem simulates named-parameters in Ruby. It's a complement to the common 
    Ruby idiom of using `Hash` args to emulate the use of named parameters. 

    It does this by extending the language with a `has_named_parameters` clause 
    that allows a class to declare the parameters that are acceptable to a method.

    The `has_named_parameters` dictates how the presence of these parameters are
    enforced and raises an `ArgumentError` when a method invocation is made that
    violates the rules for those parameters.
    }
  s.email = %q{jurisgalang@gmail.com}
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "GPL-LICENSE",
     "MIT-LICENSE",
     "README.md",
     "RELEASENOTES",
     "Rakefile",
     "VERSION",
     "lib/named-parameters.rb",
     "lib/named-parameters/module.rb",
     "lib/named-parameters/object.rb",
     "named-parameters.gemspec",
     "spec/named-parameters_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/jurisgalang/named-parameters}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Poor man's named-parameters in Ruby}
  s.test_files = [
    "spec/named-parameters_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_development_dependency(%q<yard>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<yard>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<yard>, [">= 0"])
  end
end

