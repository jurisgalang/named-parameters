require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "named-parameters"
    gem.summary = %Q{Poor man's named-parameters in Ruby}
    gem.description = %Q{This gem simulates named-parameters in Ruby. It's a complement to the common 
    Ruby idiom of using `Hash` args to emulate the use of named parameters. 

    It does this by extending the language with a `has_named_parameters` clause 
    that allows a class to declare the parameters that are acceptable to a method.

    The `has_named_parameters` dictates how the presence of these parameters are
    enforced and raises an `ArgumentError` when a method invocation is made that
    violates the rules for those parameters.
    }
    gem.email = "jurisgalang@gmail.com"
    gem.homepage = "http://github.com/jurisgalang/named-parameters"
    gem.authors = ["Juris Galang"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "yard", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
